#!/bin/sh

set -e
set -x

rm -rf build
mkdir build

./autogen.sh

cd build

../configure
make
