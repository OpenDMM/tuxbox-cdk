# Why install in $(targetprefix)? Because the library reduction
# expects to find shared libraries there :-\ (Yes, it should be
# fixed there.)

$(flashprefix)/root-neutrino-cramfs-p \
$(flashprefix)/root-neutrino-squashfs-p \
$(flashprefix)/root-neutrino-jffs2-p: \
$(flashprefix)/root-neutrino-%-p: \
$(flashprefix)/root-% $(flashprefix)/root $(appsdir)/tuxbox/neutrino/config.status
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	$(MAKE) -C $(appsdir)/tuxbox/neutrino install prefix=$@
	$(MAKE) -C $(appsdir)/dvb/zapit install prefix=$@
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa    $@/share/fonts
	$(MAKE) $@/lib/ld.so.1
	@TUXBOX_CUSTOMIZE@
