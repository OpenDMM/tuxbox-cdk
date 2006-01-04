## Makefile for Tuxbox
#
# These variables are only used for generating template files in
# $(serversupport). Therefore, if they are not right, just override
# them from the invoking command, or edit the
# generated files.  It is not really worthwhile to make them ./configure-able.

DBOX_IP = 192.168.1.5
DBOX_SUBNET = $(basename $(DBOX_IP)).0
DBOX_SUBNETMASK = 255.255.255.0
DBOX_MAC = 00:50:9c:xx:xx:x

PATH := $(hostprefix)/bin:$(PATH)
BUILDENV := \
	AR=$(target)-ar \
	AS=$(target)-as \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	NM=$(target)-nm \
	RANLIB=$(target)-ranlib \
	CFLAGS="$(TARGET_CFLAGS)" \
	CXXFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(targetprefix)/lib/pkgconfig

################################################################
if ENABLE_OLDTARGETS
all: yadd-all
else
all:
	@echo "You probably do not want to build all possible targets."
	@echo "Sensible targets are, e.g. yadd-enigma or flash-neutrino-jffs2-2x."
	@echo "If you REALLY want to build everything, then \"make everything\""
endif

extra: libs libs_optional contrib_apps fun dvb_apps root_optional udev

root_optional: mrouted
#root_optional: mrouted portmap

if TARGETRULESET_FLASH
everything: yadd-all flash-all-all-all extra serversupport 
else
everything: yadd-all extra serversupport
endif

# This rule script checks if all archives are present at the given address but
# does NOT download them.
#
# It takes some time so it's not useful to include it in a regular
# build

archivecheck:
	@$(buildprefix)/rules-downcheck.pl

#######################
#
#   core
#

core: directories binutils linuxdir glibc gcc

DEPDIR = .deps

VPATH = $(DEPDIR)

$(DEPDIR):
	$(INSTALL) -d $(DEPDIR)

$(DEPDIR)/bootstrap: gcc
	touch $@

$(DEPDIR)/directories:
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/boot
	$(INSTALL) -d $(targetprefix)/dev
	$(INSTALL) -d $(targetprefix)/etc
	$(INSTALL) -d $(targetprefix)/include
	$(INSTALL) -d $(targetprefix)/mnt
	$(INSTALL) -d $(targetprefix)/lib
	$(INSTALL) -d $(targetprefix)/lib/pkgconfig
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/root
	$(INSTALL) -d $(targetprefix)/sbin
if KERNEL26
	$(INSTALL) -d $(targetprefix)/sys
endif
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/var
	$(INSTALL) -d $(targetprefix)/var/etc
	$(INSTALL) -d $(targetprefix)/var/run
	$(INSTALL) -d $(targetprefix)/var/tuxbox/boot
#	$(INSTALL) -d $(targetprefix)$(UCODEDIR)
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(bootprefix)
	-rm -f $(hostprefix)/$(target)/include
	-rm -f $(hostprefix)/$(target)/lib
	-ln -sf $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -sf $(targetprefix)/lib $(hostprefix)/$(target)/lib
	-ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include
if TARGETRULESET_FLASH
	$(INSTALL) -d $(flashprefix)
endif
	touch $@


if KERNEL26
KERNEL_DEPENDS = @DEPENDS_linux@
KERNEL_DIR = @DIR_linux@
KERNEL_PREPARE = @PREPARE_linux@
KERNEL_BUILD_FILENAME = @DIR_linux@/arch/ppc/boot/images/uImage
else
KERNEL_DEPENDS = @DEPENDS_linux24@
KERNEL_DIR = @DIR_linux24@
KERNEL_PREPARE = @PREPARE_linux24@
KERNEL_BUILD_FILENAME = @DIR_linux24@/arch/ppc/boot/images/vmlinux.gz
endif

$(DEPDIR)/linuxdir: $(KERNEL_DEPENDS) directories
	$(KERNEL_PREPARE)
	cp Patches/linux-$(KERNELVERSION).config $(KERNEL_DIR)/.config
	$(MAKE) -C $(KERNEL_DIR) oldconfig \
		ARCH=ppc
if KERNEL26
	$(MAKE) -C $(KERNEL_DIR) include/asm \
		ARCH=ppc
endif
	$(MAKE) -C $(KERNEL_DIR) include/linux/version.h \
		ARCH=ppc
	rm $(KERNEL_DIR)/.config
	touch $@

$(DEPDIR)/binutils: @DEPENDS_binutils@ directories
	@PREPARE_binutils@
	cd @DIR_binutils@ && \
		CC=$(CC) \
		CFLAGS="$(CFLAGS)" \
		@CONFIGURE_binutils@ \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--disable-nls \
			--without-fp && \
		$(MAKE) all all-gprof && \
		@INSTALL_binutils@
	@CLEANUP_binutils@
	touch $@

#
# gcc first stage without glibc
#
$(DEPDIR)/bootstrap_gcc: @DEPENDS_bootstrap_gcc@ binutils linuxdir
	@PREPARE_bootstrap_gcc@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	ln -sf $(buildprefix)/linux/include/{asm,linux} $(hostprefix)/$(target)/sys-include/
	cd @DIR_bootstrap_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_bootstrap_gcc@ \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-cpu=$(CPU_MODEL) \
			--enable-target-optspace \
			--enable-languages="c" \
			--disable-shared \
			--disable-threads \
			--disable-nls \
			--without-fp && \
		$(MAKE) all && \
		@INSTALL_bootstrap_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@
	touch $@

$(DEPDIR)/glibc: @DEPENDS_glibc@ bootstrap_gcc
	@PREPARE_glibc@
	touch @DIR_glibc@/config.cache
	@if [ $(GLIBC_PTHREADS) = "nptl" ]; then \
		cp @SOURCEDIR_glibc@/nptl/sysdeps/pthread/pthread.h @DIR_glibc@ && \
		cp @SOURCEDIR_glibc@/nptl/sysdeps/unix/sysv/linux/powerpc/bits/pthreadtypes.h @DIR_glibc@ && \
		echo "libc_cv_forced_unwind=yes" > @DIR_glibc@/config.cache && \
		echo "libc_cv_c_cleanup=yes" >> @DIR_glibc@/config.cache; \
	fi
	cd @DIR_glibc@ && \
		$(BUILDENV) \
		@CONFIGURE_glibc@ \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-headers=$(buildprefix)/linux/include \
			--disable-profile \
			--disable-debug  \
			--enable-shared \
			--without-gd \
			--with-tls \
			--with-__thread \
			--enable-add-ons=$(GLIBC_PTHREADS) \
			--enable-clocale=gnu \
			--without-fp \
			--cache-file=config.cache \
			$(GLIBC_EXTRA_FLAGS) && \
		$(MAKE) all && \
		@INSTALL_glibc@
	@CLEANUP_glibc@
	sed -e's, /lib/, $(targetprefix)/lib/,g' < $(targetprefix)/lib/libc.so > $(targetprefix)/lib/libc.so.new
	mv $(targetprefix)/lib/libc.so.new $(targetprefix)/lib/libc.so
	sed -e's, /lib/, $(targetprefix)/lib/,g' < $(targetprefix)/lib/libpthread.so > $(targetprefix)/lib/libpthread.so.new
	mv $(targetprefix)/lib/libpthread.so.new $(targetprefix)/lib/libpthread.so
	touch $@

#
# uClibc
# a minimalistic libc, won't currently work with libstdc++
#
$(DEPDIR)/uclibc: @DEPENDS_uclibc@
	@PREPARE_uclibc@
	cd @DIR_uclibc@ && \
		$(MAKE) all CROSS=$(target)- && \
		@INSTALL_uclibc@
	@CLEANUP_uclibc@
	touch $@

#
# gcc second stage
#
$(DEPDIR)/gcc: @DEPENDS_gcc@ glibc
# if we have a symlink inside the libdir (in case gcc has already been built)
# we remove it here
	@if [ -h $(hostprefix)/$(target)/lib/nof ]; then \
		rm -f $(hostprefix)/$(target)/lib/nof; \
	fi
	@PREPARE_gcc@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	cp -p $(hostprefix)/$(target)/include/limits.h $(hostprefix)/$(target)/sys-include/
	cd @DIR_gcc@ && \
		CC=$(CC) CFLAGS="$(CFLAGS)" \
		@CONFIGURE_gcc@ \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--with-cpu=$(CPU_MODEL) \
			--enable-target-optspace \
			--enable-languages="c,c++" \
			--enable-shared \
			--enable-threads \
			--disable-nls \
			--without-fp && \
		$(MAKE) all && \
		@INSTALL_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	for i in `find $(hostprefix)/$(target)/lib/nof` ; do mv $$i $(hostprefix)/$(target)/lib; done
	rm -rf $(hostprefix)/$(target)/lib/nof
	ln -sf $(hostprefix)/$(target)/lib $(hostprefix)/$(target)/lib/nof
	@CLEANUP_gcc@
	touch $@

################################################################
bare-os: $(bootprefix)/u-boot $(bootprefix)/kernel-cdk driver $(targetprefix)/etc/init.d/rcS $(targetprefix)/bin/busybox modutils $(targetprefix)/bin/tuxinfo

yadd-none: bare-os $(targetprefix)/share/tuxbox/cables.xml tuxbox_tools procps $(targetprefix)/sbin/in.ftpd $(targetprefix)/var/tuxbox/ucodes

yadd-micro-neutrino: bare-os $(targetprefix)/share/tuxbox/cables.xml $(targetprefix)/var/tuxbox/ucodes $(targetprefix)/bin/camd2 $(targetprefix)/bin/switch neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-neutrino: yadd-none neutrino-plugins fx2-plugins neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-enigma: yadd-none enigma-plugins fx2-plugins enigma
	@TUXBOX_YADD_CUSTOMIZE@

yadd-lcars: yadd-none lcars
	@TUXBOX_YADD_CUSTOMIZE@

yadd-all: yadd-none plugins neutrino enigma lcars apps
	@TUXBOX_YADD_CUSTOMIZE@

#######################
#
#   root
#

# yadd-only rule (now)
$(targetprefix)/bin/busybox: bootstrap @DEPENDS_busybox@
	@PREPARE_busybox@
	m4 -Dyadd Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
#	touch $@

$(targetprefix)/etc/init.d/rcS:
	$(MAKE) -C root install

$(targetprefix)/sbin/in.ftpd: bootstrap @DEPENDS_ftpd@
	-rm -rf $(targetprefix)/share/empty
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_ftpd@
	@CLEANUP_ftpd@
#	touch $@

$(DEPDIR)/module_init_tools: bootstrap       @DEPENDS_module_init_tools@
	@PREPARE_module_init_tools@
	cd @DIR_module_init_tools@ && \
		$(BUILDENV) \
		./configure \
		      --build=$(build) \
		      --host=$(target) \
		      --prefix= && \
		$(MAKE) && \
		@INSTALL_module_init_tools@
	@CLEANUP_module_init_tools@
	touch $@

$(DEPDIR)/modutils: bootstrap @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		$(BUILDENV) \
		BUILDCC=$(CC) BUILDCFLAGS="-O2" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-root-check \
			--disable-strip && \
		$(MAKE) && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch $@

$(DEPDIR)/portmap: bootstrap @DEPENDS_portmap@
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		$(BUILDENV) \
		$(MAKE) && \
		@INSTALL_portmap@
	@CLEANUP_portmap@
	touch $@

