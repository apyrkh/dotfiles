return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)" },
      { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions/references (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List (Trouble)" },
    },
    opts = {}, -- for default options, refer to the configuration section for custom setup.
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" }, -- normal and any visual mode
        desc = "Format File (Conform)",
      },
    },
    opts = {
      format_on_save = false,
      -- format_on_save = {
      --   lsp_format = "fallback", -- fallback to LSP formatter if no formatter
      --   timeout_ms = 500,
      -- },

      formatters_by_ft = {
        javascript      = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        typescript      = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "eslint_d", "prettierd", "prettier", stop_after_first = true },

        json            = { "biome", "prettierd", "prettier", stop_after_first = true },
        jsonc           = { "biome", "prettierd", "prettier", stop_after_first = true },

        css             = { "biome", "prettierd", "prettier", stop_after_first = true },
        scss            = { "biome", "prettierd", "prettier", stop_after_first = true },
        html            = { "biome", "prettierd", "prettier", stop_after_first = true },

        markdown        = { "prettierd", "prettier", stop_after_first = true },

        sql             = { "pg_format", stop_after_first = true },

        ["_"]           = { "lsp" },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "alexandre-abrioux/blink-cmp-npm.nvim",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      completion = {
        ghost_text = {
          enabled = false,
          show_without_menu = false,
        },
        list = {
          max_items = 30,
        },
        menu = {
          enabled = true,
          max_height = 10 + 2,
          direction_priority = { "n", "s" },
          -- direction_priority = { "n" },
          -- auto_show = false,
          -- scrollbar = false,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 10,
        }
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = "default",
        ["<C-space>"] = {},
        ["<C-p>"] = {},
        ["<C-n>"] = {},
        ["<C-e>"] = { "show", "hide" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
      },

      signature = {
        enabled = true,
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lazydev", "lsp", "snippets", "buffer", "path", "npm" },

        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          lsp = {
            transform_items = function(_, items)
              local kind = require("blink.cmp.types").CompletionItemKind
              return vim.tbl_filter(function(item)
                return item.kind ~= kind.Snippet
              end, items)
            end,
          },
          snippets = {
            score_offset = -10,
          },
          buffer = {
            min_keyword_length = 3,
          },
          npm = { name = "npm", module = "blink-cmp-npm", async = true },
        },
      },

      cmdline = {
        completion = {
          ghost_text = {
            enabled = true
          },
          menu = { auto_show = true },
        },
        keymap = {
          preset = "cmdline",
          ["<C-space>"] = {},
          ["<C-p>"] = {},
          ["<C-n>"] = {},
          ["<C-e>"] = { "show", "hide" },
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<C-j>"] = { "select_next", "fallback" },
        },
      },
    },
    opts_extend = { "sources.default" }
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "Mason", "LspInfo" },
    config = function()
      local servers = require("lsp")

      -- register configs before mason-lspconfig enables the servers;
      -- blink.cmp already adds its capabilities via vim.lsp.config("*")
      for server, opts in pairs(servers) do
        vim.lsp.config(server, opts)
      end

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
      })

      -- conform.nvim formatters aren't LSP servers (mason-lspconfig skips them),
      -- and mason-tool-installer's VimEnter auto-install races this plugin's
      -- lazy load — so call check_install() directly below.
      local mason_tool_installer = require("mason-tool-installer")
      mason_tool_installer.setup({
        ensure_installed = { "eslint_d", "prettierd", "prettier", "pgformatter" },
      })
      mason_tool_installer.check_install()
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim",        words = { "Snacks" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter.install({
        "bash",
        "lua",
        "vim",
        "vimdoc",

        "markdown",
        "markdown_inline",
        "diff",
        "json",
        "yaml",

        "html",
        "css",
        "scss",

        "javascript",
        "typescript",
        "tsx",

        "sql",
      })

      -- vim.treesitter.start()
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascriptreact", "typescriptreact", "xml" },
    event = "InsertEnter",
    opts = {},
  },
}
