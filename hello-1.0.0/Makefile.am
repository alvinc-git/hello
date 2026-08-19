AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4

# Strictness and hardening flags are probed by configure; see the
# corresponding sections of configure.ac.  Kept in AM_CFLAGS/AM_LDFLAGS so
# binaries inherit them.
AM_CFLAGS  = -Wall $(STRICT_CFLAGS) $(HARDEN_CFLAGS)
AM_LDFLAGS = $(HARDEN_LDFLAGS)

# Files that are part of the release but are not sources of a program.
#
# debian/ is deliberately absent: the 3.0 (quilt) source format expects the
# packaging to be applied on top of an orig tarball that does not contain it.
EXTRA_DIST = \
	autogen.sh \
	CHANGELOG \
	COPYRIGHT \
	README.md \
	hello-rust/Cargo.toml \
	hello-rust/README.md \
	hello-rust/src/main.rs \
	hello-rust/test-build.sh \
	hello-go/go.mod \
	hello-go/README.md \
	hello-go/main.go \
	hello-go/test-build.sh

# Man pages live upstream rather than in debian/ so they exist for any
# packaging format, and are picked up automatically by dh_installman via
# `make install`.  The dist_ prefix puts them in the release tarball.
dist_man_MANS = \
	man/hello.1 \
	man/hello_rust.1 \
	man/hello_go.1

bin_PROGRAMS = hello
hello_SOURCES = \
	src/config.h \
	src/hello.c
hello_CFLAGS = \
	$(AM_CFLAGS)
hello_LDFLAGS = \
	$(AM_LDFLAGS)

EXTRA_PROGRAM_TARGETS =
if HAVE_CARGO
EXTRA_PROGRAM_TARGETS += hello-rust-build
endif
if HAVE_GO
EXTRA_PROGRAM_TARGETS += hello-go-build
endif

all-local: $(EXTRA_PROGRAM_TARGETS)

hello-rust-build:
	cd $(srcdir)/hello-rust && cargo build --release

hello-go-build:
	cd $(srcdir)/hello-go && go build -ldflags "-X main.programVersion=$(PACKAGE_VERSION)" -o hello_go main.go

install-exec-hook:
	if [ -f $(srcdir)/hello-rust/target/release/hello_rust ]; then \
		$(MKDIR_P) $(DESTDIR)$(bindir) && \
		$(INSTALL_PROGRAM) $(srcdir)/hello-rust/target/release/hello_rust $(DESTDIR)$(bindir)/hello_rust; \
	fi
	if [ -f $(srcdir)/hello-go/hello_go ]; then \
		$(MKDIR_P) $(DESTDIR)$(bindir) && \
		$(INSTALL_PROGRAM) $(srcdir)/hello-go/hello_go $(DESTDIR)$(bindir)/hello_go; \
	fi

clean-local:
	if [ -d $(srcdir)/hello-rust ]; then \
		(cd $(srcdir)/hello-rust && cargo clean 2>/dev/null || true); \
	fi
	if [ -f $(srcdir)/hello-go/hello_go ]; then \
		rm -f $(srcdir)/hello-go/hello_go; \
	fi