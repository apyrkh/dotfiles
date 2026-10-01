#!/usr/bin/env node
// ─── Status line payload schema (Claude Code statusLine command, v2.1.193) ────
// To re-inspect the live payload, temporarily add to the main block:
//   const F = '/tmp/statusline-debug.json';
//   const sz = require('fs').existsSync(F) ? require('fs').statSync(F).size : 0;
//   if (sz < 100) require('fs').writeFileSync(F, JSON.stringify(data, null, 2));
// Then trigger any response and read /tmp/statusline-debug.json.
//
// Top-level fields used here:
//   data.session_id          — unique session UUID
//   data.transcript_path     — ~/.claude/projects/<project>/<session-id>.jsonl
//                              subagents live at <transcript_path without .jsonl>/subagents/
//   data.model.id            — e.g. "claude-sonnet-4-6"
//   data.model.display_name  — e.g. "Sonnet 4.6"
//   data.workspace.repo.name — git repo name (absent for non-git dirs)
//   data.workspace.project_dir  — session root, stable (set at start, ignores cd)
//   data.workspace.current_dir  — actual cwd, changes with cd
//   data.cost.total_cost_usd — cumulative USD for session incl. all subagents
//   data.context_window.used_percentage
//   data.context_window.total_input_tokens
//   data.context_window.context_window_size
//   data.context_window.current_usage.{input,output,cache_creation_input,cache_read_input}_tokens
// ─────────────────────────────────────────────────────────────────────────────
// ─── ANSI helpers ─────────────────────────────────────────────────────────────
const R    = '\x1b[0m';
const DIM  = '\x1b[2m';
const BOLD = '\x1b[1m';
const c    = n => `\x1b[38;5;${n}m`;

const COL_LABEL  = DIM  + c(245);
const COL_BAR_HI = c(75);
const COL_BAR_LO = c(237);
const COL_PCT    = BOLD + c(255);
const COL_VAL    = c(252);
const COL_WARM   = c(214);
const COL_COLD   = c(117);
const COL_MODEL  = BOLD + c(39);
const COL_REPO   = BOLD + c(255);
const COL_COST   = c(185);

// ─── Column layout constants ───────────────────────────────────────────────────
const IND      = '  ';   // 2-space left indent on every line
const SEP      = '  ';   // column separator
const LABEL_W  = 5;      // widest label is "cache" = 5 chars
const BAR_W    = 20;     // full bar visual width
const PCT_W    = 4;      // widest pct is "100%" = 4 chars

// ─── Helpers ──────────────────────────────────────────────────────────────────
// Pad label to LABEL_W BEFORE adding color so padEnd works on plain chars.
function label(s) {
    return COL_LABEL + s.padEnd(LABEL_W) + R;
}

// Normal progress bar: filled ═ + dim ═, always BAR_W visual chars.
function bar(pct) {
    const n = Math.round(Math.max(0, Math.min(100, pct || 0)) / 100 * BAR_W);
    return COL_BAR_HI + '═'.repeat(n) + COL_BAR_LO + '═'.repeat(BAR_W - n) + R;
}

// Right-justify pct to PCT_W chars BEFORE adding color.
function pct(n) {
    return COL_PCT + (Math.round(n || 0) + '%').padStart(PCT_W) + R;
}

// Dim "0%" placeholder for "no data yet" — same shape as a real pct(), just
// gray instead of white so it doesn't read as an actual measured value.
function pctEmpty() {
    return COL_LABEL + '0%'.padStart(PCT_W) + R;
}

function fmtK(n) {
    if (n == null || isNaN(n)) return '?';
    return n >= 1000 ? (n / 1000).toFixed(1) + 'k' : String(n);
}

function fmtCost(usd) {
    if (usd == null || isNaN(usd)) return null;
    return '$' + usd.toFixed(4);
}

// ─── Moving average hit rate ────────────────────────────────────────────────────
// Reads a tail slice of the transcript (the session log Claude Code already
// writes to disk — not a state file we maintain) and averages cache hit rate
// over the assistant turns visible in the sparkline. Stateless-safe: works
// even though this process is spawned fresh on every render.
const fs = require('fs');
// Sized from real transcripts: 200KB reached only ~8 turns on a 1.2MB session
// (tool-heavy turns push megabytes of JSONL between assistant messages).
// 1.5MB covers every measured session; the extra cost is ~1ms, vs ~25ms of
// node startup, because of the cheap substring prescreen in the scan loop.
const TAIL_BYTES = 1_500_000;

