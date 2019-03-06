--------------------------------------------------------------------------------
-- error.lua: error handling convenience wrapper
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

--This module is deprecated. Use lua-nucleo/error.lua instead

local call,
      try,
      fail,
      rethrow,
      xfinally,
      xcall,
      create_error_object,
      is_error_object,
      error_handler_for_call
      = import 'lua-nucleo/error.lua'
      {
        'call',
        'try',
        'fail',
        'rethrow',
        'xfinally',
        'xcall',
        'create_error_object',
        'is_error_object',
        'error_handler_for_call'
      }

return
{
  call = call;
  try = try;
  fail = fail;
  rethrow = rethrow;
  xfinally = xfinally;
  xcall = xcall;
  -- semi-public, for unit tests
  create_error_object = create_error_object;
  is_error_object = is_error_object;
  error_handler_for_call = error_handler_for_call;
  PK_META = { alias_of_module = 'lua-nucleo/error.lua' }
}
