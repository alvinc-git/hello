# Process this file with autoconf to create configure.
AC_PREREQ([2.65])

# ====================
# Version informations
# ====================
# Three components only. This is the single source of truth for the version;
# src/config.h derives PROGRAM_VERSION from it.
m4_define([hello_version_major],[1])
m4_define([hello_version_minor],[0])
m4_define([hello_version_micro],[0])
m4_define([hello_version],[hello_version_major.hello_version_minor.hello_version_micro])

# =============
# Automake init
# =============
AC_INIT([hello], [hello_version], [alvinc@sysdudez.com])
AC_PREFIX_DEFAULT(/usr)
AM_INIT_AUTOMAKE([1.11 subdir-objects foreign dist-xz dist-bzip2])
AC_LANG([C])

# Makefile.am already passes -I m4 via ACLOCAL_AMFLAGS
AC_CONFIG_MACRO_DIR([m4])

# ===========================
# Find required base packages
# ===========================
AC_PROG_CPP
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_LN_S

# ===================
# Language strictness
# ===================
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

# ============
# Rust Program
# ============
AC_ARG_ENABLE([rust],
  [AS_HELP_STRING([--disable-rust],[do not build the Rust program])],
  [enable_rust=$enableval],
  [enable_rust=auto])

AS_IF([test "x$enable_rust" != "xno"], [
  AC_PATH_PROG([CARGO], [cargo], [no])
  AS_IF([test "x$enable_rust" = "xyes" && test "x$CARGO" = "xno"], [
    AC_MSG_ERROR([--enable-rust requested but cargo was not found])
  ])
], [
  CARGO="no"
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
AC_MSG_NOTICE([
==============================================================================
Build configuration:
        version:            ${PACKAGE_VERSION}
        prefix:             ${prefix}
        strict conformance: ${enable_strict}
        werror:             ${enable_werror}
        hardening:          ${enable_hardening}
        rust program:       ${CARGO}
        STRICT_CFLAGS:      ${STRICT_CFLAGS}
        HARDEN_CFLAGS:      ${HARDEN_CFLAGS}
        HARDEN_LDFLAGS:     ${HARDEN_LDFLAGS}
==============================================================================
])