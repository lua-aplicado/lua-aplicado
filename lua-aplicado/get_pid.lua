--------------------------------------------------------------------------------
-- get_pid.lua: wrapper for posix.getpid. For compatibility posix 30-1 and 34.0.1
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

require 'posix'
local posix_getpid = (posix.getpid or posix.unistd.getpid)



local function get_pid()
  if posix.getpid then
    return posix_getpid("pid")
  else
    return posix_getpid()
  end
end
-------------------------------------------------------------------------------

return
{
  get_pid = get_pid;
}
