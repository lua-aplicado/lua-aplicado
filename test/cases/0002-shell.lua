--------------------------------------------------------------------------------
-- 0002-shell-read.lua: tests for shell piping
--------------------------------------------------------------------------------

local make_suite = ...

--------------------------------------------------------------------------------

local shell_read,
      shell_exec,
      exports
      = import 'lua-aplicado/shell.lua'
      {
        'shell_read',
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

test:test_for "shell_exec" (function ()
    ensure_equals("/bin/true", 0, shell_exec("/bin/true"))
    local rc = shell_exec("/bin/false")
    ensure("/bin/false", rc ~= 0)
end)

--------------------------------------------------------------------------------

test:UNTESTED "shell_format_command_no_subst"
test:UNTESTED "shell_escape_many"
test:UNTESTED "shell_escape_no_subst"
test:UNTESTED "shell_exec_no_subst"
test:UNTESTED "shell_escape"
test:UNTESTED "shell_format_command"
test:UNTESTED "shell_read_no_subst"
test:UNTESTED "shell_escape_many_no_subst"

test:run()
