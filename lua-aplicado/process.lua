--------------------------------------------------------------------------------
-- process.lua: utilities for various process management
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local socket = require 'socket'
local socket_sleep = socket.sleep

local arguments,
      optional_arguments,
      method_arguments,
      pack
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments',
        'pack'
      }

--------------------------------------------------------------------------------

local retry_n_times
do
  local function impl(fn, attempts, sleep_time, error_msg, ok, ...)
    if ok then
      return ok, ...
    end
    if attempts <= 0 then
      return nil, error_msg
    end

    socket_sleep(sleep_time)

    return impl(fn, attempts - 1, sleep_time, error_msg, fn())
  end

  --- Call function @param fn @param attempts times, with @param sleep_time
  -- interval.
  -- @param fn Function to call.
  -- @param attempts Amount of attempts to run function.
  -- @param sleep_time Time to wait, before next attempt
  -- @return Returns result of @param fn on success, otherwise returns nil and
  --   error mesafw
  retry_n_times = function(fn, attempts, sleep_time, error_msg)
    error_msg = error_msg or "timeout"

    arguments(
        "function", fn,
        "number", attempts,
        "number", sleep_time,
        "string", error_msg
      )

    return impl(fn, attempts - 1, sleep_time, error_msg, fn())
  end
end

--------------------------------------------------------------------------------

return
{
  retry_n_times = retry_n_times;
}
