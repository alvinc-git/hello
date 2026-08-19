# RPM Packaging for hello

![RPM Package](https://img.shields.io/badge/RPM-x86__64-CC0000?style=for-the-badge&logo=redhat)
![Version](https://img.shields.io/badge/version-1.0.0-0052CC?style=for-the-badge)

This directory contains the RPM packaging infrastructure for `hello` (The standard Hello program). It is located within the versioned source directory alongside `debian/` to support version-isolated packaging evolution.

## Structure

- `SPECS/` - RPM spec files (`hello.spec`)
- `RPMS/` - Built RPM packages (populated after build)
- `SOURCES/` - Source tarballs and patches (populated during build)
- `BUILD/` - Build environment (populated during build)
- `BUILDROOT/` - Installation root (populated during build)
- `SRPMS/` - Source RPMs (populated after build)

## Building

To build the RPM package:

```bash
./ci/build-rpm.sh
```

Or manually:

```bash
cd hello-1.0.0

# 1. Generate release source tarball
./autogen.sh
./configure
make dist

# 2. Setup RPM build tree
mkdir -p rpm/SOURCES rpm/BUILD rpm/RPMS rpm/SRPMS
cp hello-1.0.0.tar.xz rpm/SOURCES/

# 3. Build RPM packages
rpmbuild --define "_topdir $(pwd)/rpm" -ba rpm/SPECS/hello.spec
```

The resulting packages will be in `hello-1.0.0/rpm/RPMS/` and `hello-1.0.0/rpm/SRPMS/`.
