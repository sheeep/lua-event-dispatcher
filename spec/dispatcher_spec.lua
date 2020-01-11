-- Busted runner
require "busted.runner"()

-- Modules
local Dispatcher = require "dispatcher"
local Event = require "event"

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

    it("should be possible to dispatch an Event object", function()
        local dispatcher = Dispatcher:new()
        local event1 = Event:new()
        local event2 = Event:new()

        dispatcher:addListener("event-name", function(event1) end)

        dispatcher:dispatch("event-name", event1)

        assert.truthy(event1.isDispatched)
        assert.is_not.truthy(event2.isDispatched)
    end)

    it("should be possible to pass data within an Event object", function()
        local dispatcher = Dispatcher:new()
        local event = Event:new({
            changed = false
        })

        dispatcher:addListener("event-name", function(event)
            event.data.changed = true
        end)

        dispatcher:dispatch("event-name", event)

        assert.truthy(event.data)
        assert.truthy(event.data.changed)
    end)

    it("should be possible to stop the event propagation", function()
        local dispatcher = Dispatcher:new()
        local event = Event:new({
            number = 0
        })

        local listener1 = function(event)
            event.data.number = event.data.number + 1
            event:stopPropagation()
        end
        local listener2 = function(event)
            event.data.number = event.data.number + 3
        end

        dispatcher:addListener("event-name", listener1)
        dispatcher:addListener("event-name", listener2)
        dispatcher:addListener("event-name", listener2)

        dispatcher:dispatch("event-name", event)

        assert.same(1, event.data.number)
    end)

    it("should be possible to have multiple dispatchers (event busses)", function()
        local dispatcher1 = Dispatcher:new()
        local dispatcher2 = Dispatcher:new()

        local listener = function(event) end

        dispatcher1:addListener("event-name", listener)
        dispatcher2:addListener("event-name", listener)

        assert.same(1, #dispatcher1:getListeners("event-name"))
        assert.same(1, #dispatcher2:getListeners("event-name"))
    end)
end)
