local M = {}

local configured = false

local function capture_node(match, capture_id)
  local capture = match[capture_id]
  if type(capture) == "table" then
    return capture[1]
  end
  return capture
end

local function get_parser_from_markdown_info_string(injection_alias)
  local aliases = {
    ex = "elixir",
    pl = "perl",
    sh = "bash",
    uxn = "uxntal",
    ts = "typescript",
  }

  local match = vim.filetype.match({ filename = "a." .. injection_alias })
  return match or aliases[injection_alias] or injection_alias
end

function M.setup()
  if configured then
    return
  end
  configured = true

  local query = require("vim.treesitter.query")
  local opts = { force = true }

  query.add_predicate("nth?", function(match, _, _, pred)
    local node = capture_node(match, pred[2])
    local n = tonumber(pred[3])
    if node and n and node:parent() and node:parent():named_child_count() > n then
      return node:parent():named_child(n) == node
    end
    return false
  end, opts)

  query.add_predicate("is?", function(match, _, bufnr, pred)
    local node = capture_node(match, pred[2])
    local types = { unpack(pred, 3) }
    if not node then
      return true
    end

    local locals = require("nvim-treesitter.locals")
    local _, _, kind = locals.find_definition(node, bufnr)
    return vim.tbl_contains(types, kind)
  end, opts)

  query.add_predicate("kind-eq?", function(match, _, _, pred)
    local node = capture_node(match, pred[2])
    local types = { unpack(pred, 3) }
    if not node then
      return true
    end
    return vim.tbl_contains(types, node:type())
  end, opts)

  query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
    local node = capture_node(match, pred[2])
    if not node then
      return
    end

    local html_script_type_languages = {
      ["importmap"] = "json",
      ["module"] = "javascript",
      ["application/ecmascript"] = "javascript",
      ["text/ecmascript"] = "javascript",
    }

    local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
    local configured_language = html_script_type_languages[type_attr_value]
    if configured_language then
      metadata["injection.language"] = configured_language
    else
      local parts = vim.split(type_attr_value, "/", {})
      metadata["injection.language"] = parts[#parts]
    end
  end, opts)

  query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
    local node = capture_node(match, pred[2])
    if not node then
      return
    end

    local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
  end, opts)

  query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local node = capture_node(match, capture_id)
    if not node then
      return
    end

    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[capture_id] }) or ""
    metadata[capture_id] = metadata[capture_id] or {}
    metadata[capture_id].text = string.lower(text)
  end, opts)
end

return M
