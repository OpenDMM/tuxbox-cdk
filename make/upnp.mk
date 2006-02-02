$(DEPDIR)/fuse: bootstrap
	( rm -rf fuse-2.5.1 || /bin/true ) && gunzip -cd Archive/fuse-2.5.1.tar.gz | TAPE=- tar -x && ( cd fuse-2.5.1; patch -p1 < ../Patches/fuse.diff )
	cd fuse-2.5.1 && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(targetprefix)
	rm -rf fuse-2.5.1
	touch $@

$(DEPDIR)/djmount: bootstrap
	( rm -rf djmount-0.51 || /bin/true ) && gunzip -cd Archive/djmount-0.51.tar.gz | TAPE=- tar -x
	cd djmount-0.51 && \
	$(BUILDENV) \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(targetprefix)
	rm -rf djmount-0.51
	touch $@

if TARGETRULESET_FLASH

flash-upnp: flash-fuse flash-djmount

flash-fuse: bootstrap
	( rm -rf fuse-2.5.1 || /bin/true ) && gunzip -cd Archive/fuse-2.5.1.tar.gz | TAPE=- tar -x && ( cd fuse-2.5.1; patch -p1 < ../Patches/fuse.diff )
	cd fuse-2.5.1 && \
	$(BUILDENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --with-kernel=$(buildprefix)/$(KERNEL_DIR) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(flashprefix)/root
	rm -rf fuse-2.5.1

flash-djmount: bootstrap flash-fuse
	( rm -rf djmount-0.51 || /bin/true ) && gunzip -cd Archive/djmount-0.51.tar.gz | TAPE=- tar -x
	cd djmount-0.51 && \
	$(BUILDENV) \
	./configure \
	   --build=$(build) \
	   --host=$(target) \
	   --prefix= && \
	$(MAKE) all && \
	$(MAKE) install DESTDIR=$(flashprefix)/root
	rm -rf djmount-0.51

endif
