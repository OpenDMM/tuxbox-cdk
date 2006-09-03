$(flashprefix):
	$(INSTALL) -d $@

$(flashprefix)/root: bootstrap $(wildcard root-local.sh) | $(flashprefix)
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
	$(INSTALL) -d $@/etc/init.d
	$(INSTALL) -d $@/root
	ln -s /tmp $@/var/run
	ln -s /tmp $@/var/tmp
if ENABLE_IDE
	$(INSTALL) -d $@/hdd
endif
	$(MAKE) $@/etc/cramfs.urls
	$(MAKE) flash-tuxinfo
	$(MAKE) flash-tools_misc
	$(MAKE) flash-fcp
	$(MAKE) flash-config
	$(MAKE) flash-camd2
	$(MAKE) flash-busybox
	$(MAKE) flash-ftpd
	$(MAKE) flash-satfind
	$(MAKE) flash-streampes
	$(MAKE) flash-lufsd
	$(MAKE) flash-etherwake
	$(MAKE) flash-tuxmail
	$(MAKE) flash-tuxtxt
	$(MAKE) flash-tuxcom
	$(MAKE) flash-vncviewer
	$(MAKE) flash-fx2-plugins
	$(MAKE) flash-ucodes
	$(MAKE) flash-lcdip
	$(MAKE) flash-automount
if ENABLE_LIRC
	$(MAKE) flash-lircd
endif
if ENABLE_CDKVCINFO
	$(MAKE) flash-cdkVcInfo
endif
if ENABLE_NFSSERVER
	$(MAKE) flash-nfsserver
endif
	$(MAKE) flash-version
	@FLASHROOTDIR_MODIFIED@
	@TUXBOX_CUSTOMIZE@
