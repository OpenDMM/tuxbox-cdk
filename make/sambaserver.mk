if ENABLE_SAMBASERVER

sambaserver: samba

$(DEPDIR)/samba: bootstrap @DEPENDS_samba@
	@PREPARE_samba@
	cd @DIR_samba@ && \
		$(INSTALL) -m 644 examples/dbox/smb.conf.dbox $(targetprefix)/etc/smb.conf && \
		cd source && \
		$(MAKE) make_smbcodepage CC=$(CC) && \
		$(INSTALL) -d $(targetprefix)/lib/codepages && \
		./make_smbcodepage c 850 codepage_def.850 \
			$(targetprefix)/lib/codepages/codepage.850 && \
		$(MAKE) clean && \
		for i in smbd nmbd smbclient smbmount smbmnt smbpasswd; do \
			$(MAKE) $$i; \
			cp $$i $(targetprefix)/bin; \
		done; \
		$(INSTALL) -m 644 $(buildprefix)/root/etc/smb.conf $(targetprefix)/etc && \
		$(INSTALL) -m 644 $(buildprefix)/root/etc/smbpasswd $(targetprefix)/etc
	@CLEANUP_samba@
	touch $@

if TARGETRULESET_FLASH
flash-sambaserver: flash-samba

flash-samba: $(flashprefix)/root/sbin/samba

$(flashprefix)/root/sbin/samba: bootstrap @DEPENDS_samba@ | $(flashprefix)/root
	@PREPARE_samba@
	cd @DIR_samba@ && \
		$(INSTALL) -m 644 examples/dbox/smb.conf.dbox $(flashprefix)/root/etc/smb.conf && \
		cd source && \
		$(MAKE) make_smbcodepage CC=$(CC) && \
		$(INSTALL) -d $(flashprefix)/root/lib/codepages && \
		./make_smbcodepage c 850 codepage_def.850 \
			$(flashprefix)/root/lib/codepages/codepage.850 && \
		$(MAKE) clean && \
		for i in smbd nmbd smbpasswd; do \
			$(MAKE) $$i; \
			cp $$i $(flashprefix)/root/bin; \
		done; \
		$(INSTALL) -m 644 $(buildprefix)/root/etc/smb.conf $(flashprefix)/root/var/etc && \
		$(INSTALL) -m 644 $(buildprefix)/root/etc/smbpasswd $(flashprefix)/root/var/etc ;
	@CLEANUP_samba@
	@FLASHROOTDIR_MODIFIED@

endif

endif
