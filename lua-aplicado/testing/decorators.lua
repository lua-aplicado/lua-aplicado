--------------------------------------------------------------------------------
-- decorators.lua: testing decorators
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local bind_many
      = import 'lua-nucleo/functional.lua'
      {
        'bind_many'
      }

local arguments,
      optional_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments'
      }

local ensure
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure'
      }

local xfinally
      = import 'lua-aplicado/error.lua'
      {
        'xfinally'
      }

local rm_tree,
      join_path,
      create_temporary_directory
      = import 'lua-aplicado/filesystem.lua'
      {
        'rm_tree',
        'join_path',
        'create_temporary_directory'
      }

--------------------------------------------------------------------------------

--- Create test decorator, which create temporary directory with auto cleanup
-- @param variable directory
-- @return decorator
local temporary_directory = function(variable, prefix, tmpdir)
  arguments(
      "string", variable,
      "string", prefix
    )
  optional_arguments("string", tmpdir)

  return function(test_function)
    return function(env)
      local created_tmpdir = ensure(
          "temporary directory was created",
          create_temporary_directory(prefix, tmpdir)
        )
      env[variable] = created_tmpdir
      return xfinally(
          bind_many(test_function, env),
          function()
            ensure(
                "temporary directory removed",
                rm_tree(created_tmpdir)
              )

            -- cleanup environment, because directory no longer exists.
            env[variable] = nil
          end
        )
    end
  end
end

--------------------------------------------------------------------------------

return
{
  temporary_directory = temporary_directory;
}
