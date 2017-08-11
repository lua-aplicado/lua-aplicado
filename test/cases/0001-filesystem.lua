--------------------------------------------------------------------------------
-- 0001-filesystem.lua: tests for file system
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local socket = require 'socket'
require 'posix'
local posix_strftime, posix_gmtime, posix_link, posix_time =
      (posix.strftime or posix.time.strftime), (posix.gmtime or posix.time.gmtime), (posix.link or posix.unistd.link), ((type(posix.time)=="function" and posix.time) or posix.time.time)
--------------------------------------------------------------------------------

local arguments,
      method_arguments,
      optional_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'method_arguments',
        'optional_arguments'
      }

local ensure,
      ensure_is,
      ensure_equals,
      ensure_strequals,
      ensure_tequals,
      ensure_error,
      ensure_aposteriori_probability,
      ensure_fails_with_substring,
      ensure_error_with_substring
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_is',
        'ensure_equals',
        'ensure_strequals',
        'ensure_tequals',
        'ensure_error',
        'ensure_aposteriori_probability',
        'ensure_fails_with_substring',
        'ensure_error_with_substring',
      }

local starts_with,
      ends_with
      = import 'lua-nucleo/string.lua'
      {
        'starts_with',
        'ends_with',
      }

local assert_is_string
      = import 'lua-nucleo/typeassert.lua'
      {
        'assert_is_string'
      }

local temporary_directory
      = import 'lua-aplicado/testing/decorators.lua'
      {
        'temporary_directory'
      }

local find_all_files,
      write_file,
      read_file,
      update_file,
      create_path_to_file,
      do_atomic_op_with_file,
      join_path,
      normalize_path,
      rm_tree,
      does_file_exist,
      create_temporary_directory,
      get_filename_from_path,
      is_directory,
      load_all_files,
      load_all_files_with_curly_placeholders,
      exports
      = import 'lua-aplicado/filesystem.lua'
      {
        'find_all_files',
        'write_file',
        'read_file',
        'update_file',
        'create_path_to_file',
        'do_atomic_op_with_file',
        'join_path',
        'normalize_path',
        'rm_tree',
        'does_file_exist',
        'create_temporary_directory',
        'get_filename_from_path',
        'is_directory',
        'load_all_files',
        'load_all_files_with_curly_placeholders',
      }

local get_pid
      = import 'lua-aplicado/get_pid.lua'
      {
        'get_pid',
      }

--------------------------------------------------------------------------------

local test = (...)("filesystem", exports)

--------------------------------------------------------------------------------

