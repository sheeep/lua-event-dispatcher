-- Busted runner
require "busted.runner"()

-- Modules
local Dispatcher = require "dispatcher"

describe("Event dispatcher", function()
    it("should be createable", function()
        local dispatcher = Dispatcher:new()

        assert.same("table", type(dispatcher))
    end)

    it("should be possible to register a single listener", function ()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name", true)

        assert.same(1, #dispatcher:getListeners("event-name"))
    end)

    it("should be possible to register multiple listeners", function ()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name", true)
        dispatcher:addListener("event-name", true)

        assert.same(2, #dispatcher:getListeners("event-name"))
    end)
end)
