local xml_convert_attrs = function(attrs)
  local attr = { }

  for i = 1, #attrs do
    attr[attrs[i]] = attrs[attrs[i]]
  end

  return attr
end

local function xml_convert_lom_r(t)
  local result = { }

  assert(v.attr, "missing attr")
  result['attrs'] = pkb_convert_attrs(t.attr)

  for i = 1, #t do
    local v = t[i]
    if type(v) ~= "table" then
      result['value'] = result['value'] or ""
      result['value'] = result['value'] .. trim(v)
    else
      assert(v.tag, "missing tag name")
      result[v.tag] = result[v.tag] or { }
      result[v.tag][#result[v.tag] + 1] = xml_convert_lom_r(v)
    end
  end

  return result
end

local xml_convert_lom = function(t)
  local r = { }

  assert(t.tag, "missing tag name")
  r[t.tag] = xml_convert_lom_r(t)

  return r
end

------------------------------------------------------------------------

return
{
  xml_convert_lom = xml_convert_lom;
}