local register_temp_file
do
  local files_to_be_removed = {}

  register_temp_file = function(filename)
    os.remove(filename)
    files_to_be_removed[#files_to_be_removed + 1] = filename
    return filename
  end

  test:tear_down(function()
    for i = 1, #files_to_be_removed do
      os.remove(files_to_be_removed[i])
    end
  end)
end

-- Helper: Creates list of empty temporary files in temporary directory.
-- Returns path to temporary directory
local function create_tmp_files(filenames_table, tmp_dir)
  for _, filename in pairs(filenames_table) do
    local test_file_name = register_temp_file(join_path(tmp_dir, filename))
    create_path_to_file(test_file_name)
    write_file(test_file_name, "")
  end
end

-- Helper: Creates symlink in temporary directory.
local function create_tmp_symlink(target, link, tmp_dir)
  local targetpath = join_path(tmp_dir, target)
  local linkpath = join_path(tmp_dir, link)
  register_temp_file(linkpath)
  posix_link(targetpath, linkpath, true)
end
--------------------------------------------------------------------------------

test:group 'do_atomic_op_with_file'

--------------------------------------------------------------------------------

-- TODO: broken, due do_with_server dependency
-- https://github.com/lua-aplicado/lua-aplicado/issues/11
test:BROKEN "update-file-from-2-threads" (function()
  local TEST_FILE_DO_ATOMIC = register_temp_file("./data/test_do_atomic")

  local make_callback = function(op_timeout, data)
    arguments(
      "number", op_timeout,
      "string", data
      )

    return function(file)
      socket.sleep(op_timeout)
      return file:write(data)
    end
  end

  local make_file_updater = function(start_timeout, op_timeout, data)
    arguments(
      "number", start_timeout,
      "number", op_timeout,
      "string", data
      )

    return function()
      socket.sleep(start_timeout)
      local res, err = do_atomic_op_with_file(TEST_FILE_DO_ATOMIC, make_callback(op_timeout, data))
      if not res then
        error("worker `" .. data .. "' failed: " .. err)
      end
    end
  end

  local make_file_updater_loops = function()
    local workers = {}

    workers[#workers + 1] = make_file_updater(0,  2, "(worker 1)")
    workers[#workers + 1] = make_file_updater(1,  0, "(worker 2)")

    return workers
  end

  local expected = "(worker 1)(worker 2)"

  do_with_servers(
      make_file_updater_loops(),
      function(pid_list)
        socket.sleep(3)
        local actual = read_file(TEST_FILE_DO_ATOMIC)
        ensure_strequals("file content after atomic ops", actual, expected)
      end
    )
end)

--------------------------------------------------------------------------------

test:test_for "join_path" (function()
  ensure_strequals(
    "regular joininig",
    join_path('A', 'B'),
    'A/B'
    )
  ensure_strequals(
    "multiple joininig",
    join_path('A', 'B', 'C', 'D'),
    'A/B/C/D'
    )
  ensure_strequals(
    "doesn't add extra slashes, if first path ends with slash",
    join_path('A/', 'B/'),
    'A/B/'
    )
  ensure_strequals(
    "doesn't add extra slashes, if second path begins with slash",
    join_path('/A', '/B'),
    '/A/B'
    )
  ensure_strequals(
    "joins 'as is', making no normalization: case /./",
    join_path('./A', './B'),
    './A/./B'
    )
  ensure_strequals(
    "joins 'as is', making no normalization: case /foo/..",
    join_path('A/foo/..', 'foo/../B'),
    'A/foo/../foo/../B'
    )
  ensure_strequals(
    "joins 'as is', making no normalization: case //",
    join_path('A//B/', '/C//D'),
    'A//B//C//D'
    )
end)

--------------------------------------------------------------------------------

test:tests_for "normalize_path"

test:case "normalize_slashes" (function()
  ensure_strequals(
    "normalize //",
    normalize_path('A//B'),
    'A/B'
    )
  ensure_strequals(
    "normalize // in any position",
    normalize_path('//A//B//'),
    '/A/B/'
    )
end)

test:case "normalize_empty_part_of_path" (function()
  ensure_strequals(
    "normalize /./",
    normalize_path('A/./B'),
    'A/B'
    )
  ensure_strequals(
    "normalize /foo/..",
    normalize_path('A/foo/../B'),
    'A/B'
    )
end)

--TODO: https://github.com/lua-aplicado/lua-aplicado/issues/8
test:BROKEN "normalize_empty_part_of_path_in_any_position" (function()
  ensure_strequals(
    "must remove './' in the beginning of a path too",
    normalize_path('./A/B'),
    'A/B'
    )
end)

--------------------------------------------------------------------------------

-- NOTE: Tests for rm_tree doesn't use ":with(tmpdir())" decorator,
--       because it uses rm_tree itself
test:tests_for "rm_tree"

local TEST_DIR = join_path(
    "/tmp",
    "lua-aplicado-0001-" .. get_pid() .. "-" .. posix_strftime('%F-%T', posix_gmtime(posix_time()))
  )

test:case "rm_tree_without_params" (function()
  ensure_fails_with_substring(
      "rm_tree must fail if is called witout params",
      (function()
          rm_tree()
      end),
      "argument #1: expected `string'"
    )
end)

test:case "rm_tree_single_empty_dir" (function()
  -- note, that only path is created in this test-case
  create_path_to_file(join_path(TEST_DIR, "test_file"))

  rm_tree(TEST_DIR)
  ensure(
      "rm_tree deletes single empty directory",
      not does_file_exist(TEST_DIR)
    )
end)

test:case "rm_tree_single_dir_with_files" (function()
  create_tmp_files({ "test_file_1", "test_file_2" }, TEST_DIR)

  rm_tree(TEST_DIR)
  ensure(
      "rm_tree deletes single directory with files",
      not does_file_exist(TEST_DIR)
    )
end)

test:case "rm_tree_full_test" (function()
  local tmp_files_names =
  {
    "test_file_1";
    "1/test_file_1_1";
    "1/test_file_1_2";
    "1/1/test_file_1_1_1";
  }
  create_tmp_files(tmp_files_names, TEST_DIR)

  rm_tree(TEST_DIR)
  ensure(
      "rm_tree full test",
      not does_file_exist(TEST_DIR)
    )
end)

--------------------------------------------------------------------------------

test:tests_for "create_temporary_directory"

test:case "create_temporary_directory_works" (function()
  local prefix = "test-tmpdir"

  -- prepare sandbox
  -- TODO: https://github.com/lua-aplicado/lua-aplicado/issues/17
  --       Write create_path, and avoid this hack with `join_path`
  create_path_to_file(join_path(TEST_DIR, "dummy"))

  local tmpdir = create_temporary_directory(prefix, TEST_DIR)

  ensure_is("create_temporary_directory returns string", tmpdir, "string")
  ensure(
      "create_temporary_directory returns directory",
      does_file_exist(tmpdir)
    )
  ensure(
      "created directory name starts with required prefix",
      starts_with(get_filename_from_path(tmpdir), prefix)
    )

  rm_tree(TEST_DIR)

  -- ensure our temporary dirs was cleaned up
  ensure(
      "rm_tree deletes single directory with files",
      not does_file_exist(TEST_DIR)
    )
end)

--------------------------------------------------------------------------------

test:tests_for "find_all_files"

test:case "find_all_files-with-empty-regexp-returns-everything"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a";
        "b";
        "X/c";
        "X/d";
        "X/Y/e";
        "Z/f";
      },
      env.tmpdir
    )

  -- Using empty regexp; should get all files
  local files = find_all_files(env.tmpdir, "")

  ensure_equals("6 files should be found", #files, 6)
  for i = 1, #files do
    ensure(
        "file is missing in result",
        ends_with(files[i], "/a")
        or ends_with(files[i], "/b")
        or ends_with(files[i], "/X/c")
        or ends_with(files[i], "/X/d")
        or ends_with(files[i], "/X/Y/e")
        or ends_with(files[i], "/Z/f")
      )
  end
end)

test:case "find_all_files-with-wildcard-regexp-returns-everything"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a";
        "b";
        "X/c";
        "X/d";
        "X/Y/e";
        "Z/f";
      },
      env.tmpdir
    )

  -- Using wildcard regexp; should get all files
  local files = find_all_files(env.tmpdir, ".*")

  ensure_equals("6 files should be found", #files, 6)
  for i = 1, #files do
    ensure(
        "file is missing in result",
        ends_with(files[i], "/a")
        or ends_with(files[i], "/b")
        or ends_with(files[i], "/X/c")
        or ends_with(files[i], "/X/d")
        or ends_with(files[i], "/X/Y/e")
        or ends_with(files[i], "/Z/f")
      )
  end
end)

