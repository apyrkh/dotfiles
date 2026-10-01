-- Pull in the wezterm API
local wezterm = require "wezterm"

-- Use the config_builder which will help provide clearer error messages
local config = wezterm.config_builder()

config.default_prog = { "/bin/zsh", "-l" }

-- config.color_scheme = "Tokyo Night Moon"
-- config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- no ligatures
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono") -- NL means no ligatures ===
config.font_size = 13

-- config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

config.enable_kitty_keyboard = true

config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 5,
  top = 5,
  bottom = 0,
}

-- Mode bubble in the tab bar: rounded pill with a Nerd Font icon and a label
wezterm.on("update-right-status", function(window, _)
  local icon, label, bg

  if window:leader_is_active() then
    icon, label, bg = utf8.char(0xf11c), "LEADER", "#94e2d5" -- keyboard, teal
  elseif window:active_key_table() == "resize_pane" then
    icon, label, bg = utf8.char(0xf047), "RESIZE", "#f5a97f" -- arrows, peach
  else
    window:set_left_status("")
    return
  end

  -- flush with the window's left edge; right cap (U+E0B4) uses the pill color
  window:set_left_status(wezterm.format {
    { Background = { Color = bg } },
    { Foreground = { Color = "#1e2030" } },
    { Attribute = { Intensity = "Bold" } },
    { Text = " " .. icon .. " " .. label },
    "ResetAttributes",
    { Foreground = { Color = bg } },
    { Text = utf8.char(0xe0b4) .. " " },
  })
end)

local window_maximize = wezterm.action_callback(function(window)
  window:maximize()
end)

local window_restore = wezterm.action_callback(function(window)
  window:restore()
end)

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
  -- Ctrl-a twice sends a real Ctrl-a (zsh line start, Neovim increment)
  {
    key = "a",
    mods = "LEADER|CTRL",
    action = wezterm.action.SendKey { key = "a", mods = "CTRL" },
  },
  -- resize mode: arrows/hjkl repeat; any other key exits (and still does its normal job)
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.ActivateKeyTable {
      name = "resize_pane",
      one_shot = false,
      until_unknown = true,
    },
  },
  -- [ ] go to prev/next tab (like Neovim), { } move the tab
  {
    key = "[",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "]",
    mods = "LEADER",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "{",
    mods = "LEADER",
    action = wezterm.action.MoveTabRelative(-1),
  },
  {
    key = "}",
    mods = "LEADER",
    action = wezterm.action.MoveTabRelative(1),
  },
  {
    mods = "LEADER",
    key = "M",
    action = window_maximize,
  },
  {
    mods = "LEADER",
    key = "m",
    action = window_restore,
  },
  {
    mods = "LEADER",
    key = "n",
    action = wezterm.action.SpawnTab "CurrentPaneDomain",
  },
  {
    mods = "LEADER",
    key = "x",
    action = wezterm.action.CloseCurrentPane { confirm = true }
  },
  {
    mods = "LEADER",
    key = "v",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
  },
  {
    mods = "LEADER",
    key = "s",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
  },
  {
    mods = "LEADER",
    key = "h",
    action = wezterm.action.ActivatePaneDirection "Left"
  },
  {
    mods = "LEADER",
    key = "j",
    action = wezterm.action.ActivatePaneDirection "Down"
  },
  {
    mods = "LEADER",
    key = "k",
    action = wezterm.action.ActivatePaneDirection "Up"
  },
  {
    mods = "LEADER",
    key = "l",
    action = wezterm.action.ActivatePaneDirection "Right"
  },
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  -- { key = "LeftArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bb" } },
  -- Make Option-Right equivalent to Alt-f; forward-word
  -- { key = "RightArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bf" } },
}

for i = 1, 9 do
  -- leader + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i - 1),
  })
end

local function resize(direction)
  return wezterm.action.AdjustPaneSize { direction, 5 }
end

config.key_tables = {
  resize_pane = {
    { key = "LeftArrow",  action = resize("Left") },
    { key = "RightArrow", action = resize("Right") },
    { key = "UpArrow",    action = resize("Up") },
    { key = "DownArrow",  action = resize("Down") },
    { key = "h",          action = resize("Left") },
    { key = "l",          action = resize("Right") },
    { key = "k",          action = resize("Up") },
    { key = "j",          action = resize("Down") },
    { key = "Escape",     action = "PopKeyTable" },
    { key = "Enter",      action = "PopKeyTable" },
  },
}

-- and finally, return the configuration to wezterm
return config
