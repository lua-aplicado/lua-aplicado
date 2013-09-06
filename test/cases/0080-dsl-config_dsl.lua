--------------------------------------------------------------------------------
-- test/cases/0080-config_dsl.lua: tests for config_dsl.lua
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local log, dbg, spam, log_error
      = import 'lua-aplicado/log.lua' { 'make_loggers' } (
         "test/config_dsl", "T080"
       )

--------------------------------------------------------------------------------

local get_data_walkers,
      validate_format,
      config_dsl_exports
      = import 'lua-aplicado/dsl/config_dsl.lua'
      {
        'get_data_walkers',
        'validate_format'
      }

local ensure,
      ensure_equals,
      ensure_strequals,
      ensure_error,
      ensure_fails_with_substring,
      ensure_tdeepequals
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_strequals',
        'ensure_error',
        'ensure_fails_with_substring',
        'ensure_tdeepequals'
      }

local arguments,
      optional_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments'
      }

local load_data_walkers,
      load_data_schema
      = import 'lua-nucleo/dsl/walk_data_with_schema.lua'
      {
        'load_data_walkers',
        'load_data_schema'
      }

--------------------------------------------------------------------------------

local test = (...)("config_dsl", config_dsl_exports)

--------------------------------------------------------------------------------
test:group "get_data_walkers"

test:case "good_data" (function()
  local schema = function()
    cfg:root
    {
      cfg:positive_integer "positive_integer";
      cfg:table "table"
      {
        cfg:number "number";
        cfg:optional_number "optional_number";
        cfg:string "string";
        cfg:url "url";
        cfg:boolean "boolean";
        cfg:integer "integer";
        cfg:port "port";
        cfg:optional_string "optional_string";
        cfg:non_empty_string "non_empty_string";
        cfg:host "host";
        cfg:optional_host "optional_host";
        cfg:path "path";
        cfg:optional_path "optional_path";
        cfg:existing_path "existing_path";
        cfg:importable_path "importable_path";
        cfg:enum_value "enum_value"
        {
          values_set =
          {
            ["first_value"] = "A";
            ["second_value"] = "B";
            ["default_value"] = 42;
          }
        };
        cfg:optional_freeform_table "optional_freeform_table";
        cfg:freeform_table "freeform_table";
        cfg:variant "variant"
          {
            variants =
            {
              ["variant1"] =
              {
                -- No parameters
              };

              ["variant2"] =
              {
                cfg:boolean "boolean_value" { default = true }
              };
            }
          };
        cfg:ilist "ilist";
        cfg:non_empty_ilist "non_empty_ilist";
        cfg:node "node";
        cfg:optional_node "optional_node";
      }
    }
  end

  local data =
  {
    ["positive_integer"] = 1;
    ["table"] =
    {
      ["number"] = 1;
      ["optional_number"] = 15;
      ["string"] = "some string";
      ["url"] = "url";
      ["boolean"] = true;
      ["integer"] = 1;
      ["port"] = 50000; -- integer between 1 and 65535
      ["optional_string"] = "optional_string"; --string or nil
      ["non_empty_string"] = "non_empty_string";
      ["host"] = "host";
      ["optional_host"] = "optional_host"; -- host or nil
      ["path"] = "path";
      ["optional_path"] = "optional_path"; -- path or nil
      ["existing_path"] = "/etc/passwd"; -- real path to a file
      -- real path to an importable file
      ["importable_path"] = "lua-aplicado/log.lua";
      ["enum_value"] = "default_value"; -- value must be one of enum table keys
      ["optional_freeform_table"] = { };
      ["freeform_table"]  = { };
      ["variant"] =
      {
        name = "variant2";
        param =
        {
          variant2 =
          {
            boolean_value = false;
          }
        };
      };
      ["ilist"] = { };
      ["non_empty_ilist"] = { 1, 2, 3, 4, 5 };
      ["node"] =
      {
        name = "name";
        value = 42;
      };
      ["optional_node"] = -- node or nil
      {
        name = "name";
        value = 42;
      };
    }
  }

  ensure("good data validate format", validate_format(schema, data))
end)

test:case "bad_data" (function()
  local schema = function()
    cfg:root
    {
      cfg:positive_integer "positive_integer";
    }
  end
  local data =
  {
    ["positive_integer"] = -1;
  }

  -- Do we have better way to check such things?
  local res, err = validate_format(schema, data)
  ensure("invalid data was expected", res == nil)
  ensure("error message does not match: " .. err, string.match(err, '> 0'))
end)

