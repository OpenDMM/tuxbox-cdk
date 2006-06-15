$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ Patches/busybox.config.m4 Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dyadd Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ Patches/busybox.config.m4 Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dflash Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		$(MAKE) install PREFIX=$(flashprefix)/root
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
