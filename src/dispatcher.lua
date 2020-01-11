local Dispatcher = {}

function Dispatcher:new ()
    local state = {
        listeners = {}
    }

    setmetatable(state, self)
    self.__index = self

    return state
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

function Dispatcher:getListeners(name)
    local listeners = self.listeners[name] or {}

    return listeners
end

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
