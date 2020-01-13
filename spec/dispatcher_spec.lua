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

        dispatcher:on("event-name", function() end)

        assert.same(1, #dispatcher:getListeners("event-name"))
    end)

    it("should be possible to register multiple listeners", function()
        local dispatcher = Dispatcher:new()

        dispatcher:on("event-name", function() end)
        dispatcher:on("event-name", function() end)

        assert.same(2, #dispatcher:getListeners("event-name"))
    end)

    it("should be possible to register a listener to multiple events", function()
        local dispatcher = Dispatcher:new()

        dispatcher:on("event-name-1", function() end)
        dispatcher:on("event-name-2", function() end)

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

        local listener1 = function() end
        local listener2 = function() end

        dispatcher:on("event-name", listener1)
        dispatcher:on("event-name", listener2)
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

        dispatcher:addListener("event-name", function() end)

        dispatcher:dispatch("event-name", event1)

        assert.truthy(event1.isDispatched)
        assert.is_not.truthy(event2.isDispatched)
    end)

    it("should be possible to pass data within an Event object", function()
        local dispatcher = Dispatcher:new()
        local event = Event:new({
            changed = false
        })

        dispatcher:on("event-name", function(e)
            e.data.changed = true
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

        local listener1 = function(e)
            e.data.number = e.data.number + 1
            e:stopPropagation()
        end
        local listener2 = function(e)
            e.data.number = e.data.number + 3
        end

        dispatcher:on("event-name", listener1)
        dispatcher:on("event-name", listener2)
        dispatcher:on("event-name", listener2)

        dispatcher:dispatch("event-name", event)

        assert.same(1, event.data.number)
    end)

    it("should be possible to have multiple dispatchers (event busses)", function()
        local dispatcher1 = Dispatcher:new()
        local dispatcher2 = Dispatcher:new()

        local listener = function() end

        dispatcher1:on("event-name", listener)
        dispatcher2:on("event-name", listener)

        assert.same(1, #dispatcher1:getListeners("event-name"))
        assert.same(1, #dispatcher2:getListeners("event-name"))
    end)

    it("should be possible to use the method :on instead of :addListener", function()
        local dispatcher = Dispatcher:new()
        local event = Event:new({
            number = 0
        })

        dispatcher:on("event-name", function(e)
            e.data.number = 1
        end)

        dispatcher:dispatch("event-name", event)

        assert.same(1, event.data.number)
    end)

    it("should be possible to run listeners in order", function()
        local dispatcher = Dispatcher:new()
        local event = Event:new({
            number = 1
        })

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number + 1
        end, 4)

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number + 2
        end, 3)

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number * 2
        end, 2)

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number * 3
        end, 1)

        dispatcher:dispatch("event-name", event)

        assert.same(24, event.data.number)
        assert.is_not.same(9, event.data.number)
    end)

    it("should be possible to register multiple listeners for the same priority", function()
        local dispatcher = Dispatcher:new()
        local event = Event:new({
            number = 1
        })

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number + 1
        end, 1)

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number + 1
        end, 1)

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number * 2
        end, 2)

        dispatcher:on("event-name", function(e)
            e.data.number = e.data.number * 2
        end, 2)

        dispatcher:dispatch("event-name", event)

        assert.same(6, event.data.number)
        assert.is_not.same(12, event.data.number)
    end)
end)
