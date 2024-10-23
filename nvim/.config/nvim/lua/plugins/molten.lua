return {
  --[[ {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      -- auto open could be annoying, keep in mind setting this option will require setting
      -- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"

      -- optional, works for virt text and the output window
      vim.g.molten_wrap_output = true
      -- Output as virtual text. Allows outputs to always be shown, works with images, but can
      -- be buggy with longer images
      vim.g.molten_virt_text_output = true
      -- this will make it so the output shows up below the \`\`\` cell delimiter
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_output_win_max_height = 20
      vim.keymap.set("n", "<leader>bi", function()
        local venv = os.getenv("VIRTUAL_ENV")
        if venv ~= nil then
          -- in the form of $HOME/.virtualenvs/VENV_NAME
          venv = string.match(venv, "/.+/(.+)")
          vim.cmd(("MoltenInit %s"):format(venv))
        else
          vim.cmd("MoltenInit python3")
        end
      end, { desc = "Initialize Molten for python3", silent = true })
      vim.keymap.set(
        "n",
        "<leader>be",
        ":MoltenEvaluateOperator<CR>",
        { desc = "evaluate operator", silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader>bw",
        ":noautocmd MoltenEnterOutput<CR>",
        { desc = "open output window", silent = true }
      )
      vim.keymap.set("n", "<leader>bv", ":MoltenEvaluateVisual<CR>", { desc = "re-eval cell", silent = true })
      vim.keymap.set("n", "<leader>bh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
      vim.keymap.set("n", "<leader>bd", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
    end,
  }, ]]
  {
    -- see the image.nvim readme for more information about configuring this plugin
    "3rd/image.nvim",
    branch = "feat/toggle-rendering",
    opts = {
      backend = "kitty", -- whatever backend you would like to use
      max_width = 500,
      max_height = 22,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
    config = function()
      local image = require("image")
      vim.keymap.set("n", "<leader>ti", function()
        if image.is_enabled() then
          image.disable()
          print("Image rendering disabled")
        else
          image.enable()
          print("Image rendering enabled")
        end
      end, {})
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = function()
      require("jupytext").setup({
        style = "hydrogen",
        output_extension = "auto", -- Default extension. Don't change unless you know what you are doing
        force_ft = nil,        -- Default filetype. Don't change unless you know what you are doing
        custom_language_formatting = {
          python = {
            extension = "md",
            style = "markdown",
            force_ft = "markdown", -- you can set whatever filetype you want here
          },
        },
      })
    end,
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
  },
}