$(DEPDIR)/procps: bootstrap libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		$(BUILDENV) \
		$(MAKE) top ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch $@

$(DEPDIR)/udev: bootstrap @DEPENDS_udev@
	@PREPARE_udev@
	cd @DIR_udev@ && \
	       $(BUILDENV) \
	       CROSS=$(target)- \
	       $(MAKE) && \
	       @INSTALL_udev@
	       @CLEANUP_udev@
	touch $@

$(DEPDIR)/watchdog: bootstrap @DEPENDS_watchdog@
	@PREPARE_watchdog@
	cd @DIR_watchdog@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--cache-file=/dev/null && \
		$(MAKE) all && \
		@INSTALL_watchdog@
	@CLEANUP_watchdog@
	touch $@

$(DEPDIR)/mrouted: bootstrap @DEPENDS_mrouted@
	@PREPARE_mrouted@
	cd @DIR_mrouted@ && \
	    $(BUILDENV) \
	    $(MAKE) all && \
	    $(INSTALL) -m755 mrouted $(targetprefix)/bin/mrouted && \
	    $(INSTALL) -m755 map-mbone $(targetprefix)/bin/map-mbone && \
	    $(INSTALL) -m755 mrinfo $(targetprefix)/bin/mrinfo
	@CLEANUP_mrouted@
	touch $@

#######################
#
#   contrib libs
#

libs: \
	libcurl libdirectfb libdirectfbpp libppdirectfb libdvbpsi \
	libfreetype libjpeg libmad libid3tag libncurses libpng \
	libreadline libsdl libsigc libz libdvb 

libs_optional: \
	libcommoncplusplus libffi \
	libpcap libxml2 libungif libexpat libcrypto

$(DEPDIR)/libboost: bootstrap @DEPENDS_libboost@
	@PREPARE_libboost@
	cd @DIR_libboost@ && \
		@INSTALL_libboost@
	@CLEANUP_libboost@
	touch $@

$(DEPDIR)/libcommoncplusplus: bootstrap libxml2 @DEPENDS_libcommoncplusplus@
	@PREPARE_libcommoncplusplus@
	cd @DIR_libcommoncplusplus@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/ccgnu2-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < src/ccgnu2-config > $(hostprefix)/bin/ccgnu2-config && \
		chmod 755 $(hostprefix)/bin/ccgnu2-config && \
		@INSTALL_libcommoncplusplus@
	@CLEANUP_libcommoncplusplus@
	touch $@

$(DEPDIR)/libcrypto: bootstrap @DEPENDS_libcrypto@
	@PREPARE_libcrypto@
	cd @DIR_libcrypto@ && \
		sed -e 's/__TUXBOX_CC__/$(target)-gcc/' -e 's/__TUXBOX_CFLAGS__/$(TARGET_CFLAGS)/' ./Configure > ./Configure.tuxbox && \
		sh ./Configure.tuxbox shared no-hw no-idea no-md2 no-md4 no-mdc2 no-rc2 no-rc5 tuxbox --prefix=/ --openssldir=/ && \
		$(MAKE) depend all && \
		@INSTALL_libcrypto@
	rm -f $(targetprefix)/lib/pkgconfig/openssl.pc && \
	sed -e "s,^prefix=,prefix=$(targetprefix)," < @DIR_libcrypto@/openssl.pc > $(targetprefix)/lib/pkgconfig/openssl.pc && \
	@CLEANUP_libcrypto@
	touch $@

$(DEPDIR)/libcurl: bootstrap @DEPENDS_libcurl@
	@PREPARE_libcurl@
	cd @DIR_libcurl@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-random && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/curl-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < curl-config > $(hostprefix)/bin/curl-config && \
		chmod 755 $(hostprefix)/bin/curl-config && \
		@INSTALL_libcurl@
	@CLEANUP_libcurl@
	touch $@

$(DEPDIR)/libdirectfb: bootstrap libfreetype libjpeg libpng libz @DEPENDS_libdirectfb@
	@PREPARE_libdirectfb@
	cd @DIR_libdirectfb@ && \
		$(BUILDENV) \
		LDFLAGS=-L$(targetprefix)/lib \
		CPPFLAGS="-I$(buildprefix)/linux/arch/ppc" \
		CFLAGS="$(TARGET_CFLAGS) -I$(buildprefix)/linux/arch/ppc" \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-debug \
			--with-inputdrivers=linuxinput \
			--disable-sdl \
			--disable-multi \
			--without-tools \
			--with-gfxdrivers=none && \
		$(MAKE) all && \
		@INSTALL_libdirectfb@
	@CLEANUP_libdirectfb@
	mv $(targetprefix)/lib/libdirectfb.la $(targetprefix)/lib/libdirectfb.la.old
	mv $(targetprefix)/lib/libfusion.la $(targetprefix)/lib/libfusion.la.old
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/libdirectfb.la.old >$(targetprefix)/lib/libdirectfb.la
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/libfusion.la.old >$(targetprefix)/lib/libfusion.la
	rm -f $(targetprefix)/lib/libdirectfb.la.old
	rm -f $(targetprefix)/lib/libfusion.la.old
	touch $@

$(DEPDIR)/libdirectfbpp: bootstrap libdirectfb @DEPENDS_libdirectfbpp@
	@PREPARE_libdirectfbpp@
	cd @DIR_libdirectfbpp@ && \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libdirectfbpp@
	@CLEANUP_libdirectfbpp@
	mv $(targetprefix)/lib/libdfb++.la $(targetprefix)/lib/libdfb++.la.old
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/libdfb++.la.old >$(targetprefix)/lib/libdfb++.la
	rm -f $(targetprefix)/lib/libdfb++.la.old
	touch $@

$(DEPDIR)/libppdirectfb: bootstrap libdirectfb @DEPENDS_libppdirectfb@
	@PREPARE_libppdirectfb@
	cd @DIR_libppdirectfb@ && \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libppdirectfb@
	@CLEANUP_libppdirectfb@
	mv $(targetprefix)/lib/lib++dfb.la $(targetprefix)/lib/lib++dfb.la.old
	sed -e "s, /lib, $(targetprefix)/lib,g" < $(targetprefix)/lib/lib++dfb.la.old >$(targetprefix)/lib/lib++dfb.la
	rm -f $(targetprefix)/lib/lib++dfb.la.old
	touch $@

$(DEPDIR)/libdvb: bootstrap @DEPENDS_libdvb@
	@PREPARE_libdvb@
	cd @DIR_libdvb@ && \
		$(MAKE) libdvb.a libdvbci.a libdvbmpegtools.a \
		$(BUILDENV) \
		CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/dvb/include -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_libdvb@
	@CLEANUP_libdvb@
	touch $@

$(DEPDIR)/libdvbpsi: bootstrap @DEPENDS_libdvbpsi@
	@PREPARE_libdvbpsi@
	cd @DIR_libdvbpsi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libdvbpsi@
	@CLEANUP_libdvbpsi@
	touch $@

$(DEPDIR)/libexpat: bootstrap @DEPENDS_libexpat@
	@PREPARE_libexpat@
	cd @DIR_libexpat@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libexpat@
	@CLEANUP_libexpat@
	touch $@

$(DEPDIR)/libffi: bootstrap @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch $@

$(DEPDIR)/libfreetype: bootstrap @DEPENDS_libfreetype@
	@PREPARE_libfreetype@
	cd @DIR_libfreetype@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/freetype-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < builds/unix/freetype-config > $(hostprefix)/bin/freetype-config && \
		chmod 755 $(hostprefix)/bin/freetype-config && \
		@INSTALL_libfreetype@
	@CLEANUP_libfreetype@
	touch $@

$(DEPDIR)/libfribidi: bootstrap @DEPENDS_libfribidi@
	@PREPARE_libfribidi@
	cd @DIR_libfribidi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-memopt && \
		$(MAKE) all && \
		@INSTALL_libfribidi@
	@CLEANUP_libfribidi@
	touch $@

$(DEPDIR)/libgmp: bootstrap @DEPENDS_libgmp@
	@PREPARE_libgmp@
	cd @DIR_libgmp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libgmp@
	@CLEANUP_libgmp@
	touch $@

$(DEPDIR)/libid3tag: bootstrap libz @DEPENDS_libid3tag@
	@PREPARE_libid3tag@
	cd @DIR_libid3tag@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-shared=yes && \
		$(MAKE) all && \
		@INSTALL_libid3tag@
	@CLEANUP_libid3tag@
	touch $@

$(DEPDIR)/libjpeg: bootstrap @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) libjpeg.so.6 && \
		@INSTALL_libjpeg@
	@CLEANUP_libjpeg@
	touch $@

$(DEPDIR)/libmad: bootstrap libz @DEPENDS_libmad@
	@PREPARE_libmad@
	cd @DIR_libmad@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-shared=yes \
			--enable-speed \
			--enable-fpm=ppc \
			--enable-sso && \
		$(MAKE) all && \
		@INSTALL_libmad@
	@CLEANUP_libmad@
	touch $@

$(DEPDIR)/libncurses: bootstrap @DEPENDS_libncurses@
	@PREPARE_libncurses@
	cd @DIR_libncurses@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-terminfo-dirs=/share/terminfo \
			--disable-big-core \
			--without-debug \
			--without-progs \
			--without-ada \
			--with-shared \
			--without-profile \
			--disable-rpath \
			--without-cxx-binding \
			--with-fallbacks='linux vt100 xterm' && \
		$(MAKE) libs \
			HOSTCC=$(CC) \
			HOSTCCFLAGS="$(CFLAGS) -DHAVE_CONFIG_H -I../ncurses -DNDEBUG -D_GNU_SOURCE -I../include" \
			HOSTLDFLAGS="$(LDFLAGS)" && \
			@INSTALL_libncurses@
	@CLEANUP_libncurses@
	touch $@

$(DEPDIR)/libpcap: bootstrap @DEPENDS_libpcap@
	@PREPARE_libpcap@
	cd @DIR_libpcap@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-pcap=linux && \
		$(MAKE) all && \
		@INSTALL_libpcap@
	@CLEANUP_libpcap@
	touch $@

$(DEPDIR)/libpng: bootstrap libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(MAKE) libpng.a libpng12.so libpng.pc libpng-config \
	 		$(BUILDENV) \
			CPPFLAGS="-DPNG_DEBUG=0" \
			prefix=$(targetprefix) && \
		@INSTALL_libpng@
	@CLEANUP_libpng@
	touch $@

$(DEPDIR)/libreadline: bootstrap @DEPENDS_libreadline@
	@PREPARE_libreadline@
	cd @DIR_libreadline@ && \
		autoconf && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_libreadline@
	@CLEANUP_libreadline@
	touch $@

$(DEPDIR)/libsdl: bootstrap libdirectfb @DEPENDS_libsdl@
	@PREPARE_libsdl@
	cd @DIR_libsdl@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-alsa \
			--disable-openbsdaudio \
			--disable-esd \
			--disable-arts \
			--disable-nas \
			--disable-diskaudio \
			--disable-nasm \
			--disable-nanox \
			--disable-video-x11 \
			--without-x \
			--enable-video-fbcon \
			--disable-video-photon \
			--disable-video-directfb \
			--disable-video-ps2gs \
			--disable-video-ggi \
			--disable-video-svga \
			--disable-video-vgl \
			--disable-video-aalib \
			--disable-video-dummy \
			--disable-video-opengl \
			--disable-stdio-redirect \
			--disable-directx && \
		$(MAKE) all && \
		rm -f $(hostprefix)/bin/sdl-config && \
		sed -e "s,^prefix=,prefix=$(targetprefix)," < sdl-config > $(hostprefix)/bin/sdl-config && \
		chmod 755 $(hostprefix)/bin/sdl-config && \
		@INSTALL_libsdl@
	@CLEANUP_libsdl@
	touch $@

