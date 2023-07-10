local helper = {}
helper.path_sep = package.config:sub(1, 1) == '\\' and '\\' or '/'

function helper.path_join(...)
  return table.concat({ ... }, helper.path_sep)
end

function helper.data_path()
  local cli = require('core.cli')
  if cli.config_path then
    return cli.config_path
  end
  return vim.fn.stdpath('data')
end

function helper.config_path()
  local cli = require('core.cli')
  if cli.data_path then
    return cli.data_path
  end
  return vim.fn.stdpath('config')
end

local function get_color(color)
  local tbl = {
    black = '\027[90m',
    red = '\027[91m',
    green = '\027[92m',
    yellow = '\027[93m',
    blue = '\027[94m',
    purple = '\027[95m',
    cyan = '\027[96m',
    white = '\027[97m',
  }
  return tbl[color]
end

local function color_print(color)
  local rgb = get_color(color)
  return function(text)
    print(rgb .. text .. '\027[m')
  end
end

function helper.write(color)
  local rgb = get_color(color)
  return function(text)
    io.write(rgb .. text .. '\027[m')
  end
end

function helper.success(msg)
  color_print('green')('\t🍻 ' .. msg .. ' Success ‼️ ')
end

function helper.error(msg)
  color_print('red')(msg)
end

function helper.run_git(name, cmd, type)
  local pip = assert(io.popen(cmd .. ' 2>&1'))
  color_print('green')('\t🍻 ' .. type .. ' ' .. name)
  local failed = false
  for line in pip:lines() do
    if line:find('fatal') then
      failed = true
    end
    io.write('\t ' .. line)
    io.write('\n')
  end

  pip:close()
  return failed
end

local function exists(file)
  local ok, _, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      return true
    end
  end
  return ok
end

--- Check if a directory exists in this path
function helper.isdir(path)
  return exists(path .. '/')
end

setmetatable(helper, {
  __index = function(_, k)
    return color_print(k)
  end,
})

return helper
