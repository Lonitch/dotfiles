return {
  'rust-lang/rust.vim',
  ft = "rust",
  init = function ()
    -- auto-format at save 
    vim.g.rustfmt_autosave = 1
  end
}
