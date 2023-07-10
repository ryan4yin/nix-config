local cli = {}
local helper = require('core.helper')

function cli:env_init()
  self.module_path = helper.path_join(self.config_path, 'lua', 'modules')
  self.lazy_dir = helper.path_join(self.data_path, 'lazy')

  package.path = package.path
    .. ';'
    .. self.rtp
    .. '/lua/vim/?.lua;'
    .. self.module_path
    .. '/?.lua;'
  local shared = assert(loadfile(helper.path_join(self.rtp, 'lua', 'vim', 'shared.lua')))
  _G.vim = shared()
end

function cli:get_all_packages()
  local pack = require('core.pack')
  local p = io.popen('find "' .. cli.module_path .. '" -type f')
  if not p then
    return
  end

  for file in p:lines() do
    if file:find('package.lua') then
      local module = file:match(cli.module_path .. '/(.+).lua$')
      require(module)
    end
  end
  p:close()

  local lazy_keyword = {
    'keys',
    'ft',
    'cmd',
    'event',
    'lazy',
  }

  local function generate_node(tbl, list)
    local node = tbl[1]
    list[node] = {}
    list[node].type = tbl.dev and 'Local Plugin' or 'Remote Plugin'

    local check_lazy = function(t, data)
      vim.tbl_filter(function(k)
        if vim.tbl_contains(lazy_keyword, k) then
          data.load = type(t[k]) == 'table' and table.concat(t[k], ',') or t[k]
          return true
        end
        return false
      end, vim.tbl_keys(t))
    end

    check_lazy(tbl, list[node])

    if tbl.dependencies then
      for _, v in pairs(tbl.dependencies) do
        if type(v) == 'string' then
          v = { v }
        end

        list[v[1]] = {
          from_depend = true,
          load_after = node,
        }

        list[v[1]].type = v.dev and 'Local Plugin' or 'Remote Plugin'
        check_lazy(v, list[v[1]])
      end
    end
  end

  local list = {}
  for _, data in pairs(pack.repos or {}) do
    if type(data) == string then
      data = { data }
    end
    generate_node(data, list)
  end

  return list
end

function cli:boot_strap()
  helper.blue('🔸 Search plugin management lazy.nvim in local')
  if helper.isdir(self.lazy_dir) then
    helper.green('🔸 Found lazy.nvim skip download')
    return
  end
  helper.run_git('lazy.nvim', 'git clone https://github.com/folke/lazy.nvim ' .. self.lazy_dir, 'Install')
  helper.success('lazy.nvim')
end

function cli:installer(type)
  cli:boot_strap()

  local packages = cli:get_all_packages()
  ---@diagnostic disable-next-line: unused-local, param-type-mismatch
  local res = {}
  for name, v in pairs(packages or {}) do
    if v.type:find('Remote') then
      local non_user_name = vim.split(name, '/')[2]
      local path = self.lazy_dir .. helper.path_sep .. non_user_name
      if helper.isdir(path) and type == 'install' then
        helper.purple('\t🥯 Skip already in plugin ' .. name)
      else
        local url = 'git clone https://github.com/'
        local cmd = type == 'install' and url .. name .. ' ' .. path or 'git -C ' .. path .. ' pull'
        local failed = helper.run_git(name, cmd, type)
        table.insert(res, failed)
      end
    else
      helper.purple('\t🥯 Skip local plugin ' .. name)
    end
  end
  if not vim.tbl_contains(res, true) then
    helper.green('🎉 Congratulations Config install or update success. Enjoy ^^')
    return
  end
  helper.red('Some plugins not install or update success please run install again')
end

function cli.install()
  cli:installer('install')
end

function cli.update()
  cli:installer('update')
end

function cli.clean()
  os.execute('rm -rf ' .. cli.lazy_dir)
end

function cli.doctor(pack_name)
  local list = cli:get_all_packages()
  if not list then
    return
  end

  helper.yellow('🔹 Total: ' .. vim.tbl_count(list) + 1 .. ' Plugins')
  local packs = pack_name and { [pack_name] = list[pack_name] } or list
  for k, v in pairs(packs) do
    helper.blue('\t' .. '✨' .. k)
    if v.type then
      helper.write('purple')('\tType: ')
      helper.write('white')(v.type)
      print()
    end
    if v.load then
      helper.write('purple')('\tLoad: ')
      helper.write('white')(v.load)
      print()
    end

    if v.from_depend then
      helper.write('purple')('\tDepend: ')
      helper.write('white')(v.load_after)
      print()
    end
  end
end

function cli.modules()
  local p = io.popen('find "' .. cli.module_path .. '" -type d')
  if not p then
    return
  end
  local res = {}

  for dict in p:lines() do
    dict = vim.split(dict, helper.path_sep)
    if dict[#dict] ~= 'modules' then
      table.insert(res, dict[#dict])
    end
  end

  helper.green('Found ' .. #res .. ' Modules in Local')
  for _, v in pairs(res) do
    helper.write('yellow')('\t✅ ' .. v)
    print()
  end
end

function cli:meta(arg)
  return function(data)
    self[arg](data)
  end
end

return cli