test:case "find_all_files-with-specific-regexp-returns-matching-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a.txt";
        "b";
        "X/c";
        "X/d.txt";
        "X/Y/e";
        "Z/f";
      },
      env.tmpdir
    )

  -- Get all files ending with ".txt"
  local files = find_all_files(env.tmpdir, "%.txt$")

  ensure_equals("2 files should be found", #files, 2)
  for i = 1, #files do
    ensure(
        "file is missing in result",
        ends_with(files[i], "/a.txt")
        or ends_with(files[i], "/X/d.txt")
      )
  end
end)

test:case "find_all_files-with-directory-mode-fails"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a.txt";
        "X.txt/c";
      },
      env.tmpdir
    )

  create_tmp_symlink(
    "a.txt",
    "link.txt",
    env.tmpdir
  )

  ensure_fails_with_substring(
      "fails with directory mode",
      function()
        find_all_files(env.tmpdir, "%.txt", nil, "directory")
      end,
      "assertion failed"
    )
end)

test:case "find_all_files-with-regular-mode-returns-only-matching-regular-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a.txt";
        "B/F/c.txt";
        "X.txt/c";
        "B/d";
      },
      env.tmpdir
    )

  create_tmp_symlink(
    "B/d",
    "link.txt",
    env.tmpdir
  )
  create_tmp_symlink(
    "B/d",
    "B/link2.txt",
    env.tmpdir
  )

  local files = find_all_files(env.tmpdir, "%.txt", {}, "regular")

  ensure_equals("2 files are found", #files, 2)
  for i = 1, #files do
    ensure(
      "link and dirs are missing in result, files are found",
      ends_with(files[i], "/a.txt")
      or ends_with(files[i], "B/F/c.txt")
    )
  end
end)

