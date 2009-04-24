W E B G U I   R U N T I M E   E N V I R O N M E N T   B U I L D   R E A D M E
-----------------------------------------------------------------------------

This is the WebGUI Runtime Environment (WRE) build system core. This is used 
to build the WRE for your operating system. License details and change log
can be found in the wre/wre/docs folder of this distribution.

For more information about the WRE, visit:

	http://wiki.webgui.org/


-----------------------------------------------------------------------------
 REQUIREMENTS
-----------------------------------------------------------------------------

- A unix-like system, such as Linux, OS X, Solaris, BSD, etc.
- gcc 3 or higher
- bash


-----------------------------------------------------------------------------
 QUICK BUILD INSTRUCTIONS
-----------------------------------------------------------------------------

To build the WRE for your platform follow these simple steps.

1) Download wrebuild-x.x.x-source.tar.gz (this distribution)

2) Extract the source.

	tar xvfz wrebuild-x.x.x-source.tar.gz

3) Make a /data folder and make it writable by you. Note that you should not
   install or run the WRE as root.

	sudo mkdir /data
	sudo chown you /data

4) Run build.sh

	./build.sh

That's it. This will create a working WRE in the /data/wre folder of your 
system.

NOTE: The build process can take a really long time. Depending upon the
speed of your system it can take anywhere from 2 to 6 hours.




-----------------------------------------------------------------------------
 OPERATING SYSTEM SPECIFIC NOTES
-----------------------------------------------------------------------------

The following sections deal with specific notes about compiling the WRE on
various operating systems. On most Linux and BSD operating systems the WRE
will compile without having to install anything else, because most of them
come with common utilities like gcc, make, binutils, etc. The following
instructions will help you out when your OS doesn't come with those things.



-----------------------------------------------------------------------------
 * MAC OS X
-----------------------------------------------------------------------------

In order to compile the WRE you must have the developer tools including GCC.
You can get them from http://connect.apple.com



-----------------------------------------------------------------------------
 * UBUNTU
-----------------------------------------------------------------------------

From apt-get you'll need to install the following packages before you can
compile the WRE:

gcc
g++
make



-----------------------------------------------------------------------------
 * DEBIAN
-----------------------------------------------------------------------------

From apt-get you'll need to install the following packages before you can
compile the WRE:

build-essential
g++
make
libncurses5-dev
gsfonts



-----------------------------------------------------------------------------
 * SuSE / SLES
-----------------------------------------------------------------------------

You'll need the following RPMs before you can compile:

gcc
gcc-c++
autoconf



-----------------------------------------------------------------------------
 * RHEL / CENTOS
-----------------------------------------------------------------------------

You'll need to install the following RPMs to before you can compile:

gcc
gcc-c++

On RHEL 5 or higher you also need to install:

libgomp


-----------------------------------------------------------------------------
 * FREEBSD
-----------------------------------------------------------------------------

From the Ports system you'll need to install the following packages before 
you can compile:

bash
gmake
autoconf261

You'll also need to run the following command:

ln -s /usr/local/bin/bash /bin/bash


-----------------------------------------------------------------------------
 * OPENBSD
-----------------------------------------------------------------------------

From the OpenBSD Packages you'll need the following items:
	* bash
	* gmake
	* autoconf-2.61p1

You'll also need to run the following command:
	ln -s /usr/local/bin/bash /bin/bash

--- GOTCHAS FOR OPENBSD 4.2 ---

* You will need expat to install libiconv. In 4.2-RELEASE, expat does
not exist as a port and is only available as part of the xbase file set.
This means you will need the xbase file set when you install OpenBSD.
This problem is fixed in OpenBSD 4.3 (expat is part of the base set).

* OpenSSL 0.9.7n does not compile under OpenBSD due to some rewritten ASM
code. You will need to remove the wrebuild/source/openssl-0.9.7n directory
and replace it with at least OpenSSL 0.9.8g. You will also need to update
'build.sh' to compile the new OpenSSL.

For more detailed instructions, visit:
http://wiki.webgui.org/how-to-build-the-wre-on-openbsd


-----------------------------------------------------------------------------
 * GENTOO
-----------------------------------------------------------------------------

You need to run the following command:

ln -s /usr/src/linux/include/asm/page.h /usr/include/asm/



-----------------------------------------------------------------------------
 * SOLARIS
-----------------------------------------------------------------------------

You need to get GCC and bash installed on your Solaris box, and then the
following command line instructions will get you the other build prereqs. Note
that during the "pkg-get" commands just select "y" or "all" whenever it asks
you any questions.

bash
export PATH=/opt/csw/bin:/usr/sfw/bin:/opt/sfw/bin:/usr/local/bin:/opt/bin:$PATH
export LD_LIBRARY_PATH=/opt/csw/lib:/usr/sfw/lib:/opt/sfw/lib:/usr/local/lib:/opt/lib:/usr/lib:/usr/lib/sparcv9:$LD_LIBRARY_PATH
export TERM=vt100
mkdir -p /data/downloads
cd /data/downloads
wget http://easynews.dl.sourceforge.net/sourceforge/pbwebgui/wrebuild-0.8.0-source.tar.gz
wget http://www.blastwave.org/pkg_get.pkg
pkgadd -d pkg_get.pkg
pkg-get -U install textutils
pkg-get -U install gnupg
wget http://www.blastwave.org/mirrors.html
gpg --import mirrors.html
pkg-get install vim
pkg-get install glib
pkg-get install binutils
ln -s /opt/csw/bin/gar /opt/csw/bin/ar
ln -s /opt/csw/bin/granlib /opt/csw/bin/ranlib
ln -s /opt/csw/bin/gld  /opt/csw/bin/ld
pkg-get install ggrep
ln -s /opt/csw/bin/gegrep /opt/csw/bin/egrep
tar xvfz wrebuild-0.8.0-source.tar.gz
./build.sh --all




