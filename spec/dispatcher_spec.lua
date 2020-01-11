-- Busted runner
require "busted.runner"()

-- Modules
local Dispatcher = require "dispatcher"

describe("Event dispatcher", function()
    it("should be createable", function()
        local dispatcher = Dispatcher:new()

        assert.same("table", type(dispatcher))
    end)

    it("should be possible to register a single listener", function()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name", function() end)

        assert.same(1, #dispatcher:getListeners("event-name"))
    end)

    it("should be possible to register multiple listeners", function()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name", function() end)
        dispatcher:addListener("event-name", function() end)

        assert.same(2, #dispatcher:getListeners("event-name"))
    end)

    it("should not be possible to register non-callable listeners", function()
        local dispatcher = Dispatcher:new()

        assert.has_error(function()
            dispatcher:addListener("event-name", true)
        end, "A registered listener must be callable")
    end)

    it("should be possible for a listener to be callend", function()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name", function(event)
            event.value = 2
        end)

        local event = {
            value = 1
        }

        dispatcher:dispatch("event-name", event)

        assert.same(2, event.value)
    end)

    it("should be possible to remove a listener", function()
        local dispatcher = Dispatcher:new()
        local listener = function(event)
            event.value = 2
        end

        dispatcher:addListener("event-name", listener)
        assert.same(1, #dispatcher:getListeners("event-name"))

        dispatcher:removeListener("event-name", listener)
        assert.same(0, #dispatcher:getListeners("event-name"))
    end)
end)
