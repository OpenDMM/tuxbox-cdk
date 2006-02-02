$(flashprefix):
	$(INSTALL) -d $@

$(flashprefix)/root: bootstrap | $(flashprefix)
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
	$(MAKE) flash-tuxinfo
	$(MAKE) flash-tools_misc
	$(MAKE) flash-config
	$(MAKE) flash-camd2
	$(MAKE) flash-busybox
	$(MAKE) flash-ftpd
	$(MAKE) flash-satfind
	$(MAKE) flash-streampes
	$(MAKE) flash-lufsd
	$(MAKE) flash-tuxmail
	$(MAKE) flash-tuxtxt
	$(MAKE) flash-tuxcom
	$(MAKE) flash-vncviewer
	$(MAKE) flash-fx2-plugins
	$(MAKE) flash-ucodes
	$(MAKE) flash-lcdip
	$(MAKE) flash-version
	@TUXBOX_CUSTOMIZE@
