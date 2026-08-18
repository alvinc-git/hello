# Process this file with autoconf to create configure.
AC_PREREQ([2.65])

# ====================
# Version informations
# ====================
# Three components only.  A fourth ("nano") component made AC_INIT report
# 1.5.0.0, so `make dist` produced skydsecd-1.5.0.0.tar.xz while the Debian
# orig tarball is skydsecd_1.5.0.orig.tar.xz and debian/changelog declares
# 1.5.0-1.  dpkg-buildpackage matches those names literally, so the extra
# component broke the packaging workflow.  This is the single source of truth
# for the version; src/config.h derives PROGRAM_VERSION from it.
m4_define([skydsecd_version_major],[2])
m4_define([skydsecd_version_minor],[0])
m4_define([skydsecd_version_micro],[0])
m4_define([skydsecd_version],[skydsecd_version_major.skydsecd_version_minor.skydsecd_version_micro])

# =============
# Automake init
# =============
AC_INIT([skydsecd], [skydsecd_version], [alvin.cura@skydio.com])
AC_PREFIX_DEFAULT(/usr)
#AM_INIT_AUTOMAKE
AM_INIT_AUTOMAKE([1.11 subdir-objects foreign dist-xz dist-bzip2])
AC_LANG([C])

# Makefile.am already passes -I m4 via ACLOCAL_AMFLAGS, but without this the
# m4/ macros vendored in this tree (AX_CHECK_COMPILE_FLAG, AX_CHECK_LINK_FLAG)
# are not found by aclocal in every autoconf version.
AC_CONFIG_MACRO_DIR([m4])

# ===========================
# Find required base packages
# ===========================
AC_PROG_CPP
AC_PROG_CC
# AC_PROG_CC_STDC was removed here: obsolete since autoconf 2.70, which
# folded standard-mode selection into AC_PROG_CC.  autoreconf warned about
# it on every run.  The C standard is selected explicitly by STRICT_CFLAGS
# below in any case.
AC_PROG_INSTALL
AC_PROG_LN_S

# ================
# Language strictness
# ================
#
# Note on "ANSI C": literal C89 (-ansi) is not achievable for this program.
# snprintf is C99, and every network and host-inspection call it makes --
# socket, bind, gethostname, fork, setsid, access -- is POSIX rather than
# ISO C, and glibc hides those declarations under -ansi.  C99 plus an
# explicit _POSIX_C_SOURCE is the strictest conforming mode that still
# compiles, and -pedantic makes any remaining extension an error to rely on.
AC_ARG_ENABLE([strict],
  [AS_HELP_STRING([--disable-strict],[do not enforce strict C99/POSIX conformance])],
  [enable_strict=$enableval],
  [enable_strict=yes])

STRICT_CFLAGS=""
AS_IF([test "x$enable_strict" != "xno"], [
  AX_CHECK_COMPILE_FLAG([-std=c99],   [STRICT_CFLAGS="$STRICT_CFLAGS -std=c99"])
  AX_CHECK_COMPILE_FLAG([-pedantic],  [STRICT_CFLAGS="$STRICT_CFLAGS -pedantic"])
  AX_CHECK_COMPILE_FLAG([-Wextra],    [STRICT_CFLAGS="$STRICT_CFLAGS -Wextra"])
  AX_CHECK_COMPILE_FLAG([-Wstrict-prototypes],
                                      [STRICT_CFLAGS="$STRICT_CFLAGS -Wstrict-prototypes"])
  AX_CHECK_COMPILE_FLAG([-Wmissing-prototypes],
                                      [STRICT_CFLAGS="$STRICT_CFLAGS -Wmissing-prototypes"])
  AX_CHECK_COMPILE_FLAG([-Wold-style-definition],
                                      [STRICT_CFLAGS="$STRICT_CFLAGS -Wold-style-definition"])
  AX_CHECK_COMPILE_FLAG([-Wshadow],   [STRICT_CFLAGS="$STRICT_CFLAGS -Wshadow"])
  AX_CHECK_COMPILE_FLAG([-Wconversion],
                                      [STRICT_CFLAGS="$STRICT_CFLAGS -Wconversion"])
  # -std=c99 alone hides the POSIX declarations the daemon needs.
  STRICT_CFLAGS="$STRICT_CFLAGS -D_POSIX_C_SOURCE=200809L"
])
AC_SUBST([STRICT_CFLAGS])

AC_ARG_ENABLE([werror],
  [AS_HELP_STRING([--enable-werror],[treat compiler warnings as errors])],
  [enable_werror=$enableval],
  [enable_werror=no])
AS_IF([test "x$enable_werror" = "xyes"], [
  AX_CHECK_COMPILE_FLAG([-Werror], [STRICT_CFLAGS="$STRICT_CFLAGS -Werror"])
])

# =========
# Hardening
# =========
#
# The m4/ax_check_*_flag.m4 macros were already vendored in this tree for
# this purpose but had never been called, and this section was empty while
# the summary below reported HARDEN_CFLAGS/HARDEN_LDFLAGS as though it were
# populated.  Each flag is probed rather than assumed so the build still
# works on a toolchain that lacks it.
#
# -fPIE/-pie are deliberately NOT probed: they cannot be combined with the
# -static link used for the daemon, and a static non-PIE binary is the
# explicit trade chosen here (see the note on static linking below).
AC_ARG_ENABLE([hardening],
  [AS_HELP_STRING([--disable-hardening],[do not add compiler and linker hardening flags])],
  [enable_hardening=$enableval],
  [enable_hardening=yes])

HARDEN_CFLAGS=""
HARDEN_LDFLAGS=""

