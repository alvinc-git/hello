# skydsecd — working notes

![Status](https://img.shields.io/badge/status-active-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/license-Proprietary-red?style=for-the-badge)

Operational runbook for the work: how to merge it, how to
pick it up on another machine, and how to build, package, install and release.

Everything here was executed and verified, not written from memory. Commands
assume you start at the repository root.

---

## 1. Current state

| | |
|---|---|
| Branch | `antigravity/refactor` |
| Tag | `v2.0.0` (or `v1.5.0` signed release tag) |

Release 2.0.0 includes C daemon, C client, zero-dependency Rust client, Debian packaging, and RPM packaging. Working tree clean.



---

## 2. Merging — read this before opening the PR

**Do not squash-merge.**

`v1.0.0` is a signed, *already published* tag pointing at `f68be83`. A squash
creates a brand-new commit with a different hash, which would leave the tag
pointing at a commit that exists nowhere in `master`'s history. The tag would
still resolve, but it would reference an orphan.

Because the tag is already on `origin`, the easy escape hatch — delete and
re-tag — is no longer clean; anyone who has fetched it would keep the old one.

### Do this

```bash
git checkout master
git pull origin master
git merge --no-ff claude/refactor      # merge commit preserves f68be83
git push origin master
```

`--no-ff` forces a merge commit even if a fast-forward is possible, which keeps
the branch's history — and therefore the tagged commit — intact and visible.

A rebase-merge is also acceptable **only** if `f68be83` itself is not rewritten.
If review demands changes, add new commits on top rather than amending history
at or before the tagged commit.

### If someone squashes it anyway

The tag survives as a git object but no longer describes mainline history. The
least-bad recovery is to leave `v1.0.0` alone (it is published) and cut a
`v1.0.1` on the squashed commit, documenting the discontinuity.

### Opening the PR

Bitbucket offered:

```
https://bitbucket.org/alvincura/skydsecd/pull-requests/new?source=claude/refactor&t=1
```

Worth leading the description with: a reproducible startup segfault, a clone
that could not be built at all, the daemon being compiled without `-Wall`, and
a licensing contradiction in `debian/copyright`.

---

## 3. Picking this up on another machine

```bash
git clone git@bitbucket.org:alvincura/skydsecd.git
cd skydsecd
git checkout claude/refactor
```

### GPG signing does NOT travel with the clone

`commit.gpgsign=true` was set with `--local`, so it lives in `.git/config` and
is **not** cloned. Without re-enabling it, commits on the new machine will be
unsigned and nothing will warn you.

```bash
gpg --list-secret-keys --keyid-format=long     # confirm the key is present
git config --local user.signingkey 933DF15ABD75CBFB
git config --local commit.gpgsign true
```

Verify after your first commit — do not assume:

```bash
git log --show-signature -1
git log --format='%h %G? %s' -5                # G = good signature
```

If GPG prompts for a passphrase and hangs in a non-interactive context, export
`GPG_TTY=$(tty)` in your shell profile.

### Host packages needed

```bash
sudo apt-get install -y build-essential autoconf automake \
                        debhelper dpkg-dev fakeroot lintian
```

`debhelper` is required for packaging; `lintian` is optional but is how you
confirm the package is still clean.

---

## 4. Building from source

```bash
cd skydsecd-2.0.0
./autogen.sh          # only after touching configure.ac / Makefile.am
./configure
make
```

Produces `skydsecd` (daemon), `skydsec` (C client), and `skydsec-rust` (Rust client) at the top of `skydsecd-2.0.0/`.

**The tree builds with zero warnings. A new warning is a regression.** To check
honestly, always clean first — a bare second `make` is a no-op and will report
a clean build whether or not one happened:

```bash
make clean && make 2>&1 | grep -cE 'warning|error'    # expect 0
```

`autoreconf` should also emit no warnings.

### Configure options

| Option | Default | Effect |
|---|---|---|
| `--disable-strict` | strict on | Drops `-std=c99 -pedantic -Wextra -Wconversion` |
| `--enable-werror` | off | Adds `-Werror` |
| `--disable-hardening` | on | Drops stack protector, FORTIFY, relro/now |
| `--disable-static-daemon` | static on | Links `skydsecd` dynamically |
| `--with-systemdsystemunitdir=DIR` | auto | Unit install dir, or `no` to skip |

### Running locally

```bash
./skydsecd -f -d        # foreground + debug tracing to stderr
./skydsec 127.0.0.1     # query via C client
./skydsec-rust 127.0.0.1 # query via Rust client
```

Without `sudo`, expect `baseboard-serial-number unreadable (Permission denied)`
— `/sys/class/dmi/id/board_serial` is mode `0400 root:root`. That is correct
behaviour, not a bug.

---

## 5. Building Debian and RPM packages

### Debian Package Build:
```bash
./ci/build.sh
```
Or manually:
```bash
cd skydsecd-2.0.0
make dist                                   # -> skydsecd-2.0.0.tar.xz

B=/tmp/debbuild && rm -rf $B && mkdir -p $B
cp skydsecd-2.0.0.tar.xz $B/skydsecd_2.0.0.orig.tar.xz   # note _ and .orig
cd $B && tar xf skydsecd_2.0.0.orig.tar.xz
cp -r /path/to/skydsecd/skydsecd-2.0.0/debian skydsecd-2.0.0/debian
cd skydsecd-2.0.0 && dpkg-buildpackage -us -uc
```


The `_` and `.orig` in the filename are not cosmetic — `dpkg-buildpackage`
matches that name literally and fails without it.

### RPM Package Build:
```bash
./ci/build-rpm.sh
```

### Expected lintian result

```bash
lintian /tmp/debbuild/skydsecd_1.5.0-1_amd64.changes
```

Exactly two findings are expected:
- `E: bad-distribution-in-changes-file stable`
- `W: initial-upload-closes-no-bugs`

`statically-linked-binary` is intentionally overridden in
`debian/skydsecd.lintian-overrides`.

---

## 6. Install, verify, uninstall

```bash
sudo apt-get install -y ./skydsecd_1.5.0-1_amd64.deb
```

Verify:

```bash
systemctl is-enabled skydsecd            # enabled
systemctl is-active  skydsecd            # active
systemctl status     skydsecd --no-pager
skydsec 127.0.0.1                        # query with C client
skydsec-rust 127.0.0.1                   # query with Rust client
ss -ltn | grep 2014
sudo systemctl restart skydsecd          # exercises the SO_REUSEADDR fix
sudo journalctl -u skydsecd -n 20
```


Remove completely:

```bash
sudo systemctl stop skydsecd
sudo systemctl disable skydsecd
sudo apt-get purge -y skydsecd
```

**Installing starts an unauthenticated daemon on `0.0.0.0:2014`, enabled at
boot.** Anyone who can reach that port gets this host's name and hardware
serial. See §8.

---

## 7. Cutting the next release

The version lives in **one** place: `AC_INIT` in `configure.ac`. `config.h`
derives `PROGRAM_VERSION` from it. Do not add a second source.

1. Bump `skydsecd_version_*` in `configure.ac`. **Keep it to three
   components** — a fourth makes `make dist` emit a tarball name
   `dpkg-buildpackage` cannot consume.
2. Add a `debian/changelog` entry with the matching version.
3. Rebuild, repackage, re-run lintian.
4. Tag — annotated and signed, matching the `v<version>` convention:

```bash
git tag -s v1.0.1 -F -    # write a real annotation, not a one-liner
git push origin v1.0.1
```

Tag only commits that are on `master`, or that you are certain will reach
`master` unrewritten. That is the mistake to avoid repeating with `v1.0.0`.

---

## 8. Outstanding — not done, deliberately

**Unauthenticated network endpoint.** The daemon binds `INADDR_ANY:2014` and
serves hostname and hardware serial to anyone who connects, with no
authentication and no access control. Deferred by decision, not oversight.
Options when you pick it up: bind loopback by default, make the bind address
configurable, or put authentication on the protocol. Restrict at the network
layer in the meantime.

**`debian/copyright` wording needs a licensing sign-off.** It previously
declared `debian/*` as GPL-2+ while upstream `COPYRIGHT` says "Skydio Internal
Use Only" — a direct contradiction that shipped in the installed docs. Both
stanzas now declare a single `Skydio-Proprietary` license, **but that text was
newly authored and has not been reviewed by anyone who owns licensing.**

**systemd hardening.** `systemd-analyze security skydsecd` rates the unit
7.6 ("EXPOSED"). Cheap wins available: `UMask=0077`, `PrivateDevices=`,
`CapabilityBoundingSet=`, `SystemCallFilter=@system-service`. The daemon needs
root *only* to read `/sys/class/dmi/id/board_serial`, so a narrow capability set
plus `ReadOnlyPaths=` would likely let it drop root entirely.

**No test suite.** `make check` is a no-op — `Makefile.am` defines no `TESTS`.
The old `tests/` directory was scratch prototypes and was removed. Verification
today is manual (§4, §6).

---

## 9. Invariants — things that look like cleanups but are not

- **Do not hoist `gather_facts()` out of the accept loop.** Probing per
  connection is the point: a startup snapshot lets a host report itself
  compliant long after the tool was removed.
- **Do not call `exit()` anywhere in the serve loop.** A transient probe
  failure must degrade the answer, not kill the daemon.
- **Do not reintroduce `getpwuid`/`getgrgid`.** NSS `dlopen()`s modules at
  runtime even from a static binary, which defeats the static link. Compare raw
  `st_uid`/`st_gid` against `NOBODY_ID` instead.
- **Do not generate the systemd unit with `AC_CONFIG_FILES`.** `config.status`
  substitutes `@sbindir@` as the literal `${exec_prefix}/sbin`, which systemd
  does not expand — the resulting `ExecStart` cannot run. The make rule expands
  it properly.
- **Do not restate `-static` in `skydsecd_CFLAGS`.** A per-target `_CFLAGS`
  *replaces* `AM_CFLAGS`; that is how the daemon ended up compiled without
  `-Wall`.
- **Do not commit generated files.** `configure`, `Makefile`, `aclocal.m4`,
  `src/daemon/skydsecd.service` and the dist tarballs are all ignored. Prefer
  naming paths over `git add -A` — that is exactly how a generated unit file
  got committed once on this branch.
