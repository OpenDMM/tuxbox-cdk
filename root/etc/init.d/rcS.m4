dnl This file generates rcS and (with macro insmod defined) rcS.insmod
dnl
dnl Most of its "power" comes from the macro loadmodule, that is expanded
dnl differently depending upon if insmod is defined or not.
dnl 
changequote({,})dnl
define({loadmodule},{ifdef({insmod},{$IM $MD/$1.o $2},{modprobe $1 $2})})dnl
define({ifmarkerfile},{if [ -e /var/etc/.$1 ]; then
	$2
ifelse($3,,,{else
	$3})
fi})dnl
define({runprogifexists},{if [ -e $1 ]; then
	$2 $3
fi})dnl
define({runaltprogifexists},{if [ -e $1 ]; then
	$2
else
	$3
fi})dnl
define({runprogcreatedirifexists},{if [ -e $1 ]; then
	if [ ! -d $2 ]; then
		mkdir $2
	fi
	$3
fi})dnl
define({runifexists},{if [ -x $1 ]; then
	$1 $2
fi})dnl
dnl
dnl
#!/bin/sh
# This file was automatically generated from rcS.m4
#
PATH=/sbin:/bin
ifdef({insmod},{IM=/sbin/{insmod}
MD=/lib/modules/$(uname -r)/misc
})dnl

# If appropriate, load ide drivers and file system drivers
if [ -e /lib/modules/$(uname -r)/misc/dboxide.o ] ; then
	loadmodule(ide-core)
	loadmodule(dboxide)
	loadmodule(ide-detect)
	loadmodule(ide-disk)
	loadmodule(ext2)
	loadmodule(jbd)
	loadmodule(ext3)
fi

# Mount file systems in /etc/fstab
mount -a

# Set time zone etc
. /etc/profile
  
# Setup hostname
hostname -F /etc/hostname
ifup -a

ifdef({insmod},{loadmodule(event)},{touch /etc/modules.conf
depmod -ae}) dnl

loadmodule(tuxbox)

# Get info about the current box
VENDOR=`/bin/tuxinfo -V`
VENDOR_ID=`/bin/tuxinfo -v`
MODEL=`/bin/tuxinfo -M`
MODEL_ID=`/bin/tuxinfo -m`
SUBMODEL=`/bin/tuxinfo -S`
SUBMODEL_ID=`/bin/tuxinfo -s`

echo "Detected STB:"
echo "	Vendor: $VENDOR"
echo "	Model: $MODEL $SUBMODEL"

loadmodule(dvb-core, dvb_shutdown_timeout=0)

if [ $MODEL_ID -eq 2 ]; then
	# Dreambox, not supported
	echo "For the Dreambox, please use another version"
	exit 1
fi

# I2C core
loadmodule(dbox2_i2c)

# Frontprocessor
loadmodule(dbox2_fp)
if [ -e /var/etc/.oldrc ]; then
        loadmodule(dbox2_fp_input, disable_new_rc=1)
elif [ -e /var/etc/.newrc ]; then
	loadmodule(dbox2_fp_input.o, disable_old_rc=1)
else
        loadmodule(dbox2_fp_input)
fi

# Misc IO
loadmodule(avs)
loadmodule(saa7126)

# Frontends
if [ $VENDOR_ID -eq 1 ]; then
	# Nokia
	loadmodule(ves1820)
	loadmodule(ves1x93, board_type=1)
	loadmodule(cam, mio=0xC000000 firmware=/var/tuxbox/ucodes/cam-alpha.bin)
elif [ $VENDOR_ID -eq 2 ]; then
	# Philips
	ifmarkerfile({tda80xx.o},
		{loadmodule(tda80xx)},
		{loadmodule(tda8044h)})
	loadmodule(cam, mio=0xC040000 firmware=/var/tuxbox/ucodes/cam-alpha.bin)
elif [ $VENDOR_ID -eq 3 ]; then
	# Sagem
	loadmodule(at76c651)
	loadmodule(ves1x93, board_type=2)
	loadmodule(cam, mio=0xC000000 firmware=/var/tuxbox/ucodes/cam-alpha.bin)
fi

loadmodule(dvb_i2c_bridge)
loadmodule(avia_napi)
loadmodule(cam_napi)
loadmodule(dbox2_fp_napi)
# Possibly turn off the watchdog on AVIA 500
ifmarkerfile({no_watchdog},
	{loadmodule(avia_av, firmware=/var/tuxbox/ucodes no_watchdog=1)},
	{loadmodule(avia_av, firmware=/var/tuxbox/ucodes)})

# Bei Avia_gt hw_sections und nowatchdog abfragen
GTOPTS=""
ifmarkerfile({hw_sections},{GTOPTS="hw_sections=0 "})
ifmarkerfile({no_enxwatchdog},{GTOPTS="${{GTOPTS}}no_watchdog=1 "})

loadmodule(avia_gt, {ucode=/var/tuxbox/ucodes/ucode.bin ${GTOPTS}})
  
loadmodule(avia_gt_fb, console_transparent=0)
loadmodule(lcd)
loadmodule(avia_gt_lirc)
loadmodule(avia_gt_oss)
loadmodule(avia_gt_v4l2)

loadmodule(avia_av_napi)
ifmarkerfile({spts_mode},
	{loadmodule(avia_gt_napi, mode=1)
		loadmodule(dvb2eth)},
	{loadmodule(avia_gt_napi)})

loadmodule(aviaEXT)

# Create a telnet greeting
echo "$VENDOR $MODEL - Kernel %r (%t)." > /etc/issue.net

# compatibility links
ln -sf demux0 /dev/dvb/adapter0/demux1
ln -sf dvr0 /dev/dvb/adapter0/dvr1
ln -sf fb/0 /dev/fb0

if [ ! -d /var/etc ] ; then
    mkdir /var/etc
fi

runprogcreatedirifexists({/sbin/syslogd},{/var/log},{/sbin/syslogd})
runprogifexists({/var/tuxbox/config/lirc/lircd.conf},{lircd},
	{/var/tuxbox/config/lirc/lircd.conf})
runifexists({/bin/loadkeys},{/share/keymaps/i386/qwertz/de-latin1-nodeadkeys.kmap.gz})
runifexists({/sbin/inetd})
runprogifexists({/sbin/sshd},{/etc/init.d/start_sshd},{&})
runprogifexists({/sbin/lircd},{/etc/init.d/start_lircd},{&})
runifexists({/sbin/dropbear})
runprogifexists({/sbin/automount},{/etc/init.d/start_automount})
runprogifexists({/bin/djmount},{/etc/init.d/start_upnp})
runifexists({/bin/cdkVcInfo})

# Start the nfs server if /etc/exports exists
runprogifexists({/etc/exports},{loadmodule(nfsd)
	pidof portmap >/dev/null || portmap
	exportfs -r
	rpc.mountd
	rpc.nfsd 3})	

ifmarkerfile({tuxmaild},{tuxmaild})
ifmarkerfile({tuxcald},{tuxcald})
ifmarkerfile({rdate},{rdate time.fu-berlin.de})
ifmarkerfile({initialize},{/etc/init.d/initialize && rm /var/etc/.initialize})

if [ -e /var/etc/init.d/rcS.local ]; then
	. /var/etc/init.d/rcS.local
elif [ -e /etc/init.d/rcS.local ]; then
	. /etc/init.d/rcS.local
fi
