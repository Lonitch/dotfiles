return {
	"jmbuhr/otter.nvim",
	"quarto-dev/quarto-nvim",
	config = function()
		local quarto = require("quarto")
		local otter = require("otter")
		quarto.setup({
			debug = false,
			closePreviewOnExit = true,
			lspFeatures = {
				enabled = true,
				chunks = "curly",
				languages = { "r", "python", "julia", "bash", "html" },
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			codeRunner = {
				enabled = false,
				default_method = nil, -- 'molten' or 'slime'
				ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
				-- Takes precedence over `default_method`
				never_run = { "yaml" }, -- filetypes which are never sent to a code runner
			},
			keymap = false,
			-- {
			-- set whole section or individual keys to `false` to disable
			-- hover = "<leader>k",
			-- definition = "<leader>gd",
			-- type_definition = "gD",
			-- rename = "<leader>lR",
			-- format = "<leader>lf",
			-- references = "<leader>gr",
			-- document_symbols = "<leader>gS",
			-- },
		})
		otter.setup({
			lsp = {
				-- `:h events` that cause the diagnostics to update. Set to:
				-- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
				-- but more instant diagnostic updates
				diagnostic_update_events = { "BufWritePost" },
				-- function to find the root dir where the otter-ls is started
				root_dir = function(_, bufnr)
					return vim.fs.root(bufnr or 0, {
						".git",
						"book.toml",
						"_quarto.yml",
						"package.json",
					}) or vim.fn.getcwd(0)
				end,
			},
			buffers = {
				-- if set to true, the filetype of the otterbuffers will be set.
				-- otherwise only the autocommand of lspconfig that attaches
				-- the language server will be executed without setting the filetype
				set_filetype = true,
				-- write <path>.otter.<embedded language extension> files
				-- to disk on save of main buffer.
				-- usefule for some linters that require actual files
				-- otter files are deleted on quit or main buffer close
				write_to_disk = false,
			},
			strip_wrapping_quote_characters = { "'", '"', "`" },
			-- otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
			-- When true, otter handles these cases fully.
			handle_leading_whitespace = true,
		})
		-- Activate otter for both Quarto and Markdown files
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
			pattern = { "*.qmd" },
			callback = function()
				otter.activate({ "r", "python", "julia", "bash", "html", "rust" })
			end,
		})
	end,
}
