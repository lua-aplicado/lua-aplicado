--------------------------------------------------------------------------------
-- expat.lua: various utilities to work with lua-expat
-- This file is a part of Lua-Aplicado library
-- Copyright (c) Lua-Aplicado authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local assert, type
    = assert, type

--------------------------------------------------------------------------------

local unique_object
      = import 'lua-nucleo/misc.lua'
      {
        'unique_object'
      }

local trim
      = import 'lua-nucleo/string.lua'
      {
        'trim'
      }

local arguments,
      optional_arguments,
      method_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments'
      }

local is_table
      = import 'lua-nucleo/type.lua'
      {
        'is_table'
      }

--------------------------------------------------------------------------------

local LOM_ATTRS = unique_object()

local xml_convert_lom
do
  --reads a list of attributes from a integer-index part of source table and
  -- return the table of the form "attribute name" => "value"
  --example:
  --source table: attr={"id","status","sum",status="150",sum="0.05",id="FF00"}
  --result: {status="150",sum="0.05",id="FF00"}
  local xml_convert_attrs = function(src)
    local dest = { }

    for i = 1, #src do
      dest[src[i]] = src[src[i]]
    end

    return dest
  end

  local function impl(t, visited)
    arguments(
        "table", t,
        "table", visited
      )

    local result = { }

    assert(t.attr, "missing attr field")
    result[LOM_ATTRS] = xml_convert_attrs(t.attr)

    for i = 1, #t do
      local v = t[i]
      if type(v) ~= "table" then
        result['value'] = result['value'] or ""
        result['value'] = result['value'] .. trim(v)
      else
        assert(v.tag, "missing tag name")
        result[v.tag] = result[v.tag] or { }

        assert(not visited[v], "recursion detected")
        visited[v] = true
        result[v.tag][#result[v.tag] + 1] = impl(v, visited)
        visited[v] = nil
      end
    end

    return result
  end

  xml_convert_lom = function(t)
    local r = { }

    assert(t.tag, "missing tag name")
    r[t.tag] = impl(t, { })

    return r
  end
end

------------------------------------------------------------------------

local walk_lom_data
do
  walk_lom_data = function(handlers, lom_data)
    arguments(
        "table", handlers
        -- "*", lom_data
      )

    local tag = is_table(lom_data) and lom_data.tag or nil
    if tag == nil then
      -- NOTE: Come on. If lom_data is not a tagged table, then it is a string.
      --       it is LOM data walker, not random data walker after all...
      tag = { tag = type(lom_data), lom_data }
    end

    local down = handlers.down[tag]
    if down then
      if down(handlers, lom_data) == "break" then
        return
      end
    end

    if is_table(lom_data) and lom_data.tag then
      -- Not checking for recursive references: they are unlikely in LOM data.
      for i = 1, #lom_data do
        walk_lom_data(handlers, lom_data[i])
      end
    end

    local up = handlers.up[tag]
    if up then
      up(handlers, lom_data)
    end
  end
end

--------------------------------------------------------------------------------

return
{
  LOM_ATTRS = LOM_ATTRS;
  --
  xml_convert_lom = xml_convert_lom;
  walk_lom_data = walk_lom_data;
}