// Returns { avg, history } where history is oldest→newest hit-rate % per turn
// (up to historyTurns entries; avg is over that same visible set — 1 turn at
// the start of a session, up to historyTurns once there's enough history), or
// null if no cache-active turns were found.
function movingAvgHitRate(transcriptPath, historyTurns = BAR_W) {
    if (!transcriptPath) return null;
    let raw, truncated;
    try {
        const fd = fs.openSync(transcriptPath, 'r');
        try {
            const size = fs.fstatSync(fd).size;
            const start = Math.max(0, size - TAIL_BYTES);
            const len = size - start;
            const buf = Buffer.alloc(len);
            // readSync may return short; decode only what was actually read,
            // otherwise the zero-filled tail of buf becomes trailing NULs.
            const n = fs.readSync(fd, buf, 0, len, start);
            raw = buf.toString('utf8', 0, n);
            truncated = start > 0; // only true if the read actually cut into the file
        } finally {
            fs.closeSync(fd);
        }
    } catch {
        return null;
    }

    const lines = raw.split('\n');
    if (truncated && lines.length) lines.shift(); // drop the possibly-truncated first line

    const rates = []; // newest → oldest
    const seenIds = new Set(); // one API call can log multiple JSONL lines (one per content
                                // block) that share the same message id and usage — count once
    for (let i = lines.length - 1; i >= 0 && rates.length < historyTurns; i--) {
        const line = lines[i];
        if (!line) continue;
        // Cheap prescreen: most lines are multi-KB tool results we'd throw away
        // after a full JSON.parse. Keeps the larger TAIL_BYTES effectively free.
        if (line.indexOf('"assistant"') < 0) continue;
        let entry;
        try {
            entry = JSON.parse(line);
        } catch {
            continue;
        }
        if (entry?.type !== 'assistant') continue;
        const id = entry.message?.id;
        if (id) {
            if (seenIds.has(id)) continue;
            seenIds.add(id);
        }
        const usage = entry.message?.usage;
        if (!usage) continue;
        const read  = usage.cache_read_input_tokens     || 0;
        const write = usage.cache_creation_input_tokens || 0;
        if (read + write === 0) continue; // no cache activity this turn, skip rather than dragging avg to 0
        rates.push((read / (read + write)) * 100);
    }

    if (!rates.length) return null;
    const avg = rates.reduce((a, b) => a + b, 0) / rates.length;
    return { avg, history: rates.slice().reverse() }; // oldest→newest
}

// ─── Hit-rate history sparkline ────────────────────────────────────────────────
// TL;DR — how to read the "hit" line:
//
//   bar   hit %          miss %        meaning
//   █     >99.8          <0.2          normal, healthy
//   ▇     99.6–99.8      0.2–0.4       normal
//   ▆     99.2–99.6      0.4–0.8       fine
//   ▅     98.4–99.2      0.8–1.6       fine
//   ▄     96.8–98.4      1.6–3.2       more cache writes than usual
//   ▃     93.6–96.8      3.2–6.4       more cache writes than usual
//   ▂     87.2–93.6      6.4–12.8      bad — much context re-sent
//   ▁     <87.2          >12.8         bad — much context re-sent
//
//   One bar up = 2× fewer cache misses. Read the miss column: it doubles.
//   The hit column looks random only because it is 100 minus that doubling.
//
//   ▁ has two meanings, separated by color only:
//     blue ▁ = a real turn, bad hit rate
//     gray ▁ = no data yet (session shorter than 20 turns); always on the left
//   Newest turn is rightmost. avg can hide a spiky line — check the shape too.
//
// Absolute scale — a bar always represents its own true value and never
// reshapes based on other points in the window.
//
// The scale is log2 over the MISS rate (100 - hit), not linear over hit rate.
// Hit rate is the wrong quantity to space evenly: measured over 4317 real
// turns the miss rate spans two orders of magnitude and clusters at the very
// bottom (p95=36%, median=0.89%, p5=0.06%), so linear bands spend almost all
// their resolution where no data lives and every bar pins to █.
//
// One rule replaces a table of thresholds: each step up the glyph means
// HALF AS MANY cache misses. This holds regardless of how usage shifts, so
// the scale never needs re-tuning.
//
// Bands, in hit % (nominal — a value sitting exactly on an edge can land on
// either side, since 100-99.2 is 0.7999999999999972 in binary floating point
// and the log/floor amplifies that. Real hit rates never hit an edge exactly):
//   █ >99.8      ▇ 99.6–99.8   ▆ 99.2–99.6   ▅ 98.4–99.2
//   ▄ 96.8–98.4  ▃ 93.6–96.8   ▂ 87.2–93.6   ▁ <87.2
//
// A shifted log — log2(1 + miss/s), which would drop the clamp below — was
// measured and rejected: its edges land on 0.2/0.6/1.4/3.0/6.2/12.6 instead of
// clean doublings, pushing turns into ▇ and leaving ▁ unused (sd 5.4-8.9 vs 4.2).
//
// TOP_MISS is the one remaining tuned constant — the log needs a floor
// somewhere. 0.1% spreads real data most evenly (9/5/9/12/17/18/15/15%);
// raising it to 0.2% or 0.4% collapses 29% / 47% of turns into the top band.
// Note the full block covers everything below 2×TOP_MISS, since the first
// doubling step still lands on the top level.
const BLOCK_LEVELS = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█']; // low → high
const TOP_MISS     = 0.1; // miss-rate anchor for the log scale, in %