test:case "find_all_files-with-link-mode-returns-only-matching-links" 
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a.txt";
        "B/F/c.txt";
        "X.txt/c";
        "B/d";
      },
      env.tmpdir
    )

  create_tmp_symlink(
    "B/d",
    "link.txt",
    env.tmpdir
  )
  create_tmp_symlink(
    "B/d",
    "B/link2.txt",
    env.tmpdir
  )

  local files = find_all_files(env.tmpdir, "%.txt", {}, "link")
  ensure_equals("2 links is found", #files, 2)
  for i = 1, #files do
    ensure(
      "files and dirs are missing in result, links are found",
      ends_with(files[i], "/link.txt")
      or ends_with(files[i], "B/link2.txt")
    )
  end
end)

test:case "find_all_files-with-no-mode-returns-matching-links-and-files" 
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "a.txt";
        "B/F/c.txt";
        "X.txt/c";
        "B/d";
      },
      env.tmpdir
    )

  create_tmp_symlink(
    "B/d",
    "link.txt",
    env.tmpdir
  )
  create_tmp_symlink(
    "B/d",
    "B/link2.txt",
    env.tmpdir
  )

  local files = find_all_files(env.tmpdir, "%.txt")
  ensure_equals("2 links and 2 files are found", #files, 4)
  for i = 1, #files do
    ensure(
      "files and links are found",
      ends_with(files[i], "/link.txt")
      or ends_with(files[i], "B/link2.txt")
      or ends_with(files[i], "/a.txt")
      or ends_with(files[i], "B/F/c.txt")
    )
  end
end)

test:case "find_all_files-fails-on-unexisting-path" (
function()
  -- Fail to get files of directory that doesn't exist
  ensure_fails_with_substring(
      "raise error on unexisting path",
      function()
        find_all_files("no/such/directory", "")
      end,
      "No such file or directory"
    )
end)

test:case "find_all_files-with-symlink-to-file-returns-matched-linked-file"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  create_tmp_symlink(
    "files/a.txt",
    "links/link_to_a",
    env.tmpdir
  )

  local files = find_all_files(join_path(env.tmpdir, "links"), "txt")
  ensure_equals("1 file should be found", #files, 1)
  ensure_equals("linked file is found", files[1], join_path(env.tmpdir, "files/a.txt"))
end)

test:case "find_all_files-fails-with-circle-symlink"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "links/b";
      },
      env.tmpdir
    )
  create_tmp_symlink(
    "links/link_to_a.txt",
    "links/link_to_a.txt",
    env.tmpdir
  )

  ensure_fails_with_substring(
      "error with circle symlink",
      function()
        find_all_files(join_path(env.tmpdir, "links"), "txt")
      end,
      "Too many levels of symbolic links"
    )
end)

test:case "find_all_files-with-relative-symlink-to-file-returns-matched-linked-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  register_temp_file(join_path(env.tmpdir, "links/link_to_a"))
  posix_link("../files/a.txt", join_path(env.tmpdir, "links/link_to_a"), true)

  local files = find_all_files(join_path(env.tmpdir, "links"), "txt")
  ensure_equals("1 file should be found", #files, 1)
  ensure_equals("linked file is found", files[1], join_path(env.tmpdir, "files/a.txt"))
end)

