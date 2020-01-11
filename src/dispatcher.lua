local Dispatcher = {}

function Dispatcher:new (state)
    state = state or {}
    setmetatable(state, self)
    self.__index = self

    return state
end

return Dispatcher
