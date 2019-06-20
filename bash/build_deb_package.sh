#!/bin/bash

# Note: put a copy of the GNU Licence as "copyright"-file into the directory of changelog, control, etc.

if [[ $# -eq 0 ]] ; then
    echo 'Specify zip file as argument!'
    exit 0
fi

if [ -d "simpledrive-$version" ]; then
	rm -r simpledrive-$version
fi

printf "Enter version: "
read -r version

mkdir -p simpledrive-$version/{DEBIAN,tmp}

touch simpledrive-$version/DEBIAN/{changelog,compat,control,copyright,debhelper.log,md5sums,postinst,prerm,rules,simpledrive.install}
chmod 755 simpledrive-$version/DEBIAN/postinst simpledrive-$version/DEBIAN/prerm

if ! unzip $1 -d simpledrive-$version/tmp &> /dev/null; then
	rm -r simpledrive-$version/
	echo "Error: Could not unzip $1 - Aborting."
	exit 1
fi

# Write changelog
echo "--> writing changelog..."
echo "simpledrive ("$version") wily; urgency=low

  * Minor changes and bugfixes

 -- Kevin Schulz <paranerd.development@gmail.com>  Mo, 01 Dec 2014 20:44:23 +0200" > simpledrive-$version/DEBIAN/changelog

# Write compat
echo "--> writing compat..."
echo "9" > simpledrive-$version/DEBIAN/compat

# Write control
echo "--> writing control..."
echo "Package: simpledrive
Version: "$version"
Section: misc
Priority: extra
Architecture: all
Maintainer: Kevin Schulz <paranerd.development@gmail.com>
Depends: apache2, php5, php5-gd, libapache2-mod-php5, mysql-server, php5-mysql, mysql-client
Homepage: http://simpledrive.org
Description: Kurze Beschreibung von simpledrive
	Lange Beschreibung von simpledrive" > simpledrive-$version/DEBIAN/control

# Write copyright
printf "Copyright file: "
read -r copyright_path
cat $copyright_path > simpledrive-$version/DEBIAN/copyright

# Write debhelper.log
echo "--> writing debhelper.log..."
echo "dh_auto_configure
dh_auto_build
dh_auto_test" > simpledrive-$version/DEBIAN/debhelper.log

# Write postinst
echo "--> writing postinst..."
echo -e "#!/bin/sh
string=\$(grep -i 'DocumentRoot' /etc/apache2/sites-available/000-default.conf)
string2=\${string#*DocumentRoot }

echo 'Copying server files to DocumentRoot at \$string2'

mkdir \$string2/simpledrive
cp -r /tmp/simpledrive \$string2/
rm -r /tmp/simpledrive
chown -R www-data:www-data \$string2/simpledrive" > simpledrive-$version/DEBIAN/postinst

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
	dh_install tmp/simpledrive/ /tmp/" > simpledrive-$version/DEBIAN/rules

# Write changelog
echo "--> calculating md5-sums..."
find simpledrive-$version/tmp/simpledrive -type f -exec md5sum {} + > simpledrive-$version/DEBIAN/file.md5

dpkg-deb --build simpledrive-$version