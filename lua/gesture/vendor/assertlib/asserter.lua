local M = {}

function M.new(name, attributes)
  vim.validate({
    name = { name, "string" },
    attributes = { attributes, "table" },
  })
  attributes.get_actual = attributes.get_actual or function() end
  attributes.get_actual_args = attributes.get_actual_args
    or function(args)
      return { unpack(args, 1, #args - 1) }
    end
  attributes.get_expected = attributes.get_expected or function(...)
    return ...
  end
  attributes.get_expected_args = attributes.get_expected_args or function(args)
    return { args[#args] }
  end
  return {
    name = name,
    get_result = function(args)
      local expected_args = attributes.get_expected_args(args)
      local expected = attributes.get_expected(unpack(expected_args))
      local actual_args = attributes.get_actual_args(args)
      local actual = attributes.get_actual(unpack(actual_args))
      return {
        name = name,
        expected = expected,
        expected_args = expected_args,
        actual = actual,
        actual_args = actual_args,
      }
    end,
    is_ok = attributes.is_ok or function(result)
      local expected = vim.inspect(result.expected)
      local actual = vim.inspect(result.actual)
      return vim.deep_equal(expected, actual)
    end,
    positive_message = attributes.positive_message or function(result)
      return ("%s should be %s, but actual: %s"):format(result.name, result.expected, result.actual)
    end,
    negative_message = attributes.negative_message or function(result)
      return ("%s should not be %s, but actual: %s"):format(result.name, result.expected, result.actual)
    end,
  }
end

function M.from(module)
  local asserters = {}
  for name, fn_or_table in pairs(module) do
    local atributes
    if type(fn_or_table) == "function" then
      atributes = { get_actual = fn_or_table }
    else
      atributes = fn_or_table
    end
    table.insert(asserters, M.new(name, atributes))
  end
  return asserters
end

return M
