-- Tabs
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { silent = true, desc = "Open New Tab" })
vim.keymap.set("n", "<leader>tq", "<cmd>tabclose<CR>", { silent = true, desc = "Close Tab" })
-- prev/next tab: built-in gT / gt

-- Windows
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true, desc = "Go Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true, desc = "Go Down Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true, desc = "Go Up Window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true, desc = "Go Right Window" })

-- Resize
vim.keymap.set("n", "<A-Up>", "<cmd>resize +2<CR>", { silent = true, desc = "Increase Height" })
vim.keymap.set("n", "<A-Down>", "<cmd>resize -2<CR>", { silent = true, desc = "Decrease Height" })
vim.keymap.set("n", "<A-Left>", "<cmd>vertical resize -2<CR>", { silent = true, desc = "Decrease Width" })
vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { silent = true, desc = "Increase Width" })

-- Scroll + center
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "Scroll Up Center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "Scroll Down Center" })

-- Search: keep centered
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zzzv'", { silent = true, expr = true, desc = "Next Search" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zzzv'", { silent = true, expr = true, desc = "Prev Search" })
vim.keymap.set({ "x", "o" }, "n", "'Nn'[v:searchforward]", { silent = true, expr = true, desc = "Next Search" })
vim.keymap.set({ "x", "o" }, "N", "'nN'[v:searchforward]", { silent = true, expr = true, desc = "Prev Search" })
vim.keymap.set("n", "<esc>", "<cmd>noh<CR><esc>", { silent = true, desc = "Clear Highlight" })

-- Edit (move lines / indent)
-- Alt instead of Shift keeps built-in J (join) and K (docs) in Visual mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move Line Down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move Line Up" })
vim.keymap.set("v", "<", "<gv", { silent = true, desc = "Shift Left" })
vim.keymap.set("v", ">", ">gv", { silent = true, desc = "Shift Right" })

-- Quick-fix
local quickfix_opts = function(desc)
  return { silent = true, desc = desc }
end

vim.keymap.set("n", "<leader>qq", function()
  -- winid is 0 when the quickfix window is closed
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end, quickfix_opts("Quickfix Toggle"))
vim.keymap.set("n", "<leader>qb", "<cmd>colder<CR><cmd>copen<CR>", quickfix_opts("Quickfix History Back"))
vim.keymap.set("n", "<leader>qf", "<cmd>cnewer<CR><cmd>copen<CR>", quickfix_opts("Quickfix History Forward"))

vim.keymap.set("n", "<leader>qt", function()
  local word = vim.fn.expand("<cword>")
  vim.fn.setqflist({}, "a", { title = "REF: " .. word })
end, quickfix_opts("Quickfix Title From Word"))

vim.keymap.set("n", "<leader>qr", function()
  local qf = vim.fn.getqflist({ title = 1 })
  local title = vim.fn.input("QF title: ", qf.title or "")
  if title ~= "" then
    vim.fn.setqflist({}, "a", { title = title })
  end
end, quickfix_opts("Quickfix Rename"))
