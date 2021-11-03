#Debhelper can't change filenames when installing, so make a local directory structure
DESTDIR ?=

scaleimp: scaleimp.tcl
	cp scaleimp.tcl scaleimp

.PHONY: install
install:
	mkdir -p ${DESTDIR}/usr/bin
	mkdir -p ${DESTDIR}/usr/share/icons/hicolor/16x16/apps/
	mkdir -p ${DESTDIR}/usr/share/icons/hicolor/24x24/apps/
	mkdir -p ${DESTDIR}/usr/share/icons/hicolor/32x32/apps/
	mkdir -p ${DESTDIR}/usr/share/icons/hicolor/48x48/apps/
	mkdir -p ${DESTDIR}/usr/share/icons/hicolor/128x128/apps/
	mkdir -p ${DESTDIR}/usr/share/applications/
	install scaleimp.tcl ${DESTDIR}/usr/bin/scaleimp
	install scaleimp16.png ${DESTDIR}/usr/share/icons/hicolor/16x16/apps/scaleimp.png -m 644
	install scaleimp24.png ${DESTDIR}/usr/share/icons/hicolor/24x24/apps/scaleimp.png -m 644
	install scaleimp32.png ${DESTDIR}/usr/share/icons/hicolor/32x32/apps/scaleimp.png -m 644
	install scaleimp48.png ${DESTDIR}/usr/share/icons/hicolor/48x48/apps/scaleimp.png -m 644
	install scaleimp128.png ${DESTDIR}/usr/share/icons/hicolor/128x128/apps/scaleimp.png -m 644
	install scaleimp.desktop ${DESTDIR}/usr/share/applications/scaleimp.desktop -m 644

.PHONY: uninstall
uninstall:
	rm -rf ${DESTDIR}/usr/bin/scaleimp
	rm -rf ${DESTDIR}/usr/share/icons/hicolor/16x16/apps/scaleimp.png
	rm -rf ${DESTDIR}/usr/share/icons/hicolor/24x24/apps/scaleimp.png
	rm -rf ${DESTDIR}/usr/share/icons/hicolor/32x32/apps/scaleimp.png
	rm -rf ${DESTDIR}/usr/share/icons/hicolor/48x48/apps/scaleimp.png
	rm -rf ${DESTDIR}/usr/share/icons/hicolor/128x128/apps/scaleimp.png
	rm -rf ${DESTDIR}/usr/share/applications/scaleimp.desktop

.PHONY: clean
clean:
	rm -f scaleimp
	rm -fr usr
