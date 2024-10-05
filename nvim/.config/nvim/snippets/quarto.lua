local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

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
    t({ "", '#| code-summary: ' }),
    i(1),
    t({ "", "" }),
    i(2),
    t({ "", "```" }),
  }),

  --- ```{mermaid}
  --- gantt
  --- ```
  s("mermaid-gantt", {
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

  s("gantt-item", {
    i(1, "NewTask"),
    t(" :active, "),
    f(function()
      return os.date("%Y-%m-%d")
    end),
    t(", "),
    i(2, "7d"),
  }),
}
