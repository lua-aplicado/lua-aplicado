--------------------------------------------------------------------------------
-- common_logging.lua: common logging facilities
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local posix = require 'posix'

--------------------------------------------------------------------------------

local twithdefaults
      = import 'lua-nucleo/table-utils.lua'
      {
        'twithdefaults'
      }

local LOG_LEVEL,
      LOG_FLUSH_MODE,
      FLUSH_SECONDS_DEFAULT,
      wrap_file_sink,
      make_common_logging_config
      = import 'lua-nucleo/log.lua'
      {
        'LOG_LEVEL',
        'LOG_FLUSH_MODE',
        'FLUSH_SECONDS_DEFAULT',
        'wrap_file_sink',
        'make_common_logging_config'
      }

local create_common_logging_system,
      get_current_logsystem_date_microsecond
      = import 'lua-aplicado/log.lua'
      {
        'create_common_logging_system',
        'get_current_logsystem_date_microsecond'
      }

--------------------------------------------------------------------------------

local create_common_stdout_logging
do
  local LOG_LEVEL_CONFIG =
  {
    [LOG_LEVEL.ERROR] = true;
    [LOG_LEVEL.LOG]   = true;
    [LOG_LEVEL.DEBUG] = false;
    [LOG_LEVEL.SPAM]  = false;
  }

  local LOG_MODULE_CONFIG =
  {
    -- Empty; everything is enabled by default.
  }

  local flush_seconds = FLUSH_SECONDS_DEFAULT

  local log_flush_config = LOG_FLUSH_MODE[tostring(os.getenv("PK_LOGFLUSH"))]
    or LOG_FLUSH_MODE.ALWAYS -- Assuming someone wants to read this ASAP.

  local LOGGING_SYSTEM_ID = ""

  create_common_stdout_logging = function(
      log_level_config,
      log_module_config,
      logging_system_id,
      pipe
    )
    log_level_config = log_level_config
      and twithdefaults(log_level_config, LOG_LEVEL_CONFIG)
       or LOG_LEVEL_CONFIG

    log_module_config = log_module_config
      and twithdefaults(log_module_config, LOG_MODULE_CONFIG)
       or LOG_MODULE_CONFIG

    local get_time = function()
      return socket.gettime()
    end

    logging_system_id = logging_system_id or LOGGING_SYSTEM_ID

    pipe = pipe or io.stdout

    create_common_logging_system(
        logging_system_id .. "{"..("%05d"):format(posix.getpid("pid")).."} ",
        wrap_file_sink(pipe),
        make_common_logging_config(
            log_level_config,
            log_module_config,
            log_flush_config,
            flush_seconds
          ),
        get_current_logsystem_date_microsecond,
        nil,
        get_time
      )
  end
end

return
{
  create_common_stdout_logging = create_common_stdout_logging;
}
