local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("javascript", {
  ls.snippet("readln", fmt([[
  const fs = require('fs');

  function readLines(path) {{
    if (!fs.existsSync(path)) {{
      throw new Error(`no such file: ${{path}}`);
    }}
    return fs.readFileSync(path).toString().split(/\r?\n/)
      .filter(line => line.length > 0);
  }}

  ]], {})),
})

