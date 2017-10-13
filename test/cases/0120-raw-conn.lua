--------------------------------------------------------------------------------
-- test/cases/0120-raw-conn.lua: tests for config_dsl.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local raw_conn_exports = import 'lua-aplicado/srv/raw_conn.lua' ()

--------------------------------------------------------------------------------

local test = (...)('raw_conn', raw_conn_exports)

test:TODO "write tests on raw_conn"
test:UNTESTED "read_bytes"
test:UNTESTED "read_const"
test:UNTESTED "read_until"
test:UNTESTED "read_and_handle"
test:UNTESTED "send_bytes"
