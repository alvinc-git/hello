# Developer HOWTO: Building and Packaging `hello`

This guide provides step-by-step instructions for software engineers and systems administrators to build, test, package, and deploy `hello` (The standard Hello program).

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Source Code Structure](#2-source-code-structure)
3. [Building from Source](#3-building-from-source)
   - [Bootstrapping (Autotools)](#31-bootstrapping-autotools)
   - [Configuring the Build](#32-configuring-the-build)
   - [Compiling](#33-compiling)
   - [Installation](#34-installation)
4. [Developer Testing & Verification](#4-developer-testing--verification)
   - [Running `hello` in Foreground Debug Mode](#41-running-hello-in-foreground-debug-mode)
   - [Querying via `hello` Client](#42-querying-via-hello-client)
5. [Distribution Packaging](#5-distribution-packaging)
   - [Generating Source Tarballs](#51-generating-source-tarballs)
   - [Building Debian (`.deb`) Packages](#52-building-debian-deb-packages)
6. [Systemd Service Deployment](#6-systemd-service-deployment)
7. [Troubleshooting & FAQs](#7-troubleshooting--faqs)

---

## 1. Prerequisites

Before building `hello`, ensure your Linux build system has standard C compilation tools and GNU Autotools installed.

### On Debian / Ubuntu:
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    dpkg-dev \
    debhelper
```

### On RHEL / Fedora / CentOS:
```bash
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    autoconf \
    automake \
    libtool \
    pkgconfig
```

---

## 2. Source Code Structure

The repository is organized into the main Autotools package and repository tools:

```
hello/
├── README.md                     # Main repository documentation
├── docs/
│   └── BUILD_HOWTO.md            # Developer build guide (this document)
├── hello-1.0.0/               # Primary source tree & Autotools package
│   ├── configure.ac              # Autoconf script
│   ├── Makefile.am               # Automake targets
│   ├── autogen.sh                # Bootstrapping helper script
│   ├── src/
│   │   ├── config.h              # Shared macro definitions & defaults
│   │   ├── skydsecd.c            # Security checker daemon binary source
│   │   ├── skydsec.c             # Client binary source
│   │   └── daemon/
│   │       └── skydsecd.service  # Systemd service unit configuration
│   └── debian/                   # Debian package construction files
└── tests/                        # Additional integration & diagnostic tests
```

---

## 3. Building from Source

All compilation step commands are executed within the package directory:

```bash
cd skydsecd-1.0.0
```

### 3.1 Bootstrapping (Autotools)

If you checked out the codebase directly from git or if `configure` is missing or updated, run `autogen.sh` to generate the `configure` script and build build-aux scripts:

```bash
./autogen.sh
```

*(Alternatively, you can run `autoreconf -v -i -f` directly).*

### 3.2 Configuring the Build

Run `./configure` to inspect system headers, compiler options, and generate `Makefile`s:

```bash
./configure --prefix=/usr
```

#### Common Configuration Flags:
- `--prefix=PREFIX`: Set installation root (e.g. `/usr` or `/usr/local`). Default is `/usr`.
- `CFLAGS="-O2 -g -Wall"`: Pass custom GCC optimization/debug flags.

Example custom build configuration:
```bash
./configure --prefix=/usr CFLAGS="-O2 -Wall -Wextra"
```

### 3.3 Compiling

Compile `hello`:

```bash
make
```

Upon completion, two binaries will be compiled:
- `hello` (Client CLI binary)

### 3.4 Installation

Install binaries to system folders (`/usr/bin/hello`):

```bash
sudo make install
```

To clean build artifacts:
```bash
make clean
```

---

## 4. Developer Testing & Verification

### 4.1 Running `skydsecd` in Foreground Debug Mode

During active development, run `skydsecd` in foreground mode (`-f`) with verbose debugging output (`-d`) on a non-privileged custom port (e.g. `12014`):

```bash
./skydsecd -f -d -p 12014
```

Expected output:
```text
skydsecd daemon listening on port 12014
```

### 4.2 Querying via `skydsec` Client

In a separate terminal window, test the server response using `skydsec`:

```bash
./skydsec -p 12014 127.0.0.1
```

Expected output format:
```text
hostname-node-01
baseboard-serial-number is null, likely a VM
ws1HubUtil not installed
Sun Aug 09 18:40:00 2026
```

---

## 5. Distribution Packaging

### 5.1 Generating Source Tarballs

To generate standard distribution tarballs (`.tar.gz`, `.tar.xz`, `.tar.bz2`):

```bash
make dist
```

To verify that the distribution tarball builds cleanly from scratch:

```bash
make distcheck
```

### 5.2 Building Debian (`.deb`) Packages

To package `skydsecd` into a standard Debian/Ubuntu `.deb` package:

```bash
cd skydsecd-1.0.0
dpkg-buildpackage -us -uc -b
```

This will produce the binary `.deb` package in the parent directory (`../skydsecd_1.0.0_amd64.deb`).

Install the package via `dpkg`:
```bash
sudo dpkg -i ../skydsecd_1.0.0_amd64.deb
```

---

## 6. Systemd Service Deployment

`skydsecd` includes a systemd unit template located at [`src/daemon/skydsecd.service`](file:///home/alvinc/bitbucket/skydsecd/skydsecd-1.0.0/src/daemon/skydsecd.service).

### Installation Steps:

1. Copy service file to systemd directory:
   ```bash
   sudo cp src/daemon/skydsecd.service /etc/systemd/system/skydsecd.service
   ```
2. Reload systemd daemon:
   ```bash
   sudo systemctl daemon-reload
   ```
3. Start and enable service on boot:
   ```bash
   sudo systemctl enable --now skydsecd.service
   ```
4. Check service status & logs:
   ```bash
   sudo systemctl status skydsecd.service
   sudo journalctl -u skydsecd.service -f
   ```

---

## 7. Troubleshooting & FAQs

- **Error: `Address already in use` (EADDRINUSE)**:  
  Ensure another instance of `skydsecd` is not already bound to port 2014. Use `lsof -i :2014` or `ss -tulpn | grep 2014` to check. The daemon uses `SO_REUSEADDR` to allow rapid restart.

- **Error: `stat(/sys/class/dmi/id/board_serial) failed`**:  
  Certain virtualized containers (Docker/LXC/VMs) do not expose DMI sysfs nodes. `skydsecd` gracefully handles missing sysfs nodes and returns `"baseboard-serial-number is null, likely a VM"` or `"Unprivileged container"`.

- **Rebuilding `configure` script**:  
  If modifying `configure.ac` or `Makefile.am`, always run `./autogen.sh` or `autoreconf -v -i -f` before running `./configure`.
