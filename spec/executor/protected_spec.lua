-- Busted runner
require "busted.runner"()

-- Modules
local Dispatcher = require "dispatcher"
local Event = require "event"
local executor = require "executor/protected"

describe("Protected executor", function()
    it("should call registered listeners", function()
        local dispatcher = Dispatcher:new(executor)
        local event = Event:new({
            called = false
        })

        local listener = function (e)
            e.data.called = true
        end

        dispatcher:on("some-event", listener)
        dispatcher:dispatch("some-event", event)

        assert.truthy(event.data.called)
    end)

    it("should not propagate errors and resume execution", function()
        local dispatcher = Dispatcher:new(executor)
        local event = Event:new({
            called = false
        })

        local listener1 = function ()
            error(1)
        end
        local listener2 = function (e)
            e.data.called = true
        end

        dispatcher:on("some-event", listener1)
        dispatcher:on("some-event", listener2)

        assert.is_not.has_error(function()
            dispatcher:dispatch("some-event", event)
        end, 1)

        assert.truthy(event.data.called)
    end)
end)
