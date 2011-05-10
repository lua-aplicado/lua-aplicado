#! /bin/bash

set -e

echo "----> Making manifest"
sudo luajit2 etc/rockspec/generate.lua banner-1 > rockspec/lua-aplicado-banner-1.rockspec

echo "----> Making rocks"
sudo luarocks make rockspec/lua-aplicado-banner-1.rockspec

echo "----> Creating list-exports"
cd etc/list-exports/
sudo ./list-exports --root=../.. list_all
cd ../..

echo "----> Restarting multiwatch and LJ2"
sudo killall multiwatch && sudo killall luajit2

echo "----> OK"
