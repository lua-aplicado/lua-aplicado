--------------------------------------------------------------------------------
-- fork.lua: wrapper around posix.fork()
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local posix = require 'posix'
local posix_fork = (posix.fork or posix.unistd.fork)
--------------------------------------------------------------------------------

local optional_arguments
      = import 'lua-nucleo/args.lua'
      {
        'optional_arguments',
      }

--------------------------------------------------------------------------------

local fork
local atfork
do
  local prepare_callbacks = {}
  local parent_callbacks = {}
  local child_callbacks = {}

  --- Call posix.fork() and all registered callbacks
  -- @return Returns whatever posix.fork() returns
  -- @see http://luaposix.github.io/luaposix/docs/index.html#fork
  fork = function()
    for i = 1, #prepare_callbacks do
      prepare_callbacks[i]()
    end
    local cpid = posix_fork()
    if cpid > 0 then
      for j = 1, #parent_callbacks do
        parent_callbacks[j]()
      end
    else
      for k = 1, #child_callbacks do
        child_callbacks[k]()
      end
    end
    return cpid
  end

  --- Register callbacks to be executed when fork() is called
  -- @param on_prepare (optional) Callback to be called before fork()
  -- @param on_parent (optional) Callback to be called after fork() in parent
  -- process
  -- @param on_child (optional) Callback to be called after fork() in child
  -- process
  atfork = function(on_prepare, on_parent, on_child)
    optional_arguments(
        "function", on_prepare,
        "function", on_parent,
        "function", on_child
      )
    prepare_callbacks[#prepare_callbacks + 1] = on_prepare
    parent_callbacks[#parent_callbacks + 1] = on_parent
    child_callbacks[#child_callbacks + 1] = on_child
  end
end

--------------------------------------------------------------------------------

return
{
  fork = fork;
  atfork = atfork;
}
