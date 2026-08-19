#
# spec file for hello
#

Name:           hello
Version:        1.0.0
Release:        1%{?dist}
Summary:        Standard Hello program

License:        MIT
URL:            https://github.com/alvinc-git/hello
Source0:        %{name}-%{version}.tar.xz

BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  libtool

%description
hello is the standard Hello program. Includes C, Rust, and Go implementations.

%prep
%setup -q

%build
./configure \
    --prefix=/usr \
    --sbindir=/usr/sbin \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --disable-strict \
    --enable-werror \
    --disable-hardening

make %{?_smp_mflags}
if command -v cargo >/dev/null 2>&1 && [ -d hello-rust ]; then
    (cd hello-rust && cargo build --release)
fi
if command -v go >/dev/null 2>&1 && [ -d hello-go ]; then
    (cd hello-go && go build -ldflags "-X main.programVersion=%{version}" -o hello_go main.go)
fi

%install
make install DESTDIR=%{buildroot}

rm -f file.list
cat << 'EOF' > file.list
%doc README.md
%{_bindir}/hello
%{_mandir}/man1/hello.1*
EOF

if [ -f hello-rust/target/release/hello_rust ]; then
    install -D -m 755 hello-rust/target/release/hello_rust %{buildroot}/%{_bindir}/hello_rust
    install -D -m 644 man/hello_rust.1 %{buildroot}/%{_mandir}/man1/hello_rust.1
    echo "%{_bindir}/hello_rust" >> file.list
    echo "%{_mandir}/man1/hello_rust.1*" >> file.list
fi

if [ -f hello-go/hello_go ]; then
    install -D -m 755 hello-go/hello_go %{buildroot}/%{_bindir}/hello_go
    install -D -m 644 man/hello_go.1 %{buildroot}/%{_mandir}/man1/hello_go.1
    echo "%{_bindir}/hello_go" >> file.list
    echo "%{_mandir}/man1/hello_go.1*" >> file.list
fi

%check
%{buildroot}/%{_bindir}/hello

%files -f file.list

%changelog
* Thu Aug 13 2026 Alvin Cura <alvinc@sysdudez.com> 1.0.0-1
- Initial release of hello 1.0.0 (The standard Hello program)
