--------------------------------------------------------------------------------
-- 005-domain.lua: domain attribute honored well
-- This file is a part of lua-aplicado library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local make_suite = ...

local ensure,
      ensure_equals,
      ensure_strequals,
      ensure_tdeepequals
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_strequals',
        'ensure_tdeepequals'
      }

local make_cookie_jar,
      exports
      = import 'lua-aplicado/web/cookie_jar.lua'
      {
        'make_cookie_jar'
      }

--------------------------------------------------------------------------------

local test = make_suite('domain', exports)

--------------------------------------------------------------------------------

test:factory('make_cookie_jar', make_cookie_jar)

--------------------------------------------------------------------------------

test 'domain attribute' (function()

  local c = make_cookie_jar()

  -- domain attribute doesn't match request URL
  c:update(
[[
, foo=1;expires=Mon, 2013 ;path= /;domain=a.b.c,
 bar = 2;expires = 2013 1:2:3 GMT;max-AGE=0   ;secure ;HTTPonlY;domain=a.q.w.e;path=-,
   baz=  3;;domain=.e:8080;httpONLy ;expires=,,,
]], 'https://q.w.e:8080/a/b'
    )
  ensure_tdeepequals(
      'mismatch in domain invalidates cookies',
      c:get_all(),
      { }
    )

  -- domain attribute looks like dot-decimal IPv4
  c:update('foo=1;domain=1.2.3.4', 'http://2.3.4/')
  ensure_tdeepequals('domain-match rejects IPv4', c:get_all(), { })

  -- domain attribute looks like IP, but literally equal to host
  c:update('foo=1;domain=1.2.3.4', 'http://1.2.3.4/')
  ensure_tdeepequals(
      'domain-match allows exact match of IPv4',
      c:get_all(),
      {
        { value = '1', path = '/', name = 'foo', domain = '1.2.3.4' }
      }
    )

end)

--------------------------------------------------------------------------------

assert(test:run())
