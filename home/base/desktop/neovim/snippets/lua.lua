return {
  -- e.g. local bar = require("foo.bar")
  s(
    'require',
    fmt([[local {} = require("{}")]], {
      d(2, function(args)
        local modules = vim.split(args[1][1], '%.')
        return sn(nil, { i(1, modules[#modules]) })
      end, { 1 }),
      i(1),
    })
  ),
}
