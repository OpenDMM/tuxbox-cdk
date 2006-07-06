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
		./configure \
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
		./configure \
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
		./configure \
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

$(DEPDIR)/libfreetype: bootstrap @DEPENDS_libfreetype@ Patches/libfreetype.diff
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

$(DEPDIR)/libpcap: bootstrap @DEPENDS_libpcap@ Patches/libpcap.diff
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

$(DEPDIR)/libvorbisidec: bootstrap @DEPENDS_libvorbisidec@ Patches/tremor.diff
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
