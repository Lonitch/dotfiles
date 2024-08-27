return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      debug = true,
      sources = {
        -- auto-format lua
        null_ls.builtins.formatting.stylua,
        -- js formatting
        null_ls.builtins.formatting.prettier,
        -- eslint diagnostics
        require("none-ls.code_actions.eslint"),
        -- spell completion
        null_ls.builtins.completion.spell,
        -- python formatting
        -- null_ls.builtins.formatting.black,
      },
    })
  end,
}
