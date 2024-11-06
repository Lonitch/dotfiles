local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	-- imports
	s("cetz-import", {
		t({ '#import "@preview/cetz:0.3.1"', "" }),
	}),

	s("touying-import", {
		t({
			'#import "@preview/touying:0.5.2": *',
			'#import "@preview/numbly:0.1.0": numbly',
		}),
	}),

	s("touying-univ-theme", {
		t({
			"#import themes.university: *",
			"#show: university-theme.with(",
			'  aspect-ratio: "16-9",',
			"  footer: self => self.info.institution,",
			'  navigation: "mini-slides",',
			"  config-info(",
			"    title: [",
		}),
		i(1, "Project Name"),
		t({ "],", "    subtitle: [" }),
		i(2, "Subtitle"),
		t({ "],", "    author: [" }),
		i(3, "Names"),
		t({ "],", "    date: datetime.today(),", "    institution: [" }),
		i(4, "Your Company"),
		t({
			"],",
			"  ),",
			")",
			'#set heading(numbering: numbly("{1:1}.", default: "1.1"))',
			"#title-slide()",
			'#components.adaptive-columns(outline(title: "Agenda", indent: 1em))',
		}),
	}),

	s("imports", {
		t({ '#import "@preview/cetz:0.3.1"', "" }),
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

	-- section settings
	s("pb", t("#pagebreak(weak: true)")),

	s(
		"apdx",
		t([[
#pagebreak(weak: true)
// appendix
#let appendix(body) = {
  set heading(numbering: "A.1"/*, supplement: [Appendices]*/)
  counter(heading).update(0)
  body
}
#show: appendix
// appendices hereon
  ]])
	),

	s(
		"ref",
		fmt('#bibliography(title: "References", "{filename}.bib")', {
			filename = i(1, "filename_incl_path"),
		})
	),

	-- object creation
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

  s("touying-ctx", {
    t({ "#[", "#set text(size: 22pt)", "#set align(center)", "", "]"})
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

	s("cetz-canvas", {
		t({ "#cetz.canvas(", "length:1pt,", "padding:none," }),
		t({ "{", "import cetz.draw: *", "" }),
		i(1, ""),
		t({ "", "})", "" }),
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
