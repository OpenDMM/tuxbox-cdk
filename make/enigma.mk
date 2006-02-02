# tuxbox/enigma

$(appsdir)/tuxbox/enigma/config.status: bootstrap libfreetype libfribidi libmad libid3tag libpng libsigc libjpeg libungif $(targetprefix)/lib/pkgconfig/tuxbox.pc $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/include/tuxbox/plugin.h
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE)

enigma: $(appsdir)/tuxbox/enigma/config.status | tuxbox_tools
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install
