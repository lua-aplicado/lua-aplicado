--------------------------------------------------------------------------------
-- test/cases/0100-process.lua: tests for process.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local socket = require 'socket'

local ensure,
      ensure_equals,
      ensure_returns,
      ensure_error
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_returns',
        'ensure_error'
      }

local epsilon_equals
      = import 'lua-nucleo/math.lua'
      {
        'epsilon_equals'
      }

local retry_n_times,
      exports
      = import 'lua-aplicado/process.lua'
      {
        'retry_n_times'
      }

--------------------------------------------------------------------------------

local log, dbg, spam, log_error
      = import 'lua-aplicado/log.lua' { 'make_loggers' } (
          "test/process", "T100"
      )

--------------------------------------------------------------------------------

local test = (...)("process", exports)

--------------------------------------------------------------------------------

test:tests_for "retry_n_times"

test:case "retry_works" (function()
  local tries = 0
  local attempts = 10
  local on_attempt = 5
  local timeout = 0.1
  local value = 42

  local test_func = function()
    tries = tries + 1
    if tries == on_attempt then
      return value
    else
      return nil, "wait more"
    end
  end

  ensure_returns(
      "retry_n_times works",
      1,
      { value },
      retry_n_times(
          test_func,
          attempts,
          timeout
        )
    )
  ensure_equals("retry counts", tries, on_attempt)
end)

test:case "retry_limits" (function()
  local tries = 0
  local attempts = 10
  local sleep_time = 0.1
  local msg = "really not works"
  local not_working_func = function()
    tries = tries + 1
    return nil
  end

  local before = socket.gettime()
  ensure_error(
      "retry limits works",
      msg,
      retry_n_times(not_working_func, attempts, sleep_time, msg)
    )
  local after = socket.gettime()

  ensure_equals("tries", tries, attempts)
  ensure(
      "timeout",
      epsilon_equals(
          after - before,
          (attempts - 1) * sleep_time, -- we not sleep on first attempt
          0.009
        )
    )
end)
