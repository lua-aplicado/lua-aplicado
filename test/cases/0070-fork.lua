--------------------------------------------------------------------------------
-- test/cases/0070-fork.lua: tests for fork.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local posix = require 'posix'
local posix_exit, posix_wait = (posix._exit or posix.unistd._exit), (posix.wait or posix.sys.wait.wait)
local ensure,
      ensure_equals
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
      }

local fork,
      atfork,
      exports
      = import 'lua-aplicado/fork.lua'
      {
        'fork',
        'atfork',
      }

--------------------------------------------------------------------------------

local log, dbg, spam, log_error
      = import 'lua-aplicado/log.lua' { 'make_loggers' } (
          "test/fork", "T070"
      )

--------------------------------------------------------------------------------

local test = (...)("fork", exports)

--------------------------------------------------------------------------------

test:tests_for "fork"
test:tests_for "atfork"

test:case "fork-and-atfork-work" (function()
  local x = ""
  local on_prepare = function()
    x = x .. "prepare"
  end
  local on_parent = function()
    x = x .. ",parent"
  end
  local on_child = function()
    x = x .. ",child"
  end
  atfork(on_prepare, on_parent, on_child)
  local cpid = fork()
  if cpid > 0 then
    local _, _, status = posix_wait(cpid)
    ensure_equals("should call right callbacks in child", status, 11)
    ensure_equals("should call right callbacks in parent", x, "prepare,parent")
  else
    if x ~= "prepare,child" then
      posix_exit(10)
    else
      posix_exit(11) -- "These go to eleven"
    end
  end
end)
