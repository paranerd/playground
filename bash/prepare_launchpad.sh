#!/bin/bash

# Required packages: build-essentials dh-make dput

# First generate gpg-key
# $ gpg --gen-key
# $ gpg --keyserver keyserver.ubuntu.com --send-keys <key_id> (key_id can be seen at the end of --gen-key or via gpg --list-keys)
# $ gpg --fingerprint
# Go to https://launchpad.net/~paranerd-development/+editpgpkeys, paste the fingerprint, click import and wait for the e-mail
# To activate the new gpg-key, follow the instructions on https//help.lauchpad.net/YourAccount/ImportingYourPGPKey
# TL;DR:
# Open the "Passwords and Encryption Keys"-Program on Ubuntu
# Menu --> Remote --> Sync and Publish Keys --> hkp://keyserver.ubuntu.com --> Sync
# Wait approx. 30min for the keys to be imported
# Then go to "Passwords and Encryption Keys" again, select the Key, go to details and copy the Fingerprint
# Go to https://launchpad.net/~paranerd-development/+editpgpkeys, paste the fingerprint, click import and wait for the e-mail
# The e-mail is encrypted --> copy the part from -----BEGIN to MESSAGE----- (including the dashes) into a file --> decrypt it in the command line by running
# $ gpg <filename>

# Put the text of the AGPL into a file and enter the path when prompted
# To upload for new distribution: you can't have the same version! (so i.e. do 2.9.6-1 instead)

# For building a .deb package, simply put all the system files (except the debian/control - but definitely the DEBIAN/control!) into debian/DEBIAN and the tmp/ next to it (also into the debian-directory)
# All system files need permissions >= 555 and <= 775 (I guess, just executable). Then, to build the .deb, run:
# dpkg-deb -b debian/

if [[ $# -eq 0 ]] ; then
    echo 'Specify zip file as argument!'
    exit 0
fi

printf "Enter version: "
read -r version

mkdir -p simpledrive-$version/debian/DEBIAN
mkdir simpledrive-$version/tmp

echo "--> unzipping $1..."

if ! unzip $1 -d simpledrive-$version/tmp &> /dev/null; then
	rm -r simpledrive-$version/
	echo "Error: Could not unzip $1 - Aborting."
	exit 1
fi

touch simpledrive-$version/debian/{changelog,compat,control,copyright,debhelper.log,md5sums,postinst,prerm,rules,simpledrive.install}
touch simpledrive-$version/debian/DEBIAN/control

# Write install
#echo "--> writing install..."
#echo "tmp/simpledrive /tmp/" > simpledrive-$version/debian/install

# Write simpledrive.install
#echo "--> writing simpledrive.install..."
#echo "tmp/simpledrive/* /tmp/" > simpledrive-$version/debian/simpledrive.install

# Write changelog
echo "--> writing changelog..."
echo "simpledrive ("$version") all; urgency=low

  * Minor changes and bugfixes

 -- Kevin Schulz <paranerd.development@gmail.com>  Th, 07 Apr 2016 17:52:00 +0200" > simpledrive-$version/debian/changelog

# Write compat
echo "--> writing compat..."
echo "9" > simpledrive-$version/debian/compat

# Write control
echo "--> writing control..."
echo "Source: simpledrive
Section: misc
Priority: extra
Maintainer: Kevin Schulz <paranerd.development@gmail.com>
Build-Depends: debhelper, apache2, php5, php5-gd, libapache2-mod-php5, mysql-server, php5-mysql
Standards-Version: "$version"
Homepage: http://simpledrive.org

Package: simpledrive
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Kurze Beschreibung von simpledrive
	Lange Beschreibung von simpledrive" > simpledrive-$version/debian/control

# Write copyright
echo "Copyright file:"
read copyright_path
cat $copyright_path > simpledrive-$version/debian/copyright

# Write debhelper.log
echo "--> writing debhelper.log..."
echo "dh_auto_configure
dh_auto_build
dh_auto_test" > simpledrive-$version/debian/debhelper.log

# Write postinst
echo "--> writing postinst..."
echo -e "#!/bin/sh
string=\$(grep -i 'DocumentRoot' /etc/apache2/sites-available/000-default.conf)
string2=\${string#*DocumentRoot }

echo 'Copying server files to DocumentRoot at \$string2'

mkdir \$string2/simpledrive
cp -r /tmp/simpledrive \$string2/
rm -r /tmp/simpledrive
chown -R www-data:www-data \$string2/simpledrive" > simpledrive-$version/debian/postinst

# Write rules
echo "--> writing rules..."
echo "#!/usr/bin/make -f
# See debhelper(7) (uncomment to enable)
# output every command that modifies files on the build system.
#DH_VERBOSE = 1
# see EXAMPLES in dpkg-buildflags(1) and read /usr/share/dpkg/*
DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/default.mk
# see FEATURE AREAS in dpkg-buildflags(1)
#export DEB_BUILD_MAINT_OPTIONS = hardening=+all
# see ENVIRONMENT in dpkg-buildflags(1)
# package maintainers to append CFLAGS
#export DEB_CFLAGS_MAINT_APPEND  = -Wall -pedantic
# package maintainers to append LDFLAGS
#export DEB_LDFLAGS_MAINT_APPEND = -Wl,--as-needed
# main packaging script based on dh7 syntax

%:
	dh \$@

#override_dh_install:
	dh_install tmp/simpledrive/ /tmp/" > simpledrive-$version/debian/rules

# Write DEBIAN/control
echo "--> writing DEBIAN/control..."
echo "Package: simpledrive
Version: "$version"
Section: misc
Priority: extra
Architecture: all
Maintainer: Kevin Schulz <paranerd.development@gmail.com>
Depends: apache2, php5, php5-gd, libapache2-mod-php5, mysql-server, php5-mysql
Homepage: http://simpledrive.org
Description: Kurze Beschreibung von simpledrive
	Lange Beschreibung von simpledrive" > simpledrive-$version/debian/DEBIAN/control

# Calculate MD5-Sums
echo "--> calculating md5-sums..."
find simpledrive-$version/tmp/simpledrive -type f -exec md5sum {} + > simpledrive-$version/debian/md5sums

cd simpledrive-$version/
debuild -S
cd ../
dput ppa:paranerd-development/simpledrive "simpledrive_"$version"_source.changes"
echo "Build successful."