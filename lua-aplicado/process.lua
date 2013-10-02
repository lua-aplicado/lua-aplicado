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

local retry_n_times = function(fn, attempts, sleep_time, error_msg)
  error_msg = error_msg or "timeout"

  arguments(
      "function", fn,
      "number", attempts,
      "number", sleep_time,
      "string", error_msg
    )

  for times = 1, attempts do
    local n, values = pack(fn())
    if values[1] then
      return unpack(values)
    else
      socket_sleep(sleep_time)
    end
  end
  return nil, error_msg
end

--------------------------------------------------------------------------------

return
{
  retry_n_times = retry_n_times;
}
