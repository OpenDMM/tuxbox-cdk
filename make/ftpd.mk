$(DEPDIR)/ftpd: bootstrap @DEPENDS_ftpd@
	-rm -rf $(targetprefix)/share/empty
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_ftpd@
	@CLEANUP_ftpd@
	touch $@

if TARGETRULESET_FLASH

# Remark: the install target in the Makefile in in.ftpd is not GNU-conformant,
# therefor the silly install command.
flash-ftpd: | $(flashprefix)/root @DEPENDS_ftpd@
	-rm -rf $(flashprefix)/root/share/empty
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		$(INSTALL) -m755 vsftpd $(flashprefix)/root/sbin/in.ftpd && \
		$(INSTALL) -m644 vsftpd-dbox2.conf $(flashprefix)/root/etc/vsftpd.conf && \
		$(INSTALL) -d $(flashprefix)/root/share/empty
	@CLEANUP_ftpd@
	@TUXBOX_CUSTOMIZE@

endif
