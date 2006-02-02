SUBDIRS = init.d network

FILES_FLASH_RO = \
	fstab host.conf inittab mime.types nsswitch.conf \
	protocols termcap timezone.xml

FILES_FLASH_RW = \
	group hostname hosts inetd.conf passwd profile resolv.conf services auto.stuff

FILES = \
	$(FILES_FLASH_RO) $(FILES_FLASH_RW) modules.conf

EXTRA_DIST = $(FILES)

DIR = /etc

include $(top_srcdir)/root/Makefile.inc
