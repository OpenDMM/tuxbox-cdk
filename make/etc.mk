yadd-etc: $(targetprefix)/etc/init.d/rcS

$(targetprefix)/etc/init.d/rcS:
	$(MAKE) -C root install
