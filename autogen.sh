#! /bin/sh

set -e
set -x

# generate configure.ac
autoscan

# configure.ac -> aclocal.m4
aclocal

# configure.ac -> config.h.in
autoheader

# config.h.in + Makefile.am -> Makefile.in
automake --foreign --add-missing -c

# generate configure
autoconf