-- Based on real bug scenario
-- #tmp2036
test:case "explicit_default_values" (function()
  local schema = function()
    cfg:root
    {
      cfg:node "foo"
      {
        cfg:node "redis"
        {
          cfg:string "host" { default = "localhost" };
        };
      }
    }
  end
  local data =
  {
    ["foo"] =
    {
      ["redis"] = { }
    }
  }

  local res, err = validate_format(schema, data)
  ensure("explicit default values validate", res, err)
  ensure_strequals(
      "string default value",
      res.foo.redis.host,
      "localhost"
    )
end)

-- Based on real bug scenario
-- #tmp2036
test:case "implicit_node_default_value" (function()
  local schema = function()
    cfg:root
    {
      cfg:node "foo"
      {
        cfg:node "redis";
      }
    }
  end
  local data =
  {
    ["foo"] = { }
  }

  local res, err = validate_format(schema, data)
  ensure("implicit node default value validate", res, err)
  ensure_tdeepequals(
      "implicit node default value",
      res.foo.redis,
      { }
    )
end)

-- Based on real bug scenario
-- #tmp2036
test:case "explicit_node_default_value" (function()
  local schema = function()
    cfg:root
    {
      cfg:node "foo"
      {
        cfg:node "redis"
        {
          default =
          {
            value = "default value";
          }
        }
      }
    }
  end
  local data =
  {
    ["foo"] = { }
  }

  local res, err = validate_format(schema, data)
  ensure("explicit node default value validate", res, err)
  ensure_tdeepequals(
      "explicit node default value",
      res.foo.redis,
      { ["value"] = "default value" }
    )
end)

-- Based on real bug scenario
-- #tmp2036
test:case "different_node_default_values" (function()
  local schema = function()
   cfg:root
   {
     cfg:node "foo-1"
     {
       cfg:string "bar-1" { default = "baz-1" };
     };
     cfg:node "foo-2"
     {
       cfg:string "bar-2" { default = "baz-2" };
     };
   }
  end

  local data =
  {
    ["foo"] = { }
  }

  local res, err = validate_format(schema, data)
  ensure("different node default value validate", res, err)
  ensure("nodes values are different", data["foo-1"] ~= data["foo-2"])
  ensure_equals("check node structure 1", data["foo-1"]["bar-2"], nil)
  ensure_equals("check node structure 2", data["foo-2"]["bar-1"], nil)
end)

--------------------------------------------------------------------------------
-- Tests for optional_node

test:case "optional_node_base" (function()
  local schema = function()
    cfg:root
    {
      cfg:optional_node "node1";
      cfg:optional_node "node2";
    }
  end
  local data =
  {
    ["node1"] = { ["string1"] = "string1" };
  }

  local res, err = validate_format(schema, data)
  ensure("optional node must be node or nil", res, err)
  ensure_tdeepequals(
      "optional node data",
      res.node1,
      { ["string1"] = "string1" }
    )
end)

-- Based on real bug scenario
-- #tmp2295
test:case "optional_node_no_deafults" (function()
  local schema = function()
    cfg:root
    {
      cfg:optional_node "node1";
    }
  end
  local data = { }

  local res = ensure("optional node must be node or nil",
    validate_format(schema, data))
  ensure_equals("optional node has no default value", res["node1"], nil)
end)

-- Based on real bug scenario
-- #tmp2295
test:case "optional_node_with_inner_data" (function()
  local schema = function()
    cfg:root
    {
      cfg:optional_node "node1"
      {
        cfg:string "string1";
      }
    }
  end
  local data = { }

  local res = ensure("optional node data is valid",
    validate_format(schema, data))
  ensure_equals("optional node with inner data", res["node1"], nil)
end)

