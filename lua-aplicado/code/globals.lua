--------------------------------------------------------------------------------
-- globals.lua: list of known globals and exports
--------------------------------------------------------------------------------

local LUA51_GLOBALS
      = import 'tools/schema/code/globals/lua5_1.lua'
      {
        'LUA51_GLOBALS'
      }

local LUAJIT2_GLOBALS
      = import 'tools/schema/code/globals/luajit2.lua'
      {
        'LUAJIT2_GLOBALS'
      }

local LUA_NUCLEO_GLOBALS
      = import 'tools/schema/code/globals/lua-nucleo.lua'
      {
        'LUA_NUCLEO_GLOBALS'
      }

--------------------------------------------------------------------------------

return
{
  LUA51_GLOBALS = LUA51_GLOBALS;
  LUAJIT2_GLOBALS = LUAJIT2_GLOBALS;
  LUA_NUCLEO_GLOBALS = LUA_NUCLEO_GLOBALS;
}
