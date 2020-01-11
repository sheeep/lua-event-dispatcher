-- Busted runner
require "busted.runner"()

-- Modules
local Dispatcher = require "dispatcher"

describe("Event dispatcher", function()
    it("should be createable", function()
        local dispatcher = Dispatcher:new()

        assert.same("table", type(dispatcher))
    end)
end)
