--------------------------------------------------------------------------------
-- test/cases/0110-base-conn.lua: tests for config_dsl.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local base_conn_exports = import 'lua-aplicado/srv/base_conn.lua' ()

--------------------------------------------------------------------------------

local test = (...)("base_conn", base_conn_exports)

test:TODO "write tests on base_conn"
test:UNTESTED "raw_send_bytes"
test:UNTESTED "raw_read_bytes"
test:UNTESTED "copas_read_bytes"
test:UNTESTED "copas_send_bytes"
test:UNTESTED "wrap_read_write"
