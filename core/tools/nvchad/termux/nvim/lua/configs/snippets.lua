local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local jsx_tsx_snippets = {
  -- Basic structure
  s("html", { t { "<html>" }, i(0), t { "</html>" } }),
  s("head", { t { "<head>" }, i(0), t { "</head>" } }),
  s("body", { t { "<body>" }, i(0), t { "</body>" } }),
  s("title", { t { "<title>" }, i(0), t { "</title>" } }),

  -- Headings
  s("h1", { t { "<h1>" }, i(0), t { "</h1>" } }),
  s("h2", { t { "<h2>" }, i(0), t { "</h2>" } }),
  s("h3", { t { "<h3>" }, i(0), t { "</h3>" } }),
  s("h4", { t { "<h4>" }, i(0), t { "</h4>" } }),
  s("h5", { t { "<h5>" }, i(0), t { "</h5>" } }),
  s("h6", { t { "<h6>" }, i(0), t { "</h6>" } }),

  -- Text and formatting
  s("p", { t { "<p>" }, i(0), t { "</p>" } }),
  s("blockquote", { t { "<blockquote>" }, i(0), t { "</blockquote>" } }),
  s("pre", { t { "<pre>" }, i(0), t { "</pre>" } }),
  s("code", { t { "<code>" }, i(0), t { "</code>" } }),
  s("hr", { t { "<hr />" } }),
  s("br", { t { "<br />" } }),

  -- Inline elements
  s("a", { t { '<a href="' }, i(0), t { '">' }, i(1), t { "</a>" } }),
  s("span", { t { "<span>" }, i(0), t { "</span>" } }),
  s("strong", { t { "<strong>" }, i(0), t { "</strong>" } }),
  s("em", { t { "<em>" }, i(0), t { "</em>" } }),
  s("small", { t { "<small>" }, i(0), t { "</small>" } }),
  s("sub", { t { "<sub>" }, i(0), t { "</sub>" } }),
  s("sup", { t { "<sup>" }, i(0), t { "</sup>" } }),
  s("i", { t { "<i>" }, i(0), t { "</i>" } }),
  s("b", { t { "<b>" }, i(0), t { "</b>" } }),
  s("u", { t { "<u>" }, i(0), t { "</u>" } }),
  s("del", { t { "<del>" }, i(0), t { "</del>" } }),
  s("ins", { t { "<ins>" }, i(0), t { "</ins>" } }),
  s("mark", { t { "<mark>" }, i(0), t { "</mark>" } }),
  s("cite", { t { "<cite>" }, i(0), t { "</cite>" } }),
  s("time", { t { "<time>" }, i(0), t { "</time>" } }),

  -- Lists
  s("ul", { t { "<ul>" }, i(0), t { "</ul>" } }),
  s("ol", { t { "<ol>" }, i(0), t { "</ol>" } }),
  s("li", { t { "<li>" }, i(0), t { "</li>" } }),

  -- Tables
  s("table", { t { "<table>" }, i(0), t { "</table>" } }),
  s("thead", { t { "<thead>" }, i(0), t { "</thead>" } }),
  s("tbody", { t { "<tbody>" }, i(0), t { "</tbody>" } }),
  s("tr", { t { "<tr>" }, i(0), t { "</tr>" } }),
  s("th", { t { "<th>" }, i(0), t { "</th>" } }),
  s("td", { t { "<td>" }, i(0), t { "</td>" } }),
  s("caption", { t { "<caption>" }, i(0), t { "</caption>" } }),

  -- Forms
  s("form", { t { "<form>" }, i(0), t { "</form>" } }),
  s("input", { t { '<input type="' }, i(0), t { '" />' } }),
  s("textarea", { t { "<textarea>" }, i(0), t { "</textarea>" } }),
  s("select", { t { "<select>" }, i(0), t { "</select>" } }),
  s("option", { t { "<option>" }, i(0), t { "</option>" } }),
  s("label", { t { "<label>" }, i(0), t { "</label>" } }),
  s("button", { t { "<button>" }, i(0), t { "</button>" } }),
  s("fieldset", { t { "<fieldset>" }, i(0), t { "</fieldset>" } }),
  s("legend", { t { "<legend>" }, i(0), t { "</legend>" } }),
  s("datalist", { t { "<datalist>" }, i(0), t { "</datalist>" } }),
  s("output", { t { "<output>" }, i(0), t { "</output>" } }),

  -- Multimedia and graphics
  s("img", { t { '<img src="' }, i(0), t { '" alt="' }, i(1), t { '" />' } }),
  s("video", { t { "<video>" }, i(0), t { "</video>" } }),
  s("audio", { t { "<audio>" }, i(0), t { "</audio>" } }),
  s("source", { t { '<source src="' }, i(0), t { '" type="' }, i(1), t { '" />' } }),
  s("track", { t { '<track src="' }, i(0), t { '" kind="' }, i(1), t { '" />' } }),
  s("canvas", { t { "<canvas>" }, i(0), t { "</canvas>" } }),
  s("svg", { t { "<svg>" }, i(0), t { "</svg>" } }),

  -- Semantic elements
  s("header", { t { "<header>" }, i(0), t { "</header>" } }),
  s("footer", { t { "<footer>" }, i(0), t { "</footer>" } }),
  s("nav", { t { "<nav>" }, i(0), t { "</nav>" } }),
  s("section", { t { "<section>" }, i(0), t { "</section>" } }),
  s("article", { t { "<article>" }, i(0), t { "</article>" } }),
  s("aside", { t { "<aside>" }, i(0), t { "</aside>" } }),
  s("main", { t { "<main>" }, i(0), t { "</main>" } }),
  s("div", { t { "<div>" }, i(0), t { "</div>" } }),
  s("figure", { t { "<figure>" }, i(0), t { "</figure>" } }),
  s("figcaption", { t { "<figcaption>" }, i(0), t { "</figcaption>" } }),
  s("details", { t { "<details>" }, i(0), t { "</details>" } }),
  s("summary", { t { "<summary>" }, i(0), t { "</summary>" } }),

  -- Other elements
  s("script", { t { "<script>" }, i(0), t { "</script>" } }),
  s("style", { t { "<style>" }, i(0), t { "</style>" } }),
  s("noscript", { t { "<noscript>" }, i(0), t { "</noscript>" } }),
  s("template", { t { "<template>" }, i(0), t { "</template>" } }),

  -- Additional self-closing tags
  s("meta", { t { '<meta name="' }, i(0), t { '" content="' }, i(1), t { '" />' } }),
  s("link", { t { '<link rel="' }, i(0), t { '" href="' }, i(1), t { '" />' } }),
  s("area", { t { '<area shape="' }, i(0), t { '" />' } }),
  s("base", { t { '<base href="' }, i(0), t { '" />' } }),
  s("col", { t { "<col />" } }),
  s("embed", { t { '<embed src="' }, i(0), t { '" />' } }),
  s("param", { t { '<param name="' }, i(0), t { '" value="' }, i(1), t { '" />' } }),
  s("wbr", { t { "<wbr />" } }),
}

ls.add_snippets("javascriptreact", jsx_tsx_snippets)
ls.add_snippets("typescriptreact", jsx_tsx_snippets)
