return {
  "python-mode/python-mode",
  branch = "develop",
  ft = { "python" },
  config = function()
    vim.g.pymode_python = "python3"
    vim.g.pymode_lint = 1
    vim.g.pymode_folding = 0
    vim.g.pymode_lint_checkers = { "pyflakes", "pep8", "mccabe" }
    vim.g.pymode_lint_options_pycodestyle = { max_line_length = 80 }
    vim.g.pymode_lint_options_mccabe = { complexity = 16 }
    vim.g.pymode_rope = 0
    vim.g.pymode_rope_completion = 0
    vim.g.pymode_rope_complete_on_dot = 1
    vim.g.pymode_completion_bind = "<Alt-!>"
    vim.g.pymode_rope_goto_definition_bind = "<C-c>g"
    vim.g.pymode_rope_goto_definition_cmd = "vnew"
    vim.g.pymode_rope_regenerate_on_write = 1
    vim.g.pymode_rope_autoimport = 1
    vim.g.pymode_rope_autoimport_import_after_complete = 0
    vim.g.pymode_rope_autoimport_modules = {'os', 'shutil', 'datetime'}
    -- Search for .ropeproject folder in current and parent directories up to $HOME
    local function find_ropeproject()
      local cwd = vim.fn.getcwd()
      local home = os.getenv("HOME")
      while cwd ~= home do
        local ropeproject = cwd .. "/.ropeproject"
        if vim.fn.isdirectory(ropeproject) == 1 then
          return ropeproject
        end
        cwd = vim.fn.fnamemodify(cwd, ":h")
      end
      return nil
    end
    -- Create .ropeproject folder if not found
    local function create_ropeproject()
      local cwd = vim.fn.getcwd()
      local home = os.getenv("HOME")
      while cwd ~= home do
        local git = cwd .. "/.git"
        local gitignore = cwd .. "/.gitignore"
        if vim.fn.isdirectory(git) == 1 or vim.fn.filereadable(gitignore) == 1 then
          local ropeproject = cwd .. "/.ropeproject"
          vim.fn.mkdir(ropeproject, "p")
          return ropeproject
        end
        cwd = vim.fn.fnamemodify(cwd, ":h")
      end
      return nil
    end
    -- Set the location of .ropeproject folder
    local ropeproject = find_ropeproject()
    if ropeproject == nil then
      ropeproject = create_ropeproject()
    end
    if ropeproject ~= nil then
      vim.g.pymode_rope_project_root = ropeproject
    end
  end,
}
