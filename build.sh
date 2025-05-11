#!/bin/sh
luastatic breek.lua commands.lua fs.lua argparse.lua /usr/local/lib/liblua.a /usr/local/lib/liblfs.a -I/usr/local/include -I/usr/include/lua5.4 -static -o breek
