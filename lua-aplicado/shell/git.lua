--------------------------------------------------------------------------------
-- git.lua: dumb ad-hoc code to work with git
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local assert, 
      error
    = assert,
      error

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

local assert_is_table,
      assert_is_nil
      = import 'lua-nucleo/typeassert.lua'
      {
        'assert_is_table',
        'assert_is_nil'
      }

local split_by_char,
      trim
      = import 'lua-nucleo/string.lua'
      {
        'split_by_char',
        'trim'
      }

local shell_exec,
      shell_read
      = import 'lua-aplicado/shell.lua'
      {
        'shell_exec',
        'shell_read'
      }

local is_email_exist = false

--------------------------------------------------------------------------------

local git_format_command = function(path, command, ...)
  return
    "cd", path,
    "&&", "git", command, ...
end

local git_exec = function(path, command, ...)
  if not is_email_exist then
    if
      shell_exec(git_format_command(path, "config", '--local', '--get', 'user.email')) == 0 or
      shell_exec(git_format_command(path, "config", '--global', '--get', 'user.email')) == 0
    then
      is_email_exist = true
    else
      error('git GLOBAL or LOCAL user.email must be specified')
    end
  end

  return shell_exec(git_format_command(path, command, ...))
end

local git_read = function(path, command, ...)
  return shell_read(git_format_command(path, command, ...))
end

local git_get_tracking_branch_name_of_HEAD = function(path)
  -- Will work only on recent Git versions
  -- TODO: This spams into stderr too loud if branch has no remotes
  local full_name = git_read(path, "rev-parse", "--symbolic-full-name", "@{u}")
  return full_name:match("^refs/remotes/(.-)%s*$") -- May be nil.
end

local git_update_index = function(path)
  assert(git_exec(
      path, "update-index", "-q", "--refresh"
    ) == 0)

  -- TODO: HACK! Remove when Git is fixed.
  -- http://thread.gmane.org/gmane.comp.version-control.git/164216
  require('socket').sleep(0.5)
end

-- WARNING: needs git_update_index()!
local git_is_dirty = function(path)
  return git_exec(
      path, "diff-index", "--exit-code", "--quiet", "HEAD"
    ) ~= 0
end

-- WARNING: needs git_update_index()!
local git_has_untracked_files = function(path)
  return #git_read(
      path, "ls-files", "--exclude-standard", "--others"
    ) ~= 0 -- TODO: Hack
end

local git_are_branches_different = function(path, lhs_branch, rhs_branch)
  return #git_read(
      path,
      "rev-list", "--left-right", lhs_branch .. "..." .. rhs_branch
    ) ~= 0 -- TODO: Hack
end

local git_is_file_changed_between_revisions = function(
    path,
    filename,
    lhs_branch,
    rhs_branch
  )
  return #git_read(
      path,
      "rev-list",
      "--left-right",
      lhs_branch .. "..." .. rhs_branch,
      "--",
      filename
    ) ~= 0 -- TODO: Hack
end

local git_add_path = function(path, path_to_add)
  assert(git_exec(
      path, "add", path_to_add
    ) == 0)
end

local git_add_directory = function(path, dir)
  git_add_path(path, dir .. "/")
end

local git_commit_with_editable_message = function(path, message)
  assert(git_exec(
      path, "commit", "--edit", "-m", message
    ) == 0)
end

local git_commit_with_message = function(path, message)
  assert(git_exec(
      path, "commit", "-m", message
    ) == 0)
end

local git_push_all = function(path)
  assert(git_exec(
      path, "push", "--all"
    ) == 0)
end

local git_is_directory_dirty = function(path, directory)
  return git_exec(
      path, "diff-index", "--exit-code", "--quiet", "HEAD", "--", directory
   ) ~= 0
end

local git_get_remote_url = function(path, remote_name)
  local url = git_read(
      path, "ls-remote", "--get-url", remote_name
    )
  if not url then
    return false -- Assuming remote is not found.
  end

  url = trim(url)
  if url == remote_name then
    return false -- git ls-remote returns remote name if remote is not found
  end

  return url
end

