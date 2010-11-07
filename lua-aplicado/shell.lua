--------------------------------------------------------------------------------
-- shell.lua: dumb ad-hoc code to work with sh-like shell
--------------------------------------------------------------------------------

local assert, error
    = assert, error

local table_concat = table.concat

local os_execute = os.execute

local io_popen = io.popen

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

local tset = import 'lua-nucleo/table-utils.lua' { 'tset' }

--------------------------------------------------------------------------------

local shell_escape
do
  local passthrough = tset
  {
    "&&", "||";
    "(", ")";
    "{", "}";
    ">", ">>";
    "<", "<<";
  }

  shell_escape = function(s)
    if s == "" then
      return "''"
    end

    if passthrough[s] then
      return s
    end

    s = s:gsub('"', '\\"')
    if s:find('[^A-Za-z0-9_."/%-]') then
      s = '"' .. s .. '"' -- Allowing shell substitutions to happen
    end

    return s
  end
end

local function shell_escape_many(a1, a2, ...)
  if a2 == nil then
    return a1
  end

  return a1, shell_escape_many(a2, ...)
end

local shell_format_command = function(...)
  return table_concat({ shell_escape_many(...) }, " ") -- TODO: Avoid table creation
end

local shell_exec = function(...)
  local cmd = shell_format_command(...)
  -- print("executing:", cmd)
  return assert(os_execute(cmd))
end

local shell_read = function(...)
  local cmd = shell_format_command(...)
  -- print("reading:", cmd)
  local f = assert(io_popen(cmd))
  local result = f:read("*a")
  f:close()
  f = nil
  -- print("READ", "`"..result.."'")
  return result
end

--------------------------------------------------------------------------------

return
{
  shell_escape = shell_escape;
  shell_escape_many = shell_escape_many;
  shell_format_command = shell_format_command;
  shell_exec = shell_exec;
  shell_read = shell_read;
}