$(DEPDIR)/libsigc: bootstrap @DEPENDS_libsigc@
	@PREPARE_libsigc@
	cd @DIR_libsigc@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-checks && \
		$(MAKE) all && \
		@INSTALL_libsigc@
	@CLEANUP_libsigc@
	touch $@

$(DEPDIR)/libvorbisidec: bootstrap @DEPENDS_libvorbisidec@
	@PREPARE_libvorbisidec@
	cd @DIR_libvorbisidec@ && \
		$(BUILDENV) \
		./autogen.sh \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) && \
		@INSTALL_libvorbisidec@
	@CLEANUP_libvorbisidec@
	touch $@

$(DEPDIR)/libxml2: bootstrap @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-html-dir \
			--with-threads \
			--without-ftp \
			--without-http \
			--without-html \
			--without-catalog \
			--without-docbook \
			--with-xpath \
			--without-xptr \
			--without-xinclude \
			--without-iconv \
			--without-debug \
			--without-mem-debug \
			--without-python && \
		$(MAKE) all && \
		@INSTALL_libxml2@
	@CLEANUP_libxml2@
	touch $@

$(DEPDIR)/libz: bootstrap @DEPENDS_libz@
	@PREPARE_libz@
	cd @DIR_libz@ && \
		$(BUILDENV) \
		./configure \
			--prefix= \
			--shared && \
		$(MAKE) all && \
		@INSTALL_libz@
	@CLEANUP_libz@
	touch $@

$(DEPDIR)/libglib: bootstrap @DEPENDS_libglib@
	@PREPARE_libglib@
	echo "ac_cv_func_posix_getpwuid_r=yes" > @DIR_libglib@/config.cache
	echo "glib_cv_stack_grows=no" >> @DIR_libglib@/config.cache
	echo "glib_cv_uscore=no" >> @DIR_libglib@/config.cache
	cd @DIR_libglib@ && \
		$(BUILDENV) \
		./configure \
			--cache-file=config.cache \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) &&\
		$(MAKE) all && \
		@INSTALL_libglib@
	@CLEANUP_libglib@
	touch $@

$(DEPDIR)/libungif: bootstrap @DEPENDS_libungif@
	@PREPARE_libungif@
	cd @DIR_libungif@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
			--without-x && \
		$(MAKE) && \
		@INSTALL_libungif@
	@CLEANUP_libungif@
	touch $@

$(DEPDIR)/libiconv: bootstrap @DEPENDS_libiconv@
	@PREPARE_libiconv@
	cd @DIR_libiconv@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--build=$(build) \
			--prefix= \
		$(MAKE) && \
		@INSTALL_libiconv@
	@CLEANUP_libiconv@
	touch $@

#######################
#
#   contrib apps
#

contrib_apps: bzip2 console_data console_tools fbset lirc lsof ssh tcpdump lufs bonnie

$(DEPDIR)/bzip2: bootstrap @DEPENDS_bzip2@
	@PREPARE_bzip2@
	cd @DIR_bzip2@ && \
	mv Makefile-libbz2_so Makefile && \
		CC=$(target)-gcc \
		$(MAKE) all && \
		@INSTALL_bzip2@
	@CLEANUP_bzip2@
	touch $@

$(DEPDIR)/console_data: bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-main_compressor=gzip && \
		@INSTALL_console_data@
	@CLEANUP_console_data@
	touch $@

$(DEPDIR)/console_tools: bootstrap console_data @DEPENDS_console_tools@
	@PREPARE_console_tools@
	cd @DIR_console_tools@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-nls && \
		@INSTALL_console_tools@
	@CLEANUP_console_tools@
	touch $@

$(DEPDIR)/directfb_examples: bootstrap libdirectfb @DEPENDS_directfb_examples@
	@PREPARE_directfb_examples@
	cd @DIR_directfb_examples@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_directfb_examples@
	@CLEANUP_directfb_examples@
	touch $@

$(DEPDIR)/fbset: bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
			$(BUILDENV) && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch $@

$(DEPDIR)/lirc: bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		$(BUILDENV) \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=none \
			--with-kerneldir=$(buildprefix)/linux \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

$(DEPDIR)/lsof: bootstrap @DEPENDS_lsof@
	@PREPARE_lsof@
	cd @DIR_lsof@ && \
	tar xvf @DIR_lsof@_src.tar && \
	cd @DIR_lsof@_src && \
	patch -p1 < ../../Patches/lsof.diff && \
		CROSS_COMPILE=$(target)- \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LSOF_VSTR=$(KERNELVERSION) \
		LINUX_CLIB="-DGLIBCV=202" \
		./Configure -n linux && \
		$(MAKE) all && \
		@INSTALL_lsof@
	@CLEANUP_lsof@
	touch $@

$(DEPDIR)/dropbear: bootstrap libz @DEPENDS_dropbear@
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-syslog \
			--disable-shadow \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx && \
		cp ../Patches/dropbear-options.h options.h && \
		$(MAKE) PROGRAMS="dropbear dbclient scp" MULTI=1 && \
		$(MAKE) install PROGRAMS="dropbear dbclient scp" MULTI=1 DESTDIR=$(targetprefix) && \
		rm -f $(targetprefix)/sbin/dropbear && \
		rm -f $(targetprefix)/sbin/dbclient && \
		rm -f $(targetprefix)/bin/scp && \
		ln -s $(targetprefix)/bin/dropbearmulti $(targetprefix)/sbin/dropbear && \
		ln -s $(targetprefix)/bin/dropbearmulti $(targetprefix)/sbin/dbclient && \
		ln -s $(targetprefix)/bin/dropbearmulti $(targetprefix)/bin/scp
	@CLEANUP_dropbear@
	touch $@

$(DEPDIR)/dropbearkey: bootstrap libz @DEPENDS_dropbear@
	@PREPARE_dropbear@
	cd @DIR_dropbear@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--prefix= \
			--disable-syslog \
			--disable-shadow \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx && \
		cp ../Patches/dropbear-options.h options.h && \
		$(MAKE) PROGRAMS="dropbear dropbearkey"
		@if [ ! -e $(targetprefix)/etc/dropbear ]; then \
			mkdir $(targetprefix)/etc/dropbear; \
		fi
		-rm -rf $(targetprefix)/etc/dropbear/dropbear_rsa_host_key $(targetprefix)/etc/dropbear/dropbear_dss_host_key
		./@DIR_dropbear@/dropbearkey -t rsa -f $(targetprefix)/etc/dropbear/dropbear_rsa_host_key && \
		./@DIR_dropbear@/dropbearkey -t dss -f $(targetprefix)/etc/dropbear/dropbear_dss_host_key
	@CLEANUP_dropbear@
	touch $@

$(DEPDIR)/ssh: bootstrap libcrypto libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		$(BUILDENV) \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--sysconfdir=/etc/ssh \
			--without-shadow \
			--with-4in6 \
			--disable-suid-ssh \
			--with-path="/bin:/sbin" \
			--with-privsep-user=sshd \
			--with-privsep-path=/share/empty && \
		$(MAKE) all && \
		@INSTALL_ssh@
	@CLEANUP_ssh@
	touch $@

$(DEPDIR)/tcpdump: bootstrap libpcap @DEPENDS_tcpdump@
	@PREPARE_tcpdump@
	cd @DIR_tcpdump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-smb \
			--disable-ipv6 \
			--without-crypto && \
		$(MAKE) all && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch $@

$(DEPDIR)/bonnie: bootstrap @DEPENDS_bonnie@
	@PREPARE_bonnie@
	cd @DIR_bonnie@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all WFLAGS= && \
                $(target)-strip -s bonnie++ &&\
		cp bonnie++ $(targetprefix)/sbin/bonnie
	@CLEANUP_bonnie@
	touch $@

$(DEPDIR)/vdr: bootstrap @DEPENDS_vdr@
	@PREPARE_vdr@
	cd @DIR_vdr@ && \
		$(BUILDENV) \
		DVBDIR="$(driverdir)/dvb" \
		$(MAKE) all DRIVERDIR=$(driverdir) && \
		$(MAKE) plugins PREFIX=$(prefix) DRIVERDIR=$(driverdir) && \
		@INSTALL_vdr@
	@CLEANUP_vdr@
	touch $@

$(DEPDIR)/lufs: bootstrap @DEPENDS_lufs@
	@PREPARE_lufs@
	cd @DIR_lufs@ && \
		$(BUILDENV) \
		aclocal && \
		libtoolize --force && \
		autoconf && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--exec_prefix=$(targetprefix) \
			--disable-kernel-support && \
		$(MAKE) all && \
		@INSTALL_lufs@
	@CLEANUP_lufs@
	touch $@

$(DEPDIR)/kermit: bootstrap @DEPENDS_kermit@ libcrypto
	@echo "Kermit is licensed differently from other software (more restrictively),"
	@echo "see http://www.columbia.edu/kermit/licensing.html"
	@PREPARE_kermit@
	cd @DIR_kermit@ && \
		$(BUILDENV) \
		$(MAKE) tuxbox && \
		@INSTALL_kermit@
	ln -sf ./kermit $(targetprefix)/bin/kermit-sshsub
	[ -d $(targetprefix)/var/lock ] ||  mkdir $(targetprefix)/var/lock
	@CLEANUP_kermit@
	touch $@

#######################
#
#   development tools
#

devel: gdb ltrace strace nano joe
devel_optional: gdb-remote insight bash

$(DEPDIR)/gdb: bootstrap libncurses @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		$(BUILDENV) \
		LD_LIBRARY_PATH=$(libdir) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--nfp \
			--disable-tui \
			--without-tui \
			--disable-sim \
			--without-sim \
			--without-expect \
			--disable-expect \
			--prefix= && \
		$(MAKE) all-gdb && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch $@

$(DEPDIR)/gdb-remote: @DEPENDS_gdb@
	@PREPARE_gdb@
	cd @DIR_gdb@ && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_gdb@
	touch $@

$(DEPDIR)/insight: @DEPENDS_insight@
	@PREPARE_insight@
	cd @DIR_insight@ && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--target=$(target) \
			--prefix=$(hostprefix) && \
		$(MAKE) all-gdb && \
		$(MAKE) install-gdb
	@CLEANUP_insight@
	touch $@

$(DEPDIR)/ltrace: bootstrap @DEPENDS_ltrace@
	@PREPARE_ltrace@
	cd @DIR_ltrace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		@INSTALL_ltrace@
	@CLEANUP_ltrace@
	touch $@

$(DEPDIR)/strace: bootstrap @DEPENDS_strace@
	@PREPARE_strace@
	cd @DIR_strace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch $@

$(DEPDIR)/nano: bootstrap libncurses @DEPENDS_nano@
	@PREPARE_nano@
	cd @DIR_nano@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=  \
			--includedir=$(targetprefix)/include && \
		$(MAKE) all && \
		@INSTALL_nano@
	@CLEANUP_nano@
	touch $@

