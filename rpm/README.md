# RPM Packaging for hello

![RPM Package](https://img.shields.io/badge/RPM-x86__64-CC0000?style=for-the-badge&logo=redhat)
![Version](https://img.shields.io/badge/version-1.0.0-0052CC?style=for-the-badge)

This directory contains the RPM packaging infrastructure for `hello` (The standard Hello program).

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
# First create the source tarball
cd hello-1.0.0
./autogen.sh
./configure
make dist

# Copy the tarball to the SOURCES directory
mkdir -p ../rpm/SOURCES
cp hello-1.0.0.tar.xz ../rpm/SOURCES/

# Build the RPM
cd ../rpm
rpmbuild --define "_topdir $(pwd)" -ba SPECS/hello.spec
```

The resulting packages will be in `rpm/RPMS/` and `rpm/SRPMS/`.
