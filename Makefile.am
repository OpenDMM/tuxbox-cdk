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

all: core libs root boot apps devel
extra: java contrib_apps fun dvb_apps

#######################
#
#   core
#

core: .directories .binutils .linuxdir .glibc .gcc

checkout:
	@for i in apps/tuxbox/enigma apps/dvb/dvbsnoop \
		apps/dvb/tools/stream apps/tuxbox/plugins \
		apps/tuxbox/libs ; do \
		CURRENT_PATH=`pwd`; \
		cd ../$$i && cvs update -d -P -A; \
		cd $$CURRENT_PATH; \
	done

.bootstrap:
	@if [ ! -f .glibc ]; then \
		$(MAKE) .glibc .gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) .gcc; \
	fi
	touch $@

.directories:
	@for i in bin boot dev etc include mnt lib lib/pkgconfig proc root sbin tmp var/run $(UCODEDIR); do \
		$(INSTALL) -d $(targetprefix)/$$i ; done;
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(bootprefix)
	-rm $(hostprefix)/$(target)/include
	-rm $(hostprefix)/$(target)/lib
	-ln -s $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -s $(targetprefix)/lib $(hostprefix)/$(target)/lib
if TARGETRULESET_FLASH
	$(INSTALL) -d $(flashprefix)
endif
	touch $@

.linuxdir: @DEPENDS_linux@
	@if [ ! -d $(targetprefix)/bin ]; then \
		$(MAKE) .directories; \
	fi
	@PREPARE_linux@
if BOXTYPE_DM7000
	cat @DIR_linux@/arch/ppc/configs/dm7000_defconfig > @DIR_linux@/.config
endif
if BOXTYPE_DM56x0
	cat @DIR_linux@/arch/ppc/configs/dm56x0_defconfig > @DIR_linux@/.config
endif
if BOXTYPE_DM500
	cat @DIR_linux@/arch/ppc/configs/dm500_defconfig > @DIR_linux@/.config
endif
	$(MAKE) -C @DIR_linux@ oldconfig \
		ARCH=ppc
	$(MAKE) -C @DIR_linux@ include/linux/version.h \
		ARCH=ppc
	-ln -sf $(buildprefix)/linux/include/asm-ppc $(buildprefix)/linux/include/asm
	touch $@

.binutils: @DEPENDS_binutils@
	@if [ ! -h linux ]; then \
		$(MAKE) .linuxdir; \
	fi
	@PREPARE_binutils@
	cd @DIR_binutils@ && \
		CC=$(CC) \
		CFLAGS="$(CFLAGS)" \
		@CONFIGURE_binutils@ \
			--target=$(target) \
			--prefix=$(hostprefix) \
			--disable-nls \
			--nfp && \
		$(MAKE) all all-gprof && \
		@INSTALL_binutils@
	@CLEANUP_binutils@
	touch $@

#
# gcc first stage without glibc
#
bootstrap_gcc: @DEPENDS_bootstrap_gcc@
	@if [ ! -d $(hostprefix)/$(target)/bin/as ]; then \
		$(MAKE) .binutils; \
	fi
	@PREPARE_bootstrap_gcc@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/sys-include/
	@for i in linux asm-generic asm mtd ; do \
		rm -rf $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		ln -sf $(buildprefix)/linux/include/$$i $(hostprefix)/$(target)/include; \
	done;
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
			--disable-nls \
			--disable-threads \
			--with-float=soft && \
		$(MAKE) all && \
		@INSTALL_bootstrap_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@CLEANUP_bootstrap_gcc@

.glibc: @DEPENDS_glibc@ @DEPENDS_linux_libc_headers@
	@rm $(hostprefix)/bin/$(target)-gcc 2>/dev/null || /bin/true
	@if [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) bootstrap_gcc; \
	elif [ ! -f $(hostprefix)/bin/$(target)-gcc ]; then \
		$(MAKE) .gcc; \
	fi
	@PREPARE_glibc@
	cd @DIR_glibc@ && \
		CC=$(target)-gcc \
		AR=$(target)-ar \
		RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		@CONFIGURE_glibc@ \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--with-headers=$(buildprefix)/linux/include \
			--enable-kernel=2.6.5 \
			--disable-profile \
			--enable-shared \
			--enable-add-ons=nptl \
			--with-__thread \
			--without-fp \
			--with-tls && \
		$(MAKE) all && \
		@INSTALL_glibc@
	@CLEANUP_glibc@
	@PREPARE_linux_libc_headers@
	mv $(buildprefix)/linux-libc-headers/include/asm-ppc $(buildprefix)/linux-libc-headers/include/asm
	for i in linux asm asm_generic; do \
		rm -R $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		if [ $$i != asm_generic ] ; then \
			mv $(buildprefix)/linux-libc-headers/include/$$i $(hostprefix)/$(target)/include; \
		fi; \
	done;
	for i in config.h autoconf.h; do \
		ln -sf $(buildprefix)/linux/include/linux/$$i $(hostprefix)/$(target)/include/linux; \
	done;
	@CLEANUP_linux_libc_headers@
	rm $(hostprefix)/$(target)/include/asm-generic 2> /dev/null || /bin/true;
	rm $(buildprefix)/linux-libc-headers 2> /dev/null || /bin/true
	touch $@

#
# uClibc
# a minimalistic libc, won't currently work with libstdc++
#
.uclibc: @DEPENDS_uclibc@
	@PREPARE_uclibc@
	cd @DIR_uclibc@ && \
		$(MAKE) all CROSS=$(target)- && \
		@INSTALL_uclibc@
	@CLEANUP_uclibc@
	touch $@

#
# gcc second stage with glibc
#
.gcc: @DEPENDS_gcc@
	@if [ ! -f $(hostprefix)/$(target)/lib/libc.so ]; then \
		$(MAKE) .glibc; \
	fi
	@PREPARE_gcc@
	$(INSTALL) -d $(hostprefix)/$(target)/sys-include
	@if [ -s $(hostprefix)/$(target)/lib/nof ] ; then \
		rm $(hostprefix)/$(target)/lib/nof; \
	fi
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
			--enable-threads=posix \
			--disable-nls \
			--with-float=soft \
			--enable-__cxa_atexit && \
		$(MAKE) all && \
		@INSTALL_gcc@
	rm -rf $(hostprefix)/$(target)/sys-include
	@for i in `find $(hostprefix)/$(target)/lib/nof -type f` ; do mv $$i $(hostprefix)/$(target)/lib; done
	@for i in `find $(hostprefix)/$(target)/lib/nof -type l` ; do mv $$i $(hostprefix)/$(target)/lib; done
	rm -rf $(hostprefix)/$(target)/lib/nof
	ln -sf $(hostprefix)/$(target)/lib $(hostprefix)/$(target)/lib/nof
	@CLEANUP_gcc@
	touch $@

#######################
#
#   root
#

root: \
	.etc .busybox .ftpd .modutils \
	.procps .watchdog

root_optional: \
	.portmap .mrouted

.busybox: .bootstrap .etc @DEPENDS_busybox@
	@PREPARE_busybox@
	cat Patches/busybox.config > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="-Os -msoft-float" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch $@

.etc:
#	$(MAKE) -C etc install
	touch $@

.ftpd: .bootstrap @DEPENDS_ftpd@
	@PREPARE_ftpd@
	cd @DIR_ftpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_ftpd@
	@CLEANUP_ftpd@
	touch $@

.modutils: .bootstrap @DEPENDS_modutils@
	@PREPARE_modutils@
	cd @DIR_modutils@ && \
		$(BUILDENV) \
		BUILDCC=$(CC) BUILDCFLAGS="-O2" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-root-check \
			--disable-strip && \
		$(MAKE) && \
		@INSTALL_modutils@
	@CLEANUP_modutils@
	touch $@

