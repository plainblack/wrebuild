W E B G U I   R U N T I M E   E N V I R O N M E N T   B U I L D   R E A D M E
-----------------------------------------------------------------------------

This is the WebGUI Runtime Environment (WRE) build system core. This is used 
to build the WRE for your operating system. License details and change log
can be found in the wre/wre/docs folder of this distribution.

For more information about the WRE, visit:

	http://www.plainblack.com/wre


REQUIREMENTS

- A unix-like system, such as Linux, OS X, Solaris, BSD, etc.
- gcc 3 or higher
- bash


QUICK BUILD INSTRUCTIONS

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


OPERATING SYSTEM SPECIFIC NOTES

The following sections deal with specific notes about compiling the WRE on
various operating systems. On most Linux and BSD operating systems the WRE
will compile without having to install anything else, because most of them
come with common utilities like gcc, make, binutils, etc. The following
instructions will help you out when your OS doesn't come with those things.

MAC OS X
--------

In order to compile the WRE you must have the developer tools including GCC.
You can get them from http://connect.apple.com

SOLARIS
-------

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
wget http://easynews.dl.sourceforge.net/sourceforge/pbwebgui/wrebuild-0.7.0-source.tar.gz
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
tar xvfz wrebuild-0.7.0-source.tar.gz
./build.sh


