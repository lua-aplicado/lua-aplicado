--------------------------------------------------------------------------------
-- remote.lua: dumb ad-hoc code to work with sh-like shells remotely
--------------------------------------------------------------------------------

local assert
    = assert

--------------------------------------------------------------------------------

local arguments,
      optional_arguments,
      method_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments'
      }

local shell_exec,
      shell_read,
      shell_exec_no_subst,
      shell_read_no_subst,
      shell_format_command,
      shell_format_command_no_subst
      = import 'lua-aplicado/shell.lua'
      {
        'shell_exec',
        'shell_read',
        'shell_exec_no_subst',
        'shell_read_no_subst',
        'shell_format_command',
        'shell_format_command_no_subst'
      }

--------------------------------------------------------------------------------

-- TODO: UBERHACK! Detect in caller (or some wrapper) instead!!!
local FORCE_LOCAL_SSH = false
local LOCALHOST = "localhost"

local shell_exec_remote = function(host, ...)
  if not FORCE_LOCAL_SSH and host == LOCALHOST then
    return shell_exec(...)
  end

  return shell_exec_no_subst(
      "ssh", host, shell_format_command(...)
    )
end

local shell_read_remote = function(host, ...)
  if not FORCE_LOCAL_SSH and host == LOCALHOST then
    return shell_read(...)
  end

  return shell_read_no_subst(
      "ssh", host, shell_format_command(...)
    )
end

--------------------------------------------------------------------------------

return
{
  shell_exec_remote = shell_exec_remote;
  shell_read_remote = shell_read_remote;
}
