# Kernel
#
# Yes, this depends on $(KERNEL_DIR)/.config, which the Makefile does not have
# as a target.
# This is deliberate, and makes the target "private".

#$(DEPDIR)/linuxkernel: bootstrap linuxdir $(KERNEL_DIR)/.config
$(KERNEL_BUILD_FILENAME): bootstrap linuxdir $(KERNEL_DIR)/.config
	$(MAKE) -C $(KERNEL_DIR) oldconfig ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) uImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
else
	$(MAKE) -C $(KERNEL_DIR) zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
endif
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)
# if KERNEL26
# 	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $(bootprefix)/kernel-cdk
# else
#	$(hostprefix)/bin/mkimage \
#		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
#		-a 00000000 -e 00000000 \
#		-d $(KERNEL_DIR)/arch/ppc/boot/images/vmlinux.gz \
#		$(bootprefix)/kernel-cdk
# endif
#	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
#	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
#	touch $@

if ENABLE_IDE
IDE_SED_CONF=$(foreach param,CONFIG_IDE CONFIG_BLK_DEV_IDE CONFIG_BLK_DEV_IDEDISK CONFIG_EXT2_FS CONFIG_EXT3_FS CONFIG_JBD,-e s"/^.*$(param)[= ].*/$(param)=m/")
else
IDE_SED_CONF=-e ""
endif

kernel-cdk: $(bootprefix)/kernel-cdk

$(bootprefix)/kernel-cdk: linuxdir $(hostprefix)/bin/mkimage Patches/linux-$(KERNELVERSION).config Patches/dbox2-flash.c.m4
	sed $(IDE_SED_CONF) Patches/linux-$(KERNELVERSION).config \
		> $(KERNEL_DIR)/.config
	m4 Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	$(MAKE) $(KERNEL_BUILD_FILENAME)
if KERNEL26
# not tested
	$(INSTALL) -m644 $(KERNEL_DIR)/arch/ppc/boot/images/uImage $@
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d $(KERNEL_BUILD_FILENAME) \
		$@
endif
	chmod 644 $@
	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/var/run

driver: $(KERNEL_BUILD_FILENAME)
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) \
		install

driver-clean:
	$(MAKE) -C $(driverdir) \
		KERNEL_LOCATION=$(buildprefix)/linux \
		distclean
#	-rm $(DEPDIR)/driver

$(driverdir)/directfb/Makefile: bootstrap libdirectfb
	cd $(driverdir)/directfb && \
	$(BUILDENV) \
	./autogen.sh \
		--build=$(build) \
		--host=$(target) \
		--prefix= \
		--enable-maintainer-mode \
		--with-kernel-source=$(buildprefix)/linux

$(DEPDIR)/directfb_gtx: $(driverdir)/directfb/Makefile
	$(MAKE) -C $(driverdir)/directfb all install DESTDIR=$(targetprefix)
	touch $@

.PHONY: driver-clean
