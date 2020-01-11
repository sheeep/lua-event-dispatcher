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

    it("should be possible to register a listener to multiple events", function ()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name-1", function() end)
        dispatcher:addListener("event-name-2", function() end)

        assert.same(1, #dispatcher:getListeners("event-name-1"))
        assert.same(1, #dispatcher:getListeners("event-name-2"))
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

        local listener1 = function(event) end
        local listener2 = function(event) end

        dispatcher:addListener("event-name", listener1)
        dispatcher:addListener("event-name", listener2)
        assert.same(2, #dispatcher:getListeners("event-name"))

        dispatcher:removeListener("event-name", listener1)

        assert.same(1, #dispatcher:getListeners("event-name"))

        dispatcher:removeListener("event-name", listener2)
        assert.same(0, #dispatcher:getListeners("event-name"))
    end)
end)
