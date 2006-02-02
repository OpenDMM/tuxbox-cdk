# Bootloader: u-boot
#
# This target builds a u-boot, assuming that u-boot.config has been 
# setup correctly.
# Therefore, it depends on $(bootdir)/u-boot-config/u-boot.config, which the 
# Makefile does not have as an explicit target.
# This is deliberate, and makes the target sort-of "private".

@DIR_uboot@/u-boot.stripped: bootstrap @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.config
	@PREPARE_uboot@
	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot@
	cp -p $(bootdir)/u-boot-config/u-boot.config @DIR_uboot@/include/configs/dbox2.h
	$(MAKE) -C @DIR_uboot@ dbox2_config
	$(MAKE) -C @DIR_uboot@ CROSS_COMPILE=$(target)- u-boot.stripped
	$(INSTALL) @DIR_uboot@/tools/mkimage $(hostprefix)/bin
#	@CLEANUP_uboot@
#	touch $@

yadd-u-boot: $(bootprefix)/u-boot

$(bootprefix)/u-boot \
$(hostprefix)/bin/mkimage: @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.cdk.dbox2.h
	ln -sf ./u-boot.cdk.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $(bootprefix)/u-boot
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config
