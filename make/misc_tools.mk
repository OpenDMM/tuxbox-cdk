# misc/tools

$(appsdir)/misc/tools/config.status: bootstrap
	cd $(appsdir)/misc/tools && $(CONFIGURE)

misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install


if TARGETRULESET_FLASH
flash-misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

flash-eraseall: $(flashprefix)/root/sbin/eraseall

$(flashprefix)/root/sbin/eraseall: misc_tools | $(flashprefix)/root
	$(INSTALL) $(appsdir)/misc/tools/mtd/eraseall $@
	@FLASHROOTDIR_MODIFIED@

flash-fcp: $(flashprefix)/root/sbin/fcp

$(flashprefix)/root/sbin/fcp: misc_tools | $(flashprefix)/root
	$(INSTALL) $(appsdir)/misc/tools/mtd/fcp $@
	@FLASHROOTDIR_MODIFIED@

endif
