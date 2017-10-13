--------------------------------------------------------------------------------
-- base_conn.lua
-- This file is a part of lua-aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local copas = require 'copas'

--------------------------------------------------------------------------------

local make_loggers
      = import 'lua-aplicado/log.lua'
      {
        'make_loggers'
      }

--------------------------------------------------------------------------------

local log, dbg, spam, log_error = make_loggers("base_conn", "BCO")

--------------------------------------------------------------------------------

-- TODO: Really silly and lazy reading code. Throw it away?

local raw_read_bytes = function(conn, size)
  return conn:receive(size)
end

local raw_send_bytes = function(conn, data)
  return conn:send(data)
end

local copas_read_bytes = function(conn, size)
  return copas.receive(conn, size)
end

local copas_send_bytes = function(conn, data)
  return copas.send(conn, data)
end

-- TODO: Generalize and reuse!
local log_if_error = function(logger, message, ...)
  local res, err = ...
  if res ~= nil then
    return ...
  end

  logger(message, err)

  return nil, err
end

local wrap_read_write = function(read_bytes, send_bytes)
  local read_const = function(conn, expected)
    local data, err = read_bytes(conn, #expected)

    if data == expected then
      return true
    end

    if err then
      return nil, err
    end

    return nil, "unexpected data `"..tostring(data).."'"
  end

  local read_and_handle = function(conn, size, handlers, ...)
    -- TODO: Read all available data. Partial reads should be slow.
    spam("BEGIN read_and_handle", conn)--, next(handlers))
    local data, err = read_bytes(conn, size)
    spam("read data:", data)
    if not data then
      -- Note: It's normal case now: we have sent OK to client
      --       as answer on previous command and he have already closed the connection
      log_error("failed to read command:", err, conn)
      return nil, err
    end

    local handler = handlers[data]
    if handler then
      --spam("BEGIN HANDLING", data)
      return log_if_error(
          log_error,
          "handler failed:",
          handler(conn, ...)
        )
    end

    log_error("unknown command detected")
    return nil, "unknown command `"..tostring(data).."'"
  end

  local read_until = function(conn, stop_char)
    -- TODO: Looks SLOW!
    local buf = {}

    local c, err = read_bytes(conn, 1)
    if not c then
      return nil, err
    end

    while c ~= stop_char do
      buf[#buf + 1] = c
      c, err = read_bytes(conn, 1)
      if not c then
        return nil, err
      end
    end
    return table.concat(buf)
  end

  return
  {
    read_bytes = read_bytes;
    read_const = read_const;
    read_until = read_until;
    read_and_handle = read_and_handle;
    send_bytes = send_bytes;
  }
end

return
{
  raw_read_bytes = raw_read_bytes;
  raw_send_bytes = raw_send_bytes;
  copas_read_bytes = copas_read_bytes;
  copas_send_bytes = copas_send_bytes;
  wrap_read_write = wrap_read_write;
}
