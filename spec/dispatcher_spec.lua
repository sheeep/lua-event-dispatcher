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

    it("should be possible to remove all listeners for a given event", function()
        local dispatcher = Dispatcher:new()

        local listener1 = function() end
        local listener2 = function() end

        dispatcher:on("event-name", listener1)
        dispatcher:on("event-name", listener2)

        dispatcher:on("another-event", listener1)
        dispatcher:on("another-event", listener2)

        assert.same(2, #dispatcher:getListeners("event-name"))
        assert.same(2, #dispatcher:getListeners("another-event"))

        dispatcher:removeListeners("event-name")

        assert.same(0, #dispatcher:getListeners("event-name"))
        assert.same(2, #dispatcher:getListeners("another-event"))
    end)


    it("should be possible to remove all listeners", function()
        local dispatcher = Dispatcher:new()

        local listener1 = function() end
        local listener2 = function() end

        dispatcher:on("event-name", listener1)
        dispatcher:on("event-name", listener2)

        dispatcher:on("another-event", listener1)
        dispatcher:on("another-event", listener2)

        assert.same(2, #dispatcher:getListeners("event-name"))
        assert.same(2, #dispatcher:getListeners("another-event"))

        dispatcher:removeAllListeners()

        assert.same(0, #dispatcher:getListeners("event-name"))
        assert.same(0, #dispatcher:getListeners("another-event"))
    end)

    it("should be possible to dispatch an event object", function()
        local dispatcher = Dispatcher:new()
        local event1 = Event:new()
        local event2 = Event:new()

        dispatcher:addListener("event-name", function() end)

        dispatcher:dispatch("event-name", event1)

        assert.truthy(event1.isDispatched)
        assert.is_not.truthy(event2.isDispatched)
    end)

    it("should be possible to dispatch without an event object", function()
        local dispatcher = Dispatcher:new()

        dispatcher:addListener("event-name", function() end)
        dispatcher:dispatch("event-name")

        assert.truthy(true)
    end)

    it("should be possible to pass data within an event object", function()
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
        local event = Event:new()

        local listener1 = spy.new(function(e)
            e:stopPropagation()
        end)
        local listener2 = spy.new(function() end)

        dispatcher:on("event-name", listener1)
        dispatcher:on("event-name", listener2)
        dispatcher:on("event-name", listener2)

        dispatcher:dispatch("event-name", event)

        assert.spy(listener1).was.called()
        assert.spy(listener2).was_not.called()
    end)

    it("should be possible to stop the event propagation event without an event object", function()
        local dispatcher = Dispatcher:new()
        local a = 1

        local listener1 = spy.new(function(e)
            e:stopPropagation()
        end)
        local listener2 = spy.new(function() end)

        dispatcher:on("event-name", listener1)
        dispatcher:on("event-name", listener2)

        dispatcher:dispatch("event-name")

        assert.spy(listener1).was.called()
        assert.spy(listener2).was_not.called()
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
        local event = Event:new()
        local listener = spy.new(function() end)

        dispatcher:on("event-name", listener)
        dispatcher:dispatch("event-name", event)

        assert.spy(listener).was.called()
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

    it("should not be possible to add a non-numeric priority", function()
        local dispatcher = Dispatcher:new()

        assert.has_error(function()
            dispatcher:addListener("event-name", function() end, "NaN")
        end, "priority must be a number")
    end)

    it("should do nothing if removeListeners is called without an eventName", function()
        local dispatcher = Dispatcher:new()

        local listener = function() end

        dispatcher:on("event-name", listener)
        dispatcher:on("event-name", listener)

        dispatcher:removeListeners()

        assert.same(2, #dispatcher:getListeners("event-name"))
    end)
end)
