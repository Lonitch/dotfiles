local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

local util_path = vim.fn.stdpath("config") .. "/snippets/snippet-utils.lua"
local ok, utils= pcall(dofile, util_path)
if not ok then
  print("Error loading utils: " .. util_path)
  return {}
end


return {
  --- ```{python}
  -- #| label: {1}
  -- #| fig-cap: "{2}"
  -- #| out-width: {3}%
  -- {4}
  --- ```
  s("py-fig", {
    t("```{python}"),
    t({ "", "#| label: fig-" }),
    i(1),
    t({ "", '#| fig-cap: "' }),
    i(2),
    t('"'),
    t({ "", "#| out-width: " }),
    i(3),
    t("%"),
    t({ "", "" }),
    i(4),
    t({ "", "```" }),
  }),

  s("py-code", {
    t("```{python}"),
    t({ "", "#| echo: true" }),
    t({ "", "#| code-summary: " }),
    i(1),
    t({ "", "" }),
    i(2),
    t({ "", "```" }),
  }),

  --- ```{mermaid}
  --- gantt
  --- ```
  s("mmd-gantt", {
    t("```{mermaid}"),
    t({ "", "gantt" }),
    t({ "", "    title " }),
    i(1, "Chart Title"),
    t({ "", "    dateFormat  YYYY-MM-DD" }),
    t({ "", "    axisFormat %m/%d", "", "" }),
    t({ "", "    section " }),
    i(2, "Section 1"),
    t({ "", "    " }),
    i(3, "Task 1"),
    t(" :"),
    i(4, "active, 2023-01-05, 7d"),
    t({ "", "    Task 2 :done, 2024-01-02,7d" }),
    t({ "", "    Task 3 :crit, 2024-01-03,7d" }),
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

  --- prompts
  s("llm-summary", {
    t({ "", "---", "<!-- please summarize this file" }),
    c(1, utils.populate_options("llm-sum"), { key = "sum-typ" }),
    t({
      "",
      "<!-- If there are exact numbers, use them as much as possible to in the summary. If there are math expressions, try to use latex to explain them. If there are abbreviatons, try to first explain what they are. If there are picutures, try to use them in your summary as much as possible. -->",
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
    c(1, utils.populate_options("llm-mmd"), { key = "chart-opt" }),
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
