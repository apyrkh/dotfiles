return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- notifier
      {
        "<leader>un",
        function() Snacks.notifier.show_history() end,
        desc = "Notification History"
      },

      {
        "<leader>vg",
        function() Snacks.lazygit() end,
        desc = "Lazygit"
      },

      -- rename
      {
        "<leader>er",
        function() Snacks.rename.rename_file() end,
        desc = "Rename",
      },

      -- words
      {
        "]w",
        function() Snacks.words.jump(1, true) end,
        desc = "Next Word"
      },
      {
        "[w",
        function() Snacks.words.jump(-1, true) end,
        desc = "Prev Word"
      },

      -- terminal
      {
        "<leader>ut",
        function() Snacks.terminal.toggle() end,
        desc = "Toggle Terminal"
      },

      -- scratch
      {
        "<leader>so",
        function() Snacks.scratch() end,
        desc = "Create Scratch Buffer with Filetype",
      },
      {
        "<leader>sf",
        function() Snacks.scratch.select() end,
        desc = "Select Scratch Buffer"
      },
    },
    opts = {
      input = { enabled = true },
      notifier = {
        enabled = true,
        level = "info",
      },

      lazygit = { enabled = true },

      rename = { enabled = true },
      words = { enabled = true },

      scratch = { enabled = true },
      terminal = { enabled = true },
    },
  },
  -- FIX:
  -- HACK:
  -- WARN:
  -- TODO:
  -- NOTE:
  -- TEST:
  -- PERF:
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ft", "<cmd>TodoFzfLua<CR>", desc = "Todo Comments" },
    },
    opts = {
      signs = false,
      keywords = {
        FIX = { color = "error" },
        TODO = { color = "info" },
      },
      merge_keywords = false,
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--hidden", -- added line
        },
      },
    }
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>e", group = "file", icon = "󰙅" },
        { "<leader>f", group = "find", icon = "󰍉" },
        { "<leader>h", group = "harpoon", icon = "󱡁" },
        { "<leader>c", group = "code", icon = "" },
        { "<leader>a", group = "ai", icon = "󰚩" },
        { "<leader>v", group = "vcs", icon = "" },
        { "<leader>vf", group = "git-search", icon = "󰍉" },
        { "<leader>x", group = "diagnostics", icon = "" },
        { "<leader>s", group = "scratch", icon = "" },
        { "<leader>t", group = "tabs", icon = "󰓩" },
        { "<leader>w", group = "session", icon = "" },
        { "<leader>u", group = "ui", icon = "󰏘" },

        { "<leader>p", group = "Yank History", icon = "" },
        { "<leader>?", group = "Keymaps", icon = "" },

        { "]", group = "next", icon = "󰒭" },
        { "[", group = "prev", icon = "󰒮" },

        -- TODO: think about a better keybinding
        { "<leader>0", hidden = true },
        { "<leader>1", hidden = true },
        { "<leader>2", hidden = true },
        { "<leader>3", hidden = true },
        { "<leader>4", hidden = true },
        { "<leader>5", hidden = true },
        { "<leader>6", hidden = true },
        { "<leader>7", hidden = true },
        { "<leader>8", hidden = true },
        { "<leader>9", hidden = true },
      },
    },
    -- plugins
    -- marks ' or `
    -- registers " in NORMAL or <C-r> in INSERT
    -- spelling z=
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show()
        end,
        desc = "Keymaps",
      },
    },
    init = function()
      vim.opt.timeout = true
      vim.opt.timeoutlen = 300
    end,
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      options = {
        parsers = {
          css = true,
          css_fn = true,
          names = { enable = false },
        },
      },
    },
  },
  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      draw = {
        delay = 10,
        animation = function() return 0 end, -- disable animation
      },
      -- TODO: ui.icon
      -- "╎" (default) "│" "┊" "┆" "⋮"
      -- symbol = "╎",
      options = {
        try_as_border = true,
      },
    },
  },
  {
    -- TODO: consider nvim-mini/mini.statusline
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      sections = {
        lualine_b = { "branch" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "filetype" },
      }
    },
  },
  -- themes
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    -- make sure to load this before all the other start plugins
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
      })
      vim.cmd.colorscheme "catppuccin-nvim"
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      light_style = "day",
    },
  },
  -- fun screen saver
  {
    "eandrju/cellular-automaton.nvim",
    keys = {
      {
        "<leader>uq",
        function()
          vim.cmd("CellularAutomaton make_it_rain")
        end,
        desc = "Make It Rain"
      },
    },
    opts = {},
  }
}
