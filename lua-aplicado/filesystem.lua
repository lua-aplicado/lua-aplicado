--------------------------------------------------------------------------------
-- filesystem.lua: basic code to work with files and directories
--------------------------------------------------------------------------------

-- TODO: Use debug.traceback() in do_atomic_op_with_file()?

local lfs = require 'lfs'

--------------------------------------------------------------------------------

local arguments,
      optional_arguments,
      method_arguments,
      eat_true
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments',
        'eat_true'
      }

local split_by_char
      = import 'lua-nucleo/string.lua'
      {
        'split_by_char'
      }

--------------------------------------------------------------------------------

local function find_all_files(path, regexp, dest, mode)
  dest = dest or {}
  mode = mode or false

  assert(mode ~= "directory")

  for filename in lfs.dir(path) do
    if filename ~= "." and filename ~= ".." then
      local filepath = path .. "/" .. filename
      local attr = lfs.attributes(filepath)
      if attr.mode == "directory" then
        find_all_files(filepath, regexp, dest)
      elseif not mode or attr.mode == mode then
        if filename:find(regexp) then
          dest[#dest + 1] = filepath
          -- print("found", filepath)
        end
      end
    end
  end

  return dest
end

local write_file = function(filename, new_data)
  arguments(
      "string", filename,
      "string", new_data
    )

  local file, err = io.open(filename, "w")
  if not file then
    return nil, err
  end

  file:write(new_data)
  file:close()
  file = nil

  return true
end

local read_file = function(filename)
  arguments(
      "string", filename
    )

  local file, err = io.open(filename, "r")
  if not file then
    return nil, err
  end

  local data = file:read("*a")
  file:close()
  file = nil

  return data
end

-- WARNING: Not atomic.
-- Returns "skipped" if data was not changed
local update_file = function(out_filename, new_data, force)
  arguments(
      "string", out_filename,
      "string", new_data,
      "boolean", force
    )

  local skip = false
  if lfs.attributes(out_filename, "mode") then
    local old_data, err = read_file(out_filename)
    if not old_data then
      return nil, err
    end

    skip = (old_data == new_data)
    if not skip and not force then
      return
        nil,
        "data is changed, refusing to override `" .. out_filename .. "'"
    end
  end

  if not skip then
    local res, err = write_file(out_filename, new_data)
    if not res then
      return nil, err
    end

    return true
  end

  return "skipped" -- Not changed
end

--------------------------------------------------------------------------------

local create_path_to_file = function(filename)
  arguments(
      "string", filename
    )

  local path = false
  local dirs = split_by_char(filename, "/")
  for i = 1, #dirs - 1 do
    path = path and (path .. "/" .. dirs[i]) or (dirs[i])
    if path ~= "" and not lfs.attributes(path) then
      local res, err = lfs.mkdir(path)
      if not res then
        return nil, "failed to create directory `" .. path .. "': " .. err
      end
    end
  end

  return true
end

--------------------------------------------------------------------------------

local do_atomic_op_with_file = function(filename, action)
  arguments(
      "string",   filename,
      "function", action
    )

  local res, err

  local file, err = io.open(filename, "a+")
  if not file then
    return nil, "do_atomic_op_with_file, open fails: " .. err
  end

  -- TODO: Very unsafe? Endless loop may occur?
  while not lfs.lock(file, "w") do end

  -- TODO: Do xpcall() instead of pcall()?
  local status
  status, res, err = pcall(action, file)
  if not status or not res then
    lfs.unlock(file)
    if not status then
      err = res
    end
    return nil, "do_atomic_op_with_file, pcall fails: " .. err
  end

  res, err = lfs.unlock(file)
  if not res then
    file:close()
    file = nil
    return nil, "do_atomic_op_with_file, unlock fails: " .. err
  end

  file:close()
  file = nil
  return true
end

--------------------------------------------------------------------------------

return
{
  find_all_files = find_all_files;
  write_file = write_file;
  read_file = read_file;
  update_file = update_file;
  create_path_to_file = create_path_to_file;
  do_atomic_op_with_file = do_atomic_op_with_file;
}