$(DEPDIR)/joe: bootstrap libncurses @DEPENDS_joe@ 
	@PREPARE_joe@
	cd @DIR_joe@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=  \
			--includedir=$(targetprefix)/include && \
		$(MAKE) all && \
		@INSTALL_joe@
	@CLEANUP_joe@
	touch $@

$(DEPDIR)/mc: bootstrap libglib libncurses @DEPENDS_mc@
	@PREPARE_mc@
	cd @DIR_mc@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-gpm-mouse \
			--with-screen=ncurses \
			--without-x && \
		$(MAKE) all && \
		@INSTALL_mc@
	@CLEANUP_mc@
	touch $@

$(DEPDIR)/bash: bootstrap @DEPENDS_bash@
	@PREPARE_bash@
	cd @DIR_bash@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= &&\
		$(MAKE) all && \
		@INSTALL_bash@
	@CLEANUP_bash@
	touch $@


#######################
#
# java stuff
#

java: kaffeh kaffe

# for x86
$(DEPDIR)/kaffeh: bootstrap @DEPENDS_kaffeh@
	@PREPARE_kaffeh@
	cd @DIR_kaffeh@ && \
		./configure \
			--host=$(build) \
			--prefix=$(hostprefix) \
			--disable-dependency-tracking \
			--without-x \
			--without-suncompat \
			--disable-gcj && \
		$(MAKE) all && \
		@INSTALL_kaffeh@
	@CLEANUP_kaffeh@
	touch $@

# for ppc
$(DEPDIR)/kaffe: bootstrap kaffeh libffi @DEPENDS_kaffe@
	@PREPARE_kaffe@
	cd @DIR_kaffe@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dependency-tracking \
			--without-x \
			--without-suncompat \
			--disable-gcj && \
		$(MAKE) all && \
		@INSTALL_kaffe@
	@CLEANUP_kaffe@
	touch $@

#######################
#
#   fun stuff
#

fun: gnuboy scummvm sdldoom

$(DEPDIR)/gnuboy: bootstrap @DEPENDS_gnuboy@
	@PREPARE_gnuboy@
	cd @DIR_gnuboy@ && \
		autoconf && \
		$(BUILDENV) \
		CPPFLAGS="-I$(driverdir)/include" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_gnuboy@
	@CLEANUP_gnuboy@
	touch $@

$(DEPDIR)/scummvm: bootstrap libreadline libsdl libmad @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		$(MAKE) \
			$(BUILDENV) \
			AR='$(target)-ar cru' \
			DEFINES="-DUNIX" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch $@

$(DEPDIR)/sdldoom: bootstrap libsdl @DEPENDS_sdldoom@
	@PREPARE_sdldoom@
	cd @DIR_sdldoom@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_sdldoom@
	@CLEANUP_sdldoom@
	touch $@

#######################
#
#  DVB apps
#

dvb_apps: dvbdate dvbstream dvbtext dvbtune vls

$(DEPDIR)/dvbdate: bootstrap @DEPENDS_dvbdate@
	@PREPARE_dvbdate@
	cd @DIR_dvbdate@ && \
		$(MAKE) dvbdate \
			$(BUILDENV) \
			CPPFLAGS="-I$(driverdir)/dvb/include -DNEWSTRUCT" && \
		@INSTALL_dvbdate@
	@CLEANUP_dvbdate@
	touch $@

$(DEPDIR)/dvbstream: bootstrap @DEPENDS_dvbstream@
	@PREPARE_dvbstream@
	cd @DIR_dvbstream@ && \
		$(MAKE) dvbstream rtpfeed\
			INCS="-I$(driverdir)/dvb/include -DNEWSTRUCT" \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_dvbstream@
	@CLEANUP_dvbstream@
	touch $@

$(DEPDIR)/dvbtext: bootstrap @DEPENDS_dvbtext@
	@PREPARE_dvbtext@
	cd @DIR_dvbtext@ && \
		$(target)-gcc $(TARGET_CFLAGS) -I$(driverdir)/dvb/include -DNEWSTRUCT -o dvbtext dvbtext.c && \
		@INSTALL_dvbtext@
	@CLEANUP_dvbtext@
	touch $@

$(DEPDIR)/dvbtune: bootstrap @DEPENDS_dvbtune@
	@PREPARE_dvbtune@
	cd @DIR_dvbtune@ && \
		$(MAKE) \
			$(BUILDENV) \
			CPPFLAGS="-I$(driverdir)/dvb/include -DNEWSTRUCT" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch $@

$(DEPDIR)/vls: bootstrap libdvbpsi @DEPENDS_vls@
	@PREPARE_vls@
	cd @DIR_vls@ && \
		$(BUILDENV) \
		CCFLAGS="$(TARGET_CFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dvd \
			--with-dvb=$(driverdir)/dvb/include && \
		$(MAKE) all && \
		@INSTALL_vls@
	@CLEANUP_vls@
	touch $@

#######################
#
# bluetooth
#

$(DEPDIR)/bluez_hcidump: bootstrap bluez_libs @DEPENDS_bluez_hcidump@
	@PREPARE_bluez_hcidump@
	cd @DIR_bluez_hcidump@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--with-bluez-libs=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_bluez_hcidump@
	@CLEANUP_bluez_hcidump@
	touch $@

$(DEPDIR)/bluez_libs: bootstrap @DEPENDS_bluez_libs@
	@PREPARE_bluez_libs@
	cd @DIR_bluez_libs@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= && \
		$(MAKE) all && \
		@INSTALL_bluez_libs@
	@CLEANUP_bluez_libs@
	touch $@

$(DEPDIR)/bluez_pan: bootstrap bluez_sdp @DEPENDS_bluez_pan@
	@PREPARE_bluez_pan@
	cd @DIR_bluez_pan@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib \
			--with-sdp-includes=$(targetprefix)/include \
			--with-sdp-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_pan@
	@CLEANUP_bluez_pan@
	touch $@

$(DEPDIR)/bluez_sdp: bootstrap bluez_libs @DEPENDS_bluez_sdp@
	@PREPARE_bluez_sdp@
	cd @DIR_bluez_sdp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_sdp@
	@CLEANUP_bluez_sdp@
	touch $@

$(DEPDIR)/bluez_utils: bootstrap bluez_libs @DEPENDS_bluez_utils@
	@PREPARE_bluez_utils@
	cd @DIR_bluez_utils@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-bluez-includes=$(targetprefix)/include \
			--with-bluez-libs=$(targetprefix)/lib && \
		$(MAKE) all && \
		@INSTALL_bluez_utils@
	@CLEANUP_bluez_utils@
	touch $@

#######################
#
#   own kernel and driver
#

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

$(bootprefix)/u-boot \
$(hostprefix)/bin/mkimage: @DEPENDS_uboot@ $(bootdir)/u-boot-config/u-boot.cdk.dbox2.h
	ln -sf ./u-boot.cdk.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $(bootprefix)/u-boot
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

# Kernel
#
# Yes, this depends on $(KERNEL_DIR)/.config, which the Makefile does not have
# as a target.
# This is deliberate, and makes the target "private".

#$(DEPDIR)/linuxkernel: bootstrap linuxdir $(KERNEL_DIR)/.config
$(KERNEL_BUILD_FILENAME): bootstrap linuxdir $(KERNEL_DIR)/.config
	$(MAKE) -C $(KERNEL_DIR) oldconfig ARCH=ppc
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

$(bootprefix)/kernel-cdk: linuxdir $(hostprefix)/bin/mkimage
	cp Patches/linux-$(KERNELVERSION).config $(KERNEL_DIR)/.config
	m4 Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	$(MAKE) $(KERNEL_BUILD_FILENAME)
if KERNEL26
# TODO
	error
else
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 \
		-d $(KERNEL_BUILD_FILENAME) \
		$@
	chmod 644 $@
	$(INSTALL) -m644 $(KERNEL_DIR)/vmlinux $(targetprefix)/boot/vmlinux-$(KERNELVERSION)
	$(INSTALL) -m644 $(KERNEL_DIR)/System.map $(targetprefix)/boot/System.map-$(KERNELVERSION)
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/var/run
endif

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
	-rm $(DEPDIR)/driver

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

#######################
#
#   own applications
#

apps: dvbsnoop enigma lcars lcd neutrino plugins dvb_tools

CONFIGURE_OPTS = \
	--build=$(build) \
	--host=$(target) \
	--prefix=$(targetprefix) \
	--with-driver=$(driverdir) \
	--with-dvbincludes=$(driverdir)/dvb/include \
	--with-target=cdk

if MAINTAINER_MODE
CONFIGURE_OPTS_MAINTAINER = \
	--enable-maintainer-mode
endif

if TARGETRULESET_FLASH
CONFIGURE_OPTS_DEBUG = \
	--without-debug
endif

CONFIGURE = \
	./autogen.sh && \
	CC=$(target)-gcc \
	CXX=$(target)-g++ \
	CFLAGS="-Wall $(TARGET_CFLAGS)" \
	CXXFLAGS="-Wall $(TARGET_CXXFLAGS)" \
	./configure $(CONFIGURE_OPTS) $(CONFIGURE_OPTS_MAINTAINER) $(CONFIGURE_OPTS_DEBUG)

# dvb/config

$(appsdir)/dvb/config/config.status:
	cd $(appsdir)/dvb/config && $(CONFIGURE)

#$(DEPDIR)/config:
$(targetprefix)/share/tuxbox/cables.xml \
$(targetprefix)/share/tuxbox/satellites.xml: $(appsdir)/dvb/config/config.status
	$(MAKE) -C $(appsdir)/dvb/config all install
	touch $@

# dvb/dvbsnoop

$(appsdir)/dvb/dvbsnoop/config.status: bootstrap
	cd $(appsdir)/dvb/dvbsnoop && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

#$(DEPDIR)/dvbsnoop
dvbsnoop: $(appsdir)/dvb/dvbsnoop/config.status
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install
#	touch $@

# dvb/libdvb++

$(appsdir)/dvb/libdvb++/config.status: bootstrap libdvbsi++
	cd $(appsdir)/dvb/libdvb++ && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/libdvb++: $(appsdir)/dvb/libdvb++/config.status
	$(MAKE) -C $(appsdir)/dvb/libdvb++ all install
	touch $@

# dvb/libdvbsi++

$(appsdir)/dvb/libdvbsi++/config.status: bootstrap
	cd $(appsdir)/dvb/libdvbsi++ && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/dvb/include"

$(DEPDIR)/libdvbsi++: $(appsdir)/dvb/libdvbsi++/config.status
	$(MAKE) -C $(appsdir)/dvb/libdvbsi++ all install
	touch $@

# dvb/zapit

$(appsdir)/dvb/zapit/config.status: | bootstrap misc_libs
	cd $(appsdir)/dvb/zapit && $(CONFIGURE)

#$(DEPDIR)/zapit:
$(DEPDIR)/zapit: $(appsdir)/dvb/zapit/config.status
	$(MAKE) -C $(appsdir)/dvb/zapit all install
#	touch $@

# dvb/tools

$(appsdir)/dvb/tools/config.status: | bootstrap misc_libs
	cd $(appsdir)/dvb/tools && $(CONFIGURE)

dvb_tools: $(appsdir)/dvb/tools/config.status
	$(MAKE) -C $(appsdir)/dvb/tools all install
