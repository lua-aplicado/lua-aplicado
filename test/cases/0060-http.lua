--------------------------------------------------------------------------------
-- test/cases/0050-http.lua: tests for http.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local ensure,
      ensure_equals,
      ensure_strequals,
      ensure_tequals,
      ensure_tdeepequals,
      ensure_returns,
      ensure_error
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_strequals',
        'ensure_tequals',
        'ensure_tdeepequals',
        'ensure_returns',
        'ensure_error'
      }

local make_wsapi_tcp_server_loop
      = import 'pk-test/wsapi_server.lua'
      {
        'make_wsapi_tcp_server_loop'
      }

-- TODO: Change pk-engine/test to pk-test after publishing of pk-test
-- https://github.com/lua-aplicado/lua-aplicado/issues/23
local do_with_server
      = import 'pk-test/server.lua'
      {
        'do_with_server'
      }

local make_loggers
      = import 'lua-aplicado/log.lua'
      {
        'make_loggers'
      }

-- TODO: Change pk-engine/test to pk-test after publishing of pk-test
-- https://github.com/lua-aplicado/lua-aplicado/issues/23
local wait_for_server_start
      = import 'pk-test/client.lua'
      {
        'wait_for_server_start'
      }

local common_send_http_request,
      send_http_request,
      is_http_error_code,
      exports
      = import 'lua-aplicado/http.lua'
      {
        'common_send_http_request',
        'send_http_request',
        'is_http_error_code'
      }

require 'wsapi.request'
require 'wsapi.response'

--------------------------------------------------------------------------------

local log, dbg, spam, log_error = make_loggers("0060-http", "T060")

--------------------------------------------------------------------------------

local test = (...)("http", exports)

--------------------------------------------------------------------------------

local wait_for_xavante_start = function(host, port)
  return wait_for_server_start("xavante", host, port)
end

test "POST-no-headers-defined-use-default-Content-type" (function()
  do_with_server(
      make_wsapi_tcp_server_loop(
          function()
            return function(env)
              local request = wsapi.request.new(env)
              if request.env.CONTENT_TYPE == "application/x-www-form-urlencoded" then
                local response = wsapi.response.new(200, { })
                return response:finish()
              else
                local response = wsapi.response.new(500, { })
                return response:finish()
              end
            end
          end
        ),
      function(host, port, server_pid)
        wait_for_xavante_start(host, port)

        local request =
        {
          url = "http://" .. host .. ":" .. port .. "/";
          method = "POST";
          request_body = "value=test";
        }
        local body, code = send_http_request(request)
        ensure_equals("code is 200", code, 200)
        local body, code = common_send_http_request(request)
        ensure_equals("code is 200", code, 200)
      end
    )
end)

test "POST-no-Content-type-defined-use-default" (function()
  do_with_server(
      make_wsapi_tcp_server_loop(
          function()
            return function(env)
              local request = wsapi.request.new(env)
              if request.env.CONTENT_TYPE == "application/x-www-form-urlencoded" then
                local response = wsapi.response.new(200, { })
                return response:finish()
              else
                local response = wsapi.response.new(500, { })
                return response:finish()
              end
            end
          end
        ),
      function(host, port, server_pid)
        wait_for_xavante_start(host, port)

        local request =
        {
          url = "http://" .. host .. ":" .. port .. "/";
          method = "POST";
          request_body = "value=test";
          {
            ["User-Agent"] = "test";
          };
        }
        local body, code = send_http_request(request)
        ensure_equals("code is 200", code, 200)
        local body, code = common_send_http_request(request)
        ensure_equals("code is 200", code, 200)
      end
    )
end)

test "POST-user-defined-Content-Type" (function()
  do_with_server(
      make_wsapi_tcp_server_loop(
          function()
            return function(env)
              local request = wsapi.request.new(env)
              if request.env.CONTENT_TYPE == "my-type" then
                local response = wsapi.response.new(200, { })
                return response:finish()
              else
                local response = wsapi.response.new(500, { })
                return response:finish()
              end
            end
          end
        ),
      function(host, port, server_pid)
        wait_for_xavante_start(host, port)

        local request =
        {
          url = "http://" .. host .. ":" .. port .. "/";
          method = "POST";
          request_body = "value=test";
          headers =
          {
            ["Content-Type"] = "my-type";
          };
        }
        local body, code = send_http_request(request)
        ensure_equals("code is 200", code, 200)
        local body, code = common_send_http_request(request)
        ensure_equals("code is 200", code, 200)
      end
    )
end)

test "send_http_request-cookie-processing" (function()

  do_with_server(
      make_wsapi_tcp_server_loop(
          function()
            return function(env)
              local request = wsapi.request.new(env)
              if request.env.CONTENT_TYPE == "application/x-www-form-urlencoded" then
                local request_cookie_value = request.cookies["foo"]
                local response = wsapi.response.new(200, { })
                if request_cookie_value then
                  response:set_cookie("foo", request_cookie_value)
                end
                return response:finish()
              else
                local response = wsapi.response.new(500, { })
                return response:finish()
              end
            end
          end
        ),
      function(host, port, server_pid)
        wait_for_xavante_start(host, port)

        local request =
        {
          url = "http://" .. host .. ":" .. port .. "/";
          method = "POST";
          request_body = "value=test";
          headers =
          {
            ["cookie"] = "foo=42;domain=example.com";
          };
        }
        local body, code, response_headers = send_http_request(request)
        ensure_equals("response OK", code, 200)
        ensure_equals("cookie foo is correct", response_headers["set-cookie"], "foo=42")
        local body, code, response_headers = common_send_http_request(request)
        ensure_equals("response OK", code, 200)
        ensure_equals("cookie foo is correct", response_headers["set-cookie"], "foo=42")
      end
    )
end)

test:UNTESTED "common_send_http_request"
test:UNTESTED "send_http_request"
test:UNTESTED "is_http_error_code"
