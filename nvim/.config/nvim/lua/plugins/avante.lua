return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    -- add any opts here
    provider = "openai",
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-3-5-sonnet-20241022",
      temperature = 0,
      max_tokens = 8000,
    },
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o-2024-08-06",
      timeout = 80000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 8000,
      ["local"] = false,
    },
    windows = {
      ---@alias AvantePosition "right" | "left" | "top" | "bottom"
      position = "right",
      wrap = true,    -- similar to vim.o.wrap
      width = 40,     -- default % based on available width in vertical layout
      height = 30,    -- default % based on available height in horizontal layout
      sidebar_header = {
        align = "center", -- left, center, right for title
        rounded = true,
      },
      input = {
        prefix = "> ",
      },
      edit = {
        border = "rounded",
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make BUILD_FROM_SOURCE=true",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
}