-- DEPRECATED! Does not support section names with '.'.
--             Use plumbing commands whenever possible instead!
-- Note that this function intentionally does not try to do any value coersion.
-- Every leaf value is a string.
local git_load_config = function(path)
  local config_str = git_read(path, "config", "--list")

  local result = { }

  for line in config_str:gmatch("(.-)\n") do
    local name, value = line:match("^(.-)=(.*)$")

    local val = result

    local keys = split_by_char(name, ".")
    for i = 1, #keys - 1 do
      local key = keys[i]

      assert_is_table(val)
      if val[key] == nil then
        local t = { }
        val[key] = t
      end
      val = val[key]
    end

    -- Note that the same value can be overridden several times in config
    -- This seems to be OK
    val[keys[#keys]] = value
  end

  return result
end

-- DEPRECATED! Does not support '.' in remote names.
-- Returns false if remote not found
local git_config_get_remote_url = function(git_config, remote_name)
  arguments(
      "table", git_config,
      "string", remote_name
    )

  local remotes = git_config.remote
  if not remotes then
    return false
  end

  local remote = remotes[remote_name]
  if not remote then
    return false
  end

  return remote.url or false
end

local git_remote_rm = function(path, remote_name)
  assert(git_exec(
      path, "remote", "rm", remote_name
    ) == 0)
end

local git_remote_add = function(path, remote_name, url, fetch)
  if fetch then
    assert(git_exec(
        path, "remote", "add", "-f", remote_name, url
      ) == 0)
  else
    assert(git_exec(
        path, "remote", "add", remote_name, url
      ) == 0)
  end
end

local git_init_subtree = function(
    path,
    remote_name,
    url,
    branch,
    relative_path,
    commit_message,
    is_interactive
  )
  git_remote_add(path, remote_name, url, true) -- with fetch

  assert(git_exec(
      path, "merge", "-s", "ours", "--no-commit", remote_name .. "/" .. branch
    ) == 0)

  assert(git_exec(
      path, "read-tree", "--prefix="..relative_path,   "-u", remote_name .. "/" .. branch
    ) == 0)

  if is_interactive then
    git_commit_with_editable_message(path, commit_message)
  else
    git_commit_with_message(path, commit_message)
  end
end

local git_pull_subtree = function(
    path,
    remote_name,
    branch,
    relative_path,
    merge_commit_message
  )
  assert(git_exec(
      path, "fetch", remote_name
    ) == 0)
  assert(git_exec(
      path,
      "merge",
      "-s",
      "recursive",
      remote_name .. "/" .. branch,
      "-Xsubtree=" .. relative_path,
      "-Xtheirs",
      merge_commit_message and "-m" or nil,
      merge_commit_message
    ) == 0)
end

-- TODO: Enhance with more options, approve option list with AG
-- https://github.com/lua-aplicado/lua-aplicado/issues/12
local git_init = function(path, bare)
  assert(git_exec(
      path, "init", path, bare and "--bare" or nil
    ) == 0)
end

local git_init_bare = function(path)
  git_init(path, true)
end

-- TODO: Enhance with more options, approve option list with AG
-- https://github.com/lua-aplicado/lua-aplicado/issues/13
local git_clone = function(path, source)
  assert(git_exec(
      path, "clone", source, path
    ) == 0)
end

local git_get_current_branch_name = function(path)
  return trim(git_read(path, "rev-parse", "--abbrev-ref", "HEAD"))
end

local git_get_branch_list = function(path, pattern)
  pattern = pattern or "refs/heads"

  local raw_branch_list = git_read(
      path,
      "for-each-ref",
      "refs/heads/",
      "--format=%(refname:short)"
    )

  return split_by_char(trim(raw_branch_list), "\n")
end

local git_create_branch = function(
    path,
    branchname,
    start_point,
    switch_after_create
  )
  if switch_after_create then
    assert(git_exec(
        path, "checkout", "-b", branchname, start_point
      ) == 0)
  else
    assert(git_exec(
        path, "branch", branchname, start_point
      ) == 0)
  end
end

local git_checkout = function(path, branchname_or_commit)
  assert(git_exec(
      path, "checkout", branchname_or_commit
    ) == 0)
end

local git_get_list_of_staged_files = function(path)
  local raw_filelist = git_read(
    path,
    "ls-files",
    "--cached"
  )

  return split_by_char(trim(raw_filelist), "\n")
end

--------------------------------------------------------------------------------

return
{
  git_format_command = git_format_command;
  git_exec = git_exec;
  git_read = git_read;
  git_get_tracking_branch_name_of_HEAD = git_get_tracking_branch_name_of_HEAD;
  git_update_index = git_update_index;
  git_is_dirty = git_is_dirty;
  git_has_untracked_files = git_has_untracked_files;
  git_are_branches_different = git_are_branches_different;
  git_is_file_changed_between_revisions = git_is_file_changed_between_revisions;
  git_add_directory = git_add_directory;
  git_commit_with_editable_message = git_commit_with_editable_message;
  git_commit_with_message = git_commit_with_message;
  git_push_all = git_push_all;
  git_is_directory_dirty = git_is_directory_dirty;
  git_load_config = git_load_config;
  git_get_remote_url = git_get_remote_url;
  git_config_get_remote_url = git_config_get_remote_url;
  git_remote_rm = git_remote_rm;
  git_remote_add = git_remote_add;
  git_init_subtree = git_init_subtree;
  git_pull_subtree = git_pull_subtree;
  git_init = git_init;
  git_init_bare = git_init_bare;
  git_clone = git_clone;
  git_get_current_branch_name = git_get_current_branch_name;
  git_get_branch_list = git_get_branch_list;
  git_create_branch = git_create_branch;
  git_checkout = git_checkout;
  git_add_path = git_add_path;
  git_get_list_of_staged_files = git_get_list_of_staged_files;
}
