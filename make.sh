#! /bin/bash

set -e

echo "----> Making manifest"
luajit2 etc/rockspec/generate.lua banner-1 > rockspec/lua-aplicado-banner-1.rockspec

echo "----> Creating list-exports"
etc/list-exports/list-exports list_all

echo "----> Making rocks"
sudo luarocks make rockspec/lua-aplicado-banner-1.rockspec

echo "----> Restarting multiwatch and LJ2"
sudo killall multiwatch && sudo killall luajit2

echo "----> OK"
