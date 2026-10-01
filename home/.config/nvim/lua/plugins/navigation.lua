return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end,                                    desc = "Add File" },
      { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "List Menu" },
      { "<leader>1",  function() require("harpoon"):list():select(1) end,                                desc = "Harpoon File 1" },
      { "<leader>2",  function() require("harpoon"):list():select(2) end,                                desc = "Harpoon File 2" },
      { "<leader>3",  function() require("harpoon"):list():select(3) end,                                desc = "Harpoon File 3" },
      { "<leader>4",  function() require("harpoon"):list():select(4) end,                                desc = "Harpoon File 4" },
      { "<leader>5",  function() require("harpoon"):list():select(5) end,                                desc = "Harpoon File 5" },
      { "<leader>6",  function() require("harpoon"):list():select(6) end,                                desc = "Harpoon File 6" },
      { "<leader>7",  function() require("harpoon"):list():select(7) end,                                desc = "Harpoon File 7" },
      { "<leader>8",  function() require("harpoon"):list():select(8) end,                                desc = "Harpoon File 8" },
      { "<leader>9",  function() require("harpoon"):list():select(9) end,                                desc = "Harpoon File 9" },
      { "<leader>0",  function() require("harpoon"):list():select(0) end,                                desc = "Harpoon File 0" },
      { "[h",         function() require("harpoon"):list():prev() end,                                   desc = "Harpoon Prev File" },
      { "]h",         function() require("harpoon"):list():next() end,                                   desc = "Harpoon Next File" },
    },
    opts = {
      settings = {
        save_on_toggle = true,
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = function()
      local function get_cwd()
        -- nvim-tree
        local ok_tree, api = pcall(require, "nvim-tree.api")
        if ok_tree and api.tree.is_tree_buf(0) then
          local node = api.tree.get_node_under_cursor()
          if node and node.name ~= ".." and node.type == "directory" then
            return vim.fs.normalize(node.absolute_path)
          end

          -- TODO: cursor on files is considered as parent dir
          -- if node and node.name ~= ".." then
          --   return vim.fs.normalize(
          --     node.type == "directory" and node.absolute_path
          --     or vim.fn.fnamemodify(node.absolute_path, ":h")
          --   )
          -- end
        end

        -- oil.nvim
        local ok_oil, oil = pcall(require, "oil")
        if ok_oil and vim.bo.filetype == "oil" then
          local entry = oil.get_cursor_entry()
          if entry.name == ".." then
            return oil.get_current_dir()
          end

          if entry.type == "directory" then
            return vim.fs.normalize(oil.get_current_dir() .. entry.name)
          end

          -- TODO: cursor on files is considered as parent dir
          -- if entry then
          --   return vim.fs.normalize(
          --     entry.type == "directory" and entry.name ~= ".." and oil.get_current_dir() .. entry.name
          --     or oil.get_current_dir()
          --   )
          -- end
        end

        return nil
      end

      local function cwd_aware_search(fn_name)
        return function()
          local opts = {}

          local tree_path = get_cwd()
          if tree_path then
            opts.cwd = tree_path
          end

          require("fzf-lua")[fn_name](opts)
        end
      end

      return {
        { "<leader>f?",  function() require("fzf-lua").builtin() end,              desc = "Builtins" },

        -- Files / search
        { "<leader>ff",  cwd_aware_search("files"),                                desc = "Files" },
        { "<leader>fg",  cwd_aware_search("live_grep"),                            desc = "Grep (live)" },
        { "<leader>fg",  function() require("fzf-lua").grep_visual() end,          desc = "Grep selection (live)", mode = "v", },
        { "<leader>fc",  function() require("fzf-lua").grep_cword() end,           desc = "Grep cursor" },
        { "<leader>fr",  function() require("fzf-lua").resume() end,               desc = "Resume" },

        -- Help / misc
        { "<leader>fb",  function() require("fzf-lua").buffers() end,              desc = "Buffers" },
        { "<leader>fh",  function() require("fzf-lua").help_tags() end,            desc = "Help tags" },
        { "<leader>fk",  function() require("fzf-lua").keymaps() end,              desc = "Keymaps" },
        { "<leader>fp",  function() require("fzf-lua").registers() end,            desc = "Registers" },
        { "<leader>fs",  function() require("fzf-lua").spell_suggest() end,        desc = "Spelling" },
        { "<leader>fq",  function() require("fzf-lua").quickfix_stack() end,       desc = "Quickfix stack" },

        -- VCS: Git
        { "<leader>vfs", function() require("fzf-lua").git_status() end,           desc = "Status" },
        { "<leader>vfb", function() require("fzf-lua").git_blame() end,            desc = "Blame" },
        { "<leader>vfc", function() require("fzf-lua").git_commits() end,          desc = "Commits" },
        { "<leader>vfC", function() require("fzf-lua").git_bcommits() end,         desc = "Buffer commits" },

        -- LSP: built-in keys with fzf-lua pickers; grn, gra stay built-in,
        { "gd",          function() require("fzf-lua").lsp_definitions() end,      desc = "Go to Definition" },
        { "grr",         function() require("fzf-lua").lsp_references() end,       desc = "References" },
        { "gri",         function() require("fzf-lua").lsp_implementations() end,  desc = "Implementations" },
        { "grt",         function() require("fzf-lua").lsp_typedefs() end,         desc = "Type Definition" },
        { "gO",          function() require("fzf-lua").lsp_document_symbols() end, desc = "Document Symbols" },
      }
    end,
    opts = {
      winopts = { backdrop = 50 },
      defaults = { cwd_prompt = false },
      buffers = { sort_lastused = true },
      files = {
        hidden = true,
        fd_opts = "--type f --hidden --follow --exclude .git --exclude .DS_Store",
      },
      grep = {
        hidden = true,
        -- default + "--glob '!.git/*'"
        -- "-e" must be at the end
        rg_opts =
            "--column --line-number --no-heading --color=always --smart-case " ..
            "--max-columns=4096 " ..
            "--glob '!.git/*' " ..
            "--glob '!.DS_Store' " .. -- exclude macOS junk
            "-e",
      },
    },
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)
      fzf.register_ui_select()
    end,
  },
}
