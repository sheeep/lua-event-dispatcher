-- Busted runner
require "busted.runner"()

-- Modules
local Dispatcher = require "dispatcher"
local Event = require "event"

describe("Event", function()
    it("should be possible to create an event without data", function()
        local event = Event:new()

        assert.same("table", type(event.data))
        assert.same(0, #event.data)
    end)

    it("should be possible to change the data", function()
        local event = Event:new()

        assert.same("table", type(event.data))

        event.data = 1

        assert.same("number", type(event.data))
        assert.same(1, event.data)
    end)

    it("should be possible to change the property isDispatched", function()
        local event = Event:new()

        assert.is_not.truthy(event.isDispatched)

        event.isDispatched = true

        assert.truthy(event.isDispatched)
    end)

    it("should be possible to stop the propagation", function()
        local event = Event:new()

        assert.is_not.truthy(event.isPropagationStopped)

        event:stopPropagation()

        assert.truthy(event.isPropagationStopped)
    end)
end)
