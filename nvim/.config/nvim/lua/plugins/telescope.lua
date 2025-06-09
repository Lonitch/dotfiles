return {
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function() -- keymap for telescope
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git", ".venv" },
				},
				pickers = {
					find_files = {
						hidden = true,
					},
					live_grep = {
						additional_args = function(_)
							return { "--hidden" }
						end,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			-- load telescope-ui-select so that code actions show
			-- in a search-bar
			require("telescope").load_extension("ui-select")

			local builtin = require("telescope.builtin")
			-- <space>+f+f to open file finder
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			-- <space>+l+g opens live grep
			vim.keymap.set("n", "<leader>lg", builtin.live_grep, {})
			-- Disable folding in Telescope's result window.
			vim.api.nvim_create_autocmd(
				"FileType",
				{ pattern = "TelescopeResults", command = [[setlocal nofoldenable]] }
			)
		end,
	},
}
