local Dispatcher = {}

-- Create a new Dispatcher object
function Dispatcher:new()
    local state = {
        listeners = {}
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function Dispatcher:on(eventName, listener)
    self:addListener(eventName, listener)
end

-- Add a new listener to the dispatcher
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:addListener(eventName, listener)
    if type(listener) ~= "function" then
        error("A registered listener must be callable")
    end

    if self.listeners[eventName] == nil then
        self.listeners[eventName] = {}
    end

    local list = self.listeners[eventName]

    table.insert(list, listener)
end

-- Remove a specific listener from the table
--
-- @param string eventName
-- @param callable listener
--
-- @return nil
function Dispatcher:removeListener(eventName, listener)
    local listeners = self:getListeners(eventName)

    for key, registeredListener in pairs(listeners) do
        if registeredListener == listener then
            table.remove(listeners, key)
        end
    end
end

-- Get a list of listeners listening to a specific event
--
-- @param string eventName
--
-- @return table A list of listeners
function Dispatcher:getListeners(eventName)
    local listeners = self.listeners[eventName] or {}

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
    local listeners = self:getListeners(name)

    for _, listener in ipairs(listeners) do
        pcall(listener, event)

        if event.isPropagationStopped then
            break
        end
    end

    event.isDispatched = true
end

return Dispatcher
