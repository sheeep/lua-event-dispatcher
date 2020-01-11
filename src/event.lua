local Event = {}

function Event:new (data)
    data = data or {}

    local state = {
        isDispatched = false,
        isPropagationStopped = false,
        data = data
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function Event:isDispatched()
    return self.dispatched
end

return Event
