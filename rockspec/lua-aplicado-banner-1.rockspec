package = "lua-aplicado"
version = "banner-1"
source = {
   url = "git://github.com/lua-aplicado/lua-aplicado.git",
   branch = "master"
}
description = {
   summary = "A random collection of application level Lua libraries",
   homepage = "http://github.com/lua-aplicado/lua-aplicado",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1",
   "lua-nucleo >= 0.0.1",
   "luafilesystem >= 1.5.0",
   "lbci >= 20090306",
   "luasocket >= 2.0.2"
}
build = {
   type = "none",
   install = {
      lua = {
         ["lua-aplicado.bci_chunk_inspector"] = "lua-aplicado/bci_chunk_inspector.lua";
         ["lua-aplicado.chunk_inspector"] = "lua-aplicado/chunk_inspector.lua";
         ["lua-aplicado.filesystem"] = "lua-aplicado/filesystem.lua";
         ["lua-aplicado.lj2_chunk_inspector"] = "lua-aplicado/lj2_chunk_inspector.lua";
         ["lua-aplicado.luajit2"] = "lua-aplicado/luajit2.lua";
         ["lua-aplicado.module"] = "lua-aplicado/module.lua";
         ["lua-aplicado.shell"] = "lua-aplicado/shell.lua";
         ["lua-aplicado.shell.git"] = "lua-aplicado/shell/git.lua";
         ["lua-aplicado.shell.luarocks"] = "lua-aplicado/shell/luarocks.lua";
         ["lua-aplicado.shell.remote"] = "lua-aplicado/shell/remote.lua";
         ["lua-aplicado.shell.remote_luarocks"] = "lua-aplicado/shell/remote_luarocks.lua";
         ["lua-aplicado.shell.send_email"] = "lua-aplicado/shell/send_email.lua";
      }
   }
}
