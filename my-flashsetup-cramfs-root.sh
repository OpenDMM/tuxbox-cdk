#!/bin/sh

set -x
flashprefix=$1
buildprefix=$2

MYFILES=$buildprefix/myfiles
MYDIRS="home/bengt local multimedia cdkroot"

# These directories should be there, just to be on the safe side...

cd $flashprefix/cramfs
rm -f etc/resolv.conf etc/network
mkdir -p boot etc etc/init.d etc/network lib/tuxbox/plugins \
 share/tuxbox share/tuxbox/neutrino/httpd

cp -f $MYFILES/lib/tuxbox/plugins/* 		lib/tuxbox/plugins
cp -f $buildprefix/../apps/dvb/config/cables.xml 	share/tuxbox/cables.xml
cp -f $MYFILES/etc/network/interfaces 		etc/network
cp -f $MYFILES/etc/passwd			etc
cp -f $MYFILES/share/tuxbox/neutrino/httpd/*	share/tuxbox/neutrino/httpd
cp -f $MYFILES/etc/hosts 			etc
cp -f $MYFILES/etc/resolv.conf 			etc

cp -f $MYFILES/etc/init.d/rcS 			etc/init.d

mkdir -p $MYDIRS
