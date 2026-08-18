# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`hello` is the standard Hello program. It is packaged for Debian.

## Repository layout

The git root is **not** the build root. All buildable source lives in `hello-1.0.0/`, which is shaped like an unpacked release tarball. Run all build commands from `hello-1.0.0/`.

Release tarballs are generated with `make dist`, not committed.

## Build

```bash
cd hello-1.0.0
./autogen.sh          # autoreconf -v -i -f; only needed after touching configure.ac/Makefile.am
./configure           # AC_PREFIX_DEFAULT is /usr, so bindir=/usr/bin, sbindir=/usr/sbin
make
```


Produces binaries: `hello` (C client) and `hello-rust` (zero-dependency Rust client)


`configure` prints a summary of what it resolved, and every line in it reflects a real setting. Relevant options:

| Option | Default | Effect |
|---|---|---|
| `--disable-strict` | strict on | Drops `-std=c99 -pedantic -Wextra -Wconversion` and the prototype warnings |
| `--enable-werror` | off | Adds `-Werror` |
| `--disable-hardening` | hardening on | Drops `-fstack-protector-strong`, `-D_FORTIFY_SOURCE=2`, `-Wl,-z,relro`, `-Wl,-z,now` |
| `--disable-static-daemon` | static on | Links `skydsecd` dynamically |

**The tree builds with zero warnings under the default flags. Keep it that way** — a new warning is a regression, not background noise.

`make check` exists but does nothing — `Makefile.am` defines no `TESTS`. `make dist` works and produces `skydsecd-2.0.0.tar.xz`, matching the name the Debian orig tarball needs.

Careful when checking for warnings: a bare second `make` is a no-op and will report a clean build regardless. Always `make clean` first.


## Run

```bash
./hello 127.0.0.1   # C client; prints the daemon's report and exits
./hello-rust 127.0.0.1 # Rust client; identical protocol & output
```

`-d` is what gates all the diagnostic `fprintf(stderr, ...)` calls in the daemon; without it failures are silent.

## Architecture

**Host facts are probed per connection, and that is deliberate.** `gather_facts()` runs inside the `accept()` loop, *after* `accept()` returns, so every reply reflects a fresh `gethostname` + `stat` + `access`. This used to be a one-shot snapshot taken before the socket opened, which meant a security tool removed after startup stayed invisible until someone restarted the unit — a compliance checker reporting a stale pass. **Do not hoist this back out of the loop for performance.** The three syscalls are negligible beside the TCP handshake that precedes them.

Corollary: nothing in the serve loop may call `exit()`. A transient probe failure must be reported in-band (as `gather_facts` does for `gethostname`), because killing the daemon is a worse outcome than one degraded answer.

**Protocol** is unauthenticated plaintext over TCP on `SKYDSECD_PORT` (2014), bound to `INADDR_ANY`. On connect the daemon writes four newline-separated fields (hostname, baseboard serial, ws1HubUtil status, `ctime`) and closes. There is no request parsing — the client sends nothing. Changing the field order or count breaks `src/skydsec.c` and `skydsec-rust`, which both echo whatever they read.

> **Known issue, deliberately deferred:** that endpoint serves the hostname and hardware serial to anyone who can reach port 2014, with no authentication. Tracked as separate work — do not assume it is an oversight.

**Container/VM detection is inferred from file ownership, not from an API.** The daemon `stat()`s `/sys/class/dmi/id/board_serial`; if `st_uid`/`st_gid` is `NOBODY_ID` (65534) it concludes it is in an unprivileged container and skips the read. If the file reads back as effectively empty it concludes it is a VM. Both are heuristics keyed to that one path.

That file is mode `0400 root:root` on a stock host, so **every non-root run takes the unreadable path** — expect `baseboard-serial-number unreadable (Permission denied)` when testing without `sudo`. That is correct behaviour, not a regression. `get_baseboard_serial()` guarantees its buffer holds a printable string on every path, because the result goes straight to a socket; an early return that skips the fill would send uninitialised stack memory to an unauthenticated caller.

**`src/config.h` is hand-written and version-controlled — it is not an autoconf artifact.** `AC_CONFIG_HEADERS` is deliberately commented out in `configure.ac`. `PROGRAM_VERSION` is derived from `PACKAGE_VERSION`, so **`configure.ac` is the single source of truth for the version** — bump it there and nowhere else. Keep it to three components: a fourth made `make dist` emit a tarball name the Debian packaging cannot consume. `config.h` is where the port, the DMI path, and the ws1HubUtil path live, and it carries one macro per binary (`CLIENT_NAME`, `DAEMON_NAME`) — do not collapse those back into a shared name, or each program starts identifying itself as the other.

