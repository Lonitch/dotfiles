local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- imports
  s("cetz-import", {
    t({ '#import "@preview/cetz:0.2.0"', "" }),
  }),

  s("imports", {
    t({ '#import "@preview/gentle-clues:1.0.0": *', "" }),
    t({ '#import "@preview/cetz:0.2.0"', "" }),
    t({ '#import "@preview/ctheorems:1.1.2": *', "#show: thmrules.with(qed-symbol: $square$)", "" }),
    t({ '#import "@preview/gentle-clues:1.0.0": *' }),
  }),

  -- file-wise settings
  s("text-normal", {
    t('#set text(font:"'),
    i(1, "DejaVu Sans Mono"),
    t('",fill:black'),
    t(", size:"),
    i(2, "12pt"),
    t({ ")", "" }),
  }),

  s("page-dark", {
    t('#set text(font:"'),
    i(1, "DejaVu Sans Mono"),
    t('",fill:white'),
    t(", size:"),
    i(2, "12pt"),
    t({ ")", "" }),
    t("#set page(fill:"),
    i(3, "rgb(24,24,37)"),
    t({ ")", "" }),
  }),

  s("math-env", {
    t({
      '#let theorem = thmbox("theorem", "Theorem", ',
      "  base_level: 1,",
      '  fill: rgb("#eeffee"))',
      "#let corollary = thmplain(",
      '  "corollary",',
      '  "Corollary",',
      '  base: "theorem",',
      "  titlefmt: strong",
      ")",
      '#let definition = thmbox("definition", "Definition", ',
      '  fill:rgb("#eeff"),',
      "  base_level: 1,",
      "  inset: (x: 1em, top: 1em, bottom:1em)",
      ")",
      '#let example = thmplain("example", "Example").with(numbering: none)',
      '#let proof = thmproof("proof", "Proof")',
    }),
  }),

  s("author-env", {
    t({ "", "#let mainauthor=" }),
    i(1, '"CJ"'),
    t({ "", "#let role=" }),
    i(2, '"hobbist"'),
    t({ "", "#let affili=" }),
    i(3, '"Sitricate"'),
    t({ "", "#let email=" }),
    i(4, '"cj@sitricate.com"'),
  }),

  s("tufte-memo", {
    t({ '#import "@preview/tufte-memo:0.1.2": *', "" }),
    t({ "#show: template.with(", "" }),
    t({ "  title: [" }),
    i(1, "TITLE"),
    t({ "],", "" }),
    t({ "  subtitle:[" }),
    i(2, "SUBTITLE"),
    t({ "],", "" }),
    t({ "  authors: (", "" }),
    t({ "      (", "" }),
    t({ "      name: #mainauthor,", "" }),
    t({ "      role: #role,", "" }),
    t({ "      affiliation: #affili,", "" }),
    t({ "      email: #email),", "" }),
    t({ "  ),", "" }),
    t({ "  document-number: [Version 0.0.1],", "" }),
    t({ "  abstract: [],", "" }),
    t({ "  toc: true,", "" }),
    t({ "  draft: false,", "" }),
    t({ '//  bib: bibliography("references.bib")', "" }),
    t({ ")", "" }),
  }),

  s("tufte-sidenote", {
    t('#let notecounter = counter("sidecounter")'),
    t({ "", "#let note(dy:-2em, numbered:true, idx:0, content) = {" }),
    t({ "", "  if idx > 0 {" }),
    t({ "", '    text(weight:"bold",super(str(idx)))' }),
    t({ "", "    notecounter.update(idx)" }),
    t({ "", "  } else if numbered {" }),
    t({ "", "    notecounter.step()" }),
    t({ "", '    text(weight:"bold",super(notecounter.display()))' }),
    t({ "", "  }" }),
    t({ "", "  text(size:9pt,font: sans-fonts,margin-note(if idx>0{" }),
    t({ "", '    text(weight:"bold",font:"Lucida Bright",size:11pt,{' }),
    t({ "", "      super(str(idx))" }),
    t({ "", '      text(size: 9pt, " ")' }),
    t({ "", "    })" }),
    t({ "", "    content" }),
    t({ "", "  }else if numbered {" }),
    t({ "", '    text(weight:"bold",font:"Lucida Bright",size:11pt,{' }),
    t({ "", "      super(notecounter.display())" }),
    t({ "", '      text(size: 9pt, " ")' }),
    t({ "", "    })" }),
    t({ "", "    content" }),
    t({ "", "  } else {" }),
    t({ "", "    content}" }),
    t({ "", "    ,dy:dy))" }),
    t({ "", "  }" }),
  }),

  -- object creation
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

  s("theorem-tag", {
    t("#theorem["),
    i(1, "Theorem title"),
    t("]["),
    i(2, "Theorem content"),
    t("]<"),
    i(3, "theo-tag"),
    t(">"),
  }),

  s("def-tag", {
    t("#definition["),
    i(1, "Definition title"),
    t("]["),
    i(2, "Definition content"),
    t("]<"),
    i(3, "def-tag"),
    t(">"),
  }),

  s("info", {
    t("#info(title:"),
    i(1, '"Info"'),
    t({ ")[", "" }),
    i(2, "content"),
    t({ "", "]", "" }),
  }),

  s("tip", {
    t("#tip(title:"),
    i(1, '"Tip"'),
    t({ ")[", "" }),
    i(2, "content"),
    t({ "", "]", "" }),
  }),
}
