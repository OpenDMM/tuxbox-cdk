#!/bin/sh

flashprefix=$1
buildprefix=$2

MYFILES=$buildprefix/myfiles
MYDIRS="home/bengt local multimedia cdkroot"

# These directories should be there, just to be on the safe side...

mkdir -p \
 boot etc etc/init.d etc/network lib/tuxbox/plugins \
 share/tuxbox share/tuxbox/neutrino/httpd var/tuxbox/config \
 var/tuxbox/config/zapit var/tuxbox/ucodes var/tuxbox/boot

cd $flashprefix/root
cp -f $MYFILES/var/tuxbox/ucodes/* 		var/tuxbox/ucodes
cp -f $MYFILES/lib/tuxbox/plugins/* 		lib/tuxbox/plugins
cp -f $MYFILES/var/tuxbox/boot/logo-fb $MYFILES/var/tuxbox/boot/logo-lcd $MYFILES/var/tuxbox/boot/boot.conf boot
cp -f $buildprefix/../apps/dvb/config/cables.xml 	share/tuxbox/cables.xml
cp -f $MYFILES/etc/network/interfaces 		etc/network
cp -f $MYFILES/etc/passwd			etc
cp -f $MYFILES/var/tuxbox/config/zapit/services.xml var/tuxbox/config/zapit
cp -f $MYFILES/var/tuxbox/config/zapit/bouquets.xml var/tuxbox/config/zapit
cp -f $MYFILES/var/tuxbox/config/neutrino.conf  var/tuxbox/config
cp -f $MYFILES/share/tuxbox/neutrino/httpd/*	share/tuxbox/neutrino/httpd
cp -fr $MYFILES/var/tuxbox/config/lirc  	var/tuxbox/config
cp -f $MYFILES/etc/hosts 			etc
cp -f $MYFILES/etc/resolv.conf 			etc
cp -f $MYFILES/etc/init.d/start_neutrino        etc/init.d
chmod +x  etc/init.d/start_neutrino

cat > etc/init.d/start <<EOF
#!/bin/sh
. /etc/profile
/etc/init.d/start_neutrino
EOF

mkdir -p $MYDIRS
