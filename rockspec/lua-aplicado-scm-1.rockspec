package = "lua-aplicado"
version = "scm-1"
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
   "lua == 5.1",
   "lua-nucleo >= 0.1.0",
   "luafilesystem >= 1.5.0",
   "lbci >= 20090306",
   "luasocket >= 2.0.2",
   "luasec >= 0.4",
   "luaposix >= 5.1.23",
   "lpeg",
   "md5"
}
build = {
   type = "none",
   install = {
      lua = {
         ["lua-aplicado.bci_chunk_inspector"] = "lua-aplicado/bci_chunk_inspector.lua";
         ["lua-aplicado.chunk_inspector"] = "lua-aplicado/chunk_inspector.lua";
         ["lua-aplicado.code.exports"] = "lua-aplicado/code/exports.lua";
         ["lua-aplicado.code.globals"] = "lua-aplicado/code/globals.lua";
         ["lua-aplicado.code.profile"] = "lua-aplicado/code/profile.lua";
         ["lua-aplicado.common_logging"] = "lua-aplicado/common_logging.lua";
         ["lua-aplicado.connector"] = "lua-aplicado/connector.lua";
         ["lua-aplicado.csv"] = "lua-aplicado/csv.lua";
         ["lua-aplicado.dsl.config_dsl"] = "lua-aplicado/dsl/config_dsl.lua";
         ["lua-aplicado.dsl.tools_cli_config"] = "lua-aplicado/dsl/tools_cli_config.lua";
         ["lua-aplicado.dsl.tree_walker_with_checker"] = "lua-aplicado/dsl/tree_walker_with_checker.lua";
         ["lua-aplicado.error"] = "lua-aplicado/error.lua";
         ["lua-aplicado.expat"] = "lua-aplicado/expat.lua";
         ["lua-aplicado.filesystem"] = "lua-aplicado/filesystem.lua";
         ["lua-aplicado.fork"] = "lua-aplicado/fork.lua";
         ["lua-aplicado.http"] = "lua-aplicado/http.lua";
         ["lua-aplicado.lj2_chunk_inspector"] = "lua-aplicado/lj2_chunk_inspector.lua";
         ["lua-aplicado.log"] = "lua-aplicado/log.lua";
         ["lua-aplicado.luajit2"] = "lua-aplicado/luajit2.lua";
         ["lua-aplicado.module"] = "lua-aplicado/module.lua";
         ["lua-aplicado.process"] = "lua-aplicado/process.lua";
         ["lua-aplicado.random"] = "lua-aplicado/random.lua";
         ["lua-aplicado.shell"] = "lua-aplicado/shell.lua";
         ["lua-aplicado.shell.filesystem"] = "lua-aplicado/shell/filesystem.lua";
         ["lua-aplicado.shell.git"] = "lua-aplicado/shell/git.lua";
         ["lua-aplicado.shell.luarocks"] = "lua-aplicado/shell/luarocks.lua";
         ["lua-aplicado.shell.remote"] = "lua-aplicado/shell/remote.lua";
         ["lua-aplicado.shell.remote_luarocks"] = "lua-aplicado/shell/remote_luarocks.lua";
         ["lua-aplicado.shell.send_email"] = "lua-aplicado/shell/send_email.lua";
         ["lua-aplicado.srv.base_conn"] = "lua-aplicado/srv/base_conn.lua";
         ["lua-aplicado.srv.copas_conn"] = "lua-aplicado/srv/copas_conn.lua";
         ["lua-aplicado.srv.raw_conn"] = "lua-aplicado/srv/raw_conn.lua";
         ["lua-aplicado.testing.decorators"] = "lua-aplicado/testing/decorators.lua";
         ["lua-aplicado.web.cookie_jar"] = "lua-aplicado/web/cookie_jar.lua";
      }
   }
}