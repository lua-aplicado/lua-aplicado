--------------------------------------------------------------------------------
-- 0020-git.lua: tests for shell git library
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local pairs
    = pairs

local exports
      = import 'lua-aplicado/shell/git.lua'
      {
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

local starts_with
      = import 'lua-nucleo/string.lua'
      {
        'starts_with'
      }

local test = (...)("git", exports)

local PROJECT_NAME = "lua-aplicado"

--------------------------------------------------------------------------------
-- TODO: cover with tests all shell/git.lua
-- https://github.com/lua-aplicado/lua-aplicado/issues/18

test:UNTESTED "git_format_command"
test:UNTESTED "git_exec"
test:UNTESTED "git_read"
test:UNTESTED "git_get_tracking_branch_name_of_HEAD"
test:UNTESTED "git_update_index"
test:UNTESTED "git_is_dirty"
test:UNTESTED "git_has_untracked_files"
test:UNTESTED "git_are_branches_different"
test:UNTESTED "git_is_file_changed_between_revisions"
test:UNTESTED "git_add_directory"
test:UNTESTED "git_commit_with_editable_message"
test:UNTESTED "git_commit_with_message"
test:UNTESTED "git_push_all"
test:UNTESTED "git_is_directory_dirty"
test:UNTESTED "git_load_config"
test:UNTESTED "git_config_get_remote_url"
test:UNTESTED "git_remote_rm"
test:UNTESTED "git_remote_add"
test:UNTESTED "git_init_subtree"
test:UNTESTED "git_pull_subtree"