test:case "find_all_files-with-relative-symlink-to-dir-returns-matched-linked-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  register_temp_file(join_path(env.tmpdir, "links/link_to_a"))
  posix_link("../files", join_path(env.tmpdir, "links/link_to_a"), true)

  local files = find_all_files(join_path(env.tmpdir, "links"), "txt")
  ensure_equals("1 file should be found", #files, 1)
  ensure_equals("linked file is found", files[1], join_path(env.tmpdir, "files/a.txt"))
end)

test:case "find_all_files-with-symlink-to-file-and-file-in-similar-path-returns-matching-file-twice"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  create_tmp_symlink(
    "files/a.txt",
    "links/link_to_a",
    env.tmpdir
  )

  local files = find_all_files(env.tmpdir, "txt")
  ensure_equals("2 files should be found", #files, 2)
  for i = 1, #files do
    ensure_equals(
      "2 files are found",
      files[i],
      join_path(env.tmpdir, "files/a.txt")
    )
  end
end)

test:case "find_all_files-with-recurcive-symlink-returns-matching-file"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  create_tmp_symlink(
    "files/a.txt",
    "files/link_to_a",
    env.tmpdir
  )

  create_tmp_symlink(
    "files/link_to_a",
    "links/link_to_link",
    env.tmpdir
  )

  local files = find_all_files(join_path(env.tmpdir, "links"), "txt")
  ensure_equals("1 files should be found", #files, 1)
  ensure_equals("file is found", files[1], join_path(env.tmpdir, "files/a.txt"))
end)

test:case "find_all_files-with-symlink-to-dir-returns-matched-files-from-linked-dir"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  create_tmp_symlink(
    "files",
    "links/link_to_dir_with_files",
    env.tmpdir
  )

  local files = find_all_files(join_path(env.tmpdir, "links"), "txt")
  ensure_equals("1 file should be found", #files, 1)
  ensure_equals("file from linked dir is found", files[1], join_path(env.tmpdir, "files/a.txt"))
end)

test:case "find_all_files-fails-with-symlink-to-nonexistent-file"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files(
      {
        "files/a.txt";
        "links/b";
      },
      env.tmpdir
    )
  create_tmp_symlink(
    "files/a.txt",
    "links/link_to_a",
    env.tmpdir
  )
  os.remove(join_path(env.tmpdir, "files/a.txt")) 

  ensure_fails_with_substring(
      "error with circle symlink",
      function()
        find_all_files(join_path(env.tmpdir, "links"), "txt")
      end,
      "No such file or directory"
    )
end)

--------------------------------------------------------------------------------

test:tests_for "update_file"

test:case "update_file-creates-new-file-if-file-does-not-exist"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "_" }, env.tmpdir)
  local bazinga_path = join_path(env.tmpdir, "bazinga.txt")

  -- Write text to a file that doesn't exist
  local res = update_file(bazinga_path, "Lorem ipsum", false)

  ensure("should succeed", res)
  ensure_equals(
      "should save text",
      io.open(bazinga_path):read(),
      "Lorem ipsum"
    )
end)

test:case "update_file-does-nothing-if-writing-same-data-and-not-forced"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "bazinga.txt" }, env.tmpdir)
  local bazinga_path = join_path(env.tmpdir, "bazinga.txt")
  local f = io.open(bazinga_path, "w")
  f:write("Lorem ipsum")
  f:close()

  -- Write same text to the file
  local res = update_file(bazinga_path, "Lorem ipsum", false)

  ensure_equals(
      "file should be skipped",
      res,
      "skipped"
    )
end)

