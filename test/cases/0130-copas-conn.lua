--------------------------------------------------------------------------------
-- test/cases/0130-copas-conn.lua: tests for config_dsl.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local copas_conn_exports = import 'lua-aplicado/srv/copas_conn.lua' ()

--------------------------------------------------------------------------------

local test = (...)('copas_conn', copas_conn_exports)

test:TODO "write tests on copas_conn"
test:UNTESTED "read_bytes"
test:UNTESTED "read_const"
test:UNTESTED "read_until"
test:UNTESTED "read_and_handle"
test:UNTESTED "send_bytes"
