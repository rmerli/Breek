#!/bin/sh

rm -r ./tmp
ROOT_DIR="$(pwd)"
cd tmp

wget https://www.lua.org/ftp/lua-5.4.7.tar.gz
tar xf lua-5.4.7.tar.gz
cd lua-5.4.7

make linux MYCFLAGS="-fPIC" 

sudo mkdir -p /usr/local/{lib,include}
sudo cp src/liblua.a /usr/local/lib/
sudo cp src/*.h /usr/local/include/
sudo ldconfig 

cd $ROOT_DIR

git clone https://github.com/keplerproject/luafilesystem.git
cd luafilesystem

# 1. Compile
gcc -fPIC -O2 -I/usr/local/include -I/usr/include/lua5.4 \
    -c src/lfs.c -o lfs.o

# 2. Archive
ar rcs liblfs.a lfs.o

# 3. Install
sudo cp liblfs.a            /usr/local/lib/
sudo cp src/lfs.h           /usr/local/include/
sudo ldconfig

cd $ROOT_DIR
