%define vers 1.0.0

Name: scaleimp
Version: %{vers}
Release: 1%{?dist}
Epoch: 1
Summary: Scale and length calculator in Tcl/Tk
License: GPL-3.0+
URL: https://github.com/Montandalar/ScaleImp
Requires: tk = %{epoch}:%{vers}
BuildRequires: make

%description
ScaleImp is a tool to convert dimensions between imperial and metric units,
and at your chosen scale. ScaleImp always calculates based on a source unit,
and gives the other three dimensions.

%prep
#Nothing to do

%build
make

%install
make install BASEDIR=%{buildroot}

%files
%{_bindir}/scaleimp
%{_datadir}/applications/scaleimp.desktop
%{_datadir}/icons/hicolor/16x16/apps/scaleimp.png
%{_datadir}/icons/hicolor/24x24/apps/scaleimp.png
%{_datadir}/icons/hicolor/32x32/apps/scaleimp.png
%{_datadir}/icons/hicolor/48x48/apps/scaleimp.png
%{_datadir}/icons/hicolor/128x128/apps/scaleimp.png

%changelog
* Fri Jan 28 2022 Jason Bigelow <jbis1337@hotmail.com> - 1:1.0.0-1
- Initial release
