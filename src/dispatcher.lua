local Dispatcher = {}

function Dispatcher:new ()
    local state = {
        listeners = {}
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function Dispatcher:addListener(name, listener)
    if self.listeners[name] == nil then
        self.listeners[name] = {}
    end

    local list = self.listeners[name]

    self.listeners[name][#list + 1] = listener
end

function Dispatcher:getListeners(name)
    return self.listeners[name]
end

function Dispatcher:dispatch(name, event)
    local listeners = self:getListeners(name)

    for key, listener in pairs(listeners) do
        pcall(listener, event)
    end
end

return Dispatcher