.portmap: .bootstrap @DEPENDS_portmap@
	@PREPARE_portmap@
	cd @DIR_portmap@ && \
		$(BUILDENV) \
		$(MAKE) && \
		$(FAKEROOT) $(MAKE) BASEDIR=$(targetprefix) install && \
		cd .. && \
	@CLEANUP_portmap@
	touch $@

.procps: .bootstrap .libncurses @DEPENDS_procps@
	@PREPARE_procps@
	cd @DIR_procps@ && \
		$(BUILDENV) \
		$(MAKE) top ps && \
		@INSTALL_procps@
	@CLEANUP_procps@
	touch $@

.watchdog: .bootstrap @DEPENDS_watchdog@
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

.mrouted: .bootstrap @DEPENDS_mrouted@
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

if WITH_LIBCRYPTO
OPTIONAL_LIBCRYPTO = .libcrypto
endif

libs: \
	$(OPTIONAL_LIBCRYPTO) .libcurl .libdvbpsi .libffi .libfreetype .libjpeg \
	.libmad .libid3tag .libncurses .libpng .libreadline .libsdl .libsigc .libz .libvorbisidec

libs_optional: \
	.libcommoncplusplus .libdb2 .libnet .libnids .libpcap .libpopt .libungif \
	.libxml2 .libxmlparse .libxmlwrapp .libgif

.libboost: .bootstrap @DEPENDS_libboost@
	@PREPARE_libboost@
	cd @DIR_libboost@ && \
		@INSTALL_libboost@
	@CLEANUP_libboost@
	touch $@

.libcommoncplusplus: .bootstrap .libxml2 @DEPENDS_libcommoncplusplus@
	@PREPARE_libcommoncplusplus@
	cd @DIR_libcommoncplusplus@ &&\
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libcommoncplusplus@
	@CLEANUP_libcommoncplusplus@
	touch $@

.libcrypto: .bootstrap @DEPENDS_libcrypto@
	@PREPARE_libcrypto@
	cd @DIR_libcrypto@ && \
		./Configure shared no-idea no-md2 no-md4 no-mdc2 no-rc2 no-rc5 tuxbox --prefix=/ --openssldir=/ && \
		$(MAKE) all && \
		@INSTALL_libcrypto@
	@CLEANUP_libcrypto@
	touch $@

.libcurl: .bootstrap @DEPENDS_libcurl@
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

.libdb2: .bootstrap @DEPENDS_libdb2@
	@PREPARE_libdb2@
	cd @DIR_libdb2@/dist && \
		chmod 755 configure && \
		autoconf && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-compat185 \
			--enable-cxx && \
		$(MAKE) all && \
		@INSTALL_libdb2@
	@CLEANUP_libdb2@
	touch $@

.libdvbpsi: .bootstrap @DEPENDS_libdvbpsi@
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

.libffi: .bootstrap @DEPENDS_libffi@
	@PREPARE_libffi@
	cd @DIR_libffi@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libffi@
	@CLEANUP_libffi@
	touch $@

.libfreetype: .bootstrap @DEPENDS_libfreetype@
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

.libfribidi: .bootstrap @DEPENDS_libfribidi@
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
if TARGETRULESET_FLASH
		cd $(hostprefix)/$(target)/lib && \
		ln -sf libfribidi.a libfribidi_pic.a
endif
	@CLEANUP_libfribidi@
	touch $@

.libgmp: .bootstrap @DEPENDS_libgmp@
	@PREPARE_libgmp@
	cd @DIR_libgmp@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libgmp@
	@CLEANUP_libgmp@
	touch $@

.libjpeg: .bootstrap @DEPENDS_libjpeg@
	@PREPARE_libjpeg@
	cd @DIR_libjpeg@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-static \
			--enable-shared && \
		$(MAKE) libjpeg.la && \
		@INSTALL_libjpeg@
if TARGETRULESET_FLASH
		cd $(hostprefix)/$(target)/lib && \
		ln -sf libjpeg.a libjpeg_pic.a
endif
	@CLEANUP_libjpeg@
	touch $@
.libdirectfb: .bootstrap .libfreetype .libjpeg .libpng .libz @DEPENDS_libdirectfb@
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
	
.libdirectfbpp: .bootstrap .libdirectfb @DEPENDS_libdirectfbpp@
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
																																	
.libppdirectfb: .bootstrap .libdirectfb @DEPENDS_libppdirectfb@
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
		
.libmad: .bootstrap .libz @DEPENDS_libmad@
	@PREPARE_libmad@
	cd @DIR_libmad@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--enable-shared=yes \
			--disable-nls \
			--without-esd \
			--enable-fpm=ppc \
			--enable-sso \
			--enable-accuracy && \
		$(MAKE) all && \
		@INSTALL_libmad@
	@CLEANUP_libmad@
	touch $@

.libid3tag: .bootstrap .libz @DEPENDS_libid3tag@
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
	
.libncurses: .bootstrap @DEPENDS_libncurses@
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

.libnet: .bootstrap @DEPENDS_libnet@
	@PREPARE_libnet@
	cd @DIR_libnet@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-pf_packet=yes \
			--with-fast_x86_check=no && \
		$(MAKE) all && \
		@INSTALL_libnet@
	@CLEANUP_libnet@
	touch $@

.libnids: .bootstrap .libnet @DEPENDS_libnids@
	@PREPARE_libnids@
	cd @DIR_libnids@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libnids@
	@CLEANUP_libnids@
	touch $@

.libpcap: .bootstrap @DEPENDS_libpcap@
	@PREPARE_libpcap@
	cd @DIR_libpcap@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-pcap=linux \
			--build=$(build) && \
		$(MAKE) all && \
		@INSTALL_libpcap@
	@CLEANUP_libpcap@
	touch $@

.libpng: .bootstrap .libz @DEPENDS_libpng@
	@PREPARE_libpng@
	cd @DIR_libpng@ && \
		$(MAKE) libpng.a libpng12.so libpng.pc libpng-config \
			$(BUILDENV) \
			CPPFLAGS="-DPNG_DEBUG=0" \
			prefix=$(targetprefix) && \
		@INSTALL_libpng@
	@CLEANUP_libpng@
	touch $@

.libpopt: .bootstrap @DEPENDS_libpopt@
	@PREPARE_libpopt@
	cd @DIR_libpopt@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix)\
			--with-pic \
			--disable-nls && \
		$(MAKE) all && \
		@INSTALL_libpopt@
	@CLEANUP_libpopt@
	touch $@

.libreadline: .bootstrap @DEPENDS_libreadline@
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

.libsdl: .bootstrap @DEPENDS_libsdl@
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

.libsigc: .bootstrap @DEPENDS_libsigc@
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

.libvorbisidec: .bootstrap @DEPENDS_libvorbisidec@
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

.libungif: .bootstrap @DEPENDS_libungif@
	@PREPARE_libungif@
	cd @DIR_libungif@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-x && \
		$(MAKE) && \
		@INSTALL_libungif@
if TARGETRULESET_FLASH
		cd $(hostprefix)/$(target)/lib && \
		ln -sf libungif.a libungif_pic.a
endif
	@CLEANUP_libungif@
	touch $@

.libxml2: .bootstrap @DEPENDS_libxml2@
	@PREPARE_libxml2@
	cd @DIR_libxml2@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
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

.libxmlparse: .bootstrap @DEPENDS_libxmlparse@
	@PREPARE_libxmlparse@
	cd @DIR_libxmlparse@ && \
		aclocal -I . && \
		libtoolize --automake --force && \
		autoconf && \
		automake --add-missing --force-missing && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--enable-ambiguous \
			--enable-libstdcpp3 && \
		$(MAKE) all && \
		@INSTALL_libxmlparse@
	@CLEANUP_libxmlparse@
	touch $@

