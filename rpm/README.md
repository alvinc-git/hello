# RPM Packaging for hello

![RPM Package](https://img.shields.io/badge/RPM-x86__64-CC0000?style=for-the-badge&logo=redhat)
![Version](https://img.shields.io/badge/version-1.5.0-0052CC?style=for-the-badge)

This directory contains the RPM packaging infrastructure for the standard Hello program.

## Structure

- `SPECS/` - RPM spec files
- `RPMS/` - Built RPM packages (will be populated after build)
- `SOURCES/` - Source tarballs and patches (will be populated after build)
- `BUILD/` - Build environment (will be populated during build)
- `BUILDROOT/` - Installation root (will be populated during build)
- `SRPMS/` - Source RPMs (will be populated after build)

## Building

To build the RPM package:

```bash
# First create the source tarball
cd hello-1.0.0
make dist

# Copy the tarball to the SOURCES directory
mkdir -p ../rpm/SOURCES
cp hello-1.0.0.tar.xz ../rpm/SOURCES/

# Build the RPM
cd ../rpm
rpmbuild --define "_topdir $(pwd)" -ba SPECS/hello.spec
```

## Notes

This packaging mirrors the Debian approach but follows RPM conventions:
- Uses static linking as per security requirements
- Includes systemd service unit
- Maintains all hardening flags
- Follows the same version scheme as Debian
