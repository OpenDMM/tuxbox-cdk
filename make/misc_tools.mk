# misc/tools

$(appsdir)/misc/tools/config.status: bootstrap
	cd $(appsdir)/misc/tools && $(CONFIGURE)

misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install


if TARGETRULESET_FLASH
flash-eraseall: $(flashprefix)/root/sbin/eraseall

$(flashprefix)/root/sbin/eraseall: misc_tools | $(flashprefix)/root
	$(INSTALL) $(targetprefix)/sbin/eraseall $@
	@FLASHROOTDIR_MODIFIED@

endif
