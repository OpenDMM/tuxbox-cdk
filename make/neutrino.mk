# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/config.status: bootstrap libid3tag libmad libvorbisidec $(appsdir)/dvb/zapit/src/zapit libboost libjpeg libcurl libfreetype libpng $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install

if TARGETRULESET_FLASH
flash-neutrino: $(flashprefix)/root-neutrino

$(flashprefix)/root-neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install prefix=$@
	$(MAKE) -C $(appsdir)/dvb/zapit install prefix=$@
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $@/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa    $@/share/fonts
	touch $@
	@TUXBOX_CUSTOMIZE@

endif
