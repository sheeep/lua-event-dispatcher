local Event = require "event"
local defaultExecutor = require "executor/direct"

local Dispatcher = {}

-- Create a new Dispatcher object
function Dispatcher:new(executor)
    executor = executor or defaultExecutor

    assert(type(executor) == "function" or type(executor) == "table", "An executor must be a callable")

    local state = {
        listeners = {},
        executor = executor
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
function Dispatcher:addListener(eventName, listener, priority)
    -- set a default priority if nothing is provided
    priority = priority or 0

    assert(type(listener) == "function" or type(listener) == "table", "A registered listener must be callable")
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

-- Add a new listener to the dispatcher
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
Dispatcher.on = Dispatcher.addListener

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

-- Remove all listeners for a given event
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:removeListeners(eventName)
    if self.listeners[eventName] == nil then
        return
    end

    self.listeners[eventName] = {}
end

-- Remove all listeners from the dispatcher
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:removeAllListeners()
    self.listeners = {}
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
-- but it is possible to dispatch with any kind of table as an event
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
        self.executor(listener, event)

        if type(event) == "table" and event.isPropagationStopped then
            break
        end
    end

    if (type(event) == "table") then
        event.isDispatched = true
    end
end

return Dispatcher
