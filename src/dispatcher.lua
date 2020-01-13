local Event = require "event"

local Dispatcher = {}

-- Create a new Dispatcher object
function Dispatcher:new()
    local state = {
        listeners = {}
    }

    self.__index = self
    return setmetatable(state, self)
end

-- Add a new listener to the dispatcher
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:on(eventName, listener, priority)
    self:addListener(eventName, listener, priority)
end

-- Add a new listener to the dispatcher
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:addListener(eventName, listener, priority)
    -- set a default priority if nothing is provided
    priority = priority or 0

    assert(type(listener) == "function", "A registered listener must be callable")
    assert(type(priority) == "number", "priority must be a number")

    if self.listeners[eventName] == nil then
        self.listeners[eventName] = {}
    end

    if self.listeners[eventName][priority] == nil then
        self.listeners[eventName][priority] = {}
    end

    local list = self.listeners[eventName][priority]

    table.insert(list, listener)
end

-- Remove a specific listener from the table
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:removeListener(eventName, listener)
    local priorityQueues = self.listeners[eventName]

    for _, priorityQueue in pairs(priorityQueues) do
        for key, registeredListener in pairs(priorityQueue) do
            if registeredListener == listener then
                table.remove(priorityQueue, key)
            end
        end
    end
end

-- Get an ordered list of listeners listening to a specific event
--
-- @param string eventName
--
-- @return table A list of listeners
function Dispatcher:getListeners(eventName)
    local priorityQueues = self.listeners[eventName] or {}

    local listeners = {}
    local keys = {}

    for priority in pairs(priorityQueues) do
        table.insert(keys, priority)
    end

    -- reverse iteration over priority keys
    -- this way a priority of 0 will be executed before higher priorities
    for i = #keys, 1, -1 do
        local priority = keys[i]

        for _, registeredListener in pairs(priorityQueues[priority]) do
            table.insert(listeners, registeredListener)
        end
    end

    return listeners
end

-- Dispatch an event, preferably with an event object
-- but it is possible to dispatch with any kind of data as an event
--
-- @param string eventName
-- @param mixed event
--
-- @return nil
function Dispatcher:dispatch(name, event)
    if event == nil then
        event = Event:new({})
    end

    local listeners = self:getListeners(name)

    for _, listener in pairs(listeners) do
        listener(event)

        if event.isPropagationStopped then
            break
        end
    end

    event.isDispatched = true
end

return Dispatcher
