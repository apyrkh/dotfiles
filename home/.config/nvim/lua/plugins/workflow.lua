return {
  {
    -- local sessions only: Session.vim in cwd (globally git-ignored, see ~/.config/git/ignore)
    "nvim-mini/mini.sessions",
    version = false,
    keys = {
      { "<leader>ww", function() MiniSessions.write(MiniSessions.config.file) end,                    desc = "Save Session" },
      { "<leader>wr", function() MiniSessions.read() end,                                             desc = "Restore Session" },
      { "<leader>wd", function() MiniSessions.delete(MiniSessions.config.file, { force = true }) end, desc = "Delete Session" },
    },
    init = function()
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
    opts = {
      directory = "", -- no global sessions
      autowrite = false, -- save only via <leader>ww
    },
  },
}
