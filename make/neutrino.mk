# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/config.status: bootstrap libid3tag libmad libvorbisidec $(appsdir)/dvb/zapit/src/zapit libboost libjpeg libcurl libfreetype libpng $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
