local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
-- local sn = ls.snippet_node
-- local d = ls.dynamic_node
-- local k = require("luasnip.nodes.key_indexer").new_key

local function populate_options(arg)
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

return {
  -- code blocks
  s("py-code", {
    t("```python"),
    t({ "", "" }),
    i(1),
    t({ "", "```", "" }),
  }),

  s("rust-code", {
    t("```rust"),
    t({ "", "" }),
    i(1),
    t({ "", "```", "" }),
  }),

  s("c-code", {
    t("```c"),
    t({ "", "" }),
    i(1),
    t({ "", "```", "" }),
  }),

  -- typst in presenterm
  s("cetz-import", {
    t({ '#import "@preview/cetz:0.2.0"', "" }),
  }),

  s("cetz-fig", {
    t({ "#figure(", "" }),
    t("  cetz.canvas({"),
    t({ "", "import cetz.draw: *", "" }),
    i(1, ""),
    t({ "", "}),  caption:[", "" }),
    i(2, "fig-caption"),
    t({ "", "])<" }),
    i(3, "fig-tag"),
    t(">"),
  }),

  s(
    "cetz-stroke",
    fmt('set-style(stroke:(paint:{}, thickness:{}, dash:"{}"))', {
      i(1, "black"),
      i(2, "2pt"),
      i(3, "solid"),
    })
  ),

  s("cetz-fill", fmt("set-style(fill:{})", { i(1, "blue") })),

  s(
    "cetz-mark",
    fmt(
      'set-style(mark:(start:{},end:"{}",width:{},length:{}))',
      { i(1, "none"), i(2, ">"), i(3, "2pt"), i(4, "2pt") }
    )
  ),

  s(
    "cetz-line",
    fmt("line(({}, {}), ({}, {}))", {
      i(1, "x1"),
      i(2, "y1"),
      i(3, "x2"),
      i(4, "y2"),
    })
  ),

  s(
    "cetz-rect",
    fmt("rect(({}, {}), ({}, {}), radius: {}, name:{})", {
      i(1, "1"),
      i(2, "1"),
      i(3, "5"),
      i(4, "5"),
      i(5, "0"),
      i(6, "none"),
    })
  ),

  s(
    "cetz-circ",
    fmt("circle(({},{}),radius:{}, name:{})", {
      i(1, "1"),
      i(2, "1"),
      i(3, "5"),
      i(4, "none"),
    })
  ),

  s(
    "cetz-oval",
    fmt("circle(({},{}),radius:({},{}), name:{})", {
      i(1, "1"),
      i(2, "1"),
      i(3, "5"),
      i(4, "5"),
      i(5, "none"),
    })
  ),

  s(
    "cetz-bezier",
    fmt("bezier(({},{}),({},{}),({},{}))", {
      i(1, "1"),
      i(2, "1"),
      i(3, "5"),
      i(4, "5"),
      i(5, "2"),
      i(6, "3"),
    })
  ),

  s(
    "cetz-content",
    fmt("content(({},{}),\n  box(width:{}, height:{}, inset:{}, outset:{},\n    text({},[[{}]])))", {
      i(1, "1"),
      i(2, "1"),
      i(3, "100pt"),
      i(4, "50pt"),
      i(5, "5pt"),
      i(6, "0pt"),
      i(7, "16pt"),
      i(8, ""),
    })
  ),

  s("typ-slide", {
    t({
      "```typst +render +width:100%",
      "#set page(width:500pt)",
      '#set text(size:12pt,fill:white,font:"DejaVu Sans Mono")',
    }),
    t({ "", "" }),
    i(1),
    t({ "", "```" }),
  }),

  s("typ-highlight", {
    t("#highlight(fill:"),
    i(1, "red"),
    t(")["),
    i(2, "text"),
    t("]"),
  }),

  s("typ-highlight-wrap", {
    t("#highlight(fill:"),
    i(1, "red"),
    t(")[*"),
    f(function(_, snip)
      return snip.env.LS_SELECT_RAW or {}
    end),
    t("*]"),
  }),

  s("typ-strike", {
    t("#strike(stroke:"),
    i(1, "red"),
    t(")["),
    i(2, "text"),
    t("]"),
  }),

  s("typ-strike-wrap", {
    t("#strike(stroke:"),
    i(1, "red"),
    t(")[*"),
    f(function(_, snip)
      return snip.env.LS_SELECT_RAW or {}
    end),
    t("*]"),
  }),

  s("code-from-file", {
    t({ "", '#let content = read("' }),
    i(1, "file.rs"),
    t('")'),
    t({ "", '#box(stroke:white,inset:20pt,raw(content, lang: "' }),
    i(2, "rust"),
    t('"))', ""),
  }),

  s("fig-from-file", {
    t({ "#figure(", "" }),
    t('  image("'),
    i(1, "fig.png"),
    t('"),'),
    t({ "", "  caption: [" }),
    i(2, "caption"),
    t({ "]," }),
    t({ "", ")<" }),
    i(3, "fig-tag"),
    t(">"),
  }),

  -- mermaid in marp
  s("mmd-gantt", {
    t("```mermaid"),
    t({ "", "gantt" }),
    t({ "", "    title " }),
    i(1, "Chart Title"),
    t({ "", "    dateFormat  YYYY-MM-DD" }),
    t({ "", "    axisFormat %m/%d", "", "" }),
    t({ "", "    section " }),
    i(2, "Section 1"),
    t({ "", "    " }),
    i(3, "Task 1"),
    t(" :active, "),
    i(
      4,
      f(function()
        return os.date("%Y-%m-%d")
      end)
    ),
    t(", "),
    i(5, "7d"),
    t({ "", "    " }),
    t({ "", "```" }),
  }),

  -- mermaid in presenterm
  s("mmd-gantt-render", {
    t("```mermaid +render +width:100%"),
    t({ "", "gantt" }),
    t({ "", "    title " }),
    i(1, "Chart Title"),
    t({ "", "    dateFormat  YYYY-MM-DD" }),
    t({ "", "    axisFormat %m/%d", "", "" }),
    t({ "", "    section " }),
    i(2, "Section 1"),
    t({ "", "    " }),
    i(3, "Task 1"),
    t(" :active, "),
    i(
      4,
      f(function()
        return os.date("%Y-%m-%d")
      end)
    ),
    t(", "),
    i(5, "7d"),
    t({ "", "    " }),
    t({ "", "```" }),
  }),

  s("mmd-gantt-task", {
    i(1, "NewTask"),
    t(" :active, "),
    f(function()
      return os.date("%Y-%m-%d")
    end),
    t(", "),
    i(2, "7d"),
  }),

  s("mmd-gantt-milestone", {
    i(1, "New Milestone"),
    t(" :milestone, "),
    i(2, "new-id"),
    t(", "),
    f(function()
      return os.date("%Y-%m-%d")
    end),
    t(", "),
    i(2, "7d"),
  }),

  s("mmd-gantt-task-wrap", {
    f(function(_, snip)
      return snip.env.LS_SELECT_DEDENT or {}
    end),
    t(" :active, "),
    f(function()
      return os.date("%Y-%m-%d")
    end),
    t(", "),
    i(2, "7d"),
  }),

  -- prompts
  s("llm-summary-file", {
    t({ "", "---", "<!-- please summarize this file" }),
    c(1, populate_options("llm-sum"), { key = "sum-typ" }),
    t({
      "",
      "<!-- If there are math expressions, try to use latex to explain them. If there are abbreviatons, try to first explain what they are. If there are picutures, try to use them in your summary as much as possible. -->",
      "---",
      "",
    }),
  }),

  s("llm-explain", {
    t(
      "<!-- based on the content of current file, please use layman examples or math(prepared in latex) to explain "
    ),
    i(1, "concept"),
    t(" in more detail without imagining the connections between this file and your previous knowledge -->"),
  }),

  s("llm-mmd-wrap", {
    t({
      "```mermaid",
      "",
      "%% Based on the syntax rules and the <content> below, create a mermaid ",
    }),
    c(1, populate_options("llm-mmd"), { key = "chart-opt" }),
    t({ "", "<content>", "" }),
    f(function(_, snip)
      local res, env = {}, snip.env
      for _, ele in ipairs(env.LS_SELECT_RAW) do
        table.insert(res, ele)
      end
      return res
    end, {}),
    t({ "", "</content>", "```", "" }),
  }),
}
