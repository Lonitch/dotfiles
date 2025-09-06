return {
  { "nvim-telescope/telescope-ui-select.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          -- Prefer ripgrep globs (below) over Lua-side filtering for speed
          file_ignore_patterns = {}, -- keep empty; let rg do the ignoring
          -- Make live_grep (and grep_string) search hidden + gitignored files
          -- Doc: vimgrep_arguments defines the command used for live_grep
          vimgrep_arguments = (function()
            local args = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--hidden",
              "--no-ignore-vcs",
              -- keep speed by excluding heavy dirs explicitly
              "--glob", "!.git/*",
              "--glob", "!node_modules/*",
              "--glob", "!.venv/*",
            }
            return args
          end)(),
          path_display = { "smart" },
        },
        pickers = {
          -- Make file search include hidden + gitignored and follow symlinks
          find_files = {
            hidden = true,
            no_ignore = true,  -- include files ignored by .gitignore
            follow = true,     -- follow symlinks
            -- Be explicit about the backend so behavior is consistent
            find_command = {
              "rg", "--files", "--hidden", "--no-ignore-vcs",
              "--glob", "!.git/*", "--glob", "!node_modules/*", "--glob", "!.venv/*",
            },
          },
          -- live_grep now inherits defaults.vimgrep_arguments (no extra args needed)
          live_grep = {},
        },
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({}),
        },
      })

      telescope.load_extension("ui-select")

      local builtin = require("telescope.builtin")
      -- Files (ALL, including hidden + gitignored)
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files (all)" })
      -- Git-tracked files only (fast path when you want just repo files)
      vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Git files (tracked)" })
      -- Ripgrep across everything (inherits vimgrep_arguments)
      vim.keymap.set("n", "<leader>lg", builtin.live_grep, { desc = "Live grep (all)" })

      -- Keep your no-folds in results
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopeResults",
        command = "setlocal nofoldenable",
      })
    end,
  },
}