.libxmlwrapp: .bootstrap .libxml2 @DEPENDS_libxmlwrapp@
	@PREPARE_libxmlwrapp@
	cd @DIR_libxmlwrapp@ && \
		$(BUILDENV) \
		./configure.pl \
			--disable-examples \
			--prefix $(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_libxmlwrapp@
	@CLEANUP_libxmlwrapp@
	touch $@

.libz: .bootstrap @DEPENDS_libz@
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

#######################
#
#   contrib apps
#

contrib_apps: .console_data .console_tools .fbset .lirc .lsof .ssh .tcpdump .xrc
contrib_apps_optional: .dsniff .pump .thttpd

.console_data: .bootstrap @DEPENDS_console_data@
	@PREPARE_console_data@
	cd @DIR_console_data@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-main_compressor=gzip && \
		@INSTALL_console_data@
	@CLEANUP_console_data@
	touch $@

.console_tools: .bootstrap .console_data @DEPENDS_console_tools@
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

.dsniff: .bootstrap .libnet .libnids .libdb2 .rpcgen @DEPENDS_dsniff@
	@PREPARE_dsniff@
	cd @DIR_dsniff@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--without-x && \
		$(MAKE) all && \
		@INSTALL_dsniff@
	@CLEANUP_dsniff@
	touch $@

.fbset: .bootstrap @DEPENDS_fbset@
	@PREPARE_fbset@
	cd @DIR_fbset@ && \
		$(MAKE) \
			$(BUILDENV) && \
		@INSTALL_fbset@
	@CLEANUP_fbset@
	touch $@

.lirc: .bootstrap @DEPENDS_lirc@
	@PREPARE_lirc@
	cd @DIR_lirc@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		mknod=/bin/true \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--with-devdir=/dev \
			--with-driver=serial \
			--with-kerneldir=$(buildprefix)/linux-$(KERNELVERSION) \
			--with-moduledir=$(targetprefix)/lib/modules/$(KERNELVERSION)/misc \
			--without-x && \
		@INSTALL_lirc@
	@CLEANUP_lirc@
	touch $@

.utillinux: .bootstrap @DEPENDS_utillinux@
	@PREPARE_utillinux@
	cd @DIR_utillinux@ && \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure && \
		$(MAKE) ARCH=ppc all && \
		@INSTALL_utillinux@
	@CLEANUP_utillinux@
	touch $@

.nfs_utils: .bootstrap @DEPENDS_nfs_utils@
	@PREPARE_nfs_utils@
	cd @DIR_nfs_utils@ && \
		CC=$(target)-gcc \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure && \
		$(MAKE) ARCH=ppc all && \
		$(FAKEROOT) $(MAKE) install_prefix=$(targetprefix) install && \
		cd .. && \
	@CLEANUP_nfs_utils@
	touch $@

.samba: .bootstrap @DEPENDS_samba@
	@PREPARE_samba@
	cd @DIR_samba@ && \
		cd source && \
		(for i in smbd nmbd smbmount smbmnt; do \
			$(MAKE) $$i; \
			cp $$i $(targetprefix)/bin; \
		done)
	@CLEANUP_samba@
	touch $@

.etherwake: .bootstrap @DEPENDS_etherwake@
	@PREPARE_etherwake@
	cd @DIR_etherwake@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) && \
		@INSTALL_etherwake@
	@CLEANUP_etherwake@
	touch $@

.reiserfsprogs: .bootstrap @DEPENDS_reiserfsprogs@
	@PREPARE_reiserfsprogs@
	cd @DIR_reiserfsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) && \
		@INSTALL_reiserfsprogs@
	@CLEANUP_reiserfsprogs@
	touch $@

.e2fsprogs: .bootstrap @DEPENDS_e2fsprogs@
	@PREPARE_e2fsprogs@
	cd @DIR_e2fsprogs@ && \
		CC=$(target)-gcc \
		RANLIB=$(target)-ranlib \
		CFLAGS="-Os -msoft-float" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) \
			--with-cc=$(target)-gcc \
			--with-linker=$(target)-ld \
			--disable-evms \
			--enable-elf-shlibs \
			--enable-htree \
			--disable-profile \
			--disable-swapfs \
			--disable-debugfs \
			--disable-image \
			--disable-resizer \
			--enable-dynamic-e2fsck \
			--enable-fsck \
			--with-gnu-ld \
			--disable-nls && \
		$(MAKE) libs progs && \
		@INSTALL_e2fsprogs@
	@CLEANUP_e2fsprogs@
	touch $@

.lsof: .bootstrap @DEPENDS_lsof@
	@PREPARE_lsof@
	cd @DIR_lsof@ && \
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

.pump: .bootstrap .libpopt @DEPENDS_pump@
	@PREPARE_pump@
	cd @DIR_pump@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) all && \
		@INSTALL_pump@
	@CLEANUP_pump@
	touch $@

.ssh: .bootstrap .libcrypto .libz @DEPENDS_ssh@
	@PREPARE_ssh@
	cd @DIR_ssh@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
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

.tcpdump: .bootstrap .libpcap @DEPENDS_tcpdump@
	@PREPARE_tcpdump@
	cd @DIR_tcpdump@ && \
		$(BUILDENV) \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--libdir=$(targetprefix)/lib \
			--build=$(build) && \
		$(MAKE) && \
		@INSTALL_tcpdump@
	@CLEANUP_tcpdump@
	touch $@

.thttpd: @DEPENDS_thttpd@
	@PREPARE_thttpd@
	cd @DIR_thttpd@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_thttpd@
	@CLEANUP_thttpd@
	touch $@

.xrc: .bootstrap .lirc @DEPENDS_xrc@
	@PREPARE_xrc@
	cd @DIR_xrc@ && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--disable-qpe \
			--disable-qt-embedded \
			--without-x && \
		@INSTALL_xrc@
	@CLEANUP_xrc@
	touch $@


#######################
#
#   development tools
#

devel: .gdb .ltrace .strace .nano .joe
devel_optional: .gdb-remote .insight .ksymoops

.gdb: .bootstrap .libncurses @DEPENDS_gdb@
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
			--prefix= && \
		$(MAKE) all-gdb && \
		@INSTALL_gdb@
	@CLEANUP_gdb@
	touch $@

.gdb-remote: @DEPENDS_gdb@
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

.ksymoops: .bootstrap @DEPENDS_ksymoops@
	@PREPARE_ksymoops@
	cd @DIR_ksymoops@ && \
		$(MAKE) CC=$(target)-gcc DEF_MAP="\\\"/boot/System.map-*r\\\"" DEF_VMLINUX="\\\"/boot/vmlinux-*r\\\"" &&\
		@INSTALL_ksymoops@
	@CLEANUP_ksymoops@
	touch $@

.insight: @DEPENDS_insight@
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

.ltrace: .bootstrap @DEPENDS_ltrace@
	@PREPARE_ltrace@
	cd @DIR_ltrace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix= && \
		$(MAKE) clean all LD=$(target)-ld && \
		@INSTALL_ltrace@
	@CLEANUP_ltrace@
	touch $@

.strace: .bootstrap @DEPENDS_strace@
	@PREPARE_strace@
	cd @DIR_strace@ && \
		$(BUILDENV) \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--target=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_strace@
	@CLEANUP_strace@
	touch $@

.nano: .bootstrap .libncurses @DEPENDS_nano@
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
.joe: .bootstrap .libncurses @DEPENDS_joe@ 
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
																								
#######################
#
# java stuff
#

java: .kaffeh .kaffe

# for x86
.kaffeh: .bootstrap @DEPENDS_kaffeh@
	@PREPARE_kaffeh@
	cd @DIR_kaffeh@ && \
		./configure \
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
.kaffe: .bootstrap .kaffeh .libffi @DEPENDS_kaffe@
	@PREPARE_kaffe@
	cd @DIR_kaffe@ && \
		CC=$(target)-gcc CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--host=$(target) \
			--prefix=$(targetprefix) \
			--libexecdir=$(targetprefix)/bin \
			--enable-feedback \
			--with-stats \
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

