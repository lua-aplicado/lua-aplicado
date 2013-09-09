--------------------------------------------------------------------------------
-- test/cases/0090-tools_cli_config.lua: tests for tools_cli_config.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local log, dbg, spam, log_error
      = import 'lua-aplicado/log.lua' { 'make_loggers' } (
         "test/tools_cli_config", "T090"
       )

--------------------------------------------------------------------------------

local get_data_walkers,
      config_dsl_exports
      = import 'lua-aplicado/dsl/config_dsl.lua'
      {
        'get_data_walkers'
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

local arguments,
      optional_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments'
      }

local load_tools_cli_data_schema,
      load_tools_cli_config,
      print_tools_cli_config_usage,
      freeform_table_value,
      tools_cli_config_exports
      = import 'lua-aplicado/dsl/tools_cli_config.lua'
      {
        'load_tools_cli_data_schema',
        'load_tools_cli_config',
        'print_tools_cli_config_usage',
        'freeform_table_value'
      }

--------------------------------------------------------------------------------

local test = (...)("tools_cli_config", tools_cli_config_exports)

--------------------------------------------------------------------------------

local schema = function()
  cfg:root
  {
    cfg:existing_path "PROJECT_PATH";
  }
end

-- very naive, only absense of exceptions tested
test:test_for "load_tools_cli_data_schema" (function ()
  load_tools_cli_data_schema(schema)
end)

test:tests_for "load_tools_cli_config"

-- Based on a real bug scenario:
-- #tmp2056
test:test "loading schema from file file" (function ()
  local EXTRA_HELP = "EXTRA_HELP"
  local CONFIG, ARGS = ensure(
    "load_tools_cli_config",
    load_tools_cli_config(
      function(args)
        return
        {
          PROJECT_PATH = "./";
        }
      end,
      EXTRA_HELP,
      load_tools_cli_data_schema(schema),
      "test/data/project-config",
      nil
    )
  )
end)

-- TODO: write tests
-- #33
test:UNTESTED "print_tools_cli_config_usage"
test:UNTESTED "freeform_table_value"
