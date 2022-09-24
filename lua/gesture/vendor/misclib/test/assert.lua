local M = {}

function M.register(create_assert, asserters)
  for _, asserter in ipairs(asserters) do
    create_assert(asserter.name):register(function(self)
      return function(_, args)
        local result = asserter.get_result(args)
        self:set_positive(asserter.positive_message(result))
        self:set_negative(asserter.negative_message(result))
        return asserter.is_ok(result)
      end
    end)
  end
end

return M
