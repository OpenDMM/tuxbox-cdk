#### Targets for building $partition-$gui.$fstype

####### var-$gui.jffs2
$(flashprefix)/var-neutrino.jffs2 $(flashprefix)/var-enigma.jffs2: \
$(flashprefix)/var-%.jffs2: $(flashprefix)/var-% $(MKJFFS2)
	@if [ "$(MKJFFS2)" = "/bin/false" ] ; then \
		echo "FATAL ERROR: No mkjffs2 or mkfs.jffs2 available"; \
		false; \
	fi
	$(MKJFFS2) -b -e 131072 -p -r $< -o $@

####### root-$gui.$fstype
$(flashprefix)/root-neutrino.cramfs $(flashprefix)/root-enigma.cramfs: \
$(flashprefix)/root-%.cramfs: $(flashprefix)/root-%-cramfs $(MKCRAMFS)
	$(MKCRAMFS) -p -n "0106`date +%Y%m%d%H%M`" $< $@

$(flashprefix)/root-neutrino.squashfs $(flashprefix)/root-enigma.squashfs: \
$(flashprefix)/root-%.squashfs: $(flashprefix)/root-%-squashfs $(MKSQUASHFS)
	rm -f $@
	$(MKSQUASHFS) $< $@ -be
	chmod 644 $@

$(flashprefix)/root-neutrino.jffs2 $(flashprefix)/root-enigma.jffs2: \
$(flashprefix)/root-%.jffs2: $(flashprefix)/root-%-jffs2 $(MKJFFS2)
	@if [ "$(MKJFFS2)" = "/bin/false" ] ; then \
		echo "FATAL ERROR: No mkjffs2 or mkfs.jffs2 available"; \
		false; \
	fi
	$(MKJFFS2)  -b -e 0x20000 --pad=0x7c0000 -r $< -o $@

################ $fs-to-boot.flfs*x
$(flashprefix)/cramfs.flfs1x $(flashprefix)/cramfs.flfs2x: \
$(hostprefix)/bin/mkflfs $(bootdir)/u-boot-config/u-boot.dbox2.h.m4 \
| $(flashprefix)
	m4 --define=rootfstype=squashfs --define=rootsize=$(ROOT_PARTITION_SIZE) $(bootdir)/u-boot-config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/cramfs.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/cramfs.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(flashprefix)/squashfs.flfs1x $(flashprefix)/squashfs.flfs2x: \
$(hostprefix)/bin/mkflfs $(bootdir)/u-boot-config/u-boot.dbox2.h.m4  \
| $(flashprefix)
	m4 --define=rootfstype=squashfs --define=rootsize=$(ROOT_PARTITION_SIZE) $(bootdir)/u-boot-config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/squashfs.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/squashfs.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(flashprefix)/jffs2.flfs1x $(flashprefix)/jffs2.flfs2x: \
$(hostprefix)/bin/mkflfs $(bootdir)/u-boot-config/u-boot.dbox2.h.m4 \
| $(flashprefix)
	m4 --define=rootfstype=jffs2 $(bootdir)/u-boot-config/u-boot.dbox2.h.m4 > $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/jffs2.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/jffs2.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config
