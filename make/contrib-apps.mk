#######################
#
#   contrib apps
#

contrib_apps: bzip2 console_data console_tools fbset lirc lsof ssh tcpdump lufs bonnie kermit

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

if TARGETRULESET_FLASH
flash-lircd: $(flashprefix)/root/sbin/lircd

$(flashprefix)/root/sbin/lircd: lirc
	$(INSTALL) $(targetprefix)/sbin/lircd $@
	$(INSTALL) -d $(targetprefix)/var/tuxbox/config/lirc

endif


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

if TARGETRULESET_FLASH
flash-dropbear: $(flashprefix)/root/sbin/dropbear

$(flashprefix)/root/sbin/dropbear: dropbear dropbearkey | $(flashprefix)/root 
	$(INSTALL) -d $(flashprefix)/root/etc/dropbear
	$(INSTALL) $(targetprefix)/bin/dropbearmulti $(flashprefix)/root/bin
	rm -f $(flashprefix)/root/sbin/dropbear
	rm -f $(flashprefix)/root/sbin/dbclient
	rm -f $(flashprefix)/root/bin/scp
	ln -s ../bin/dropbearmulti $(flashprefix)/root/sbin/dropbear
	ln -s ../bin/dropbearmulti $(flashprefix)/root/sbin/dbclient
	ln -s ../bin/dropbearmulti $(flashprefix)/root/bin/scp
	cp -rd $(targetprefix)/etc/dropbear/* $(flashprefix)/root/etc/dropbear

endif

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

if TARGETRULESET_FLASH
flash-ssh: $(flashprefix)/root/bin/ssh

$(flashprefix)/root/bin/ssh: $(flashprefix)/root $(DEPDIR)/ssh
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) $(targetprefix)/bin/ssh $(targetprefix)/bin/scp \
		$(targetprefix)/bin/sftp $(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/ssh_config $(flashprefix)/root/etc/ssh

flash-sshd: $(flashprefix)/root/sbin/sshd

$(flashprefix)/root/sbin/sshd: $(DEPDIR)/ssh | $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/etc/ssh
	$(INSTALL) -d $(flashprefix)/root/libexec
	$(INSTALL) -d $(flashprefix)/root/share/empty
	$(INSTALL) $(targetprefix)/bin/ssh-keygen $(targetprefix)/bin/scp \
		$(flashprefix)/root/bin
	cp -rd $(targetprefix)/etc/ssh/* $(flashprefix)/root/etc/ssh
#??#	cp -rd $(targetprefix)/etc/init.d/start_sshd $(flashprefix)/root/etc/init.d/
	$(INSTALL) $(targetprefix)/libexec/sftp-server $(flashprefix)/root/libexec
	$(INSTALL) $(targetprefix)/sbin/sshd $(flashprefix)/root/sbin
endif

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

if TARGETRULESET_FLASH
## flash-ftpfs 
## TODO: fix if possible
flash-lufsd: | $(flashprefix)/root $(DEPDIR)/lufs
	$(INSTALL) $(targetprefix)/bin/lufsmnt $</bin
	$(INSTALL) $(targetprefix)/bin/lufsd $</bin
	cp -rd $(targetprefix)/lib/liblufs-ftpfs* $</lib
	if [ -e $</lib/liblufs-ftpfs.2.0.0 ]; then \
		rm -f $</lib/liblufs-ftpfs ; \
		rm -f $</lib/liblufs-ftpfs.2 ; \
		mv $</lib/liblufs-ftpfs.2.0.0 $</lib/liblufs-ftpfs.so.2.0.0 ; \
		ln -s liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so.2 ; \
		ln -s liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so ; \
	fi
	@TUXBOX_CUSTOMIZE@
endif

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
