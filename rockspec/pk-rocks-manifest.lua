--------------------------------------------------------------------------------
-- pk-rocks-manifest.lua: PK rocks manifest
--------------------------------------------------------------------------------

local ROCKS =
{
  {
    "rockspec/lua-aplicado-scm-1.rockspec";
    generator =
    {
      "pk-lua-interpreter", "etc/rockspec/generate.lua", "banner-1",
        ">", "rockspec/lua-aplicado-scm-1.rockspec"
    };
  };
}

return
{
  ROCKS = ROCKS;
}
