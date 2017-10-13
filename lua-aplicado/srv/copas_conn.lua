--------------------------------------------------------------------------------
-- copas_conn.lua
-- This file is a part of lua-aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local copas_read_bytes,
      copas_send_bytes,
      wrap_read_write
      = import 'lua-aplicado/srv/base_conn.lua'
      {
        'copas_read_bytes',
        'copas_send_bytes',
        'wrap_read_write'
      }

return wrap_read_write(copas_read_bytes, copas_send_bytes)
