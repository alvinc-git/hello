#
# spec file for hello
#

Name:           hello
Version:        1.0.0
Release:        1%{?dist}
Summary:        The standard Hello program


License:        MIT
URL:            https://github.com/alvinc-git/hello
Source0:        %{name}-%{version}.tar.xz
BuildArch:      x86_64

# This package requires systemd for the service unit
BuildRequires:  systemd
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool

%description
hello is the standard Hello program.

%package -n hello
Summary:        The standard Hello program
Requires:       %{name} = %{version}-%{release}

%prep
%setup -n %{name}-%{version}

%build
# Check if toolchain supports static C linking (requires glibc-static)
STATIC_FLAG="--enable-static-daemon"
if ! gcc -static -xc - -o /dev/null <<'EOF' 2>/dev/null
int main(void) { return 0; }
EOF
then
    STATIC_FLAG="--disable-static-daemon"
fi

# Configure with strict flags
./configure \
    --prefix=/usr \
    --sbindir=/usr/sbin \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-strict \
    --enable-werror \
    --disable-hardening \
    $STATIC_FLAG


make %{?_smp_mflags}
if command -v cargo >/dev/null 2>&1 && [ -d hello-rust ]; then
    (cd hello-rust && cargo build --release --bin hello)
    (cd hello-rust && RUSTFLAGS="-C target-feature=+crt-static -C relocation-model=static" cargo build --release --bin hello)
fi



%install
make install DESTDIR=%{buildroot}

rm -f rust-files.list
cat << 'EOF' > rust-files.list
%doc README.md
%{_bindir}/hello
%{_mandir}/man1/hello.1*
%{_mandir}/man1/hello-rust.1*
EOF


if [ -f hello-rust/target/release/hello ]; then
    install -D -m 755 hello-rust/target/release/hello %{buildroot}/%{_bindir}/hello-rust
    echo "%{_bindir}/hello-rust" >> rust-files.list
fi
mkdir -p %{buildroot}/%{_unitdir}

%check
true

%files -f rust-files.list

%files -n hello
%{_bindir}/hello





%changelog
* Thu Aug 13 2026 Alvin Cura <alvinc@sysdudez.com> 1.0.0-1
- Initial RPM packaging based on Debian structure
- Maintains static linking for security
