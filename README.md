[![Build Status](https://travis-ci.com/sheeep/lua-event-dispatcher.svg?branch=master)](https://travis-ci.com/sheeep/lua-event-dispatcher)

# Lua Event Dispatcher

This is an implementation of the Mediator pattern for Lua. It provides
an event dispatcher and a generic event object.

## Installation

Install `lua-event-dispatcher` through `luarocks`.

```
$ luarocks install lua-event-dispatcher
```

## Usage

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
