-- Increment/decrement built-ins for numbers, dates, hex colors, semver,
-- booleans, weekdays, months and per-filetype word cycles.
--
-- This file owns dial's keymaps instead of lazyvim.plugins.extras.editor.dial
-- because that extra also declares <C-a>/<C-x>/g<C-a>/g<C-x>, and lazy.nvim
-- concatenates `keys` across specs, so the extra's mappings cannot be removed
-- by overriding this file. Since <C-a> must stay unowned, we own the spec.
--
-- The augend groups below mirror that extra's configuration verbatim.
--
-- Keymaps: <leader>j / <leader>k in normal and visual mode.
-- <C-a>, <C-x>, +, g<C-a>, g<C-x> and - are deliberately left alone.
return {
  "monaqa/dial.nvim",
  -- stylua: ignore
  keys = {
    {
      "<leader>j",
      function()
        local mode = vim.fn.mode(true)
        local visual = mode == "v" or mode == "V" or mode == "\22"
        return require("dial.map")[visual and "inc_visual" or "inc_normal"](vim.g.dials_by_ft[vim.bo.filetype] or "default")
      end,
      expr = true,
      mode = { "n", "v" },
      desc = "Increment",
    },
    {
      "<leader>k",
      function()
        local mode = vim.fn.mode(true)
        local visual = mode == "v" or mode == "V" or mode == "\22"
        return require("dial.map")[visual and "dec_visual" or "dec_normal"](vim.g.dials_by_ft[vim.bo.filetype] or "default")
      end,
      expr = true,
      mode = { "n", "v" },
      desc = "Decrement",
    },
  },
  opts = function()
    local augend = require("dial.augend")

    local logical_alias = augend.constant.new({
      elements = { "&&", "||" },
      word = false,
      cyclic = true,
    })

    local ordinal_numbers = augend.constant.new({
      -- elements through which we cycle. When we increment, we go down
      -- On decrement we go up
      elements = {
        "first",
        "second",
        "third",
        "fourth",
        "fifth",
        "sixth",
        "seventh",
        "eighth",
        "ninth",
        "tenth",
      },
      -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
      word = false,
      -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
      -- Otherwise nothing will happen when there are no further values
      cyclic = true,
    })

    local months = augend.constant.new({
      elements = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      },
      word = true,
      cyclic = true,
    })

    return {
      dials_by_ft = {
        css = "css",
        vue = "vue",
        javascript = "typescript",
        typescript = "typescript",
        typescriptreact = "typescript",
        javascriptreact = "typescript",
        json = "json",
        lua = "lua",
        markdown = "markdown",
        sass = "css",
        scss = "css",
        python = "python",
      },
      groups = {
        default = {
          augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.integer.alias.decimal_int, -- nonnegative and negative decimal number
          augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
          augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
          augend.constant.alias.en_weekday, -- Mon, Tue, ..., Sat, Sun
          augend.constant.alias.en_weekday_full, -- Monday, Tuesday, ..., Saturday, Sunday
          ordinal_numbers,
          months,
          augend.constant.alias.bool, -- boolean value (true <-> false)
          augend.constant.alias.Bool, -- boolean value (True <-> False)
          logical_alias,
        },
        vue = {
          augend.constant.new({ elements = { "let", "const" } }),
          augend.hexcolor.new({ case = "lower" }),
          augend.hexcolor.new({ case = "upper" }),
        },
        typescript = {
          augend.constant.new({ elements = { "let", "const" } }),
        },
        css = {
          augend.hexcolor.new({
            case = "lower",
          }),
          augend.hexcolor.new({
            case = "upper",
          }),
        },
        markdown = {
          augend.constant.new({
            elements = { "[ ]", "[x]" },
            word = false,
            cyclic = true,
          }),
          augend.misc.alias.markdown_header,
        },
        json = {
          augend.semver.alias.semver, -- versioning (v1.1.2)
        },
        lua = {
          augend.constant.new({
            elements = { "and", "or" },
            word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true, -- "or" is incremented into "and".
          }),
        },
        python = {
          augend.constant.new({
            elements = { "and", "or" },
          }),
        },
      },
    }
  end,
  config = function(_, opts)
    -- copy defaults to each group
    for name, group in pairs(opts.groups) do
      if name ~= "default" then
        vim.list_extend(group, opts.groups.default)
      end
    end
    require("dial.config").augends:register_group(opts.groups)
    vim.g.dials_by_ft = opts.dials_by_ft
  end,
}