fun: .gnuboy .scummvm .sdldoom

.gnuboy: .bootstrap @DEPENDS_gnuboy@
	@PREPARE_gnuboy@
	cd @DIR_gnuboy@ && \
		autoconf && \
		CC=$(target)-gcc \
		CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix=$(targetprefix) && \
		$(MAKE) all && \
		@INSTALL_gnuboy@
	@CLEANUP_gnuboy@
	touch $@

.scummvm: .bootstrap .libreadline .libsdl @DEPENDS_scummvm@
	@PREPARE_scummvm@
	cd @DIR_scummvm@ && \
		./configure \
		    --host=$(target) && \
		$(MAKE) \
			AR="$(target)-ar cru" \
			LD=$(target)-ld \
			CC=$(target)-gcc \
			CXX=$(target)-g++ \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TAGET_LDFLAGS)" && \
		@INSTALL_scummvm@
	@CLEANUP_scummvm@
	touch $@

.sdldoom: .bootstrap .libsdl @DEPENDS_sdldoom@
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

dvb_apps: .dvbdate .dvbstream .dvbtext .dvbtune .vls

.dvbdate: .bootstrap @DEPENDS_dvbdate@
	@PREPARE_dvbdate@
	cd @DIR_dvbdate@ && \
		$(MAKE) dvbdate \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_dvbdate@
	@CLEANUP_dvbdate@
	touch $@

.dvbstream: .bootstrap @DEPENDS_dvbstream@
	@PREPARE_dvbstream@
	cd @DIR_dvbstream@ && \
		$(MAKE) dvbstream rtpfeed\
			INCS="-I$(driverdir)/include" \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" && \
		@INSTALL_dvbstream@
	@CLEANUP_dvbstream@
	touch $@

.dvbtext: .bootstrap @DEPENDS_dvbtext@
	@PREPARE_dvbtext@
	cd @DIR_dvbtext@ && \
		$(target)-gcc $(TARGET_CFLAGS) -I$(driverdir)/include -o dvbtext dvbtext.c && \
		@INSTALL_dvbtext@
	@CLEANUP_dvbtext@
	touch $@

.dvbtune: .bootstrap @DEPENDS_dvbtune@
	@PREPARE_dvbtune@
	cd @DIR_dvbtune@ && \
		$(MAKE) \
			CC=$(target)-gcc \
			CFLAGS="$(TARGET_CFLAGS) -I$(driverdir)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)" && \
		@INSTALL_dvbtune@
	@CLEANUP_dvbtune@
	touch $@

.vls: .bootstrap .libdvbpsi @DEPENDS_vls@
	@PREPARE_vls@
	cd @DIR_vls@ && \
		CC=$(target)-gcc \
		CXX=$(target)-g++ \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			--disable-dvd \
			--with-dvb=$(driverdir)/include && \
		$(MAKE) all && \
		@INSTALL_vls@
	@CLEANUP_vls@
	touch $@

#######################
#
#   own kernel
#

boot: .linuxkernel

.linuxkernel: .bootstrap .linuxdir
	$(MAKE) -C @DIR_linux@ zImage modules \
		ARCH=ppc \
		CROSS_COMPILE=$(target)-
	$(MAKE) -C @DIR_linux@ modules_install \
		ARCH=ppc \
		CROSS_COMPILE=$(target)- \
		DEPMOD=/bin/true \
		INSTALL_MOD_PATH=$(targetprefix)

if MAINTAINER_MODE
else
	$(MAKE) -C @DIR_linux@ clean
endif
	touch $@

#######################
#
#   own applications
#

apps: .dvbsnoop .enigma .lcars .lcdmenu .neutrino .plugins .stream

CONFIGURE_OPTS = \
	--build=$(build) \
	--host=$(target) \
	--prefix=$(targetprefix) \
	--with-driver=$(driverdir) \
	--with-dvbincludes=$(driverdir)/include \
	--with-target=cdk \
	--with-boxtype=$(BOXTYPE)

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

# dvb/svbsnoop

$(appsdir)/dvb/dvbsnoop/Makefile: .bootstrap
	cd $(appsdir)/dvb/dvbsnoop && $(CONFIGURE) CPPFLAGS="$(CPPFLAGS) -I$(driverdir)/include"

.dvbsnoop: $(appsdir)/dvb/dvbsnoop/Makefile
	$(MAKE) -C $(appsdir)/dvb/dvbsnoop all install
	touch $@

$(appsdir)/dvb/zapit/Makefile: .bootstrap .misc_libs
	cd $(appsdir)/dvb/zapit && $(CONFIGURE) --with-neutrino-source=$(appsdir)/tuxbox/neutrino

.zapit: $(appsdir)/dvb/zapit/Makefile
	$(MAKE) -C $(appsdir)/dvb/zapit all install
	touch $@

# dvb/tools

$(appsdir)/dvb/tools/Makefile: .bootstrap .misc_libs
	cd $(appsdir)/dvb/tools && $(CONFIGURE)

.stream: $(appsdir)/dvb/tools/Makefile .busybox
	$(MAKE) -C $(appsdir)/dvb/tools/stream all install
	touch $@

# misc/libs

$(appsdir)/misc/libs/Makefile: .bootstrap .libz
	cd $(appsdir)/misc/libs && $(CONFIGURE)

.misc_libs: $(appsdir)/misc/libs/Makefile
	$(MAKE) -C $(appsdir)/misc/libs all install
if TARGETRULESET_FLASH
	cd $(hostprefix)/$(target)/lib && \
	ln -sf libxmltree.a libxmltree_pic.a && \
	ln -sf libmd5sum.a libmd5sum_pic.a && \
	ln -sf libmpegtools.a libmpegtools_pic.a
endif
	touch $@

# tuxbox/enigma

$(appsdir)/tuxbox/enigma/Makefile: .bootstrap .libfreetype .libfribidi .libmad .libid3tag .libpng .libsigc .libtuxbox .misc_libs .plugins .libvorbisidec
	cd $(appsdir)/tuxbox/enigma && $(CONFIGURE)

.enigma: $(appsdir)/tuxbox/enigma/Makefile .tuxbox_tools .libungif .libjpeg
	$(MAKE) -C $(appsdir)/tuxbox/enigma all install
	touch $@

# tuxbox/lcars

$(appsdir)/tuxbox/lcars/Makefile: .bootstrap .libcurl .libfreetype .plugins core
	cd $(appsdir)/tuxbox/lcars && $(CONFIGURE)

.lcars: $(appsdir)/tuxbox/lcars/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install
	touch $@

# tuxbox/lcd

$(appsdir)/tuxbox/lcd/Makefile: .bootstrap .libfreetype .misc_libs .tuxbox_libs
	cd $(appsdir)/tuxbox/lcd && $(CONFIGURE)

.lcdmenu: $(appsdir)/tuxbox/lcd/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/lcd/lcdmenu all install
	touch $@

# tuxbox/libs

$(appsdir)/tuxbox/libs/Makefile: .bootstrap .libfreetype
	cd $(appsdir)/tuxbox/libs && $(CONFIGURE)

.tuxbox_libs: $(appsdir)/tuxbox/libs/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/libs all install
	touch $@

# tuxbox/libtuxbox

$(appsdir)/tuxbox/libtuxbox/config.status: .bootstrap
	cd $(appsdir)/tuxbox/libtuxbox && $(CONFIGURE)

.libtuxbox: $(appsdir)/tuxbox/libtuxbox/config.status
	$(MAKE) -C $(appsdir)/tuxbox/libtuxbox all install
	touch $@

# tuxbox/neutrino

