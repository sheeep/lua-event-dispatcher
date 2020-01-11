# Lua Event Dispatcher

This is an implementation of the Mediator pattern for Lua. It provides
an event dispatcher and a generic event object.

[![Build Status](https://travis-ci.com/sheeep/lua-event-dispatcher.svg?branch=master)](https://travis-ci.com/sheeep/lua-event-dispatcher)

## Installation

Install `lua-event-dispatcher` through `luarocks`.

```
$ luarocks install lua-event-dispatcher
```

## Usage

A simple example of how to use this library is the following one.

```lua
local Dispatcher = require "event-dispatcher.Dispatcher"
local Event = require "event-dispatcher.Event"

local dispatcher = Dispatcher:new()

-- Create an event listener
local listener = function (event)
  event.data.meep = 2
end

-- Register this listener to a specific event
dispatcher.addListener("event-name", listener)

-- Dispatch this event
local event = Event:new({
  meep = 1
})

dispatcher.dispatch("event-name", event)
```

If for some reason you want to stop the propagation of the event
in a listener, call the `stopPropagation` method to guarantee
that the current listener is the last one to run.

```lua
local listener = function (event)
  event:stopPropagation()
end
```

## License
This library is licensed under the MIT license.
See the complete license text in the `LICENSE` file
