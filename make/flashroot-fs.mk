$(flashprefix)/root-cramfs: $(flashprefix)/root
	rm -rf $@
	cp -rd $< $@
	m4 --define=rootfs=cramfs Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	cp Patches/linux-$(KERNELVERSION).config-flash $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
#	rm -f $(DEPDIR)/driver
	$(MAKE) driver targetprefix=$@
	if [ -d $</lib/modules ] ; then \
		cp -rd $</lib/modules/* $@/lib/modules; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2: $(flashprefix)/root
	rm -rf $@
	cp -rd $< $@
	m4 --define=rootfs=jffs2 Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	cp Patches/linux-$(KERNELVERSION).config-flash $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
#	rm -f $(DEPDIR)/driver
	$(MAKE) driver targetprefix=$@
	if [ -d $</lib/modules ] ; then \
		cp -rd $</lib/modules/* $@/lib/modules; \
	fi
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-squashfs: $(flashprefix)/root
	rm -rf $@
	cp -rd $< $@
	m4 --define=rootfs=squashfs Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	cp Patches/linux-$(KERNELVERSION).config-flash $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
#	rm -f $(DEPDIR)/driver
	$(MAKE) driver targetprefix=$@
	if [ -d $</lib/modules ] ; then \
		cp -rd $</lib/modules/* $@/lib/modules; \
	fi
	@TUXBOX_CUSTOMIZE@
