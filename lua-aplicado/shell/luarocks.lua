--------------------------------------------------------------------------------
-- shell/luarocks.lua: dumb ad-hoc code to work with luarocks
--------------------------------------------------------------------------------

local assert, loadfile
    = assert, loadfile

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

local tkeys
      = import 'lua-nucleo/table-utils.lua'
      {
        'tkeys'
      }

local do_in_environment
      = import 'lua-nucleo/sandbox.lua'
      {
        'do_in_environment'
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

local luarocks_exec = function(...)
  return shell_exec("sudo", "luarocks", ...)
end

local luarocks_exec_no_sudo = function(...)
  return shell_exec("luarocks", ...)
end

local luarocks_exec_dir = function(dir, ...)
  return shell_exec(
      "cd", dir,
      "&&", "sudo", "luarocks", ...
    )
end

local luarocks_exec_dir_no_sudo = function(dir, ...)
  return shell_exec(
      "cd", dir,
      "&&", "luarocks", ...
    )
end

local luarocks_admin_exec_dir = function(dir, ...)
  return shell_exec(
      "cd", dir,
      "&&", "luarocks-admin", ...
    )
end

local luarocks_remove_forced = function(rock_name)
  assert(luarocks_exec(
      "remove", "--force", rock_name
    ) == 0)
end

local luarocks_ensure_rock_not_installed_forced = function(rock_name)
  luarocks_exec(
      "remove", "--force", rock_name
    ) -- Ignoring errors
end

local luarocks_make_in = function(rockspec_filename, path)
  assert(luarocks_exec_dir(
      path, "make", rockspec_filename
    ) == 0)
end

local luarocks_pack_to = function(rock_name, rocks_repo_path)
  assert(luarocks_exec_dir_no_sudo(
      rocks_repo_path, "pack", rock_name
    ) == 0)
end

local luarocks_admin_make_manifest = function(rocks_repo_path)
  assert(luarocks_admin_exec_dir(
      rocks_repo_path, "make-manifest", "."
    ) == 0)
end

local luarocks_load_manifest = function(filename)
  local manifest_chunk = assert(loadfile(filename))

  local env = { }
  local ok, result = assert(
      do_in_environment(
          manifest_chunk,
          env
        )
    )
  assert(result == nil)

  return env
end

local luarocks_get_rocknames_in_manifest = function(filename)
  return tkeys(assert(luarocks_load_manifest(filename).repository))
end

local luarocks_install_from = function(rock_name, rocks_repo)
  assert(shell_exec(
      "sudo", "luarocks", "install", rock_name, "--only-from="..rocks_repo
    ) == 0)
end

local luarocks_parse_installed_rocks = function(list_str)
  local installed_rocks_set, duplicate_rocks_set = { }, { }

  local mode = "installed_rocks"

  local rock_name
  for line in list_str:gmatch("(.-)\n") do
    line:gsub("%s+$", ""):gsub("^%s+", "") -- Trim line

    -- log("luarocks list:", line)

    if mode == "installed_rocks" then
      if line == "" then -- skip initial newlines
        mode = "installed_rocks"
      else
        assert(line == "Installed rocks:")
        mode = "dashed_line"
      end
    elseif mode == "dashed_line" then
      assert(line == "----------------")
      mode = "empty_line"
    elseif mode == "empty_line" then
      assert(line == "")
      mode = "rock_name"
    elseif mode == "rock_name" then
      assert(line:sub(1, 1) ~= " ")
      rock_name = line
      installed_rocks_set[rock_name] = true
      mode = "rock_version_first"
    elseif mode == "rock_version_first" then
      assert(line:sub(1, 1) == " ")
      mode = "duplicate_rock_version_or_empty_line"
    elseif mode == "duplicate_rock_version_or_empty_line" then
      if line == "" then
        rock_name = nil
        mode = "rock_name"
      else
        duplicate_rocks_set[assert(rock_name)] = true
        assert(line:sub(1, 1) == " ")
        mode = "duplicate_rock_version_or_empty_line"
      end
    end
  end

  return installed_rocks_set, duplicate_rocks_set
end

--------------------------------------------------------------------------------

return
{
  luarocks_exec = luarocks_exec;
  luarocks_exec_no_sudo = luarocks_exec_no_sudo;
  luarocks_exec_dir = luarocks_exec_dir;
  luarocks_admin_exec_dir = luarocks_admin_exec_dir;
  luarocks_remove_forced = luarocks_remove_forced;
  luarocks_ensure_rock_not_installed_forced = luarocks_ensure_rock_not_installed_forced;
  luarocks_make_in = luarocks_make_in;
  luarocks_exec_dir_no_sudo = luarocks_exec_dir_no_sudo;
  luarocks_pack_to = luarocks_pack_to;
  luarocks_admin_make_manifest = luarocks_admin_make_manifest;
  luarocks_load_manifest = luarocks_load_manifest;
  luarocks_get_rocknames_in_manifest = luarocks_get_rocknames_in_manifest;
  luarocks_install_from = luarocks_install_from;
  luarocks_parse_installed_rocks = luarocks_parse_installed_rocks;
}
