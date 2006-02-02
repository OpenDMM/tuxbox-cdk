# $(targetprefix)/share/locale/*/LC_MESSAGES/libc.mo and
# $(targetprefix)/share/zoneinfo are from the glibc installation

$(flashprefix)/root-enigma-cramfs-p \
$(flashprefix)/root-enigma-squashfs-p \
$(flashprefix)/root-enigma-jffs2-p: \
$(flashprefix)/root-enigma-%-p: \
$(flashprefix)/root-% $(appsdir)/tuxbox/enigma/config.status
	rm -rf $@
	cp -rd $< $@
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install prefix=$@
	$(INSTALL) $(appsdir)/tuxbox/neutrino/daemons/controld/scart.conf $@/var/tuxbox/config
	cp $(appsdir)/tuxbox/neutrino/data/fonts/*.pcf.gz $@/share/fonts
	cp $(appsdir)/tuxbox/neutrino/data/fonts/micron*.ttf $@/share/fonts
	cp -rd $(targetprefix)/share/zoneinfo $@/share
	cp -rd $(targetprefix)/share/locale/de/LC_MESSAGES/libc.mo $@/share/locale/de/LC_MESSAGES
	cp -rd $(targetprefix)/share/locale/fr/LC_MESSAGES/libc.mo $@/share/locale/fr/LC_MESSAGES
	rm -rf $@/share/locale/[a-c]* $@/share/locale/da $@/share/locale/e* $@/share/locale/fi $@/share/locale/[g-t]* $@/share/locale/[m-z]*
	cp $(appsdir)/tuxbox/enigma/po/locale.alias.image $@/share/locale/locale.alias
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma all install prefix=$@
	$(MAKE) $@/lib/ld.so.1
	@TUXBOX_CUSTOMIZE@
