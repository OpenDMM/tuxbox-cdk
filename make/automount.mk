if KERNEL26
else
$(DEPDIR)/automount: bootstrap @DEPENDS_automount@
	@PREPARE_automount@
	cd @DIR_automount@  && \
		$(BUILDENV) STRIP=$(target)-strip \
		$(MAKE) && \
		$(MAKE) install INSTALLROOT=$(targetprefix)
	rm -rf @DIR_automount@
#	$(INSTALL) $(buildprefix)/root/etc/init.d/start_automount $(targetprefix)/etc/init.d
	ln -sf /proc/mounts $(targetprefix)/etc/mtab
	@touch $@

if TARGETRULESET_FLASH

flash-automount: @DEPENDS_automount@ | $(flashprefix)/root
	@PREPARE_automount@
	cd @DIR_automount@  && \
		$(BUILDENV) STRIP=$(target)-strip \
		$(MAKE) && \
		$(MAKE) install SUBDIRS="lib daemon modules" INSTALLROOT=$(flashprefix)/root
	rm -rf @DIR_automount@
#	$(INSTALL) $(buildprefix)/root/etc/init.d/start_automount $(flashprefix)/root/etc/init.d
	ln -sf /proc/mounts $(flashprefix)/root/etc/mtab
endif

endif
