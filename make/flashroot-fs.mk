$(flashprefix)/root-cramfs: bootstrap $(hostprefix)/bin/mkimage
	rm -rf $@
	m4 --define=rootfs=cramfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_CRAMFS[= ].*$$/CONFIG_CRAMFS=y/' $(IDE_SED_CONF) Patches/linux-$(KERNELVERSION).config-flash > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2: bootstrap $(hostprefix)/bin/mkimage
	rm -rf $@
	m4 --define=rootfs=jffs2 --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_JFFS2_FS[= ].*$$/CONFIG_JFFS2_FS=y/' $(IDE_SED_CONF) Patches/linux-$(KERNELVERSION).config-flash > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-squashfs: bootstrap $(hostprefix)/bin/mkimage
	rm -rf $@
	m4 --define=rootfs=squashfs --define=rootsize=$(ROOT_PARTITION_SIZE) Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	sed -e 's/.*CONFIG_SQUASHFS[= ].*$$/CONFIG_SQUASHFS=y/' $(IDE_SED_CONF) Patches/linux-$(KERNELVERSION).config-flash > $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
	$(MAKE) driver targetprefix=$@
	rm -f $@/lib/modules/$(KERNELVERSION)/build
	@TUXBOX_CUSTOMIZE@
