#!/bin/sh

set -x 
flashprefix=$1
buildprefix=$2

MYFILES=$buildprefix/myfiles
MYDIRS="home/bengt local multimedia cdkroot"

# These directories should be there, just to be on the safe side...

mkdir -p \
 var/tuxbox/config \
 var/tuxbox/config/zapit var/tuxbox/ucodes var/tuxbox/boot

cd $flashprefix/jffs2
cp -f $MYFILES/var/tuxbox/ucodes/* 		tuxbox/ucodes
cp -f $MYFILES/var/tuxbox/boot/logo-fb $MYFILES/var/tuxbox/boot/logo-lcd $MYFILES/var/tuxbox/boot/boot.conf tuxbox/boot
cp -f $MYFILES/var/tuxbox/config/zapit/services.xml tuxbox/config/zapit
cp -f $MYFILES/var/tuxbox/config/zapit/bouquets.xml tuxbox/config/zapit
cp -f $MYFILES/var/tuxbox/config/neutrino.conf  tuxbox/config
cp -fr $MYFILES/var/tuxbox/config/lirc  	tuxbox/config
cp -f $MYFILES/etc/init.d/start_neutrino        etc/init.d
chmod +x etc/init.d/start_neutrino