test:case "update_file-complains-if-data-differs-and-not-forced"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "bazinga.txt" }, env.tmpdir)
  local bazinga_path = join_path(env.tmpdir, "bazinga.txt")
  local f = io.open(bazinga_path, "w")
  f:write("Lorem ipsum")
  f:close()

  -- Write new text to the file
  local res, err = update_file(bazinga_path, "Dolor sit amet", false)

  ensure_error_with_substring(
      "should report error",
      "data is changed, refusing to override",
      res,
      err
    )
  ensure_equals(
      "should keep old text",
      io.open(bazinga_path):read(),
      "Lorem ipsum"
    )
end)

test:case "update_file-does-its-job-when-forced"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "bazinga.txt" }, env.tmpdir)
  local bazinga_path = join_path(env.tmpdir, "bazinga.txt")
  local f = io.open(bazinga_path, "w")
  f:write("Lorem ipsum")
  f:close()

  -- Write new text to the file with force=true
  local res = update_file(bazinga_path, "Dolor sit amet", true)

  ensure("should succeed", res)
  ensure_equals(
      "should save new text",
      io.open(bazinga_path):read(),
      "Dolor sit amet"
    )
end)

--------------------------------------------------------------------------------

test:tests_for "create_path_to_file"

test:case "create_path_to_file-creates-subdirectories"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "_" }, env.tmpdir)
  local bazinga_path = join_path(env.tmpdir, "X", "Y", "bazinga")

  -- Create subdirectories X/ and X/Y/
  local res = create_path_to_file(bazinga_path)

  ensure("should succeed", res)
  local f = ensure(
      "possible to create file",
      io.open(bazinga_path, "w")
    )
  f:close()
end)

--------------------------------------------------------------------------------

test:tests_for "is_directory"

test:case "is_directory-tells-files-from-directories"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a", "X/Y/b" }, env.tmpdir)

  ensure(
      "recognize as directory",
      is_directory(join_path(env.tmpdir, "X"))
    )
  ensure(
      "recognize as directory",
      is_directory(join_path(env.tmpdir, "X", "Y"))
    )
  ensure(
      "does not recognize as directory",
      not is_directory(join_path(env.tmpdir, "X", "a"))
    )
  ensure(
      "does not recognize as directory",
      not is_directory(join_path(env.tmpdir, "X", "Y", "b"))
    )
end)

test:case "is_directory-complains-on-unexisting-paths" (function()
  ensure_error_with_substring(
      "report error on unexisting path",
      "", -- mg: Not sure what it should be...
      is_directory("/no/such/path")
    )
end)

--------------------------------------------------------------------------------

test:tests_for "does_file_exist"

test:case "does_file_exist-is-awesome"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a" }, env.tmpdir)

  ensure(
      "true if directory exists",
      does_file_exist(join_path(env.tmpdir, "X"))
    )
  ensure(
      "true if file exists",
      does_file_exist(join_path(env.tmpdir, "X", "a"))
    )
  ensure(
      "false if no such path",
      not does_file_exist("/no/such/path")
    )
end)

--------------------------------------------------------------------------------

test:tests_for "load_all_files"

test:case "load_all_files-loads-existing-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a", "X/b" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a"), "w")
  f:write("return (...) + 1")
  f:close()
  f = io.open(join_path(env.tmpdir, "X", "b"), "w")
  f:write("return '<<' .. (...) .. '>>'")
  f:close()

  -- Compile all files in tmp/
  local chunks = load_all_files(env.tmpdir, '')

  ensure_equals("2 files should be compiled", #chunks, 2)
  ensure_equals("first chunk should be compiled", chunks[1](42), 43)
  ensure_equals("second chunk should be compiled", chunks[2](42), '<<42>>')
end)

test:case "load_all_files-selectively-loads-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a.lua", "X/b.txt" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a.lua"), "w")
  f:write("return (...) + 1")
  f:close()
  f = io.open(join_path(env.tmpdir, "X", "b.txt"), "w")
  f:write("Lorem ipsum")
  f:close()

  -- Compile only .lua files in tmp/
  local chunks = load_all_files(env.tmpdir, '.lua')

  ensure_equals("1 file should be compiled", #chunks, 1)
  ensure_equals("first chunk should be compiled", chunks[1](42), 43)
end)

