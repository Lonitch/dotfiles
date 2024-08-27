return {
  { "nvim-neotest/nvim-nio" },
  {
    "mrcjkb/rustaceanvim",
    version = "^4", -- Recommended
    lazy = false,
    config = function() end,
  },
  {
    "mfussenegger/nvim-dap",
    env = function()
      local variables = {}
      for k, v in pairs(vim.fn.environ()) do
        table.insert(variables, string.format("%s=%s", k, v))
      end
      return variables
    end,
    config = function()
      local dap = require("dap")
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          -- CHANGE THIS to your path!
          command = "/home/sizhe/Downloads/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            -- Find the last slash in the directory path
            local last_slash_index = cwd:match("^.*()/")

            -- Extract the string after the last slash
            local directory_name = last_slash_index and cwd:sub(last_slash_index + 1) or cwd
            return vim.fn.input(
              "Is this ur target? ",
              vim.fn.getcwd() .. "/target/debug/" .. directory_name,
              "file"
            )
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dapui").setup()
    end,
  },
}