#	touch $@

# misc/libs

$(appsdir)/misc/libs/config.status: | bootstrap libz
	cd $(appsdir)/misc/libs && $(CONFIGURE)

#$(DEPDIR)/misc_libs:
misc_libs: $(appsdir)/misc/libs/config.status
	$(MAKE) -C $(appsdir)/misc/libs all install
#	touch $@

# misc/tools

$(appsdir)/misc/tools/config.status: bootstrap
	cd $(appsdir)/misc/tools && $(CONFIGURE)

#$(DEPDIR)/misc_tools
misc_tools: $(appsdir)/misc/tools/config.status
	$(MAKE) -C $(appsdir)/misc/tools all install
#	touch $@

# tuxbox/enigma

$(appsdir)/tuxbox/enigma/config.status: bootstrap libfreetype libfribidi libmad libid3tag libpng libsigc libjpeg libungif | libtuxbox misc_libs plugins
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE)

#$(DEPDIR)/enigma
enigma: $(appsdir)/tuxbox/enigma/config.status | tuxbox_tools
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install
#	touch $@

# tuxbox/funstuff

$(appsdir)/tuxbox/funstuff/config.status: bootstrap
	cd $(appsdir)/tuxbox/funstuff && $(CONFIGURE)

$(DEPDIR)/funstuff: $(appsdir)/tuxbox/funstuff/config.status
	$(MAKE) -C $(appsdir)/tuxbox/funstuff all install
	touch $@

# tuxbox/lcars

$(appsdir)/tuxbox/lcars/config.status: | bootstrap libcurl libfreetype plugins libcommoncplusplus
	cd $(appsdir)/tuxbox/lcars && $(CONFIGURE)

lcars: $(appsdir)/tuxbox/lcars/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install
#	touch $@

# tuxbox/lcd

$(appsdir)/tuxbox/lcd/config.status: bootstrap libfreetype | misc_libs tuxbox_libs
	cd $(appsdir)/tuxbox/lcd && $(CONFIGURE)

lcd: $(appsdir)/tuxbox/lcd/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcd all install
#	touch $@

# tuxbox/libs

$(appsdir)/tuxbox/libs/config.status: bootstrap libfreetype libpng
	cd $(appsdir)/tuxbox/libs && $(CONFIGURE)

#$(DEPDIR)/tuxbox_libs
tuxbox_libs: $(appsdir)/tuxbox/libs/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libs all install
#	touch $@

# tuxbox/libtuxbox

$(appsdir)/tuxbox/libtuxbox/config.status: bootstrap
	cd $(appsdir)/tuxbox/libtuxbox && $(CONFIGURE)

# $(DEPDIR)/libtuxbox
libtuxbox: $(appsdir)/tuxbox/libtuxbox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libtuxbox all install
#	touch $@

# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/config.status: | bootstrap libid3tag libmad libvorbisidec zapit libboost libjpeg libcurl libfreetype libpng tuxbox_libs $(targetprefix)/include/tuxbox/plugin.h
# lufs | libtuxbox misc_libs misc_tools plugins
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

#$(DEPDIR)/neutrino
neutrino: $(appsdir)/tuxbox/neutrino/config.status
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
#	touch $@

# tuxbox/plugins

$(appsdir)/tuxbox/plugins/config.status: | bootstrap libfreetype misc_libs tuxbox_libs libcurl libz libsigc libpng libtuxbox
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

plugins: neutrino-plugins enigma-plugins fx2-plugins

neutrino-plugins: \
		$(targetprefix)/include/tuxbox/plugin.h \
		tuxmail tuxtxt tuxcom vncviewer

fx2-plugins: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/fx2 all install

enigma-plugins: $(appsdir)/tuxbox/plugins/config.status $(targetprefix)/include/tuxbox/plugin.h
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma all install

$(targetprefix)/include/tuxbox/plugin.h \
$(targetprefix)/lib/pkgconfig/tuxbox-plugins.pc: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/include all install
	cp $(appsdir)/tuxbox/plugins/tuxbox-plugins.pc $(targetprefix)/lib/pkgconfig/tuxbox-plugins.pc
#	touch $@

tuxmail: libfreetype $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxmail all install

tuxtxt: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxtxt all install

tuxcom: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcom all install

vncviewer: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/vncviewer all install

# tuxbox/tools

# I have thrown out pluginx, then no longer dependent of plugins
# Also camd (replaced by camd2) nuked.
# TODO: reenable pluginx
$(appsdir)/tuxbox/tools/config.status: | bootstrap libtuxbox
# plugins
	cd $(appsdir)/tuxbox/tools && $(CONFIGURE)

#$(DEPDIR)/tuxbox_tools
tuxbox_tools: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools all install
#	touch $@

# These are really sub-targets of tuxbox_tools
$(targetprefix)/bin/tuxinfo: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/tuxinfo install
	touch $@

$(targetprefix)/bin/camd2: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install

$(targetprefix)/bin/satfind: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/satfind install

# $(appsdir)/tuxbox/tools/test
$(targetprefix)/bin/datarate \
$(targetprefix)/bin/fp_reg \
$(targetprefix)/bin/showfreq \
$(targetprefix)/bin/showfreq_qpsk \
$(targetprefix)/bin/test_event \
$(targetprefix)/bin/test_lcd \
$(targetprefix)/bin/wakeup: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/test install

# $(appsdir)/tuxbox/tools/graphics
$(targetprefix)/bin/fbtest \
$(targetprefix)/bin/vgrab \
$(targetprefix)/bin/overlay \
$(targetprefix)/bin/unsquasher \
$(targetprefix)/bin/yuv2ppm: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/graphics install

if KERNEL26
# this target does nothing presently
$(targetprefix)/sbin/hotplug: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug install
endif

$(targetprefix)/bin/aviafbtool \
$(targetprefix)/bin/fbclear \
$(targetprefix)/bin/lcddump \
$(targetprefix)/bin/saa \
$(targetprefix)/bin/switch \
$(targetprefix)/bin/rcsim \
$(targetprefix)/bin/aviaext \
$(targetprefix)/bin/audioplay: $(appsdir)/tuxbox/tools/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/misc install

$(hostappsdir)/config.status: bootstrap
	cd $(hostappsdir) && \
	./autogen.sh && \
	./configure --prefix=$(hostprefix)

hostapps: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)
#	touch $@

$(hostprefix)/bin/mkflfs: $(hostappsdir)/config.status
	$(MAKE) -C $(hostappsdir)/mkflfs install