test:case "cfg_dictionary_good_data" (function()
  local schema = function()
    cfg:root
    {
      cfg:dictionary "outer_dict"
      {
        key = cfg:string();
        value = cfg:node()
        {
          cfg:string "bar";
          cfg:string "baz";
          cfg:dictionary "inner_dict"
          {
            key = cfg:number();
            value = cfg:number();
          }
        };
      };
      cfg:dictionary "complex_key_dict"
      {
        key = cfg:node()
        {
          cfg:ilist "ilist";
          cfg:string "name";
          cfg:node "inner_node"
          {
            cfg:number "num";
            cfg:boolean "bool";
          };
        };
        value = cfg:boolean()
      }
    }
  end

  local data =
  {
    outer_dict =
    {
      item1 = {
        bar = "aa";
        baz = "baz_value";
        inner_dict = { 1, 2, 3 }
      };
      item2 = {
        bar = "aa";
        baz = "baz_value";
        inner_dict = { }
      };
    };
    complex_key_dict =
    {
      [{
        ilist = { 1, 2, 3 };
        name = "jack";
        inner_node =
        {
          num = 1;
          bool = true;
        };
      }] = true;
    }
  }

  ensure(
      "dictionary node data is valid",
      validate_format(schema, data)
    )

  local cli_data =
  {
    outer_dict = [[
    {
      item1 = {
        bar = "aa";
        baz = "baz_value";
        inner_dict = { 1, 2, 3 }
      };
      item2 = {
        bar = "aa";
        baz = "baz_value";
        inner_dict = { }
      };
    }]];
    complex_key_dict = [[
    {
      [{
        ilist = { 1, 2, 3 };
        name = "jack";
        inner_node =
        {
          num = 1;
          bool = true;
        };
      }] = true;
    }]];
  }

  ensure(
      "dictionary node data is valid",
      validate_format(schema, cli_data)
    )
end)

test:case "cfg_dictionary_wrong_key_value_definition" (function()
  local schema
  local data = { }

  schema = function()
    cfg:root
    {
      cfg:dictionary "dict"
      {
        key = cfg:string();
      };
    }
  end

  ensure_fails_with_substring(
      "schema validation must fails without value format definition",
      function()
        assert(validate_format(schema, data))
      end,
      "dictionary 'dict' value format must be valid"
    )

  schema = function()
    cfg:root
    {
      cfg:dictionary "dict"
      {
        value = cfg:string();
      };
    }
  end

  ensure_fails_with_substring(
      "schema validation must fails without key format definition",
      function()
        assert(validate_format(schema, data))
      end,
      "dictionary 'dict' key format must be valid"
    )
end)

test:case "cfg_dictionary_bad_data" (function()
  local schema, data

  schema = function()
    cfg:root
    {
      cfg:dictionary "dict"
      {
        key = cfg:string();
        value = cfg:number();
      };
    }
  end

  local data =
  {
    dict =
    {
      a = 1;
      b = "b";
    };
  }

  ensure_fails_with_substring(
      "schema validation must fails with wrong data in values",
      function()
        assert(validate_format(schema, data))
      end,
      "bad `dict.value': unexpected type: actual: string, expected: number"
    )

  local data =
  {
    dict = { 1, 5 }
  }

  ensure_fails_with_substring(
      "schema validation must fails with wrong data in keys",
      function()
        assert(validate_format(schema, data))
      end,
      "bad `dict.key': unexpected type: actual: number, expected: string"
    )

  schema = function()
    cfg:root
    {
      cfg:dictionary "complex_dict"
      {
        key = cfg:string();
        value = cfg:node()
        {
          value = cfg:node "level1"
          {
            value = cfg:node "level2"
            {
              cfg:boolean "bool"
            };
          };
        };
      };
    }
  end

  local data =
  {
    complex_dict =
    {
      a =
      {
        level1 =
        {
          level2 =
          {
            bool = 1;
          };
        };
      };
    };
  }

  ensure_fails_with_substring(
      "schema validation must fails with wrong data in values",
      function()
        assert(validate_format(schema, data))
      end,
      "bad `complex_dict.value.level1.level2.bool': unexpected type: "
        .. "actual: number, expected: boolean"
    )
end)

test:case "cfg_optional_dictionary_good_data" (function()
  local schema = function()
    cfg:root
    {
      cfg:dictionary "dict"
      {
        key = cfg:number();
        value = cfg:number();
      };
      cfg:optional_dictionary "optional_dict"
      {
        key = cfg:string();
        value = cfg:number();
      };
    }
  end

  local data =
  {
    dict = {};
  }

  ensure(
      "dictionary node data is valid",
      validate_format(schema, data)
    )
end)

--------------------------------------------------------------------------------
-- See #31
test:TODO "Make full test coverage. Each type must be checked separately."

-- #32
test:UNTESTED "build_config_dsl"
test:UNTESTED "validate_format"
