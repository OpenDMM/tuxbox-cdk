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

$(hostprefix)/bin/checkImage: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/checkImage install INSTALLDIR=$(hostprefix)/bin

$(hostprefix)/bin/mkfs.jffs2: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/mkfs.jffs2 install INSTALLDIR=$(hostprefix)/bin

$(hostprefix)/bin/mkcramfs: @DEPENDS_cramfs@
	@PREPARE_cramfs@
	cd @DIR_cramfs@ && \
	$(MAKE) mkcramfs && \
	$(INSTALL) mkcramfs $@
	rm -rf @DIR_cramfs@

$(hostprefix)/bin/mksquashfs: @DEPENDS_squashfs@
	@PREPARE_squashfs@
	cd @DIR_squashfs@/squashfs-tools && \
	$(MAKE) CC=$(CC) mksquashfs && \
	$(INSTALL) mksquashfs $@
	rm -rf @DIR_squashfs@

endif
