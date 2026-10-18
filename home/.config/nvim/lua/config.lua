-- Set leader key
vim.g.mapleader = " "

-- System
vim.opt.autoread = true  -- auto-reload files when modified externally
vim.opt.lazyredraw = true
-- TODO: implement clean up for undo file (hotkey?)
vim.opt.undofile = true  -- save undo history to a file
vim.opt.swapfile = false
vim.opt.updatetime = 250 -- faster completion and diagnostic display
vim.opt.confirm = true

-- Line numbers
vim.opt.number = true         -- shows absolute line number
vim.opt.relativenumber = true -- show relative line numbers

-- Scrolling and tabs
vim.opt.scrolloff = 5      -- minimal number of screen lines to keep above and below the cursor
vim.opt.expandtab = true   -- convert tab to spaces
vim.opt.shiftwidth = 2     -- 2 spaces for indent width
vim.opt.tabstop = 2        -- 2 spaces for tabs
vim.opt.softtabstop = 2
vim.opt.autoindent = true  -- copy indent from current line when starting new one
vim.opt.smartindent = true
vim.opt.colorcolumn = "80" -- vertical line at 80 characters
-- vim.opt.textwidth = 80      -- force hard wrap at 80 characters
vim.opt.wrap = false       -- disable line wrapping
vim.opt.foldlevelstart = 99 -- open files unfolded (treesitter folds, plugins/code.lua)

-- UI settings
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.cursorline = true     -- highlight the current cursor line
vim.opt.signcolumn = "yes:2"  -- show sign column with reserved 2 columns (LSP + git)
vim.opt.laststatus = 3        -- show single status line
vim.opt.showmode = false      -- hide "-- INSERT --" etc
vim.opt.list = true           -- sets how neovim will display certain whitespace in the editor
vim.opt.winborder = "rounded" -- double, rounded, solid, shadow
vim.opt.listchars = {
  eol = "↲",
  tab = "» ",
  space = ".",
  nbsp = "␣"
}
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- Diagnostics UI
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰠠",
    },
  },
  -- virtual_text = true,
  virtual_text = { current_line = true },
  -- virtual_lines = true,
  -- virtual_lines = { current_line = true },
})

-- Search settings
vim.opt.hlsearch = true
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true  -- if you include mixed case in your search, assumes you want case-sensitive

-- Backspace and clipboard
vim.opt.backspace = "indent,eol,start"
require("clipboard")
vim.opt.mouse = "a"

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"

-- Spelling
vim.opt.spell = true
vim.opt.spelllang = "en_us,en"
