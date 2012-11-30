--------------------------------------------------------------------------------
-- 0020-git.lua: tests for shell git library
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local pairs
    = pairs

local git_init,
      git_init_bare,
      git_add_directory,
      git_commit_with_message,
      git_clone,
      exports
      = import 'lua-aplicado/shell/git.lua'
      {
        'git_init',
        'git_init_bare',
        'git_add_directory',
        'git_commit_with_message',
        'git_clone'
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

local temporary_directory
      = import 'lua-aplicado/testing/decorators.lua'
      {
        'temporary_directory'
      }

local read_file,
      write_file,
      join_path
      = import 'lua-aplicado/filesystem.lua'
      {
        'read_file',
        'write_file',
        'join_path'
      }

local test = (...)("git", exports)

local PROJECT_NAME = "lua-aplicado"

--------------------------------------------------------------------------------
-- TODO: cover with tests all shell/git.lua
-- https://github.com/lua-aplicado/lua-aplicado/issues/18

test:test_for "git_init"
  :with(temporary_directory("tmp_dir", PROJECT_NAME)) (
function(env)
  git_init(env.tmp_dir)
  ensure_equals(
      "git HEAD file content must match expected",
      read_file(join_path(env.tmp_dir, ".git", "HEAD")),
      "ref: refs/heads/master\n"
    )
end)

test:test_for "git_init_bare"
  :with(temporary_directory("tmp_dir", PROJECT_NAME)) (
function(env)
  git_init_bare(env.tmp_dir)
  ensure_equals(
      "git HEAD file content must match expected",
      read_file(join_path(env.tmp_dir, "HEAD")),
      "ref: refs/heads/master\n"
    )
end)

test:test_for "git_clone"
  :with(temporary_directory("source_dir", PROJECT_NAME))
  :with(temporary_directory("destination_dir", PROJECT_NAME)) (
function(env)
  local test_filename = "testfile"
  local test_data = "test data"

  git_init(env.source_dir)
  write_file(join_path(env.source_dir, test_filename), test_data)
  git_add_directory(env.source_dir, ".")
  git_commit_with_message(env.source_dir, "test commit")

  git_clone(env.destination_dir, env.source_dir)

  ensure_equals(
      "data in testfile must match committed in source directory",
      read_file(join_path(env.destination_dir, test_filename)),
      test_data
    )
end)

--------------------------------------------------------------------------------

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
