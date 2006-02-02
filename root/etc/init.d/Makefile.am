EXTRA_DIST = \
	rcS.m4 start start_enigma start_lcars start_neutrino start_sshd halt

FILES_EXEC = \
	rcS start start_enigma start_lcars start_neutrino start_sshd halt start_automount

FILES_FLASH_RO_EXEC = \
	rcS rcS.insmod start start_sshd halt

FILES_FLASH_RW_EXEC = \
	start_enigma start_lcars start_neutrino start start_automount

DIR = /etc/init.d

CLEANFILES = rcS rcS.insmod

include $(top_srcdir)/root/Makefile.inc

rcS: rcS.m4
	m4 $< > $@
	chmod 755 $@

rcS.insmod: rcS.m4
	m4 --define=insmod $< > $@
	chmod 755 $@
