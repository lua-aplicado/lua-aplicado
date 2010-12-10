--------------------------------------------------------------------------------
-- git.lua: dumb ad-hoc code to work with git
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
      shell_read
      = import 'lua-aplicado/shell.lua'
      {
        'shell_exec',
        'shell_read'
      }

--------------------------------------------------------------------------------

local git_format_command = function(path, command, ...)
  return
    "cd", path,
    "&&", "git", command, ...
end

local git_exec = function(path, command, ...)
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
  -- TODO: ?! This gives false positives (or does it?)
  --[[
  assert(git_exec(
      path, "update-index", "-q", "--refresh"
    ) == 0)
  --]]
  git_read(path, "status")
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
      "rev-list", "--left-right", lhs_branch .. "..." .. rhs_branch, "--", filename
    ) ~= 0 -- TODO: Hack
end

-- TODO: Check that directory is inside git repo
local git_add_directory = function(path, dir)
  assert(git_exec(
      path, "add", dir .. "/"
    ) == 0)
end

local git_commit_with_editable_message = function(path, message)
  assert(git_exec(
      path, "commit", "--edit", "-m", message
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
  git_push_all = git_push_all;
  git_is_directory_dirty = git_is_directory_dirty;
}
