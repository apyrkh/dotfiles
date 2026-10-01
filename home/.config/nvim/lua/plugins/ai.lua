return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = "Copilot",
    keys = {
      {
        "<Tab>",
        function()
          local suggestion = require("copilot.suggestion")
          if suggestion.is_visible() then
            suggestion.accept()
            -- expr=true must return a string
            return ""
          end
          return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
        end,
        mode = "i",
        expr = true,
        silent = true,
        desc = "Copilot Smart Accept",
      },
      {
        "<leader>at",
        function()
          local client = require("copilot.client")
          local enabled = not client.is_disabled()

          vim.cmd(enabled and "Copilot disable" or "Copilot enable")
          vim.notify("Copilot " .. (enabled and "disabled" or "enabled"))
        end,
        desc = "Toggle Copilot",
      },
      { "<leader>as", "<cmd>Copilot status<cr>", desc = "Copilot Status" },
    },
    opts = {
      -- filetypes = {
      --   ["*"] = true,
      --   gitcommit = true,
      --   NeogitCommitMessage = true,
      -- },
      filetypes = {
        ["*"] = true,
      },
      -- should_attach = function(buf_id)
      --   local bt = vim.bo[buf_id].buftype
      --   local ft = vim.bo[buf_id].filetype
      --
      --   -- allow git commit buffers (Neogit) even if not buflisted
      --   if ft == "gitcommit" then
      --     return true
      --   end
      --
      --   if not vim.bo[buf_id].buflisted then
      --     vim.notify("not attaching, buffer is not 'buflisted'", vim.log.levels.DEBUG)
      --     return false
      --   end
      --
      --   if bt ~= "" then
      --     vim.notify("not attaching, buffer 'buftype' is " .. bt, vim.log.levels.DEBUG)
      --     return false
      --   end
      --
      --   return true
      -- end,
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false, -- Handled by custom LUA function
          accept_word = "<M-Right>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<S-Tab>",
        },
      },
      panel = { enabled = false },
    },
  },
}
