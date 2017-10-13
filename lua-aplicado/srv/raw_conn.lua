--------------------------------------------------------------------------------
-- raw_conn.lua
-- This file is a part of lua-aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local raw_read_bytes,
      raw_send_bytes,
      wrap_read_write
      = import 'lua-aplicado/srv/base_conn.lua'
      {
        'raw_read_bytes',
        'raw_send_bytes',
        'wrap_read_write'
      }

return wrap_read_write(raw_read_bytes, raw_send_bytes)