################################################################
$(targetprefix)/var/tuxbox/ucodes:
	$(INSTALL) -d $@
	if [ -d $(ucodesdir) ] ; then \
		rm -f $(targetprefix)/var/tuxbox/ucodes/*; \
		cp -p $(ucodesdir)/* $(targetprefix)/var/tuxbox/ucodes; \
	fi || true
################ Server Support ################

serversupport: dboxflasher dhcp.conf exports tftp hosts

dhcp.conf: $(serversupport)/etc/dhcpd.conf

$(serversupport)/etc:
	$(INSTALL) -d $@

$(serversupport)/etc/dhcpd.conf: $(serversupport)/etc Makefile
	@echo "Creating $@"
	@echo "# This is a template for dhcp.conf" 			> $@
	@echo "# Copy to the appropriate location for your server,"	>> $@
	@echo "# typically /etc/dhcp.conf." 				>> $@
	@echo "# You may have to modify this file manually."		>> $@
	@echo "# Please see the documention for your server and for dhcpd."	>> $@
	@echo "" 							>> $@
	@echo "ddns-update-style none;"					>> $@
	@echo "subnet $(DBOX_SUBNET) netmask $(DBOX_SUBNETMASK) {"	>> $@
	@echo "}"							>> $@
	@echo ""							>> $@
	@echo "host dbox {"						>> $@
	@echo "	fixed-address $(DBOX_IP);"				>> $@
	@echo "	hardware ethernet $(DBOX_MAC);"				>> $@
	@echo "	allow bootp;"						>> $@
	@echo "	server-name \"`uname -n`\";"				>> $@
	@echo "	option root-path \"$(targetprefix)\";"			>> $@
	@echo "	if exists vendor-class-identifier {"			>> $@
	@echo "		filename \"kernel-cdk\";"			>> $@
	@echo "	} else {"						>> $@
	@echo "		filename \"u-boot\";"				>> $@
	@echo "	}"							>> $@
	@echo "}"							>> $@

exports: $(serversupport)/etc/exports

$(serversupport)/etc/exports: $(serversupport)/etc Makefile
	@echo "Creating $@"
	@echo "# On a Linux system, this file may be appended to /etc/exports in order to"	> $@
	@echo "# export the appropriate filesystem to the dbox,"	>> $@
	@echo "# which is assumed to have the IP-name \`dbox'."		>> $@
	@echo "$(targetprefix)	dbox(rw,sync,no_root_squash)"		>> $@

tftp: $(serversupport)/etc/README.tftp

$(serversupport)/etc/README.tftp: Makefile
	@echo "Creating $@"
	@echo "# Make sure that you turn on the tftp-service, using "	> $@
	@echo "# $(bootprefix) as its root directory (this is most"	>> $@
	@echo "# likely not the default for your server)."		>> $@
	@echo ""							>> $@
	@echo "# See http://wiki.tuxbox.org/CDK_booten"			>> $@
	@echo "# This file MAY work as /etc/xinetd.d/tftp"		>> $@
	@echo ""							>> $@
	@echo "service tftp"						>> $@
	@echo "{"							>> $@
	@echo "	disable = no"						>> $@
	@echo "	socket_type = dgram"					>> $@
	@echo "	wait = yes"						>> $@
	@echo "	user = nobody"						>> $@
	@echo "	log_on_success += USERID"				>> $@
	@echo "	log_on_failure += USERID"				>> $@
	@echo "	server = /usr/sbin/in.tftpd"				>> $@
	@echo "	server_args = -s " $(bootprefix)			>> $@
	@echo "}"							>> $@

hosts: $(serversupport)/etc/hosts

$(serversupport)/etc/hosts: Makefile
	@echo "Creating $@"
	@echo "# If appropriate, append this to /etc/exports"		> $@
	@echo ""							>> $@
	@echo "# See http://wiki.tuxbox.org/CDK_booten"			>> $@
	@echo $(DBOX_IP)	dbox					>> $@

dboxflasher: $(bootprefix)/dboxflasher

$(bootprefix)/dboxflasher: $(bootdir)/u-boot-config/u-boot.flasher.dbox2.h
	ln -sf $(bootdir)/u-boot-config/u-boot.flasher.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(INSTALL) -d $(bootprefix)
	$(INSTALL) -m644 @DIR_uboot@/u-boot.stripped $@
	if [ -e $(logosdir)/dboxflasher-fb ] ; then \
		$(INSTALL) -m644 $(logosdir)/dboxflasher-fb $(bootprefix); \
	fi
	if [ -e $(logosdir)/dboxflasher-lcd ] ; then \
		$(INSTALL) -m644 $(logosdir)/dboxflasher-lcd $(bootprefix); \
	fi
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(appsdir)/tuxbox/tools/hotplug/config.status: bootstrap
	cd $(appsdir)/tuxbox/tools/hotplug && $(CONFIGURE)

$(DEPDIR)/tuxbox_hotplug: $(appsdir)/tuxbox/tools/hotplug/config.status
	$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug all install
	touch $@

if TARGETRULESET_FLASH
#######################
#
#   flash
#
################################################################
#
# Public flash targets
#
# flash-$gui-$rootfs-$chips
#
# Name for images/filesystems:
#
# $partition-$gui-$rootfilesystem.$type

# where 
# $type in { cramfs, squashfs, jffs2, img1x, img2x, flfs1x, flfs2x }
# $partition in { root, var } (empty by full images)
# $gui in { neutrino, enigma } 

# Public targets that build one or more images (*.img*x)
## TODO: include all these in .PHONY

flash-all-all-all: flash-neutrino-all-all flash-enigma-all-all

flash-all-cramfs-all: flash-neutrino-cramfs-all flash-enigma-cramfs-all

flash-all-squashfs-all: flash-neutrino-squashfs-all flash-enigma-squashfs-all

flash-all-jffs2-all: flash-neutrino-jffs2-all flash-enigma-jffs2-all


flash-all-all-1x: flash-neutrino-all-1x flash-enigma-all-1x

flash-all-all-2x: flash-neutrino-all-2x flash-enigma-all-2x

flash-neutrino-all-1x: flash-neutrino-cramfs-1x flash-neutrino-squashfs-1x flash-neutrino-jffs2-1x

flash-enigma-all-1x: flash-enigma-cramfs-1x flash-enigma-squashfs-1x flash-enigma-jffs2-1x

flash-all-all-2x: flash-neutrino-all-2x flash-enigma-all-2x

flash-neutrino-all-2x: flash-neutrino-cramfs-2x flash-neutrino-squashfs-2x flash-neutrino-jffs2-2x

flash-enigma-all-2x: flash-enigma-cramfs-2x flash-enigma-squashfs-2x flash-enigma-jffs2-2x

flash-neutrino-all-all: flash-neutrino-cramfs-all flash-neutrino-squashfs-all flash-neutrino-jffs2-all 

flash-neutrino-cramfs-all: flash-neutrino-cramfs-1x flash-neutrino-cramfs-2x

flash-neutrino-squashfs-all: flash-neutrino-squashfs-1x flash-neutrino-squashfs-2x

flash-neutrino-jffs2-all: flash-neutrino-jffs2-1x flash-neutrino-jffs2-2x

flash-enigma-all-all: flash-enigma-cramfs-all flash-enigma-squashfs-all flash-enigma-jffs2-all 

flash-enigma-cramfs-all: flash-enigma-cramfs-1x flash-enigma-cramfs-2x

flash-enigma-squashfs-all: flash-enigma-squashfs-1x flash-enigma-squashfs-2x

flash-enigma-jffs2-all: flash-enigma-jffs2-1x flash-enigma-jffs2-2x

flash-all-cramfs-1x: flash-enigma-cramfs-1x flash-neutrino-cramfs-1x 

flash-all-cramfs-2x: flash-enigma-cramfs-2x flash-neutrino-cramfs-2x 

flash-all-squashfs-1x: flash-enigma-squashfs-1x flash-neutrino-squashfs-1x 

flash-all-squashfs-2x: flash-enigma-squashfs-2x flash-neutrino-squashfs-2x 

flash-all-jffs2-1x: flash-enigma-jffs2-1x flash-neutrino-jffs2-1x 

flash-all-jffs2-2x: flash-enigma-jffs2-2x flash-neutrino-jffs2-2x 

################################################################

flash-neutrino-cramfs-1x: $(flashprefix)/neutrino-cramfs.img1x

flash-neutrino-cramfs-2x: $(flashprefix)/neutrino-cramfs.img2x

flash-neutrino-squashfs-1x: $(flashprefix)/neutrino-squashfs.img1x

flash-neutrino-squashfs-2x: $(flashprefix)/neutrino-squashfs.img2x

flash-neutrino-jffs2-1x: $(flashprefix)/neutrino-jffs2.img1x

flash-neutrino-jffs2-2x: $(flashprefix)/neutrino-jffs2.img2x

flash-enigma-cramfs-1x: $(flashprefix)/enigma-cramfs.img1x

flash-enigma-cramfs-2x: $(flashprefix)/enigma-cramfs.img2x

flash-enigma-squashfs-1x: $(flashprefix)/enigma-squashfs.img1x

flash-enigma-squashfs-2x: $(flashprefix)/enigma-squashfs.img2x

flash-enigma-jffs2-1x: $(flashprefix)/enigma-jffs2.img1x

flash-enigma-jffs2-2x: $(flashprefix)/enigma-jffs2.img2x

################################################################

$(hostprefix)/bin/checkImage:
	$(MAKE) -C $(hostappsdir)/checkImage install INSTALLDIR=$(hostprefix)/bin

################################################################
# Targets for building user images (*.img*x)
#
# They all depend on two or three $partition-$gui.$fstype, defined in the
# next section.

# Note the difference between $partition-$gui-$fstype (directory) and 
# $partition-$gui.$fstype (filesystem image of type $fstype).

$(flashprefix)/neutrino-cramfs.img1x $(flashprefix)/neutrino-cramfs.img2x: \
$(flashprefix)/neutrino-cramfs.img%: \
		$(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-neutrino.cramfs \
		$(flashprefix)/var-neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@

$(flashprefix)/neutrino-squashfs.img1x $(flashprefix)/neutrino-squashfs.img2x:\
$(flashprefix)/neutrino-squashfs.img%: \
		$(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-neutrino.squashfs \
		$(flashprefix)/var-neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@

$(flashprefix)/neutrino-jffs2.img1x $(flashprefix)/neutrino-jffs2.img2x: \
$(flashprefix)/neutrino-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-neutrino.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@TUXBOX_CHECKIMAGE@

$(flashprefix)/enigma-cramfs.img1x $(flashprefix)/enigma-cramfs.img2x: \
$(flashprefix)/enigma-cramfs.img%: \
		$(flashprefix)/cramfs.flfs% \
		$(flashprefix)/root-enigma.cramfs \
		$(flashprefix)/var-enigma.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@

$(flashprefix)/enigma-squashfs.img1x $(flashprefix)/enigma-squashfs.img2x: \
$(flashprefix)/enigma-squashfs.img%: \
		$(flashprefix)/squashfs.flfs% \
		$(flashprefix)/root-enigma.squashfs \
		$(flashprefix)/var-enigma.jffs2 \
		$(hostprefix)/bin/checkImage
	$(hostappsdir)/flash/flashmanage.pl -i $@ -o build \
		--part ppcboot=$< \
		--part root=$(word 2,$+) \
		--part var=$(word 3,$+)
	@TUXBOX_CHECKIMAGE@

$(flashprefix)/enigma-jffs2.img1x $(flashprefix)/enigma-jffs2.img2x: \
$(flashprefix)/enigma-jffs2.img%: \
		$(flashprefix)/jffs2.flfs% \
		$(flashprefix)/root-enigma.jffs2 \
		$(hostprefix)/bin/checkImage
	cat $< $(word 2,$+) > $@
	@TUXBOX_CHECKIMAGE@

################################################################
#
#### Targets for building $partition-$gui.$fstype
# All depend on directory, defined in the subsequent section

####### var-$gui.jffs2
$(flashprefix)/var-neutrino.jffs2 $(flashprefix)/var-enigma.jffs2: \
$(flashprefix)/var-%.jffs2: $(flashprefix)/var-%
	$(FAKEROOT) $(MKJFFS2) -b -e 131072 -p -r $< -o $@

####### root-$gui.$fstype
$(flashprefix)/root-neutrino.cramfs $(flashprefix)/root-enigma.cramfs: \
$(flashprefix)/root-%.cramfs: $(flashprefix)/root-%-cramfs
	$(FAKEROOT) $(MKCRAMFS) -p -n "0106`date +%Y%m%d%H%M`" $< $@

$(flashprefix)/root-neutrino.squashfs $(flashprefix)/root-enigma.squashfs: \
$(flashprefix)/root-%.squashfs: $(flashprefix)/root-%-squashfs
	rm -f $@
	$(FAKEROOT) $(MKSQUASHFS) $< $@ -be

$(flashprefix)/root-neutrino.jffs2 $(flashprefix)/root-enigma.jffs2: \
$(flashprefix)/root-%.jffs2: $(flashprefix)/root-%-jffs2
	$(FAKEROOT) $(MKJFFS2)  -b -e 0x20000 --pad=0x7c0000 -r $< -o $@

################ $fs-to-boot.flfs*x
$(flashprefix)/cramfs.flfs1x $(flashprefix)/cramfs.flfs2x: \
$(hostprefix)/bin/mkflfs $(bootdir)/u-boot-config/u-boot.cramfs.dbox2.h
	ln -sf $(bootdir)/u-boot-config/u-boot.cramfs.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/cramfs.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/cramfs.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(flashprefix)/squashfs.flfs1x $(flashprefix)/squashfs.flfs2x: \
$(hostprefix)/bin/mkflfs $(bootdir)/u-boot-config/u-boot.squashfs.dbox2.h 
	ln -sf $(bootdir)/u-boot-config/u-boot.squashfs.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/squashfs.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/squashfs.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

$(flashprefix)/jffs2.flfs1x $(flashprefix)/jffs2.flfs2x: \
$(hostprefix)/bin/mkflfs $(bootdir)/u-boot-config/u-boot.jffs2.dbox2.h
	ln -sf $(bootdir)/u-boot-config/u-boot.jffs2.dbox2.h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 1x -o $(flashprefix)/jffs2.flfs1x @DIR_uboot@/u-boot.stripped
	$(hostprefix)/bin/mkflfs 2x -o $(flashprefix)/jffs2.flfs2x @DIR_uboot@/u-boot.stripped
	@CLEANUP_uboot@
	rm $(bootdir)/u-boot-config/u-boot.config

################################################################
# This section builds directories that can be used to create filesystems
#
# Pattern: $partition-$gui[-$filesystem]

$(flashprefix)/var-neutrino $(flashprefix)/var-enigma: \
$(flashprefix)/var-%: \
$(flashprefix)/root-%-cramfs-p
	rm -rf $@
	cp -rd $</var $@
	$(INSTALL) -d $@/tuxbox/boot
	if [ -e $(logosdir)/logo-fb -a -e $(logosdir)/logo-lcd  ] ; then \
		 cp $(logosdir)/logo-fb $(logosdir)/logo-lcd $@/tuxbox/boot ; \
	fi
	$(INSTALL) -d $@/etc/init.d
	$(MAKE) -C root install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
	rm -rf $(flashprefix)/.junk
	if [ -d $</etc/ssh ] ; then \
		cp -rd $</etc/ssh $@/etc/ssh ; \
	fi
	$(INSTALL) -d $@/tuxbox/config/enigma
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(INSTALL) -d $@/bin
	cp $</bin/camd2 $@/bin/camd2
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-jffs2 $(flashprefix)/root-enigma-jffs2: \
$(flashprefix)/root-%-jffs2: \
$(flashprefix)/root-%-jffs2-p $(flashprefix)/root-%-jffs2-p/lib/ld.so.1
	rm -rf $@
	cp -rd $< $@
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	$(INSTALL) -d $@/var/tuxbox/boot
	if [ -e $(logosdir)/logo-fb -a -e $(logosdir)/logo-lcd  ] ; then \
		cp $(logosdir)/logo-fb $(logosdir)/logo-lcd $@/var/tuxbox/boot ; \
	fi
	@TUXBOX_CUSTOMIZE@

# Read-only-root mods
$(flashprefix)/root-neutrino-cramfs $(flashprefix)/root-neutrino-squashfs: \
$(flashprefix)/root-neutrino-%: \
$(flashprefix)/root-neutrino-%-p $(flashprefix)/root-neutrino-%-p/lib/ld.so.1 | $(flashprefix)/var-neutrino
	rm -rf $@
	cp -dr $< $@
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/boot
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf ../var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/bin/camd2 $@/bin/camd2
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma-cramfs $(flashprefix)/root-enigma-squashfs: \
$(flashprefix)/root-enigma-%: \
$(flashprefix)/root-enigma-%-p $(flashprefix)/root-enigma-%-p/lib/ld.so.1 | $(flashprefix)/var-enigma
	rm -rf $@
	cp -dr $< $@
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/var-enigma
	rm -fr $@/boot
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf ../var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/bin/camd2 $@/bin/camd2
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

## TODO: fix this mess
$(flashprefix)/root-neutrino-cramfs-p/lib/ld.so.1 \
$(flashprefix)/root-neutrino-squashfs-p/lib/ld.so.1 \
$(flashprefix)/root-neutrino-jffs2-p/lib/ld.so.1 \
$(flashprefix)/root-enigma-cramfs-p/lib/ld.so.1 \
$(flashprefix)/root-enigma-squashfs-p/lib/ld.so.1 \
$(flashprefix)/root-enigma-jffs2-p/lib/ld.so.1: \
%/lib/ld.so.1: %
	find $</lib -maxdepth 1 -type f -o -type l | xargs rm -f
	cp -rd $(targetprefix)/lib/libnss_dns-?.*.so $</lib
	cp -rd $(targetprefix)/lib/libnss_files-?.*.so $</lib
	$(MKLIBS) --target $(target) --ldlib ld.so.1 --libc-extras-dir \
		$(targetprefix)/lib/libc_pic \
		-d $</lib \
		-D -L $(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins \
		--root $< \
		`find $</bin/ -path "*bin/?*"` \
		`find $</lib/ -name "libnss_*"` \
		`find $</lib/tuxbox/ -name "*.so" -type f` \
		`find $</sbin/ -path "*sbin/?*"`
	$(target)-strip --remove-section=.comment --remove-section=.note \
		`find $</bin/ -path "*bin/?*"` \
		`find $</sbin/ -path "*sbin/?*"` 2>/dev/null || /bin/true
	$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $</lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	$(target)-strip $</lib/* 2>/dev/null || /bin/true
	chmod u+rwX,go+rX -R $</
	if [ -e $</lib/libfx2.so ]; then \
		if [ -e $</lib/tuxbox/plugins/ ]; then \
			rm -f $</lib/tuxbox/plugins/libfx2.so ; \
			ln -s /lib/libfx2.so $</lib/tuxbox/plugins/libfx2.so; \
		fi ; \
	fi
	if [ -e $</bin/lufsd ]; then \
		cp -rd $(targetprefix)/lib/liblufs-ftpfs* $</lib ; \
		if [ -e $</lib/liblufs-ftpfs.2.0.0 ]; then \
			rm -f $</lib/liblufs-ftpfs ; \
			rm -f $</lib/liblufs-ftpfs.2 ; \
			mv $</lib/liblufs-ftpfs.2.0.0 $</lib/liblufs-ftpfs.so.2.0.0 ; \
			ln -s liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so.2 ; \
			ln -s liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so ; \
		fi ; \
	fi
	find $</lib -name *.la | xargs rm -f

################################################################
## TODO: replace most of this by $(MAKE) -C ...
$(flashprefix)/root-neutrino-cramfs-p \
$(flashprefix)/root-neutrino-squashfs-p \
$(flashprefix)/root-neutrino-jffs2-p: \
$(flashprefix)/root-neutrino-%-p: \
$(flashprefix)/root-% neutrino fx2-plugins tuxmail tuxtxt tuxcom vncviewer
	rm -rf $@
	cp -rd $< $@
	$(INSTALL) $(targetprefix)/bin/controld $(targetprefix)/bin/neutrino \
		$(targetprefix)/bin/nhttpd $(targetprefix)/bin/timerd \
		$(targetprefix)/bin/sectionsd \
		$@/bin
	cp -rd $(targetprefix)/share/tuxbox/neutrino $(targetprefix)/share/tuxbox/lcdd \
		$@/share/tuxbox
	$(MAKE) -C $(appsdir)/tuxbox/tools/satfind install prefix=$@
	$(MAKE) -C $(appsdir)/dvb/zapit install prefix=$@
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/bluebold.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/bluehigh.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/md_khmurabi_10.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/pakenham.ttf $@/share/fonts
	cp -rd $(appsdir)/tuxbox/enigma/data/fonts/unmrs.pfa $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/micron*.ttf $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/12.pcf.gz $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/14B.pcf.gz $@/share/fonts
	cp -rd $(targetprefix)/share/fonts/15B.pcf.gz $@/share/fonts
	$(INSTALL) -d $@/share/iso-codes
	cp -rd $(targetprefix)/share/iso-codes/iso-639.tab $@/share/iso-codes
#	This is for Barf's new experimental controld
	if [ -e $(appsdir)/tuxbox/neutrino/daemons/controld/io-config.xml ] ; then \
		cp $(appsdir)/tuxbox/neutrino/daemons/controld/io-config.xml $@/var/tuxbox/config; \
	fi || true
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxmail   install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxtxt    install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcom    install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/vncviewer install prefix=$@
	$(MAKE) flash-fx2-plugins prefix=$@
	@TUXBOX_CUSTOMIZE@

## TODO: replace by $(MAKE) -C ...
$(flashprefix)/root-enigma-cramfs-p \
$(flashprefix)/root-enigma-squashfs-p \
$(flashprefix)/root-enigma-jffs2-p: \
$(flashprefix)/root-enigma-%-p: \
$(flashprefix)/root-% enigma fx2-plugins
	rm -rf $@
	cp -rd $< $@
	$(INSTALL) $(targetprefix)/bin/enigma $@/bin
	cp -rd $(targetprefix)/share/tuxbox/enigma $@/share/tuxbox
	cp -rd $(targetprefix)/share/fonts/* $@/share/fonts 
	cp -rd $(targetprefix)/share/zoneinfo $@/share
	ln -sf /var/etc/localtime $@/etc
	$(INSTALL) -d $@/share/locale
	cp -rd $(appsdir)/tuxbox/enigma/po/locale.alias.image $@/share/locale/locale.alias
	cd $@/lib && tar xjf $(appsdir)/tuxbox/enigma/po/locale.image.tar.bz2
	cp -rd $(targetprefix)/share/locale/de $@/share/locale/
	cp -rd $(targetprefix)/share/locale/fr $@/share/locale/
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma all install prefix=$@
	$(MAKE) flash-fx2-plugins prefix=$@
	@TUXBOX_CUSTOMIZE@

# $(appsdir)/tuxbox/plugins/fx2/*/Makefile.am are silly and should be
# rewritten.  In the meantime, use this kludge.
flash-fx2-plugins:
	$(INSTALL) -d $(prefix)/lib/tuxbox/plugins
	$(INSTALL) -m 755 $(appsdir)/tuxbox/plugins/fx2/[c-z]*/.libs/*.so $(prefix)/lib/tuxbox/plugins
	$(INSTALL) -m 644 $(appsdir)/tuxbox/plugins/fx2/[c-z]*/*.cfg $(prefix)/lib/tuxbox/plugins
	$(INSTALL) -d $(prefix)/share/tuxbox/sokoban 
	$(INSTALL) -m 0644 $(appsdir)/tuxbox/plugins/fx2/sokoban/*.xsb $(prefix)/share/tuxbox/sokoban

################################################################
$(flashprefix)/root-cramfs: $(flashprefix)/root $(flashprefix)/root/.version $(flashprefix)/root/bin/busybox $(flashprefix)/root/sbin/in.ftpd $(flashprefix)/root/sbin/streampes $(flashprefix)/root/bin/lufsd $(flashprefix)/root/var/tuxbox/ucodes
	rm -rf $@
	cp -rd $< $@
	m4 --define=rootfs=cramfs Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	cp Patches/linux-$(KERNELVERSION).config-flash $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
#	rm -f $(DEPDIR)/driver
	$(MAKE) driver targetprefix=$@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-jffs2: $(flashprefix)/root $(flashprefix)/root/.version $(flashprefix)/root/bin/busybox $(flashprefix)/root/sbin/in.ftpd $(flashprefix)/root/sbin/streampes $(flashprefix)/root/bin/lufsd $(flashprefix)/root/var/tuxbox/ucodes
	rm -rf $@
	cp -rd $< $@
	m4 --define=rootfs=jffs2 Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	cp Patches/linux-$(KERNELVERSION).config-flash $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
#	rm -f $(DEPDIR)/driver
	$(MAKE) driver targetprefix=$@
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-squashfs: $(flashprefix)/root $(flashprefix)/root/.version $(flashprefix)/root/bin/busybox $(flashprefix)/root/sbin/in.ftpd $(flashprefix)/root/sbin/streampes $(flashprefix)/root/bin/lufsd $(flashprefix)/root/var/tuxbox/ucodes
	rm -rf $@
	cp -rd $< $@
	m4 --define=rootfs=squashfs Patches/dbox2-flash.c.m4 > linux/drivers/mtd/maps/dbox2-flash.c
	cp Patches/linux-$(KERNELVERSION).config-flash $(KERNEL_DIR)/.config
	$(MAKE) $(KERNEL_BUILD_FILENAME) targetprefix=$@
	$(hostprefix)/bin/mkimage \
		-n 'dbox2' -A ppc -O linux -T kernel -C gzip \
		-a 00000000 -e 00000000 -d $(KERNEL_BUILD_FILENAME) $@/vmlinuz
#	rm -f $(DEPDIR)/driver
	$(MAKE) driver targetprefix=$@
	@TUXBOX_CUSTOMIZE@

############
$(flashprefix)/root/var/tuxbox/ucodes:
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/ucodes
	if [ -d $(ucodesdir) ] ; then \
		rm -f $(flashprefix)/root/var/tuxbox/ucodes/*; \
		cp -p $(ucodesdir)/* $(flashprefix)/root/var/tuxbox/ucodes; \
	fi || true

################################################################
# flash-ftpd
#$(flashprefix)/root/sbin/in.ftpd: $(flashprefix)/root $(DEPDIR)/ftpd
#	$(INSTALL) -d $</share/empty
#	$(INSTALL) $(targetprefix)/etc/vsftpd.conf $</etc
#	$(INSTALL) $(targetprefix)/sbin/in.ftpd $</sbin
#	@TUXBOX_CUSTOMIZE@

# Remark: the install target in the Makefile in in.ftpd is not GNU-conformant,
# therefor the silly install command.
$(flashprefix)/root/sbin/in.ftpd: $(flashprefix)/root
	-rm -rf $(flashprefix)/root/share/empty
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		$(INSTALL) -m755 vsftpd $(flashprefix)/root/sbin/in.ftpd && $(INSTALL) -m644 vsftpd-dbox2.conf $(flashprefix)/root/etc/vsftpd.conf && $(INSTALL) -d $(flashprefix)/root/share/empty
	@CLEANUP_ftpd@
	@TUXBOX_CUSTOMIZE@

## flash-dvb-tools
## TODO: fix if possible
$(flashprefix)/root/sbin/streampes: | $(flashprefix)/root dvb_tools zapit
	$(INSTALL) $(targetprefix)/sbin/streamsec $</sbin
	$(INSTALL) $(targetprefix)/sbin/streamts $</sbin
	$(INSTALL) $(targetprefix)/sbin/udpstreampes $</sbin
	$(INSTALL) $(targetprefix)/sbin/streampes $</sbin
	@TUXBOX_CUSTOMIZE@

## flash-ftpfs 
## TODO: fix if possible
$(flashprefix)/root/bin/lufsd: $(flashprefix)/root $(DEPDIR)/lufs
	$(INSTALL) $(targetprefix)/bin/lufsmnt $</bin
	$(INSTALL) $(targetprefix)/bin/lufsd $</bin
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root/bin/busybox: bootstrap $(flashprefix)/root
	@PREPARE_busybox@
	m4 -Dflash Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		$(MAKE) install PREFIX=$(flashprefix)/root
	@CLEANUP_busybox@

$(flashprefix)/root/.version: $(flashprefix)/root
	echo "version=0200`date +%Y%m%d%H%M`" 	> $@
	echo "creator=`id -un`" 		>> $@
	echo "imagename=newmake-image" 		>> $@
	echo "homepage=http://www.tuxbox.org" 	>> $@

# tuxbox_tools is only needed for switch.
$(flashprefix)/root: bootstrap $(appsdir)/dvb/config/config.status $(appsdir)/tuxbox/tools/config.status tuxbox_tools | $(flashprefix) 
	rm -rf $@
	$(INSTALL) -d $@/bin
	$(INSTALL) -d $@/dev
	$(INSTALL) -d $@/lib/tuxbox
	$(INSTALL) -d $@/mnt
	$(INSTALL) -d $@/proc
	$(INSTALL) -d $@/sbin
	$(INSTALL) -d $@/share/tuxbox
	$(INSTALL) -d $@/share/fonts
	$(INSTALL) -d $@/var/tuxbox/config
	$(INSTALL) -d $@/var/etc
	$(INSTALL) -d $@/tmp
	$(INSTALL) -d $@/etc
	$(INSTALL) -d $@/root
	ln -s /tmp $@/var/run
	$(INSTALL) $(appsdir)/tuxbox/neutrino/daemons/controld/scart.conf $@/var/tuxbox/config
	$(MAKE) -C $(appsdir)/tuxbox/tools/tuxinfo install prefix=$@
	$(MAKE) -C $(appsdir)/tuxbox/tools/misc install prefix=$@
	$(MAKE) -C $(appsdir)/dvb/config all install datadir=$@/share
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	@TUXBOX_CUSTOMIZE@

################################################################
$(flashprefix):
	$(INSTALL) -d $@
################################################################
# Targets, which are not executed by detault

## TODO: fix
$(flashprefix)/root/sbin/eraseall: misc_tools
	$(INSTALL) $(targetprefix)/sbin/eraseall $@

$(flashprefix)/root/sbin/lircd: lirc
	$(INSTALL) $(targetprefix)/sbin/lircd $@
	$(INSTALL) -d $(targetprefix)/var/tuxbox/config/lirc

$(flashprefix)/root/bin/ssh: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh

$(flashprefix)/root/sbin/sshd: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
#??#	cp -rd $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin

# Dreamdata
$(flashprefix)/root/bin/mrouted: $(flashprefix)/root plugins mrouted
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var/tuxbox/config
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/var/tuxbox/config/dreamdata.xml $(flashprefix)/root/var/tuxbox/config/
	$(INSTALL) $(targetprefix)/bin/mrouted $(flashprefix)/root/bin

$(flashprefix)/root/sbin/dropbear: $(flashprefix)/root dropbear dropbearkey
	$(INSTALL) -d $(flashprefix)/root/etc/dropbear
	$(INSTALL) $(targetprefix)/bin/dropbearmulti $(flashprefix)/root/bin
	rm -f $(flashprefix)/root/sbin/dropbear
	rm -f $(flashprefix)/root/sbin/dbclient
	rm -f $(flashprefix)/root/bin/scp
	ln -s ../bin/dropbearmulti $(flashprefix)/root/sbin/dropbear
	ln -s ../bin/dropbearmulti $(flashprefix)/root/sbin/dbclient
	ln -s ../bin/dropbearmulti $(flashprefix)/root/bin/scp
	cp -rd $(targetprefix)/etc/dropbear/* $(flashprefix)/root/etc/dropbear

$(flashprefix)/root/bin/lcars: $(flashprefix)/root lcars
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/init.d/start_lcars $(flashprefix)/root/etc/init.d/
	cp -rd $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
	cp -rd $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config

$(flashprefix)/root/bin/lcdmenu: $(flashprefix)/root lcd
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -rd $(targetprefix)/var/tuxbox/config/lcdmenu.conf $(flashprefix)/root/var/tuxbox/config

################################################################ 
# This .PRECIOUS-bizarreness is there to tell Make that these files are not
# just "intermediate products", but are not to be deleted.  For the
# directories, these are not really valuable, however, make tries to
# delete them with rm, and this fails, generating error messages that
# may be ugly and/or confusing.

.PRECIOUS: \
$(flashprefix)/neutrino-cramfs.img% $(flashprefix)/enigma-cramfs.img% \
$(flashprefix)/neutrino-squashfs.img% $(flashprefix)/enigma-squashfs.img% \
$(flashprefix)/neutrino-jffs2.img% $(flashprefix)/enigma-jffs2.img% \
$(flashprefix)/root-%-jffs2  $(flashprefix)/root-% \
$(flashprefix)/root-neutrino-% $(flashprefix)/root-enigma-% \
$(flashprefix)/root-neutrino-%-p $(flashprefix)/root-enigma-%-p \
$(flashprefix)/vmlinuz-% \
$(flashprefix)/var-%.jffs2 \
$(flashprefix)/root-%.jffs2 \
$(flashprefix)/root-%.cramfs $(flashprefix)/root-%.squashfs \
%/lib/ld.so.1 \
$(flashprefix)/root/lib/tuxbox/plugins/%.cfg
################################################################
# flash-clean deletes everything created with the flash-* commands
# flash-developerclean leaves the flfs-images and the vmlinuz-* files.
# (This is sensible, while these files seldomly change, and take rather
# long to build.)

# flash-semiclean and flash-developerclean, are "homemade",
# flash-clean and flash-mostlyclean have semantics like in the GNU
# Makefile standards.

flash-semiclean:
	rm -f $(flashprefix)/*.cramfs $(flashprefix)/*.squashfs \
	$(flashprefix)/*.jffs2 $(flashprefix)/.*-flfs \
	$(flashprefix)/.*_checked* $(flashprefix)/.root-*
	rm -rf $(flashprefix)/root* 
	rm -rf $(flashprefix)/var*

flash-developerclean: flash-semiclean
	rm -f $(flashprefix)/*.img*

flash-mostlyclean: flash-semiclean
	rm -f $(flashprefix)/*.flfs*x

flash-clean: flash-mostlyclean
	rm -f $(flashprefix)/*.img*
endif ## TARGETRULESET_FLASH

#######################
#
#   internal
#

APPSCLEANUP:=rm -f $(DEPDIR)/neutrino $(DEPDIR)/enigma $(DEPDIR)/zapit $(DEPDIR)/plugins $(DEPDIR)/tuxbox_tools $(DEPDIR)/misc_tools $(DEPDIR)/misc_libs $(DEPDIR)/tuxbox_libs $(DEPDIR)/libtuxbox $(DEPDIR)/dvb_tools $(DEPDIR)/driver $(DEPDIR)/lcars $(DEPDIR)/lcd $(DEPDIR)/dvbsnoop 

depsclean:
	$(DEPSCLEANUP)
	$(APPSCLEANUP)
	rm -f $(DEPDIR)/u-boot $(DEPDIR)/linuxkernel $(DEPDIR)/driver

if TARGETRULESET_FLASH
mostlyclean-local: flash-clean cdk-clean
else
mostlyclean-local: cdk-clean
endif

cdk-clean:
	$(APPSCLEANUP)
	-$(MAKE) -C linux clean
	-$(MAKE) -C $(driverdir) KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) clean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino clean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma clean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars clean
	-$(MAKE) -C $(appsdir)/dvb/zapit clean
	-$(MAKE) -C $(appsdir)/tuxbox/plugins clean
	-$(MAKE) -C $(appsdir)/tuxbox/tools clean
	-$(MAKE) -C $(appsdir)/misc/tools clean
	-$(MAKE) -C $(appsdir)/misc/libs clean
	-$(MAKE) -C $(appsdir)/tuxbox/libs clean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox clean
	-$(MAKE) -C $(appsdir)/dvb/tools clean
	-$(MAKE) -C $(appsdir)/dvb/config distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop clean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd clean
	-$(MAKE) -C $(hostappsdir) clean

clean-local:
	-$(MAKE) -C etc clean
	-$(MAKE) -C $(appsdir) clean
	-$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf build
	-rm -f $(bootprefix)/dboxflasher
	-rm -f $(bootprefix)/u-boot
	-rm -f $(bootprefix)/kernel-cdk
	-@CLEANUP@

distclean-local:
	-$(MAKE) -C root distclean
	-$(MAKE) -C $(appsdir) distclean
	-$(MAKE) -C $(appsdir)/dvb/configtools distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvb++ distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvbsi++ distclean
	-$(MAKE) -C $(appsdir)/dvb/tools distclean
	-$(MAKE) -C $(appsdir)/dvb/zapit distclean
	-$(MAKE) -C $(appsdir)/misc/libs distclean
	-$(MAKE) -C $(appsdir)/misc/tools distclean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma distclean
	-$(MAKE) -C $(appsdir)/tuxbox/funstuff distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libs distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox distclean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools distclean
	-$(MAKE) -C $(hostappsdir) distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug distclean
	-$(MAKE) -C $(driverdir) distclean KERNEL_LOCATION=$(buildprefix)/linux
	-rm Makefile-archive
	-rm rules-downcheck.pl
	-rm $(DEPDIR) -rf
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
	-rm -rf $(serversupport)
if TARGETRULESET_FLASH
	-rm -rf $(flashprefix)
endif

@ARCHIVE@

if MAINTAINER_MODE
Makefile-archive: $(top_srcdir)/rules-archive $(top_srcdir)/rules-archive.pl
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive
endif

if TARGETRULESET_FLASH
.PHONY: core libs root apps boot devel java copy lib compress \
	depsclean mostlyclean clean distclean \
	flash-clean flash-semiclean flash-developerclean flash-mostlyclean
else
.PHONY: core libs root apps boot devel java depsclean mostlyclean clean distclean
endif

EXTRA_DIST = \
	rules.pl rules-archive.pl rules-downcheck.pl.in \
	rules-archive \
	rules-install rules-install-flash \
	rules-make

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules.pl \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash \
	$(top_srcdir)/rules-make \
	Makefile-archive

if ENABLE_OLDTARGETS
include backwards_compat.mk
endif

# Give the user rope to hang himself :-).  (Note: read from the
# generated Makefile during make run, automake or configure does not
# see it.)
-include ./Makefile.local