AS_IF([test "x$enable_hardening" != "xno"], [
  AX_CHECK_COMPILE_FLAG([-fstack-protector-strong],
    [HARDEN_CFLAGS="$HARDEN_CFLAGS -fstack-protector-strong"])
  AX_CHECK_COMPILE_FLAG([-D_FORTIFY_SOURCE=2],
    [HARDEN_CFLAGS="$HARDEN_CFLAGS -D_FORTIFY_SOURCE=2"])
  AX_CHECK_COMPILE_FLAG([-Wformat],
    [HARDEN_CFLAGS="$HARDEN_CFLAGS -Wformat"])
  AX_CHECK_COMPILE_FLAG([-Wformat-security],
    [HARDEN_CFLAGS="$HARDEN_CFLAGS -Wformat-security"])
  AX_CHECK_LINK_FLAG([-Wl,-z,relro],
    [HARDEN_LDFLAGS="$HARDEN_LDFLAGS -Wl,-z,relro"])
  AX_CHECK_LINK_FLAG([-Wl,-z,now],
    [HARDEN_LDFLAGS="$HARDEN_LDFLAGS -Wl,-z,now"])
])
AC_SUBST([HARDEN_CFLAGS])
AC_SUBST([HARDEN_LDFLAGS])

# ==============
# Static linking
# ==============
#
# The daemon is linked statically on purpose: it runs as root on hosts whose
# integrity it is meant to attest, so it must not resolve its dependencies
# through shared objects an attacker may have replaced.  Enabled by default
# and controllable for platforms with no static libc.
AC_ARG_ENABLE([static-daemon],
  [AS_HELP_STRING([--disable-static-daemon],[link skydsecd dynamically])],
  [enable_static_daemon=$enableval],
  [enable_static_daemon=yes])

STATIC_LDFLAGS=""
AS_IF([test "x$enable_static_daemon" != "xno"], [
  AX_CHECK_LINK_FLAG([-static], [STATIC_LDFLAGS="-static"],
    [AC_MSG_ERROR([--enable-static-daemon requested but the toolchain cannot link -static; install a static libc or pass --disable-static-daemon])])
])
AC_SUBST([STATIC_LDFLAGS])

# =======
# systemd
# =======
#
# src/daemon/skydsecd.service is generated from the .in at build time rather
# than by AC_CONFIG_FILES.  config.status would substitute @sbindir@ with the
# literal string ${exec_prefix}/sbin, which systemd does not expand, giving a
# unit with an unrunnable ExecStart.  make expands it properly.
AC_ARG_WITH([systemdsystemunitdir],
  [AS_HELP_STRING([--with-systemdsystemunitdir=DIR],[directory for systemd service files, or "no" to skip installing them])],
  [systemdsystemunitdir=$withval],
  [systemdsystemunitdir=auto])

AS_IF([test "x$systemdsystemunitdir" = "xauto"], [
  # AC_PATH_TOOL, not AC_PATH_PROG: the latter finds the build machine's
  # pkg-config when cross-compiling and would report the host's unit
  # directory.  AC_PATH_TOOL looks for a $host_alias-prefixed tool first.
  AC_PATH_TOOL([PKG_CONFIG], [pkg-config], [no])
  AS_IF([test "x$PKG_CONFIG" != "xno"], [
    systemdsystemunitdir=`$PKG_CONFIG --variable=systemdsystemunitdir systemd 2>/dev/null`
  ])
  AS_IF([test -z "$systemdsystemunitdir"], [
    systemdsystemunitdir='${prefix}/lib/systemd/system'
  ])
])

AM_CONDITIONAL([HAVE_SYSTEMD], [test "x$systemdsystemunitdir" != "xno"])
AC_SUBST([systemdsystemunitdir])

# ===========
# Rust Client
# ===========
AC_ARG_ENABLE([rust-client],
  [AS_HELP_STRING([--disable-rust-client],[do not build the Rust client])],
  [enable_rust_client=$enableval],
  [enable_rust_client=auto])

CARGO="no"
AS_IF([test "x$enable_rust_client" != "xno"], [
  AC_CHECK_PROG([CARGO], [cargo], [cargo], [no])
  AS_IF([test "x$enable_rust_client" = "xyes" && test "x$CARGO" = "xno"], [
    AC_MSG_ERROR([--enable-rust-client requested but cargo was not found])
  ])
])

AM_CONDITIONAL([HAVE_CARGO], [test "x$CARGO" != "xno"])

# ==============
# Setup config.h
# ==============
#AC_CONFIG_HEADERS([config.h])

# =====================
# Prepare all .in files
# =====================
AC_CONFIG_FILES([
	Makefile
])
AC_OUTPUT

# ==============================================
# Display final informations about configuration
# ==============================================
# Every variable reported here is one this configure script actually sets.
# The previous version listed debug, labeled-networking, libwrap and loadavg,
# none of which exist in this project -- they were carried over from another
# configure.ac and always printed empty, alongside HARDEN_CFLAGS and
# HARDEN_LDFLAGS that nothing had ever assigned.
AC_MSG_NOTICE([
==============================================================================
Build configuration:
        version:            ${PACKAGE_VERSION}
        prefix:             ${prefix}
        strict conformance: ${enable_strict}
        werror:             ${enable_werror}
        hardening:          ${enable_hardening}
        static daemon:      ${enable_static_daemon}
        systemd unit dir:   ${systemdsystemunitdir}
        rust client:        ${CARGO}
        STRICT_CFLAGS:      ${STRICT_CFLAGS}
        HARDEN_CFLAGS:      ${HARDEN_CFLAGS}
        HARDEN_LDFLAGS:     ${HARDEN_LDFLAGS}
        STATIC_LDFLAGS:     ${STATIC_LDFLAGS}
==============================================================================
])