# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/config.status: bootstrap libid3tag libmad libvorbisidec $(appsdir)/dvb/zapit/src/zapit libboost libjpeg libcurl libfreetype libpng $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install

if TARGETRULESET_FLASH
flash-neutrino: $(flashprefix)/root-neutrino

# Why install in $(targetprefix)? Because the library reduction
# expects to find shared libraries there :-\ (Yes, it should be fixed
# there.)

$(flashprefix)/root-neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	$(MAKE) -C $(appsdir)/tuxbox/neutrino install prefix=$@
	$(MAKE) -C $(appsdir)/dvb/zapit install prefix=$@
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa    $@/share/fonts
	touch $@
	@TUXBOX_CUSTOMIZE@

endif
