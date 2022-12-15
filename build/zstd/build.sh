#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=zstd
VER=1.5.2
PKG=compress/zstd
SUMMARY="Zstandard"
DESC="Zstandard is a real-time compression algorithm, providing high "
DESC+="compression ratios."

BMI_EXPECTED=1

MAKE_INSTALL_TARGET="-C lib install"
base_MAKE_ARGS="
    PREFIX=$PREFIX
    MANDIR=$PREFIX/share/man
    INSTALL=$GNUBIN/install
"

configure_i386() {
    MOREFLAGS="$CFLAGS ${CFLAGS[i386]}"
    MAKE_INSTALL_ARGS_WS="$base_MAKE_ARGS MOREFLAGS=\"$MOREFLAGS\""
    MAKE_ARGS_WS="$base_MAKE_ARGS MOREFLAGS=\"$MOREFLAGS\" lib-release"
}

configure_amd64() {
    MOREFLAGS="$CFLAGS ${CFLAGS[amd64]}"
    MAKE_INSTALL_ARGS_WS="$base_MAKE_ARGS MOREFLAGS=\"$MOREFLAGS\"
        LIBDIR=$PREFIX/lib/amd64"
    MAKE_ARGS_WS="$base_MAKE_ARGS MOREFLAGS=\"$MOREFLAGS\"
        LIBDIR=$PREFIX/lib/amd64 lib-release zstd-release"
}

configure_aarch64() {
    MOREFLAGS="$CFLAGS ${CFLAGS[aarch64]}"
    MAKE_INSTALL_ARGS_WS="$base_MAKE_ARGS MOREFLAGS=\"$MOREFLAGS\"
        LIBDIR=$PREFIX/lib/aarch64"
    MAKE_ARGS_WS="$base_MAKE_ARGS MOREFLAGS=\"$MOREFLAGS\"
        LIBDIR=$PREFIX/lib/aarch64 lib-release zstd-release"
}

make_prog_aarch64() {
    CPPFLAGS+=" -I${SYSROOT[aarch64]}/usr/include" \
    LDFLAGS+=" -L${SYSROOT[aarch64]}/usr/lib/aarch64 -R/usr/lib/aarch64" \
        make_arch aarch64
}

make_install_amd64() {
    make_install amd64
    MAKE_INSTALL_TARGET="-C programs install" make_install amd64
    # With the current way that the makefile builds are set up, the library
    # is only built with the install target. Re-check the build-log for errors.
    check_buildlog 0
}

make_install_aarch64() {
    DESTDIR+=.aarch64 make_install aarch64
    DESTDIR+=.aarch64 MAKE_INSTALL_TARGET="-C programs install" \
        make_install aarch64
    # With the current way that the makefile builds are set up, the library
    # is only built with the install target. Re-check the build-log for errors.
    check_buildlog 0
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
