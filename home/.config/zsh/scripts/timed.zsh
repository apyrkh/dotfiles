# timed - wrapper around GNU time with formatted output
# Usage:
#   timed [-C] <command>
# Options:
#   -C print output in single line format (default: multi line)
# Example:
#   timed node test.js
#   timed -C node test.js
timed() {
  local mode="multi"
  [[ "$1" == "-C" ]] && { mode="single"; shift; }

  # GNU time: "gtime" from Homebrew on macOS, /usr/bin/time on Linux
  # (macOS's own /usr/bin/time is BSD and has no -f, hence the --version probe)
  local time_cmd
  if (( $+commands[gtime] )); then
    time_cmd=gtime
  elif /usr/bin/time --version >/dev/null 2>&1; then
    time_cmd=/usr/bin/time
  else
    print -u2 "timed: GNU time not found (macOS: brew install gnu-time)"
    return 1
  fi

  "$time_cmd" -f "Mem: %M\nCPU: %P\nTime: %e" "$@" 2>&1 | awk -v mode="$mode" '
  function format_thousands(n) {
    s = ""
    while (n >= 1000) {
      s = sprintf("_%03d%s", n % 1000, s)
      n = int(n / 1000)
    }
    return n s
  }

  BEGIN {
    CYAN  = "\033[96m"
    WHITE = "\033[97m"
    RESET = "\033[0m"
    mem = cpu = time = ""
  }

  /^Mem:/ {
    mem = format_thousands(int($2)) " Kb"
    next
  }

  /^CPU:/ {
    cpu_raw = $2
    sub(/%$/, "", cpu_raw)
    cpu = cpu_raw " %"
    next
  }

  /^Time:/ {
    time = format_thousands(int(($2 + 0) * 1000 + 0.5)) " ms"
    next
  }

  { print }

  END {
    printf "\n"
    if (mode == "single") {
      printf "💾 %s%s%s   🖥️ %s%s%s   ⏱️ %s%s%s\n", CYAN, mem, RESET, CYAN, cpu, RESET, CYAN, time, RESET
    } else {
      printf "💾 %s%s%s\n", CYAN, mem, RESET
      printf "🖥️  %s%s%s\n", CYAN, cpu, RESET
      printf "⏱️  %s%s%s\n", CYAN, time, RESET
    }
  }
  '
}
