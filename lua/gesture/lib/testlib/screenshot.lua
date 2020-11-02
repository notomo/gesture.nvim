local M = {}

local Test = {}
Test.__index = Test

local TestContext = {}
TestContext.__index = TestContext

function TestContext.create(dir_path, hash)
  local tbl = {_file_paths = {}, _dir = dir_path, _hash = hash}
  vim.fn.mkdir(dir_path, "p")

  return setmetatable(tbl, TestContext)
end

function TestContext.screenshot(self, name)
  local file_path = ("%s/%s"):format(self._dir, name or #self._file_paths)

  vim.fn.delete(file_path)
  vim.api.nvim_command("redraw!")
  vim.api.nvim__screenshot(file_path)

  table.insert(self._file_paths, file_path)
  return file_path
end

function TestContext._run(self, scenario)
  local origin_branch
  if self._hash ~= nil then
    origin_branch = vim.fn.systemlist({"git", "rev-parse", "--abbrev-ref", "HEAD"})[1]
    vim.fn.system({"git", "checkout", self._hash})
    if vim.v.shell_error ~= 0 then
      return false, "failed to checkout " .. self._hash
    end
  end

  local ok, result = pcall(scenario, self)

  if origin_branch ~= nil then
    vim.fn.system({"git", "checkout", origin_branch})
  end

  return ok, result
end

local TestResult = {}
TestResult.__index = TestResult

function TestResult.new(file_paths, dir_path)
  local tbl = {file_paths = file_paths, dir_path = dir_path}
  return setmetatable(tbl, TestResult)
end

function Test.run(self, opts)
  local name = vim.tbl_count(self._ctxs)
  if opts.hash ~= nil then
    name = ("%s_%s"):format(name, opts.hash)
  end

  local dir_path = ("%s/%s"):format(self._dir, name)
  local ctx = TestContext.create(dir_path, opts.hash)
  self._ctxs[name] = ctx

  self._cleanup()

  local ok, err = ctx:_run(opts.scenario or self._scenario)
  if self._quit_on_err and not ok then
    print(err)
    vim.api.nvim_command("cquit")
  end

  return TestResult.new(ctx._file_paths, ctx._dir)
end

function Test.diff(self, result_a, result_b)
  local ok = true
  local f = io.open(self._result_path, "w")
  for i, file_path_a in ipairs(result_a.file_paths) do
    local name_a = vim.fn.fnamemodify(file_path_a, ":t")
    local file_path_b = result_b.file_paths[i]
    if file_path_b == nil then
      f:write("\" " .. name_a .. " not found on b\n")
      goto continue
    end

    local name_b = vim.fn.fnamemodify(file_path_b, ":t")
    if name_a ~= name_b then
      f:write("\" " .. name_a .. " not found on b\n")
      goto continue
    end

    local diff = vim.trim(vim.fn.system({"diff", "-u", file_path_a, file_path_b}))
    if #diff ~= 0 then
      f:write(("\" diff found: %s %s\n"):format(file_path_a, file_path_b))

      f:write("tabedit | terminal\n")
      f:write("setlocal bufhidden=wipe\n")
      f:write(("call chansend(&channel, \"cat %s\\n\")\n"):format(file_path_a))
      f:write(("file %s_%s\n"):format(vim.fn.fnamemodify(result_a.dir_path, ":t"), name_a))

      f:write("tabedit | terminal\n")
      f:write("setlocal bufhidden=wipe\n")
      f:write(("call chansend(&channel, \"cat %s\\n\")\n"):format(file_path_b))
      f:write(("file %s_%s\n"):format(vim.fn.fnamemodify(result_b.dir_path, ":t"), name_b))

      ok = false

      goto continue
    end

    ::continue::
  end

  if not ok then
    f:write(("\" source %s \" ex command to show screenshots on failed\n"):format(self._result_path))
  end
  f:close()
end

local default_dir_path = vim.fn.getcwd() .. "/test/screenshot"

M.setup = function(opts)
  opts = opts or {}
  local result_path = vim.fn.fnamemodify(opts.result_path or default_dir_path .. "/result.vim", ":p")
  local dir_path = vim.fn.fnamemodify(result_path, ":h")
  local cleanup = opts.cleanup or function()
  end

  vim.fn.delete(dir_path, "rf")
  vim.fn.mkdir(dir_path, "p")

  local tbl = {
    _dir = dir_path,
    _result_path = result_path,
    _ctxs = {},
    _scenario = opts.scenario,
    _quit_on_err = opts.quit_on_err or false,
    _cleanup = cleanup,
  }
  return setmetatable(tbl, Test)
end

return M
