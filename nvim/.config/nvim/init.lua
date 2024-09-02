-- allow mouse use
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  command = "set mouse=n",
})
-- make tab to be 2*space
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
-- show relative line numbers
vim.cmd("set relativenumber")
-- use clipboard for copy and paste
vim.cmd("set clipboard+=unnamedplus")
-- global folding method
vim.opt.foldmethod = "indent"
vim.opt.foldenable = true
local function set_folding_for_filetype()
    local filetype = vim.bo.filetype
    if filetype == "neo-tree" then
        vim.wo.foldenable = false
        vim.wo.foldmethod = "manual"
        vim.cmd("normal! zR")
    else
        vim.wo.foldenable = true
        vim.wo.foldmethod = "indent"
    end
end
vim.api.nvim_create_autocmd({"FileType", "BufEnter"}, {
    pattern = "*",
    callback = set_folding_for_filetype
})
vim.api.nvim_create_autocmd("User", {
    pattern = "NeotreeBufferOpened",
    callback = function()
        vim.cmd("normal! zR")
    end
})
-- global leader 
vim.g.mapleader = " "
-- install lazy.vim pkg manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.lsp.set_log_level("debug")
require('vim.lsp.log').set_format_func(vim.inspect)

-- install ripgrep on ubuntu, you might change it on
-- different OS.
local function is_cmd_available(name)
  local f = io.popen("which " .. name)
  local l = f:read("*a")
  f:close()
  return l ~= ""
end

if not is_cmd_available("rg") then
  print("ripgrep not found, installing...")
  os.execute("sudo apt-get install ripgrep")
end

-- lazy.vim set up plugins with options here
require("lazy").setup("plugins")

-- run leptosfmt before saving .rs files
local function format_with_leptosfmt()
  -- Save the current cursor position
  local save_cursor = vim.api.nvim_win_get_cursor(0)
  -- Run leptosfmt on the current file
  vim.cmd("silent !leptosfmt " .. vim.fn.expand("%"))
  formatting = true
  -- Reload the file in the buffer
  vim.cmd("edit!")
  -- Restore the cursor position
  vim.api.nvim_win_set_cursor(0, save_cursor)
  -- Save the buffer again, avoiding infinite loop
  if formatting then
    -- This is a filter process running in a background thread.
    vim.cmd("silent! w")
    formatting = false
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rs",
  callback = format_with_leptosfmt,
})

-- '<leader>wd' to set pwd to where the file is located
vim.api.nvim_set_keymap('n', '<leader>wd', ':cd %:p:h<CR>:pwd<CR>', { noremap = true, silent = true })
-- '-' goes to the line end
vim.keymap.set("n", "-", "<End>")
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
vim.keymap.set("v", "<A-f>", "<C-[>")
vim.keymap.set("t", "<A-f>", "<C-[>")
-- <space>+tab to switch windows
vim.keymap.set("n", "<leader><Tab>", "<C-w><C-w>")
-- auto-cmd of centering window after line jumping to window bottom/top
vim.api.nvim_set_keymap("n", "<space>j", "Lzz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<space>m", "Hzz", { noremap = true, silent = true })
-- check the floating message from LSP at current line
vim.api.nvim_set_keymap(
  "n",
  "<space><space>f",
  ":lua vim.diagnostic.open_float()<CR>",
  { noremap = true, silent = true }
)
-- <space>+n to open/close file tree
vim.keymap.set("n", "<leader>n", ":Neotree filesystem reveal left toggle<CR>", { noremap = true, silent = true })
-- <space>+b+o to reveal opened files
vim.keymap.set("n", "<leader>bo", ":Neotree buffers reveal float<CR>", { noremap = true, silent = true })
-- FORMATTER KEY REMAPPING
vim.keymap.set("n", "<leader>gf", function()
  local filetype = vim.bo.filetype
  if filetype == "python" then
    vim.cmd("PymodeLintAuto")
  else
    vim.lsp.buf.format()
  end
end, {})
-- LSP KEY REMAPPING
-- <space> + k to show documentation of hovered word
vim.keymap.set("n", "<leader>k", function()
  local filetype = vim.bo.filetype
  if filetype == "quarto" then
    vim.cmd("QuartoHover")
  else
    vim.lsp.buf.hover()
  end
end, {})
-- <space>+g+d: go to definition
-- custom function to toggle pymode_rope and trigger goto_definition
local function pymode_goto_definition()
  vim.g.pymode_rope = 1
  vim.cmd("call pymode#rope#goto_definition()")
  vim.g.pymode_rope = 0
end
-- Keymapping to trigger goto_definition based on filetype
vim.keymap.set("n", "<leader>gd", function()
  local filetype = vim.bo.filetype
  if filetype == "python" then
    pymode_goto_definition()
  else
    vim.lsp.buf.definition()
  end
end, {})
-- <space>+a: selects a code action available at the current position
vim.keymap.set("n", "<space>a", vim.lsp.buf.code_action, {})
-- <space>gp for preview hunk
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { noremap = true, silent = true })

-- DEBUGGING KEY REMAPPING
vim.keymap.set("n", "<leader>od", ":lua require'dapui'.open()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>cd", ":lua require'dapui'.close()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tb", ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>=", ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>-", ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })

-- COMMENTING
vim.keymap.set("n", "<C-_>", function()
  require("Comment.api").toggle.linewise.current()
end, { noremap = true, silent = true })

-- EXIT INSERT MODE AND JUMP OUT OF CURRENT PAIRED BRACKETS
function _G.jump_to_next_special_char()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_get_current_line()
  local nearest_pos = nil
  local nearest_dist = nil

  for _, char in ipairs({ "/", ")", "}", "]", '"', "'", ",", "`" }) do
    local char_pos = string.find(current_line, char, col + 1, false)
    if char_pos then
      local dist = char_pos - col
      if not nearest_dist or dist < nearest_dist then
        nearest_dist = dist
        nearest_pos = char_pos
      end
    end
  end

  if nearest_pos then
    vim.api.nvim_win_set_cursor(0, { line, nearest_pos })
  end
end

vim.api.nvim_set_keymap("i", "<A-f>", "<Esc>:lua jump_to_next_special_char()<CR>", { noremap = true, silent = true })

-- Disable jedi-vim default mappings
vim.g["jedi#goto_command"] = ""
vim.g["jedi#goto_assignments_command"] = ""
vim.g["jedi#goto_stubs_command"] = ""
vim.g["jedi#goto_definitions_command"] = ""
vim.g["jedi#documentation_command"] = ""
vim.g["jedi#usages_command"] = ""
vim.g["jedi#completions_command"] = ""
vim.g["jedi#rename_command"] = ""
vim.g["jedi#rename_command_keep_name"] = ""
