local ls = require("luasnip")
local t = ls.text_node
local M = {}

function M.populate_options(arg)
  local rules_path = vim.fn.stdpath("config") .. "/snippets/opts/" .. arg .. ".lua"
  local ok, rules = pcall(dofile, rules_path)
  if not ok then
    print("Error loading mermaid rules: " .. rules)
    return {}
  end
  local options = {}
  for opt_name, opt in pairs(rules) do
    local option = {}
    table.insert(option, " " .. opt_name)
    if type(opt) == "table" then
      for _, item in ipairs(opt) do
        table.insert(option, item)
      end
    elseif type(opt) == "string" and opt:find("\n") then
      for line in opt:gmatch("([^\n]*)\n?") do
        table.insert(option, line)
      end
    else
      table.insert(option, opt)
    end
    table.insert(options, t(option))
  end
  return options
end

return M
