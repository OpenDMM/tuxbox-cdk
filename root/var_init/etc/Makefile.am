FILES = \
	group hostname hosts passwd smb.conf

EXTRA_DIST = $(FILES)

all-local: $(FILES)

install-data-local: $(FILES)
	install -d $(targetprefix)/var/etc
	@for i in $(FILES) ; do \
		install -m644 $$i $(targetprefix)/var/etc ; \
	done

