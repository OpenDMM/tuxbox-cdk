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

#######################
#
# mksquashfs with LZMA support
#
$(hostprefix)/bin/mksquashfs: @DEPENDS_squashfs@
	rm -rf @DIR_squashfs@
	mkdir -p @DIR_squashfs@
	cd @DIR_squashfs@ && \
	bunzip2 -cd ../Archive/lzma442.tar.bz2 | TAPE=- tar -x && \
	patch -p1 < ../Patches/lzma_zlib-stream.diff && \
	gunzip -cd ../Archive/squashfs3.0.tar.gz | TAPE=- tar -x && \
	patch -p0 < ../Patches/mksquashfs_lzma.diff
	$(MAKE) -C @DIR_squashfs@/C/7zip/Compress/LZMA_Lib
	$(MAKE) -C @DIR_squashfs@/squashfs3.0/squashfs-tools
	$(INSTALL) -m755 @DIR_squashfs@/squashfs3.0/squashfs-tools/mksquashfs $@
	rm -rf @DIR_squashfs@

endif
