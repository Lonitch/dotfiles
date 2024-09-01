return {
  {
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
      vim.keymap.set(
        "n",
        "<leader>e",
        ":MoltenEvaluateOperator<CR>",
        { desc = "evaluate operator", silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader>os",
        ":noautocmd MoltenEnterOutput<CR>",
        { desc = "open output window", silent = true }
      )
      vim.keymap.set("n", "<leader>re", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
      vim.keymap.set("n", "<leader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
      vim.keymap.set("n", "<leader>dm", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
    end,
  },
  {
    -- see the image.nvim readme for more information about configuring this plugin
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- whatever backend you would like to use
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })
    end,
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
  },
}
