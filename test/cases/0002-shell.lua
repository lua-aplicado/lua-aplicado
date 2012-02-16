--------------------------------------------------------------------------------
-- 0002-shell.lua: tests for shell piping
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local make_suite = ...

--------------------------------------------------------------------------------

local shell_read,
      shell_write,
      shell_exec,
      exports
      = import 'lua-aplicado/shell.lua'
      {
        'shell_read',
        'shell_write',
        'shell_exec'
      }

local ensure,
      ensure_equals,
      ensure_strequals,
      ensure_error,
      ensure_fails_with_substring
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_strequals',
        'ensure_error',
        'ensure_fails_with_substring'
      }

local test = make_suite("shell", exports)

test:test_for "shell_read" (function()
    ensure_strequals(
        "plain read",
        shell_read("/bin/echo", "foobar"),
        "foobar\n"
      )
    ensure_equals("empty read", shell_read("/bin/true"), "")
    ensure_fails_with_substring(
        "false read",
        (function()
            shell_read("/bin/false")
        end),
        "command `/bin/false' stopped with rc==1"
      )
end)

--------------------------------------------------------------------------------

test:tests_for "shell_write"
test:case "exit_0" (function ()
  shell_write("exit 0\n", "/bin/sh")
end)

-- this test different from "exit 0" by miss newline after command
test:case "closing_handle" (function ()
  shell_write("exit 0", "/bin/sh")
end)

test:case "various_exit_codes" (function ()
  for code = 1, 2 do
    ensure_fails_with_substring(
      "failed rc "..code,
      (function()
        shell_write("exit " .. code .. "\n", "/bin/sh")
      end),
     "command `/bin/sh' stopped with rc=="..code
    )
  end
end)

--------------------------------------------------------------------------------

test:test_for "shell_exec" (function ()
    ensure_equals("/bin/true", 0, shell_exec("/bin/true"))
    local rc = shell_exec("/bin/false")
    ensure("/bin/false", rc ~= 0)
end)

--------------------------------------------------------------------------------

-- shell_wait covered by tests shell_read and shell_write
test:UNTESTED "shell_wait"

-- shell_write_async covered by shell_write
test:UNTESTED "shell_write_async"
test:UNTESTED "shell_write_async_no_subst"
test:UNTESTED "shell_write_no_subst"

test:UNTESTED "shell_format_command_no_subst"
test:UNTESTED "shell_escape_many"
test:UNTESTED "shell_escape_no_subst"
test:UNTESTED "shell_exec_no_subst"
test:UNTESTED "shell_escape"
test:UNTESTED "shell_format_command"
test:UNTESTED "shell_read_no_subst"
test:UNTESTED "shell_escape_many_no_subst"

test:run()
