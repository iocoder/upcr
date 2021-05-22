#!/bin/sh

./autogen.sh

rm -rf build
mkdir build
cd build

../configure
make
