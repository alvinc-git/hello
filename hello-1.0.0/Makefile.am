AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4

# Strictness and hardening flags are probed by configure; see the
# corresponding sections of configure.ac.  Kept in AM_CFLAGS/AM_LDFLAGS so
# both binaries inherit them.
AM_CFLAGS  = -Wall $(STRICT_CFLAGS) $(HARDEN_CFLAGS)
AM_LDFLAGS = $(HARDEN_LDFLAGS)

# Files that are part of the release but are not sources of a program.
#
# These previously pointed at contrib/, a directory that does not exist in
# this tree -- the service definitions live in skydio/.  automake resolves
# EXTRA_DIST entries literally, so `make dist` failed outright with
# "No rule to make target 'contrib/skydsecd'", which in turn blocked
# producing the orig tarball the Debian packaging needs.
#
# debian/ is deliberately absent: the 3.0 (quilt) source format expects the
# packaging to be applied on top of an orig tarball that does not contain it.
EXTRA_DIST = \
	autogen.sh \
	COPYRIGHT \
	README.md \
	src/daemon/skydsecd.service.in \
	skydsec-rust/Cargo.toml \
	skydsec-rust/README.md \
	skydsec-rust/src/client.rs \
	skydsec-rust/src/daemon.rs


# Man pages live upstream rather than in debian/ so they exist for any
# packaging format, and are picked up automatically by dh_installman via
# `make install`.  The dist_ prefix puts them in the release tarball.
dist_man_MANS = \
	man/skydsec.1 \
	man/skydsec-rust.1 \
	man/skydsecd.8 \
	man/skydsecd-rust.8

bin_PROGRAMS = skydsec
skydsec_SOURCES = \
	src/config.h \
	src/skydsec.c

sbin_PROGRAMS = skydsecd

# A per-target _CFLAGS replaces AM_CFLAGS rather than adding to it, so the
# bare "-static" that used to live here meant the daemon -- the component
# that runs as root and answers the network -- was the only thing in the
# tree built without -Wall or any hardening flag.  $(AM_CFLAGS) is now
# restated explicitly so per-target flags are additive.
skydsecd_CFLAGS = \
	$(AM_CFLAGS)

# -static is a link-time property, so it belongs in LDFLAGS.  It worked from
# CFLAGS only because automake happens to pass CFLAGS on the link line too.
# $(STATIC_LDFLAGS) is set by --enable-static-daemon, which is the default:
# the daemon attests the integrity of the host it runs on, so it must not
# resolve its dependencies through shared objects that host may have had
# tampered with.
skydsecd_LDFLAGS = \
	$(AM_LDFLAGS) \
	$(STATIC_LDFLAGS)
skydsecd_SOURCES = \
	src/config.h \
	src/skydsecd.c

# ---------------------------------------------------------------------------
# systemd unit
#
# Generated here rather than by AC_CONFIG_FILES: config.status would expand
# @sbindir@ to the literal ${exec_prefix}/sbin, which systemd does not
# interpret, producing a unit whose ExecStart cannot be run.  make expands
# $(sbindir) to a real path.
#
# This is the only service definition in the tree.  It replaces
# skydio/skydsecd.service (hardcoded /usr/sbin, ignoring --prefix) and
# skydio/skydsecd (a RedHat-style SysV init script that sourced
# /etc/init.d/functions and used chkconfig and /var/lock/subsys, none of
# which apply on the Debian target).
# ---------------------------------------------------------------------------
# systemdsystemunitdir itself is AC_SUBST'd by configure, so it must not be
# assigned again here -- doing so redefined it unconditionally and automake
# warned that it "was already defined in condition TRUE, which includes
# condition HAVE_SYSTEMD".  Only the _DATA line belongs in the conditional.
if HAVE_SYSTEMD
systemdsystemunit_DATA = src/daemon/skydsecd.service
endif

src/daemon/skydsecd.service: $(srcdir)/src/daemon/skydsecd.service.in Makefile
	$(AM_V_GEN)$(MKDIR_P) src/daemon && \
	sed -e 's|@sbindir[@]|$(sbindir)|g' < $(srcdir)/src/daemon/skydsecd.service.in > $@

if HAVE_CARGO
all-local: skydsec-rust-build

skydsec-rust-build:
	cd $(srcdir)/skydsec-rust && cargo build --release --bin skydsec
	cd $(srcdir)/skydsec-rust && RUSTFLAGS="-C target-feature=+crt-static -C relocation-model=static" cargo build --release --bin skydsecd



install-exec-hook:
	if [ -f $(srcdir)/skydsec-rust/target/release/skydsec ]; then \
		$(MKDIR_P) $(DESTDIR)$(bindir) && \
		$(INSTALL_PROGRAM) $(srcdir)/skydsec-rust/target/release/skydsec $(DESTDIR)$(bindir)/skydsec-rust; \
	fi
	if [ -f $(srcdir)/skydsec-rust/target/release/skydsecd ]; then \
		$(MKDIR_P) $(DESTDIR)$(sbindir) && \
		$(INSTALL_PROGRAM) $(srcdir)/skydsec-rust/target/release/skydsecd $(DESTDIR)$(sbindir)/skydsecd-rust; \
	fi

clean-local:
	cd $(srcdir)/skydsec-rust && cargo clean 2>/dev/null || true
endif



CLEANFILES = src/daemon/skydsecd.service