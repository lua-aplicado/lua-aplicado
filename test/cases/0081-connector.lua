--------------------------------------------------------------------------------
-- tests for connector
-- This file is a part of pk-engine library
-- Copyright (c) Alexander Gladysh <ag@logiceditor.com>
-- Copyright (c) Dmitry Potapov <dp@logiceditor.com>
-- See file `COPYRIGHT` for the license
--------------------------------------------------------------------------------

local tstr = import 'lua-nucleo/table.lua' { 'tstr' }

local ensure,
      ensure_equals,
      ensure_strequals,
      ensure_tequals,
      ensure_error,
      ensure_aposteriori_probability,
      ensure_fails_with_substring
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_strequals',
        'ensure_tequals',
        'ensure_error',
        'ensure_aposteriori_probability',
        'ensure_fails_with_substring'
      }

local unique_object,
      collect_all_garbage
      = import 'lua-nucleo/misc.lua'
      {
        'unique_object',
        'collect_all_garbage'
      }

local BADHOST,
      BADPORT,
      do_with_server,
      make_dumb_server_loop,
      make_copas_server_loop
      = import 'pk-engine/test/server.lua'
      {
        'BADHOST',
        'BADPORT',
        'do_with_server',
        'make_dumb_server_loop',
        'make_copas_server_loop'
      }

local arguments,
      method_arguments,
      optional_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'method_arguments',
        'optional_arguments'
      }

local raw_send_bytes,
      raw_read_const
      = import 'pk-engine/srv/raw_conn.lua'
      {
        'send_bytes',
        'read_const'
      }

local make_loggers
      = import 'pk-core/log.lua'
      {
        'make_loggers'
      }

--------------------------------------------------------------------------------

local connect,
      make_tcp_connector,
      make_domain_socket_connector,
      connector_exports
      = import 'pk-engine/connector.lua'
      {
        'connect',
        'make_tcp_connector',
        'make_domain_socket_connector'
      }

--------------------------------------------------------------------------------

local log, dbg, spam, log_error = make_loggers("0081-connector", "T08")

--------------------------------------------------------------------------------

-- TODO: Generalize to lua-nucleo (and make more unique)
local unique_string = function()
  return "UNQ-"..tostring(unique_object()).."-QNU"
end

--------------------------------------------------------------------------------

local test = (...)("connector", connector_exports)

--------------------------------------------------------------------------------

test:group 'connect'

--------------------------------------------------------------------------------

test "connect-fails" (function()
  ensure_error(
      "connect",
      'connection refused',
      connect(BADHOST, BADPORT)
    )
end)

test "connect-succeeds" (function()
  local SIGNATURE = unique_string()
  do_with_server(
      make_dumb_server_loop(SIGNATURE, nil),
      function(host, port, server_pid)
        local conn = ensure("connect", connect(host, port))
        ensure_strequals(
            "read",
            ensure("receive", conn:receive(#SIGNATURE)),
            SIGNATURE
          )
        conn:close()
        conn = nil
      end
    )
end)

test "connect-delay-succeeds" (function()
  local SIGNATURE = unique_string()
  local MAX_RETRIES = 5
  local SLEEP_TIME = 0.2
  do_with_server(
      make_dumb_server_loop(SIGNATURE, MAX_RETRIES * SLEEP_TIME / 2),
      function(host, port, server_pid)
        local conn = ensure("connect", connect(host, port, MAX_RETRIES, SLEEP_TIME))
        ensure_strequals(
            "read",
            ensure("receive", conn:receive(#SIGNATURE)),
            SIGNATURE
          )
        conn:close()
        conn = nil
      end
    )
end)

--------------------------------------------------------------------------------

test:UNTESTED "http_request"

--------------------------------------------------------------------------------

test:UNTESTED "make_tcp_connector"

--------------------------------------------------------------------------------

test:UNTESTED "make_domain_socket_connector"
