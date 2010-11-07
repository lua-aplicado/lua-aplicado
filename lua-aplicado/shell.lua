--------------------------------------------------------------------------------
-- shell.lua: dumb ad-hoc code to work with sh-like shell
--------------------------------------------------------------------------------

local assert, error, tostring
    = assert, error, tostring

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

local is_number
      = import 'lua-nucleo/type.lua'
      {
        'is_number'
      }

local tset = import 'lua-nucleo/table-utils.lua' { 'tset' }

--------------------------------------------------------------------------------

local shell_escape -- Allowing shell substitutions to happen
local shell_escape_no_subst
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
    if is_number(s) then
      return assert(tostring(s))
    end

    if s == "" then
      return "''"
    end

    if passthrough[s] then
      return s
    end

    s = s:gsub('"', '\\"')
    if s:find('[^A-Za-z0-9_."/%-]') then
      s = '"' .. s .. '"'
    end

    return s
  end

  -- TODO: Generalize with above
  shell_escape_no_subst = function(s)
    if is_number(s) then
      return assert(tostring(s))
    end

    if s == "" then
      return "''"
    end

    if passthrough[s] then
      return s
    end

    s = s:gsub("'", "\\'")
    if s:find("[^A-Za-z0-9_.'/%-]") then
      s = "'" .. s .. "'"
    end

    return s
  end
end

-- Allowing shell substitutions to happen
local function shell_escape_many(a1, a2, ...)
  if a2 == nil then
    return shell_escape(a1)
  end

  return shell_escape(a1), shell_escape_many(a2, ...)
end

local function shell_escape_many_no_subst(a1, a2, ...)
  if a2 == nil then
    return shell_escape_no_subst(a1)
  end

  return shell_escape_no_subst(a1), shell_escape_many_no_subst(a2, ...)
end

local shell_format_command = function(...)
  return table_concat({ shell_escape_many(...) }, " ") -- TODO: Avoid table creation
end

local shell_format_command_no_subst = function(...)
  return table_concat({ shell_escape_many_no_subst(...) }, " ") -- TODO: Avoid table creation
end

local shell_exec = function(...)
  local cmd = shell_format_command(...)
  print("executing:", cmd)
  return assert(os_execute(cmd))
end

local shell_read = function(...)
  local cmd = shell_format_command(...)
  print("reading:", cmd)
  local f = assert(io_popen(cmd))
  local result = f:read("*a")
  f:close()
  f = nil
  print("READ", "`"..result.."'")
  return result
end

--------------------------------------------------------------------------------

return
{
  shell_escape = shell_escape;
  shell_escape_many = shell_escape_many;
  shell_escape_no_subst = shell_escape_no_subst;
  shell_escape_many_no_subst = shell_escape_many_no_subst;
  shell_format_command = shell_format_command;
  shell_format_command_no_subst = shell_format_command_no_subst;
  shell_exec = shell_exec;
  shell_read = shell_read;
}
