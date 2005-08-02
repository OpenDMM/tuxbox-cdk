SUBDIRS = init.d

FILES = \
	fstab host.conf inetd.conf inittab issue.net mime.types \
	nsswitch.conf profile protocols rpc services termcap timezone.xml \
	vsftpd.conf

EXTRA_DIST = $(FILES)

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/etc
	@for i in $(FILES) ; do \
		install -m644 $$i $(targetprefix)/etc ; \
	done

distclean-local:
	-rm -f fstab modules.conf

