return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("treesitter_query_compat").setup()

      -- configure treesitter for some programming languages
      local config = require("nvim-treesitter.configs")
      config.setup({
        auto_install = true,
        ensure_installed = {"lua", "javascript", "rust", "html", "c", "python"},
        highlight = { enable = true },
        indent = { enable = true }
      })
    end,
  }
}