function levelChar(p) {
    if (!Number.isFinite(p)) return BLOCK_LEVELS[0];
    // Clamping miss up to TOP_MISS keeps log2 away from -Infinity when a turn
    // is perfect (miss === 0, i.e. cache_creation === 0 — common), so no
    // special case is needed: it just yields steps === 0, the full block.
    const miss  = Math.max(TOP_MISS, Math.min(100, 100 - p));
    const steps = Math.floor(Math.log2(miss / TOP_MISS));
    const idx   = Math.max(0, BLOCK_LEVELS.length - 1 - steps);
    return BLOCK_LEVELS[idx];
}

// Single accent color, shared with the ctx bar's fill (c(75)), so the two
// sparklines read as one visual system instead of each having its own hue.
const COL_HIT = c(75);

// Always renders exactly `width` chars, oldest→newest left→right, newest
// turn at the rightmost position; left-padded with "▁" placeholders when there
// isn't enough history yet — same visual width as the ctx bar so the UI never
// jumps around. Padding uses COL_BAR_LO, the same dark gray as the ctx bar's
// unfilled track, so "no data" reads identically on both lines.
function sparkline(history, width = BAR_W) {
    const shown  = history.slice(-width); // oldest first
    const glyphs = shown.map(levelChar).join('');
    const pad = COL_BAR_LO + '▁'.repeat(width - shown.length) + R;
    return pad + COL_HIT + glyphs + R;
}

// Fully empty state: no cache-active turns exist yet at all.
function sparklineEmpty(width = BAR_W) {
    return COL_BAR_LO + '▁'.repeat(width) + R;
}


// ─── Main ─────────────────────────────────────────────────────────────────────
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);

    const repoName = data.workspace?.repo?.name
        || (data.workspace?.project_dir || data.workspace?.current_dir || data.cwd || process.cwd()).split('/').filter(Boolean).pop()
        || 'unknown';
    const model    = data.model?.display_name || data.model?.id || 'unknown';

    const cw         = data.context_window || {};
    const usedPct    = cw.used_percentage ?? 0;
    const totalInput = cw.total_input_tokens || 0;
    const windowSize = cw.context_window_size || 0;
    const usage      = cw.current_usage || null;

    const cacheRead  = usage?.cache_read_input_tokens       || 0;
    const cacheWrite = usage?.cache_creation_input_tokens   || 0;

    const ctxPct   = Math.round(usedPct);

    const cost     = data.cost?.total_cost_usd ?? null;
    const costStr  = fmtCost(cost);

    const hitRate = movingAvgHitRate(data.transcript_path);

    // ── Line 1: repo  model  cost ─────────────────────────────────────────────
    const line1 = IND + COL_REPO + repoName + R + SEP + COL_MODEL + model + R
        + (costStr ? SEP + COL_COST + costStr + R : '');

    // ── Line 2: ctx  bar  pct  tokens/total  [Xk warm / Yk cold] ───────────────
    const line2 = IND
        + label('ctx')
        + SEP + bar(ctxPct)
        + SEP + pct(ctxPct)
        + SEP + COL_VAL + fmtK(totalInput) + '/' + fmtK(windowSize) + R
        + SEP + COL_LABEL + '[' + R
        + COL_WARM + fmtK(cacheRead)  + R + COL_LABEL + ' warm / ' + R
        + COL_COLD + fmtK(cacheWrite) + R + COL_LABEL + ' cold]'   + R;

    const lines = [line1, line2];

    // ── Line 3: hit  sparkline  avg pct ─────────────────────────────────────────
    // Bars use the absolute log2-of-miss-rate scale documented at levelChar();
    // the number is the plain arithmetic mean over those same visible turns —
    // hence the "avg" tag, so the two aren't read as the same scale.
    // Always rendered, even before any cache activity exists — matches the
    // "ctx" line's empty state (0%, empty bar) instead of disappearing.
    const line3 = IND
        + label('hit')
        + SEP + (hitRate ? sparkline(hitRate.history) : sparklineEmpty())
        + SEP + (hitRate ? pct(hitRate.avg) : pctEmpty())
        + SEP + COL_LABEL + 'avg' + R;
    lines.push(line3);

    process.stdout.write(lines.join('\n') + '\n');
});
