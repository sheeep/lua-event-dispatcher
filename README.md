# Lua Event Dispatcher

This is an implementation of the Mediator pattern for Lua. It provides
an event dispatcher and a generic event object, supports priorities,
propagation stops and error safe executors.

[![Build Status](https://travis-ci.com/sheeep/lua-event-dispatcher.svg?branch=master)](https://travis-ci.com/sheeep/lua-event-dispatcher)
[![codecov](https://codecov.io/gh/sheeep/lua-event-dispatcher/branch/master/graph/badge.svg)](https://codecov.io/gh/sheeep/lua-event-dispatcher)

## Installation

Install `lua-event-dispatcher` through `luarocks`.

```
$ luarocks install lua-event-dispatcher
```

## Documentation

Usage examples can be found in the `spec/` folder in form of tests.

* [Basic usage](#basic-usage)
* [The event object](#event-object)
* [Priority queues](#priority-queues)
* [Stop propagation](#stop-propagation)
* [Executors](#executors)
* [Remove event listeners](#remove-event-listeners)

### Basic usage

A simple example of how to use this library is the following one.

```lua
local Dispatcher = require "event-dispatcher.Dispatcher"
local Event = require "event-dispatcher.Event"

-- Create an event dispatcher
local dispatcher = Dispatcher:new()

-- Create an event listener
local listener = function(event)
  event.data.meep = 2
end

-- Register this listener to a specific event
dispatcher:on("event-name", listener)

-- Create an event object with
local event = Event:new({
  meep = 1
})

dispatcher:dispatch("event-name", event)
```

### Event object

The event object already contains a data table on the key `data` which
can be used to store any arbitrary data. The same Event instance is passed
to all the listeners. This allows for data to be changed along the way.

The data passed to the constructor of the event object is stored as the
initial data for this event.

```lua
local event = Event:new({
    foo: true
    bar: false
})

print(event.data.foo) -- true
print(event.data.bar) -- false
```

You don't need to create and pass an event object yourself.

```lua
local dispatcher = Dispatcher:new()

dispatcher:dispatch("something-happened")
```

Still, your listeners will receive an event object, where they can stop
the propagation for example. The data table on such an implicit created
event object is empty.

### Priority queues

Event listeners can be added with a specific priority.

```lua

dispatcher:on("event-name", listener, 32)
dispatcher:on("event-name", listener, 64)

-- You can add multiple listeners with the same priority
dispatcher:on("event-name", listener, 128)
dispatcher:on("event-name", listener, 128)
```

If no priority is given, an implicit priority of `0` will be used.
Listeners with lower priorities will be executed *first*.

### Stop propagation

If for some reason you want to stop the propagation of the event
in a listener, call the `stopPropagation` method to guarantee
that the current listener is the last one to run.

```lua
local listener = function(event)
  event:stopPropagation()
end
```

### Executors

An executor is responsible for calling your listeners. This library provides two
different implementations.

* `direct`: Listeners will be called directly. This means that any `error`
that is thrown inside of a listener immediately bubbles up and stops the
execution of other registered listeners.
* `protected`: Listeners will be called with `pcall` which means that all of
the registered listeners will be called, even if a preceding one errors on the way.

By default, the `Dispatcher` uses the `direct` executor. You can easily provided
your own executor as a callable to a new dispatcher object.

```lua
local Dispatcher = require "event-dispatcher.Dispatcher"

local directExecutor = require "event-dispatcher.Executor.direct"
local protectedExecutor = require "event-dispatcher.Executor.protected"

Dispatcher:new() -- Implicit use of a direct executor
Dispatcher:new(directExecutor) -- Explicit use of a direct executor
Dispatcher:new(protectedExecutor) -- Use a protected call

-- ... or create an executor yourself
Dispatcher:new(function(listener, event)
    -- do some other work
    listener(event)
end)
```

### Remove event listeners

To remove event listeners from a given dispatcher, use one of the following
methods.

```lua
dispatcher:removeListener("event", listener) -- Remove a specific listener from an event
dispatcher:removeListeners("event") -- Remove all listeners from an event
dispatcher:removeAllListeners() -- Clear the dispatcher from all registered events
```

## License
This library is licensed under the MIT license.
See the complete license text in the `LICENSE` file

🌱
