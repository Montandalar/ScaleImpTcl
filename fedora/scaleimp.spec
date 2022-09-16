%define vers 1.0.1

Name: scaleimp
Version: %{vers}
Release: 1%{?dist}
Epoch: 1
Summary: Scale and length calculator in Tcl/Tk
License: GPLv3
URL: https://github.com/Montandalar/ScaleImp
Source0: https://github.com/Montandalar/ScaleImpTcl/archive/refs/tags/%{vers}.tar.gz
Requires: tk >= 8.10
BuildArch: noarch
BuildRequires: make

%description
ScaleImp is a tool to convert dimensions between imperial and metric units,
and at your chosen scale. ScaleImp always calculates based on a source unit,
and gives the other three dimensions.

%prep
%setup -n ScaleImpTcl-%{vers} -q

%build
make

%install
make install DESTDIR=%{buildroot}

%files
%{_bindir}/scaleimp
%{_datadir}/applications/scaleimp.desktop
%{_datadir}/icons/hicolor/16x16/apps/scaleimp.png
%{_datadir}/icons/hicolor/24x24/apps/scaleimp.png
%{_datadir}/icons/hicolor/32x32/apps/scaleimp.png
%{_datadir}/icons/hicolor/48x48/apps/scaleimp.png
%{_datadir}/icons/hicolor/128x128/apps/scaleimp.png
%doc README.md LICENCE.txt

%changelog
* Fri Sep 16 2022 Jason Bigelow <jbis1337@hotmail.com> - 1:1.0.1-1
- Fix numpad input for Linux and macOS.
- Bind keyboard navigation modifier to Cmd on Mac.
- macOS is now supported.
- The program can be entirely built on the command line without any GUI elements
at all now.
- Bind Ctrl-A to select all text in text inputs under Linux.
- Wrote the end user manual up
- Improved and streamlined the self-compilation processes.
- ScaleImp is now built and released through GitLab CI/CD.

* Fri Jan 28 2022 Jason Bigelow <jbis1337@hotmail.com> - 1:1.0.0-1
- Initial release
