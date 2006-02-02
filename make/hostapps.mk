$(hostappsdir)/config.status: bootstrap
	cd $(hostappsdir) && \
	./autogen.sh && \
	./configure --prefix=$(hostprefix)

hostapps: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)
#	touch $@

if TARGETRULESET_FLASH

$(hostprefix)/bin/mkflfs: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/mkflfs install

$(hostprefix)/bin/checkImage:
	$(MAKE) -C $(hostappsdir)/checkImage install INSTALLDIR=$(hostprefix)/bin

endif
