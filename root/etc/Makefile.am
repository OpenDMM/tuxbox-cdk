if ENABLE_NFSSERVER
EXPORTS=exports
endif

if ENABLE_SAMBASERVER
SMBCONF=smb.conf
SMBPASSWD=smbpasswd
endif

SUBDIRS = init.d network

FILES_FLASH_RO = \
	fstab host.conf inittab mime.types nsswitch.conf \
	protocols termcap timezone.xml modules.conf

FILES_FLASH_RW = \
	group hostname hosts inetd.conf passwd profile resolv.conf services auto.net \
	$(EXPORTS) $(SMBCONF) $(SMBPASSWD)

FILES = \
	$(FILES_FLASH_RO) $(FILES_FLASH_RW)

EXTRA_DIST = $(FILES)

DIR = /etc

include $(top_srcdir)/root/Makefile.inc
