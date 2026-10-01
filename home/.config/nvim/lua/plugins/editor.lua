return {
  {
    "nvim-mini/mini.ai",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = { n_lines = 200 },
  },
  {
    "nvim-mini/mini.align",
    version = false,
    keys = {
      -- { "<leader>ga", mode = { "n", "x" } },
      -- { "<leader>gA", mode = { "n", "x" } },
      { "ga", mode = { "n", "x" } },
      { "gA", mode = { "n", "x" } },
      -- "ga" - start
      -- "gA" - start with preview
      --    "s" - split, e.g. "s_<CR>"
      --        special "=", ",", "|", "<Space>"
      --    "j" - justify, e.g. "_jr"
      --    "m" - merge, e.g. "_m--<CR>"
      --    "f" - filter
      --    "i" - ignore
      --    "p" - pair
      --    "t" - trim
    },
    opts = {
      -- TODO: use <leader>
      -- mappings = {
      --   start = "<leader>ga",
      --   start_with_preview = "<leader>gA",
      -- },
    },
  },
  {
    "nvim-mini/mini.comment",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
          enable_autocmd = false, -- mini.comment will handle it
        },
      },
    },
    version = false,
    keys = {
      { "gc",  mode = { "n", "x" } },
      { "gcc", mode = { "n", "x" } }
    },
    -- opts = {
    --   -- TODO: use <leader>
    --   -- mappings = {
    --   --   comment = "gc",
    --   --   comment_line = "gcc",
    --   --   comment_visual = "gc",
    --   --   textobject = "gc",
    --   -- },
    -- },
    opts = function()
      return {
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring()
                or vim.bo.commentstring
          end,
        },
      }
    end,
  },
  {
    "nvim-mini/mini.operators",
    version = false,
    keys = {
      { "g=", mode = { "n", "x" } },
      { "cx", mode = { "n", "x" } },
      { "gm", mode = { "n", "x" } },
      { "cr", mode = { "n", "x" } },
      { "gs", mode = { "n", "x" } },
      -- "g=" - evaluate text and replace with result, e.g. "g=iw"
      -- "cx" - exchange text, e.g. "cxiw"
      -- "gm" - multiply text, e.g. "gmiw"
      -- "cr" - replace with register, e.g. "criw"
      -- "gs" - sort text
    },
    -- keep built-in gx (open URL) and gr* (LSP) mappings
    opts = {
      exchange = { prefix = "cx" },
      replace = { prefix = "cr" },
    },
  },
  -- TODO: consider ultimate-autopair.nvim if mini.pairs does not work well
  {
    "nvim-mini/mini.pairs",
    version = false,
    event = "InsertEnter",
    opts = {},
  },
  {
    "nvim-mini/mini.surround",
    version = false,
    keys = {
      { "sa", mode = { "n", "x" } },
      { "sd", mode = { "n", "x" } },
      { "sr", mode = { "n", "x" } },
      { "sf", mode = { "n", "x" } },
      { "sh", mode = { "n", "x" } },
      -- "sa" - "add", e.g. "saiw"
      -- "sd" - "delete", e.g. "sd"
      -- "sr" - "replace", e.g. "sr"
      -- "sf" - "find"
      -- "sh" - "highlight"
    },
    opts = {},
  },
  {
    "gbprod/yanky.nvim",
    keys = {
      { "P",          "<Plug>(YankyPutBefore)",                   desc = "Put Before",      mode = { "n", "x" } },
      { "p",          "<Plug>(YankyPutAfter)",                    desc = "Put After",       mode = { "n", "x" } },
      { "<leader>pp", function() vim.cmd("YankyRingHistory") end, desc = "Yank History" },
      { "[y",         "<Plug>(YankyPreviousEntry)",               desc = "Prev Yanky Entry" },
      { "]y",         "<Plug>(YankyNextEntry)",                   desc = "Next Yanky Entry" },
    },
    opts = {
      ring = {
        history_length = 50,
        storage = "memory",
        update_register_on_cycle = true,
      },
    },
  },
}