$(appsdir)/tuxbox/neutrino/Makefile: .bootstrap .libboost .libcurl .libfreetype .libtuxbox .misc_libs .plugins .tuxbox_libs .zapit
	cd $(appsdir)/tuxbox/neutrino && $(CONFIGURE)

.neutrino: $(appsdir)/tuxbox/neutrino/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/neutrino all install
	touch $@

# tuxbox/plugins

$(appsdir)/tuxbox/plugins/Makefile: .bootstrap .libcurl .libpng .tuxbox_libs
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

.plugins: $(appsdir)/tuxbox/plugins/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/plugins all install
	cd $(hostprefix)/$(target)/lib && ln -sf tuxbox/plugins/libfx2.so libfx2.so
	touch $@

# tuxbox/tools

$(appsdir)/tuxbox/tools/Makefile: .bootstrap .libtuxbox
	cd $(appsdir)/tuxbox/tools && $(CONFIGURE)

.tuxbox_tools: $(appsdir)/tuxbox/tools/Makefile
	$(MAKE) -C $(appsdir)/tuxbox/tools/misc all install
	touch $@

#######################
#
#   flash
#

if TARGETRULESET_FLASH
if BOXTYPE_DM7000
.dreamfiles: @DEPENDS_dreamdriver_dm7000@ @DEPENDS_dreamfiles@
	@PREPARE_dreamfiles@
	@PREPARE_dreamdriver_dm7000@
endif
if BOXTYPE_DM56x0
.dreamfiles: @DEPENDS_dreamdriver_dm56x0@ @DEPENDS_dreamfiles@
	@PREPARE_dreamfiles@
	@PREPARE_dreamdriver_dm56x0@
endif
if BOXTYPE_DM500
.dreamfiles: @DEPENDS_dreamdriver_dm500@ @DEPENDS_dreamfiles@
	@PREPARE_dreamfiles@
	@PREPARE_dreamdriver_dm500@
endif
	@for i in dreamfiles boot mkcramfs-e mksquashfs mklibs.py ; do \
		rm -R $(flashprefix)/$$i 2>/dev/null || /bin/true; \
		mv $$i $(flashprefix) 2>/dev/null || /bin/true; \
	done
	touch $@

if BOXTYPE_DM7000
dreamboximage_root: core .enigma .reiserfsprogs .e2fsprogs .samba \
	.etherwake .utillinux .linuxkernel .dreamfiles \
	flash-enigma flash-plugin_tetris flash-plugin_snake \
	flash-plugin_pacman flash-plugin_tuxtxt flash-plugin_ngrabstartstop \
	flash-ftpd flash-dvb-tools flash-reiserfs flash-fstools flash-sambaserver \
	flash-etherwake flash-dreamfiles
else
dreamboximage_root: core .enigma .etherwake .linuxkernel .dreamfiles \
	flash-enigma flash-plugin_tetris flash-plugin_snake \
	flash-plugin_pacman flash-plugin_tuxtxt flash-plugin_ngrabstartstop \
	flash-ftpd flash-dvb-tools flash-etherwake flash-dreamfiles flash-sambaclient
endif

rebuild-flash:
	-rm -rf $(flashprefix)/root
	-rm -f $(flashprefix)/.flash
	@for i in `find $(flashprefix) -type f -name "*.img"` ; do rm $$i; done
	-rm -f $(flashprefix)/*.img
	$(MAKE) flash-lib

$(flashprefix)/.flash: .busybox
	-rm -rf $(flashprefix)/root
	@for i in bin dev lib/tuxbox proc sbin var tmp etc; do \
		$(INSTALL) -d $(flashprefix)/root/$$i ; done

	$(INSTALL) $(targetprefix)/bin/busybox $(flashprefix)/root/bin
	@for i in `find $(targetprefix)/bin/ -lname "*busybox"` ; do cp -a $$i $(flashprefix)/root/bin/; done
	@for i in `find $(targetprefix)/sbin/ -lname "*busybox"` ; do cp -a $$i $(flashprefix)/root/sbin/; done
	ln -sf busybox $(flashprefix)/root/bin/udhcpc
	ln -sf telnetd $(flashprefix)/root/sbin/in.telnetd

	$(INSTALL) -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)
	cp -R $(targetprefix)/lib/modules/$(KERNELVERSION)/kernel $(flashprefix)/root/lib/modules/$(KERNELVERSION)
if BOXTYPE_DM7000
#remove cifs module when no cifs is requested
	@if [ ! -f $(flashprefix)/.part_cifs -a -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)/kernel/fs/cifs ] ; then \
		rm -rf $(flashprefix)/root/lib/modules/$(KERNELVERSION)/kernel/fs/cifs; \
	fi
#remove cifs module when no smbfs is requested
	@if [ ! -f $(flashprefix)/.part_sambaclient -a -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)/kernel/fs/smbfs ] ; then \
		rm -rf $(flashprefix)/root/lib/modules/$(KERNELVERSION)/kernel/fs/smbfs; \
	fi
#remove reiserfs module when no reiserfs is requested
	@if [ ! -f $(flashprefix)/.part_reiserfs -a ! -f $(flashprefix)/.part_mkreiserfs -a -d $(flashprefix)/root/lib/modules/$(KERNELVERSION)/kernel/fs/reiserfs ] ; then \
		rm -rf $(flashprefix)/root/lib/modules/$(KERNELVERSION)/kernel/fs/reiserfs; \
	fi
endif
	ln -sf /var/mnt $(flashprefix)/root/mnt
	@touch $@

flash-ftpd: $(flashprefix)/.part_ftpd
$(flashprefix)/.part_ftpd: $(flashprefix)/.flash .ftpd
	$(INSTALL) $(targetprefix)/sbin/in.ftpd $(flashprefix)/root/sbin
	$(INSTALL) -d $(flashprefix)/root/share/empty
	@touch $@

flash-dvb-tools: $(flashprefix)/.part_dvb_tools
$(flashprefix)/.part_dvb_tools: $(flashprefix)/.flash .stream
	@for i in streampes streamsec streamts udpstreampes; do \
		$(INSTALL) $(targetprefix)/sbin/$$i $(flashprefix)/root/sbin; done;
	$(INSTALL) $(targetprefix)/bin/dvbnet $(flashprefix)/root/bin;
	@touch $@

flash-dvbsnoop: $(flashprefix)/.part_dvbsnoop .dvbsnoop
$(flashprefix)/.part_dvbsnoop: $(flashprefix)/.flash
	$(INSTALL) $(targetprefix)/bin/dvbsnoop $(flashprefix)/root/bin;
	@touch $@

flash-reiserfs: $(flashprefix)/.part_reiserfs
$(flashprefix)/.part_reiserfs: $(flashprefix)/.flash .reiserfsprogs
	@touch $@

flash-fstools: $(flashprefix)/.part_fstools
$(flashprefix)/.part_fstools: $(flashprefix)/.flash .e2fsprogs .reiserfsprogs .utillinux
	$(INSTALL) -d $(flashprefix)/root/sbin
# reiserfsck is only copied to flashroot when .part_reiserfsck exist
	@for i in reiserfsck e2fsck sfdisk mke2fs; do \
		if [ $$i != reiserfsck -o -f $(flashprefix)/.part_reiserfs ]; then \
			$(INSTALL) $(targetprefix)/sbin/$$i $(flashprefix)/root/sbin; \
		fi; \
	done;
	cd $(flashprefix)/root/sbin && \
	    ln -sf mke2fs mkfs.ext3 && \
	    ln -sf mke2fs mkfs.ext2 && \
	    ln -sf e2fsck fsck.ext2 && \
	    ln -sf e2fsck fsck.ext3 
	@touch $@

flash-mkreiserfs: $(flashprefix)/.part_mkreiserfs
$(flashprefix)/.part_mkreiserfs: $(flashprefix)/.part_reiserfs
	$(INSTALL) -m755 $(targetprefix)/sbin/mkreiserfs $(flashprefix)/root/sbin
	@touch $@

flash-sambaserver: $(flashprefix)/.part_sambaserver
$(flashprefix)/.part_sambaserver: $(flashprefix)/.flash .samba
	$(INSTALL) -d $(flashprefix)/root/bin
	@for i in smbd nmbd ; do \
		$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done
	@touch $@

flash-sambaclient: $(flashprefix)/.part_sambaclient
$(flashprefix)/.part_sambaclient: $(flashprefix)/.flash .samba
	$(INSTALL) -d $(flashprefix)/root/bin
	@for i in smbmount smbmnt ; do \
		$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; done
	@touch $@

flash-cifs: $(flashprefix)/.part_cifs
$(flashprefix)/.part_cifs: $(flashprefix)/.flash .linuxkernel
	@touch $@

flash-etherwake: $(flashprefix)/.part_etherwake
$(flashprefix)/.part_etherwake: $(flashprefix)/.flash .etherwake
	$(INSTALL) -d $(flashprefix)/root/bin
	$(INSTALL) $(targetprefix)/bin/etherwake $(flashprefix)/root/bin
	@touch $@

flash-dreamfiles: $(flashprefix)/.part_dreamfiles
$(flashprefix)/.part_dreamfiles: $(flashprefix)/.flash .dreamfiles
	cp -R $(flashprefix)/dreamfiles/* $(flashprefix)/root
	@if [ -f $(flashprefix)/dreamfiles/.version ] ; then \
		cp $(flashprefix)/dreamfiles/.version $(flashprefix)/root; \
	fi
if !BOXTYPE_DM7000
	@echo "i:/ezap/osd/alpha=00000000" >> $(flashprefix)/root/var_init/tuxbox/config/enigma/config
	@echo "i:/ezap/osd/brightness=00000073" >> $(flashprefix)/root/var_init/tuxbox/config/enigma/config
	@echo "i:/ezap/osd/gamma=00000066" >> $(flashprefix)/root/var_init/tuxbox/config/enigma/config
endif
if !BOXTYPE_DM56x0
	@for i in skins/small_red*.esml skins/small_red*.info pictures/small-red pictures/triaxlogo-fs8.png ; do \
		rm -R $(flashprefix)/root/share/tuxbox/enigma/$$i; done
endif
if !BOXTYPE_DM500
	@for i in cables.xml terrestrial.xml; do \
		if [ -f $(flashprefix)/root/share/tuxbox/$$i ]; then \
			rm $(flashprefix)/root/share/tuxbox/$$i; \
		fi; \
	done;
endif
	@touch $@

flash-enigma: $(flashprefix)/.part_enigma
$(flashprefix)/.part_enigma: $(flashprefix)/.flash .enigma
	$(INSTALL) $(targetprefix)/bin/enigma $(flashprefix)/root/bin

	$(INSTALL) -d $(flashprefix)/root/share/fonts
	@for i in blue*.ttf md_khmurabi_10.ttf pakenham.ttf unmrs.pfa ; do \
		$(INSTALL) -m644 $(targetprefix)/share/fonts/$$i $(flashprefix)/root/share/fonts; done

	$(INSTALL) -d $(flashprefix)/root/share/locale
	@for i in `find $(targetprefix)/share/locale -name "tuxbox-enigma.mo"` ; \
		do cp -pa $${i%%/LC_MESSAGES/tuxbox-enigma.mo} $(flashprefix)/root/share/locale; done
	@for i in ar sr ur ; do rm -R $(flashprefix)/root/share/locale/$$i; done
	rm -rf $(flashprefix)/root/share/locale/LC_MESSAGES
	find $(flashprefix)/root/share/locale -name libc.mo -o -name nano.mo | xargs rm -f
	$(INSTALL) $(appsdir)/tuxbox/enigma/po/locale.alias $(flashprefix)/root/share/locale
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox/enigma
	$(INSTALL) -d $(flashprefix)/root/var_init/tuxbox/config/enigma
	$(INSTALL) -m 0644 $(targetprefix)/var/tuxbox/config/enigma/encoding.conf $(flashprefix)/root/var_init/tuxbox/config/enigma

	cp -pa $(targetprefix)/share/tuxbox/enigma/* $(flashprefix)/root/share/tuxbox/enigma

	@for i in `find $(flashprefix)/root/share/tuxbox/enigma/htdocs` ; do \
		case $$i in \
		*/rc_dbox2.jpg | */rc_dbox2_small.jpg | */topbalk?.png | */topbalk?_small.png) \
			rm $$i;; \
		esac; \
	done;
