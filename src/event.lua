local Event = {}

function Event:new (data)
    data = data or {}

    local state = {
        isDispatched = false,
        isPropagationStopped = false,

        data = data
    }

    self.__index = self
    return setmetatable(state, self)
end

function Event:stopPropagation()
    self.isPropagationStopped = true
end

return Event