test:case "load_all_files-complains-on-syntax-errors"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a.lua", "X/b.txt" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a.lua"), "w")
  f:write("return (...) + 1")
  f:close()
  f = io.open(join_path(env.tmpdir, "X", "b.txt"), "w")
  f:write("Lorem ipsum")
  f:close()

  -- Try to compile everything in tmp/, even non lua files
  local chunks, err = load_all_files(env.tmpdir, '')

  ensure_error_with_substring(
      "should report syntax error",
      "'=' expected near 'ipsum'",
      chunks,
      err
    )
end)

test:case "load_all_files-complains-on-no-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a.lua" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a.lua"), "w")
  f:write("return (...) + 1")
  f:close()

  -- It's impossible to compile 0 files
  local chunks, err = load_all_files(env.tmpdir, 'no.such.files')

  ensure_error_with_substring(
      "should report error",
      "no files found",
      chunks,
      err
    )
end)

--------------------------------------------------------------------------------

test:tests_for "load_all_files_with_curly_placeholders"

test:case "load_all_files_with_curly_placeholders-loads-existing-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a", "X/b" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a"), "w")
  f:write("return (...) + ${n}")
  f:close()
  f = io.open(join_path(env.tmpdir, "X", "b"), "w")
  f:write("return '${l}' .. (...) .. '${r}'")
  f:close()

  -- Compile all files in tmp/
  local chunks = load_all_files_with_curly_placeholders(
      env.tmpdir,
      '',
      { n = 1, l = "<<", r = ">>" }
    )

  ensure_equals("2 files should be compiled", #chunks, 2)
  ensure_equals("first chunk should be compiled", chunks[1](42), 43)
  ensure_equals("second chunk should be compiled", chunks[2](42), '<<42>>')
end)

test:case "load_all_files_with_curly_placeholders-selectively-loads-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a.lua", "X/b.txt" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a.lua"), "w")
  f:write("return (...) + ${n}")
  f:close()
  f = io.open(join_path(env.tmpdir, "X", "b.txt"), "w")
  f:write("Lorem ipsum")
  f:close()

  -- Compile only .lua files in tmp/
  local chunks = load_all_files_with_curly_placeholders(
      env.tmpdir,
      '.lua',
      { n = 1 }
    )

  ensure_equals("1 file should be compiled", #chunks, 1)
  ensure_equals("first chunk should be compiled", chunks[1](42), 43)
end)

test:case "load_all_files_with_curly_placeholders-complains-on-syntax-errors"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a.lua", "X/b.txt" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a.lua"), "w")
  f:write("return (...) + ${n}")
  f:close()
  f = io.open(join_path(env.tmpdir, "X", "b.txt"), "w")
  f:write("Lorem ipsum")
  f:close()

  -- Try to compile everything in tmp/, even non lua files
  local chunks, err = load_all_files_with_curly_placeholders(
      env.tmpdir,
      '',
      { n = 1 }
    )

  ensure_error_with_substring(
      "should report syntax error",
      "'=' expected near 'ipsum'",
      chunks,
      err
    )
end)

test:case "load_all_files_with_curly_placeholders-complains-on-no-files"
  :with(temporary_directory("tmpdir", "tmp")) (
function(env)
  create_tmp_files({ "X/a.lua" }, env.tmpdir)
  local f
  f = io.open(join_path(env.tmpdir, "X", "a.lua"), "w")
  f:write("return (...) + ${n}")
  f:close()

  -- It's impossible to compile 0 files
  local chunks, err = load_all_files_with_curly_placeholders(
      env.tmpdir,
      'no.such.files',
      { n = 1 }
    )

  ensure_error_with_substring(
      "should report error",
      "no files found",
      chunks,
      err
    )
end)

--------------------------------------------------------------------------------

test:UNTESTED "write_file"
test:UNTESTED "read_file"
test:UNTESTED "get_filename_from_path"
test:UNTESTED "get_extension"
test:UNTESTED "splitpath"

--------------------------------------------------------------------------------

-- TODO: Add more tests on do_atomic_op_with_file()
-- https://github.com/lua-aplicado/lua-aplicado/issues/10