if BOXTYPE_DM7000
	@for i in neutrino chk_v2 blueqt carbon ; do \
	    rm -R $(flashprefix)/root/share/tuxbox/enigma/pictures/$$i; done
	@for i in neutrino chk_blue2 blueqt carbon ; do \
		rm -R $(flashprefix)/root/share/tuxbox/enigma/skins/$$i.*; done

	@for i in `find $(flashprefix)/root/share/tuxbox/enigma/resources -type f` ; do \
		case $$i in \
		/*keymappings.xml | */rcdboxold.xml | \
		*/rcdm7000.xml | */rcdreambox_keyboard.xml ) ;; \
		*) rm $$i;; \
		esac; \
	done;
else
	CURRENT_PATH=`pwd` && \
	cd $(flashprefix)/root/share/tuxbox/enigma/skins && \
	patch -p0 < $$CURRENT_PATH/Patches/default_lc.esml.diff
	@for i in `find $(flashprefix)/root/share/tuxbox/enigma/resources -type f` ; do \
		case $$i in \
		/*keymappings.xml | */rcdboxold.xml | \
		*/rcdm5xxx.xml | */rcdreambox_keyboard.xml ) ;; \
		*) rm $$i;; \
		esac; \
	done;
endif

	$(INSTALL) -d $(flashprefix)/root/share/zoneinfo
	$(INSTALL) -m644 $(targetprefix)/share/zoneinfo/* $(flashprefix)/root/share/zoneinfo
	rm -f $(flashprefix)/root/share/zoneinfo/*tab

	ln -sf /var/etc/localtime $(flashprefix)/root/etc
	@touch $@

flash-joe: $(flashprefix)/.part_joe
$(flashprefix)/.part_joe: $(flashprefix)/.flash .joe
	$(INSTALL) -d $(flashprefix)/root/etc/joe
	cp -ap $(targetprefix)/etc/joe/* $(flashprefix)/root/etc/joe/
	$(INSTALL) $(targetprefix)/bin/joe $(flashprefix)/root/bin
	$(target)-strip --strip-all $(flashprefix)/root/bin/joe
	@touch $@

flash-ssh: $(flashprefix)/.part_ssh
$(flashprefix)/.part_ssh: $(flashprefix)/.flash .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	cp -ap $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	@touch $@

flash-sshd: $(flashprefix)/.part_sshd
$(flashprefix)/.part_sshd: $(flashprefix)/.flash .ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -ap $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
	@touch $@

flash-plugin_dreamdata: $(flashprefix)/.part_plugin_dreamdata
$(flashprefix)/.part_plugin_dreamdata: $(flashprefix)/.flash .mrouted .plugins
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var_init/tuxbox/config
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/dreamdata.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/var/tuxbox/config/dreamdata.xml $(flashprefix)/root/var_init/tuxbox/config/
	$(INSTALL) $(targetprefix)/bin/mrouted $(flashprefix)/root/bin
	@touch $@

flash-plugin_tuxtxt: $(flashprefix)/.part_plugin_tuxtxt
$(flashprefix)/.part_plugin_tuxtxt: $(flashprefix)/.flash .plugins
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) -m644 $(targetprefix)/share/fonts/tuxtxt.ttf $(flashprefix)/root/share/fonts/
	$(INSTALL) -m644 $(targetprefix)/share/fonts/tuxtxt.otb $(flashprefix)/root/share/fonts/
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tuxtxt.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tuxtxt.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) -d $(flashprefix)/root/var_init/tuxbox/config/tuxtxt
	$(INSTALL) -m644 $(targetprefix)/var/tuxbox/config/tuxtxt/tuxtxt.conf $(flashprefix)/root/var_init/tuxbox/config/tuxtxt
	@touch $@

flash-plugin_tuxcom: $(flashprefix)/.part_plugin_tuxcom
$(flashprefix)/.part_plugin_tuxcom: $(flashprefix)/.flash .plugins
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tuxcom.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tuxcom.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_tuxmail: $(flashprefix)/.part_plugin_tuxmail
$(flashprefix)/.part_plugin_tuxmail: $(flashprefix)/.flash .plugins
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) -m644 $(targetprefix)/share/fonts/tuxtxt.ttf $(flashprefix)/root/share/fonts/
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tuxmail.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tuxmail.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/bin/tuxmaild $(flashprefix)/root/bin/
	@touch $@

flash-plugin_libfx2: $(flashprefix)/.part_plugin_libfx2
$(flashprefix)/.part_plugin_libfx2: $(flashprefix)/.flash .plugins
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	cd $(flashprefix)/root/lib/tuxbox/plugins && ln -sf /lib/libfx2.so libfx2.so 
	@touch $@

flash-plugin_lcdcirc: $(flashprefix)/.part_plugin_lcdcirc
$(flashprefix)/.part_plugin_lcdcirc: $(flashprefix)/.flash flash-libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/lcdcirc.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/lcdcirc.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_satfind: $(flashprefix)/.part_plugin_satfind
$(flashprefix)/.part_plugin_satfind: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/satfind.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/satfind.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_pacman: $(flashprefix)/.part_plugin_pacman
$(flashprefix)/.part_plugin_pacman: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/pacman.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/pacman.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_snake: $(flashprefix)/.part_plugin_snake
$(flashprefix)/.part_plugin_snake: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/snake.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/snake.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_tetris: $(flashprefix)/.part_plugin_tetris
$(flashprefix)/.part_plugin_tetris: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tetris.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tetris.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_links: $(flashprefix)/.part_plugin_links
$(flashprefix)/.part_plugin_links: $(flashprefix)/.flash
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/links.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/links.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) -d $(flashprefix)/root/var_init/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/var_init/etc
	@echo "#!/bin/sh" >> install
	@echo "#Wo ist links" >> install
	@echo "LINKSHOME=/tmp" >> install
	@echo "if [ -d /hdd/links ] ; then LINKSHOME=/hdd/links ; fi" >> install
	@echo "if [ -d /mnt/usb/links ] ; then LINKSHOME=/mnt/usb/links ; fi" >> install
	@echo "if [ ! -d /var/tuxbox/plugins ] ; then mkdir /var/tuxbox/plugins ; fi" >> install
	@echo "ln -sf \$$LINKSHOME/links.so /var/tuxbox/plugins/links.so" >> install
	@echo "ln -sf \$$LINKSHOME/links.cfg /var/tuxbox/plugins/links.cfg" >> install
	@echo "/bin/chmod 744 \$$LINKSHOME/links.*" >> install
	@echo "if [ ! -e /var/etc/init ] ; then" >> install
	@echo "	echo \"#!/bin/sh\" >> /var/etc/init" >> install
	@echo "fi" >> install
	@echo "echo \"#Links Startpage\" >> /var/etc/init" >> install
	@echo "echo \"export WWW_HOME=\\\"www.dream-multimedia-tv.de\\\"\" >> /var/etc/init" >> install
	@echo "chmod +x /var/etc/init" >> install
	@chmod +x install
	@tar cf install.tar install
	$(INSTALL) install.tar $(flashprefix)/root/var_init/etc
	@rm install
	@touch $@

flash-plugin_lemmings: $(flashprefix)/.part_plugin_lemmings
$(flashprefix)/.part_plugin_lemmings: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/lemmings.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/lemmings.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_solitair: $(flashprefix)/.part_plugin_solitair
$(flashprefix)/.part_plugin_solitair: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/solitair.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/solitair.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_sol: $(flashprefix)/.part_plugin_sol
$(flashprefix)/.part_plugin_sol: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/sol.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/sol.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_mastermind: $(flashprefix)/.part_plugin_mastermind
$(flashprefix)/.part_plugin_mastermind: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/master.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/master.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_sokoban: $(flashprefix)/.part_plugin_sokoban
$(flashprefix)/.part_plugin_sokoban: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/soko.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/soko.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox/sokoban
	cp -pa $(targetprefix)/share/tuxbox/sokoban/*.xsb $(flashprefix)/root/share/tuxbox/sokoban/
	@touch $@

flash-plugin_tankwars: $(flashprefix)/.part_plugin_tankwars
$(flashprefix)/.part_plugin_tankwars: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tank.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/tank.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_viergewinnt: $(flashprefix)/.part_plugin_viergewinnt
$(flashprefix)/.part_plugin_viergewinnt: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/vierg.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/vierg.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_yahtzee: $(flashprefix)/.part_plugin_yahtzee
$(flashprefix)/.part_plugin_yahtzee: $(flashprefix)/.flash flash-plugin_libfx2
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/yahtzee.so $(flashprefix)/root/lib/tuxbox/plugins/
	$(INSTALL) $(targetprefix)/lib/tuxbox/plugins/yahtzee.cfg $(flashprefix)/root/lib/tuxbox/plugins/
	@touch $@

flash-plugin_ngrabstartstop: $(flashprefix)/.part_plugin_ngrabstartstop
$(flashprefix)/.part_plugin_ngrabstartstop: $(flashprefix)/.flash .plugins flash-enigma
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	@for i in so cfg; do \
		cp $(targetprefix)/lib/tuxbox/plugins/ngrab*.$$i $(flashprefix)/root/lib/tuxbox/plugins/ ; done;
	@touch $@

flash-plugin_dslstartstop: $(flashprefix)/.part_plugin_ngrabtools
$(flashprefix)/.part_plugin_dslstartstop: $(flashprefix)/.flash .plugins flash-enigma
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	@for i in so cfg; do \
		cp $(targetprefix)/lib/tuxbox/plugins/dsl*con*.$$i $(flashprefix)/root/lib/tuxbox/plugins/ ; done;
	@touch $@

############################# UNTESTED!!! ##################################
flash-neutrino: $(flashprefix)/.part_neutrino
$(flashprefix)/.part_neutrino: $(flashprefix)/.flash .neutrino
	$(INSTALL) $(targetprefix)/bin/controld $(targetprefix)/bin/lcdd $(targetprefix)/bin/neutrino \
		$(targetprefix)/bin/nhttpd $(targetprefix)/bin/timerd \
		$(flashprefix)/root/bin
	cp -a $(targetprefix)/share/tuxbox/neutrino $(targetprefix)/share/tuxbox/lcdd \
		$(flashprefix)/root/share/tuxbox

	$(INSTALL) $(targetprefix)/bin/sectionsd $(flashprefix)/root/bin

	$(INSTALL) $(targetprefix)/bin/zapit $(flashprefix)/root/bin
	cp -a $(targetprefix)/var/tuxbox/config/zapit $(flashprefix)/root/var/tuxbox/config

	$(INSTALL) -d $(flashprefix)/root/share/fonts
	cp -a $(targetprefix)/share/fonts/micron*.ttf $(flashprefix)/root/share/fonts

	@touch $@

flash-lcars: $(flashprefix)/.part_lcars
$(flashprefix)/.part_lcars: $(flashprefix)/.flash .lcars
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
	cp -pa $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
	cp -pa $(targetprefix)/share/tuxbox/lcars $(flashprefix)/root/share/tuxbox
	cp -pa $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config
	@touch $@

flash-lcdmenu: $(flashprefix)/.part_lcdmenu
$(flashprefix)/.part_lcdmenu: $(flashprefix)/.flash .lcdmenu
	$(INSTALL) -d $(flashprefix)/root/share/fonts
	$(INSTALL) $(targetprefix)/bin/lcdmenu $(flashprefix)/root/bin
	cp -pa $(targetprefix)/share/fonts/micron.ttf $(flashprefix)/root/share/fonts
	@touch $@
############################################################################

flash-lib: $(flashprefix)/.lib 
$(flashprefix)/.lib: $(flashprefix)/.flash $(shell ls -r -1 $(flashprefix)/.part_* 2>/dev/null)
	@find $(flashprefix)/root/lib -maxdepth 1 -type f -o -type l | xargs rm -f
	@cp -a $(targetprefix)/lib/libnss_dns-?.*.so $(flashprefix)/root/lib
	@cp -a $(targetprefix)/lib/libnss_files-?.*.so $(flashprefix)/root/lib
	@if [ -x ./customize-flash-pre ] ; then \
		./customize-flash-pre ; \
	fi
	@$(PYTHON) $(flashprefix)/mklibs.py --target $(target) --ldlib ld.so.1 --libc-extras-dir $(targetprefix)/lib/libc_pic \
		-d $(flashprefix)/root/lib \
		-D -L $(targetprefix)/lib \
		--root $(flashprefix)/root \
		`find $(flashprefix)/root/bin/ -path "*bin/?*"` \
		`find $(flashprefix)/root/lib/ -name "libnss_*"` \
		`find $(flashprefix)/root/lib/tuxbox/ -name "*.so" -type f` \
		`find $(flashprefix)/root/sbin/ -path "*sbin/?*"`
	cd $(flashprefix)/root/lib && ln -sf libgcc_s_nof.so.1 libgcc_s.so.1
	@if [ -x ./customize-flash ] ; then \
		./customize-flash ; \
	fi
	@$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $(flashprefix)/root/ -path "*bin/?*"` 2>/dev/null || /bin/true
	@$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $(flashprefix)/root/lib -name "*.so*"` 2>/dev/null || /bin/true
	@rm `find $(flashprefix)/root/lib/ -name "*.la"` 2>/dev/null || /bin/true
	@if [ -e $(flashprefix)/.part_plugin_links ] ; then \
		mv $(flashprefix)/root/lib/tuxbox/plugins/links.* $(flashprefix); \
	fi
	@chmod u+rwX,go+rX-w -R $(flashprefix)/root/
	@touch $@

flash-compress: $(flashprefix)/boot-cramfs.img $(flashprefix)/root-squashfs.img $(flashprefix)/complete.img

$(flashprefix)/boot-cramfs.img: .linuxkernel $(flashprefix)/.part_dreamfiles
	cp $(buildprefix)/linux/arch/ppc/boot/images/zImage.treeboot $(flashprefix)/boot/root/platform/kernel/os
if BOXTYPE_DM7000
	$(flashprefix)/mkcramfs-e -eb $(flashprefix)/boot $(flashprefix)/boot-cramfs.img
endif
if BOXTYPE_DM56x0
	mv $(flashprefix)/boot/root/platform/kernel/bild .
	$(flashprefix)/mkcramfs-e -eb $(flashprefix)/boot $(flashprefix)/boot-cramfs.img
	mv ./bild $(flashprefix)/boot/root/platform/kernel
endif
if BOXTYPE_DM500
	mv $(flashprefix)/boot/root/platform/kernel/bild .
	$(flashprefix)/mkcramfs-e -eb $(flashprefix)/boot $(flashprefix)/boot-cramfs.img
	mv ./bild $(flashprefix)/boot/root/platform/kernel
endif
	@if [ `stat -c %s $(flashprefix)/boot-cramfs.img` -gt 1179648 ]; then \
		echo "ERROR: CramFS part is too big for image (max. allowed 1179648 bytes)"; \
		rm -f $(flashprefix)/boot-cramfs.img.too-big 2> /dev/null || /bin/true; \
		mv $(flashprefix)/boot-cramfs.img $(flashprefix)/boot-cramfs.img.too-big; \
		exit 1; \
	fi

$(flashprefix)/root-squashfs.img:
	$(flashprefix)/mksquashfs $(flashprefix)/root $(flashprefix)/root-squashfs.img -be -all-root
	@if [ `stat -c %s $(flashprefix)/root-squashfs.img` -gt 5111808 ]; then \
		echo "ERROR: SquashFS part is too big for image (max. allowed 5111808 bytes)"; \
		rm -f $(flashprefix)/root-squashfs.img.too-big 2> /dev/null || /bin/true; \
		mv $(flashprefix)/root-squashfs.img $(flashprefix)/root-squashfs.img.too-big; \
		exit 1; \
	fi

$(flashprefix)/complete.img: $(flashprefix)/boot-cramfs.img $(flashprefix)/root-squashfs.img
	cp $(flashprefix)/boot-cramfs.img $(flashprefix)/complete.img; \
	dd if=$(flashprefix)/root-squashfs.img of=$(flashprefix)/complete.img bs=1024 seek=1152
endif

#######################
#
#   internal
#

clean-local:
	-$(MAKE) -C etc clean
	-$(MAKE) -C $(appsdir) clean
	-$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf build
	-@CLEANUP@

distclean-local:
	-$(MAKE) -C etc distclean
	-$(MAKE) -C $(appsdir) distclean
	-rm Makefile-archive
	-rm .bootstrap
	-rm .directories .linuxdir .binutils .glibc .gcc .rpcgen
	-rm .etc .busybox .ftpd .modutils .procps .watchdog .mrouted
	-rm .libboost .libcommoncplusplus .libcrypto .libcurl .libdb2 .libdvbpsi .libffi .libfreetype
	-rm .libncurses .libfribidi .libjpeg .libmad .libid3tag .libnet .libnids .libpcap .libpng .libpopt
	-rm .libreadline .libsdl .libsigc .libungif .libxml2 .libxmlwrapp .libz .libvorbisidec .libgmp
	-rm .cabextract
	-rm .gdb .gdb-remote .insight .ksymoops .ltrace .strace .nano
	-rm .kaffeh .kaffe
	-rm .gnuboy .scummvm .sdldoom
	-rm .linuxkernel .reiserfsprogs .e2fsprogs .samba .dreamfiles .etherwake .utillinux
	-rm .dvbsnoop .enigma .lcars .lcdmenu .neutrino .stream .zapit
	-rm .console_data .console_tools .dsniff .fbset .lirc .pump .ssh .tcpdump .xrc .thttpd
	-rm .dvbdate .dvbstream .dvbtext .dvbtune .vls
	-rm .misc_libs .misc_tools .plugins .libtuxbox .tuxbox_libs .tuxbox_tools
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
if TARGETRULESET_FLASH
	-rm -rf $(flashprefix)
endif

@ARCHIVE@

if MAINTAINER_MODE
Makefile-archive: $(top_srcdir)/rules-archive
	$(top_srcdir)/rules-archive.pl $(top_srcdir)/rules-archive > Makefile-archive
endif

if TARGETRULESET_FLASH
.PHONY: core libs root apps boot devel java copy lib compress
else
.PHONY: core libs root apps boot devel java
endif

EXTRA_DIST = \
	rules.pl rules-archive.pl \
	rules-archive \
	rules-install rules-install-flash \
	rules-make rules-make-cygwin

ACLOCAL_AMFLAGS = -I .

CONFIG_STATUS_DEPENDENCIES = \
	$(top_srcdir)/rules.pl \
	$(top_srcdir)/rules-install $(top_srcdir)/rules-install-flash \
	$(top_srcdir)/rules-make $(top_srcdir)/rules-make-cygwin \
	Makefile-archive

