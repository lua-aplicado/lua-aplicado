--------------------------------------------------------------------------------
-- expat.lua: basic code to convert lxp.lom object to table with tags as a keys
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

do
  local LOM_ATTRS = unique_object()

  local xml_convert_attrs = function(attrs)
    local attr = { }

    for i = 1, #attrs do
      attr[attrs[i]] = attrs[attrs[i]]
    end

    return attr
  end

  local function impl(t, visited)
    arguments(
        "table", t,
        "table", visited
      )

    local result = { }

    assert(t.attr, "missing attr")
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

  local xml_convert_lom = function(t)
    local r = { }

    assert(t.tag, "missing tag name")
    r[t.tag] = impl(t, { })

    return r
  end
return

------------------------------------------------------------------------

{
  LOM_ATTRS = LOM_ATTRS;
  xml_convert_lom = xml_convert_lom;
}
end
