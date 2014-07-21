Name:       thud
Version:    1
Release:    1%{?rev}%{?dist}
Summary:    Bash utility function library

License:    GPLv2+
BuildArch:  noarch
Source:     %{name}-%{version}.tar.gz

Requires:   gawk
Requires:   bash

%description

%prep
%setup -q

%build
%configure
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%files
%doc %{_datadir}/doc/%{name}/README.md
%{_bindir}/thud-*
%{_datadir}/%{name}

%changelog