**The daemon is linked `-static` on purpose, and that guarantee is load-bearing.** It runs as root on the hosts whose integrity it attests, so it must not resolve dependencies through shared objects an attacker on that host may have replaced. Driven by `--enable-static-daemon` via `skydsecd_LDFLAGS`; `configure` errors out rather than silently producing a dynamic binary if a static link is impossible.

The subtle part: **NSS defeats this**. `getpwuid`/`getgrgid` and friends `dlopen()` their modules at runtime even from a fully static binary, which the linker warns about explicitly. Those calls were removed for exactly this reason, and `nm skydsecd` should report no NSS symbols. Do not reintroduce a username or group-name lookup — compare raw `st_uid`/`st_gid` against `NOBODY_ID` instead. The client binaries are dynamically linked and are not part of this guarantee.

**Note on "ANSI C".** The build targets C99 plus `-D_POSIX_C_SOURCE=200809L`, not C89. Literal `-ansi` is unreachable here: `snprintf` is C99, and every call the daemon exists to make (`socket`, `bind`, `gethostname`, `fork`, `stat`, `access`) is POSIX, which glibc hides under `-ansi`.

## Packaging (Debian & RPM)

Both Debian (`dpkg-buildpackage`) and RPM (`rpmbuild`) frameworks package the daemon (`skydsecd`), C client (`skydsec`), and Rust client (`skydsec-rust`) together.

- **Debian packaging:** `ci/build.sh`
- **RPM packaging:** `ci/build-rpm.sh`

```bash
cd skydsecd-2.0.0 && make dist
B=/tmp/debbuild && mkdir -p $B
cp skydsecd-2.0.0.tar.xz $B/skydsecd_2.0.0.orig.tar.xz   # note the _ and .orig
cd $B && tar xf skydsecd_2.0.0.orig.tar.xz
cp -r /path/to/repo/skydsecd-2.0.0/debian skydsecd-2.0.0/debian
cd skydsecd-2.0.0 && dpkg-buildpackage -us -uc
```

Build outside the repo so packaging output doesn't land in the working tree.

`lintian` should report only two findings, both archive-submission artifacts rather than defects: `bad-distribution-in-changes-file stable` (lintian on Ubuntu only accepts Ubuntu suite names) and `initial-upload-closes-no-bugs` (expects a Debian ITP bug). **Anything else is a regression.**

`statically-linked-binary` is overridden in `debian/skydsecd.lintian-overrides` with the reasoning — it is intentional, see the static-linking note above.

Man pages live in `man/` upstream, not in `debian/`, and reach the package via `dist_man_MANS` and `dh_installman`.

Packages are built unsigned (`-us -uc`). Signing them is a separate decision from the commit signing this repo requires.

## Service definition

There is exactly one, `src/daemon/skydsecd.service.in`. A SysV init script and a second hardcoded unit under `skydio/` were deleted; don't resurrect them.

Only the `.in` is tracked. The unit is generated by a make rule and installed to the directory found via `pkg-config --variable=systemdsystemunitdir systemd`, overridable with `--with-systemdsystemunitdir=DIR` (or `=no` to skip).

Two things that will bite if changed back:

- **Generation is a make rule, not `AC_CONFIG_FILES`.** `config.status` substitutes `@sbindir@` with the literal `${exec_prefix}/sbin`, which systemd does not expand — you get a unit whose `ExecStart` cannot run. `make` expands `$(sbindir)` to a real path.
- **`Type=simple` with `ExecStart=... -f`.** The daemon never calls `sd_notify()`, so `Type=notify` hangs until `DefaultTimeoutStartSec` and fails the unit. Fixing that properly would mean linking `libsystemd`, which conflicts with the static link. And without `-f` the daemon forks and the parent exits, which under `Type=simple` looks like an immediate crash.

Validate changes with `systemd-analyze verify src/daemon/skydsecd.service` after a build.

## Commits

- Commits must be **SSH/GPG signed**. `commit.gpgsign=true` is set in this repo's `.git/config`; confirm with `git log --show-signature` rather than assuming.
- Use **Conventional Commits** subjects (`feat:`, `fix:`, `chore:`) and write a real explanatory body covering *why*, not a restatement of the diff.
- Generated autotools output (`configure`, `Makefile`, `aclocal.m4`, `config.status`, `*.o`, `.deps/`, and the `skydsec`/`skydsecd` binaries) lands directly in `skydsecd-2.0.0/`. Check `git status` before staging so build artifacts don't end up in a signed commit.


