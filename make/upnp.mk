$(DEPDIR)/fuse: bootstrap @DEPENDS_fuse@
	@PREPARE_fuse@
	cd @DIR_fuse@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(targetprefix)
	@CLEANUP_fuse@
	touch $@

$(DEPDIR)/djmount: bootstrap fuse @DEPENDS_djmount@
	@PREPARE_djmount@
	cd @DIR_djmount@ && \
	$(BUILDENV) \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(targetprefix)
	@CLEANUP_djmount@
	touch $@

if TARGETRULESET_FLASH

flash-upnp: flash-fuse flash-djmount

flash-fuse: bootstrap @DEPENDS_fuse@
	@PREPARE_fuse@
	cd @DIR_fuse@ && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(flashprefix)/root
	@CLEANUP_fuse@
	@FLASHROOTDIR_MODIFIED@

flash-djmount: bootstrap flash-fuse @DEPENDS_djmount@
	@PREPARE_djmount@
	cd @DIR_djmount@ && \
	$(BUILDENV) \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(flashprefix)/root
	@CLEANUP_djmount@
	@FLASHROOTDIR_MODIFIED@

endif
