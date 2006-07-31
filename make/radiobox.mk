# tuxbox/radiobox

$(appsdir)/tuxbox/radiobox/config.status: bootstrap libboost libcurl libfreetype libmad libid3tag libvorbisidec libtuxbox misc_libs tuxbox_libs misc_tools lufs
	cd $(appsdir)/tuxbox/radiobox && $(CONFIGURE)

radiobox: $(appsdir)/tuxbox/radiobox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/radiobox all install

if TARGETRULESET_FLASH
flash-radiobox: $(flashprefix)/root-radiobox

$(flashprefix)/root-radiobox: $(appsdir)/tuxbox/radiobox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/radiobox all install prefix=$@
	mkdir -p $@/var/tuxbox/config/radiobox
	$(MAKE) radiobox-additional-fonts targetprefix=$@
	touch $@
	@TUXBOX_CUSTOMIZE@

endif

# This is really an ugly kludge. Neutrino and the plugins should
# install the fonts they need in their own Makefiles.
radiobox-additional-fonts:
	mkdir -p $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa    $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/neutrino/data/fonts/*.ttf      $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/neutrino/data/fonts/*.gz       $(targetprefix)/share/fonts
	cp $(appsdir)/tuxbox/neutrino/data/fonts/*.pcf      $(targetprefix)/share/fonts


