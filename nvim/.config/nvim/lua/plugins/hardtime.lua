return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
  opts = {showmode=false,cmdheight=2},
  config = function()
    require("hardtime").setup()
  end,
}
