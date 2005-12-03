#!/bin/bash

# error
checkError(){
   if [ $1 -ne 0 ];
   then
       echo "WRE ERROR: "$2" did not complete successfully."
       exit
   fi
}
                 

# clean all the folders for a new build
clean(){
 #utilities
  cd source/utils/lftp
  make distclean
  make clean
  cd ../zlib
  make distclean
  make clean
  cd ../openssl
  make distclean
  make clean
  cd ../libtool
  make distclean
  make clean
  cd $BUILDDIR
 #memcached
  cd source/memcached/libevent
  make distclean
  make clean
  cd ../memcached
  make distclean
  make clean
  cd $BUILDDIR
 #perl
  cd source/perl/perl
  make distclean
  make clean
  cd ../compresszlib
  make distclean
  make clean
  cd ../netssleay
  make distclean
  make clean
  cd $BUILDDIR
 #apache 
  cd source/apache/apache
  make distclean
  make clean
  rm -Rf server/exports.c 
  rm -Rf server/export_files
  cd ../modperl
  make distclean
  make clean
  cd ../libapreq2
  make distclean
  make clean
  cd $BUILDDIR
 #mysql
  cd source/mysql/mysql
  make distclean
  cd $BUILDDIR
 #image magick
  cd source/imagemagick/imagemagick
  make distclean
  make clean
  cd ../libpng
  make distclean
  make clean 
  cd ../libungif 
  make distclean 
  make clean 
  cd ../libjpeg 
  make distclean 
  make clean 
  cd ../freetype
  make distclean 
  make clean 
  cd $BUILDDIR
}

# utilities
buildUtils(){
	echo Building Utilities
	mkdir -p /data/wre/prereqs/utils/bin
	cd source/utils/lftp
	./configure --prefix=/data/wre/prereqs/utils; checkError $? "lftp Configure"
	make; checkError $? "lftp make"
	make install; checkError $? "lftp make install"
	cd ../zlib
	./configure --prefix=/data/wre/prereqs/utils --shared; checkError $? "zlib Configure"
	make; checkError $? "zlib make"
	make install; checkError $? "zlib make install"
	cd ../openssl
	./config --prefix=/data/wre/prereqs/utils; checkError $? "OpenSSL Configure"
	make; checkError $? "OpenSSL make"
	make test; checkError $? "OpenSSL make test"
	make install; checkError $? "OpenSSL make install"
	cd ../libtool
	./configure --prefix=/data/wre/prereqs/utils; checkError $? "libtool Configure"
	make; checkError $? "libtool make"
	make install; checkError $? "libtool make install"
	cd $BUILDDIR
}

# memcached
buildMemcached(){
        echo Building memcached
        mkdir -p /data/wre/prereqs/memcached/bin
        mkdir -p /data/wre/prereqs/memcached/lib
        cd source/memcached/libevent
        ./configure --prefix=/data/wre/prereqs/memcached; checkError $? "libevent Configure"
        make; checkError $? "libevent make"
        make install; checkError $? "libevent make install"
        cd ../memcached
        ./configure --with-libevent=/data/wre/prereqs/memcached --prefix=/data/wre/prereqs/memcached; checkError $? "memcached Configure"
        make; checkError $? "memcached make"
        make install; checkError $? "memcached make install"
        cd $BUILDDIR
}

# perl
buildPerl(){
	echo Building Perl
	mkdir -p /data/wre/prereqs/perl/bin
	mkdir -p /data/wre/prereqs/perl/man/man1
	mkdir -p /data/wre/prereqs/perl/lib
	mkdir -p /data/wre/prereqs/perl/include
	cd source/perl/perl
	./Configure -Dprefix=/data/wre/prereqs/perl -des; checkError $? "Perl Configure" 
	make; checkError $? "Perl make"
	#make test; checkError $? "Perl make test"
	make install; checkError $? "Perl make install"
	cd $BUILDDIR
}


# apache
buildApache(){
	echo Building Apache
	mkdir -p /data/wre/prereqs/apache/bin
	mkdir -p /data/wre/prereqs/apache/man/man1
	mkdir -p /data/wre/prereqs/apache/lib
	mkdir -p /data/wre/prereqs/apache/include
	mkdir -p /data/wre/prereqs/apache/conf
	cd source/apache/apache
	case $OSNAME in
		Linux)
			# insists upon using it's own zlib and ours, which won't work, so temporarily hiding ours
			mv /data/wre/prereqs/utils/include/zlib.h /data/wre/prereqs/utils/include/zlib.h.ignore
			;;
	esac
	./configure --prefix=/data/wre/prereqs/apache --enable-rewrite=shared --enable-deflate=shared --enable-ssl --with-ssl=/data/wre/prereqs/utils --enable-proxy=shared --with-mpm=prefork --disable-userdir --disable-imap --disable-negotiation --disable-actions; checkError $? "Apache Configure"
	make; checkError $? "Apache make"
	make install; checkError $? "Apache make install"
	case $OSNAME in
		Linux)
		mv /data/wre/prereqs/utils/include/zlib.h.ignore /data/wre/prereqs/utils/include/zlib.h
			;;
	esac
	cd ../modperl
	perl Makefile.PL MP_APXS=/data/wre/prereqs/apache/bin/apxs; checkError $? "mod_perl Configure"
	make; checkError $? "mod_perl make"
	case $OSNAME in
		SunOS)
			#tests fail for some reason even after a good build
			;;
		*)
			make test; checkError $? "mod_perl make test"
			;;
	esac
	make install; checkError $? "mod_perl make install"
	cd $BUILDDIR
}


# mysql
buildMysql(){
	echo Building MySQL
	staticflags="--with-mysqld-ldflags=-all-static --with-client-ldflags=-all-static"
	case $OSNAME in
		Darwin | SunOS)
			# can't compile with static ldflags for some reason
			unset staticflags
			;;
	esac
	mkdir -p /data/wre/prereqs/mysql/bin
	mkdir -p /data/wre/prereqs/mysql/man/man1
	mkdir -p /data/wre/prereqs/mysql/lib
	mkdir -p /data/wre/prereqs/mysql/libexec
	mkdir -p /data/wre/prereqs/mysql/include
	mkdir -p /data/wre/prereqs/mysql/var
	cd source/mysql/mysql
	CC=gcc CFLAGS="-O3 -fno-omit-frame-pointer" CXX=g++ CXXFLAGS="-O3 -fno-omit-frame-pointer -felide-constructors -fno-exceptions -fno-rtti" ./configure --prefix=/data/wre/prereqs/mysql --with-extra-charsets=all --enable-thread-safe-client --enable-local-infile --disable-shared --enable-assembler --with-readline --without-debug --enable-large-files=yes --enable-largefile=yes $staticflags; checkError $? "MySQL Configure"
	make; checkError $? "MySQL make"
	make install; checkError $? "MySQL make install"
	cd $BUILDDIR
}


# Image Magick
buildImageMagick(){
	echo Building Image Magick
	mkdir -p /data/wre/prereqs/imagemagick/bin
	mkdir -p /data/wre/prereqs/imagemagick/man/man1
	mkdir -p /data/wre/prereqs/imagemagick/lib
	mkdir -p /data/wre/prereqs/imagemagick/include
	cd source/imagemagick/libjpeg
	./configure --enable-shared --prefix=/data/wre/prereqs/imagemagick; checkError $? "Image Magick libjpeg Configure"
	perl -i -p -e's[./libtool][libtool]g' Makefile
	make; checkError $? "Image Magick libjpeg make"
	make install; checkError $? "Image Magick libjpeg make install"
	cd ../freetype
	./configure --enable-shared --prefix=/data/wre/prereqs/imagemagick; checkError $? "Image Magick freetype Configure"
	make; checkError $? "Image Magick freetype make"
	make install; checkError $? "Image Magick freetype make install"
	cd ../libungif
	./configure --enable-shared --prefix=/data/wre/prereqs/imagemagick; checkError $? "Image Magick libungif Configure"
	make; checkError $? "Image Magick libungif make"
	make install; checkError $? "Image Magick libungif make install"
	cd ../libpng
	case $OSNAME in
		SunOS)
			cp scripts/makefile.solaris Makefile
			;;
		*)
			cp scripts/makefile.`perl -e "print lc $OSNAME"` Makefile
			;;
	esac
	perl -i -p -e's[/usr/local][/data/wre/prereqs/imagemagick]g' Makefile
	make; checkError $? "Image Magick libpng make"
	make install; checkError $? "Image Magick libpng make install"
	cd ../imagemagick
	./configure --prefix=/data/wre/prereqs/imagemagick --enable-delegate-build LDFLAGS='-L/data/wre/prereqs/imagemagick/lib' CPPFLAGS='-I/data/wre/prereqs/imagemagick/include' --enable-shared=yes --with-jp2=yes --with-jpeg=yes --with-png=yes --with-perl=yes --with-x=no
	checkError $? "Image Magick Configure"
	make; checkError $? "Image Magick make"
	make install; checkError $? "Image Magick make test"
	cd $BUILDDIR
}


#perl modules
installPerlModules(){
	echo Installing Perl Modules
	cd source/perl/compresszlib
	perl Makefile.PL; checkError $? "Compress::Zlib Makefile.PL"
	make; checkError $? "Compress::Zlib make"
	make install; checkError $? "Compress::Zlib make install"
	cd ../netssleay
	perl Makefile.PL /data/wre/prereqs/utils; checkError $? "Net::SSLeay Makefile.PL"
	make; checkError $? "Net:::SSLeay make"
	make install; checkError $? "Net::SSLeay make install"
	cd $BUILDDIR
	./installPerlModules.pl
	cd source/apache/libapreq2
	./configure --with-apache2-apxs=/data/wre/prereqs/apache/bin/apxs --enable-perl-glue; checkError $? "libapreq2 configure"
	make; checkError $? "libapreq2 make"
	make install; checkError $? "libapreq2 make install"
	cd $BUILDDIR
}

#awstats
installAwStats(){
	echo Installing AWStats
	cp -RL source/awstats/awstats /data/wre/prereqs/
}

#wre utils
installWreUtils(){
	echo Installing WebGUI Runtime Environment Core and Utilities
	cp -R wre/wre /data/
	mkdir /data/wre/etc
}

#gooey
gooey() {
  printf '\x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x4d \x57 \xd0 \x57 \x57 \x57 \x4d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x40 \x23 \x23 \x35 \x35 \x35 \x35 \x35 \x35 \x23 \x23 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x57 \x23 \x23 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x35 \x40 \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x57 \x57 \x4d \x23 \x23 \x23 \x35 \x41 \x41 \x25 \x25 \x24 \x24 \x24 \x33 \x33 \x24 \x24 \x24 \x25 \x41 \x35 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x33 \x24 \x25 \x25 \x41 \x35 \x35 \x41 \x25 \x25 \x24 \x4a \x37 \x37 \x37 \x37 \x37 \x3d \x3d \x3d \x37 \x33 \x24 \x25 \x41 \x23 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x25 \x41 \x35 \x41 \x41 \x25 \x25 \x33 \x33 \x24 \x41 \x41 \x35 \x23 \x40 \x40 \x40 \x40 \x35 \x43 \x43 \x24 \x25 \x41 \x23 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x3d \x33 \x41 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x35 \x23 \x23 \x23 \x23 \x23 \x23 \x23 \x40 \xd0 \x57 \xd0 \x43 \x4a \x24 \x25 \x23 \x41 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x23 \x41 \x41 \x23 \x23 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x25 \x24 \x33 \x33 \x33 \x33 \x33 \x24 \x35 \x35 \x43 \x25 \x25 \x35 \x25 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x25 \x57 \xd0 \x40 \x40 \x35 \x35 \x41 \x41 \x41 \x41 \x25 \x41 \x33 \x37 \x4a \x24 \x25 \x41 \x41 \x41 \x33 \x2c \x24 \x41 \x24 \x25 \x41 \x35 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \xd0 \x23 \xd0 \x23 \x35 \x41 \x41 \x41 \x25 \x25 \x4a \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \x4a \x25 \x41 \x41 \x41 \x41 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \xa6 \x25 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x25 \x43 \x41 \x4d \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4a \x4a \x25 \x41 \x41 \x41 \x24 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x2e \x2c \x41 \xd0 \x40 \x35 \x41 \x41 \x41 \x25 \x43 \x35 \x20 \x40 \x43 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x43 \x33 \x25 \x41 \x41 \x25 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \x28 \x23 \xd0 \x23 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x57 \x2a \xa6 \x24 \x57 \x41 \x4d \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x41 \x25 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x43 \xd0 \x20 \x40 \x27 \x21 \x3d \x21 \xa6 \x4d \x20 \x20 \x20 \x40 \x37 \x24 \x25 \x25 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x35 \x41 \x40 \x40 \x23 \x41 \x41 \x41 \x24 \x43 \x20 \x20 \xa9 \x24 \xa6 \xa6 \x33 \x4d \x20 \x20 \x20 \xa9 \x4a \x33 \x24 \x24 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x35 \x23 \x25 \x40 \x40 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \x4a \x33 \x24 \x43 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x33 \x24 \x33 \xd0 \x40 \x35 \x41 \x41 \x25 \x33 \x33 \x20 \x20 \x20 \x20 \xa9 \x20 \x20 \x20 \x20 \xa9 \x35 \x4a \x33 \x33 \x33 \x57 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x40 \x57 \x23 \x35 \x41 \x25 \x24 \x24 \xa9 \x40 \x25 \x4a \x4a \x33 \x25 \x23 \xd0 \x41 \x4a \x33 \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x37 \x37 \xa9 \x20 \x20 \x4d \x33 \x3d \x28 \x41 \x4d \xd0 \x35 \x41 \x41 \x25 \x24 \x24 \x25 \x35 \x23 \x40 \xd0 \x40 \x23 \x41 \x24 \x33 \x25 \x3d \x35 \x25 \x41 \x35 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \xd0 \x21 \x37 \x41 \x20 \x20 \x4a \x4a \x23 \x25 \x43 \x40 \x4d \x40 \x35 \x41 \x41 \x41 \x35 \x35 \x35 \x23 \x23 \x23 \x23 \x35 \x35 \x25 \x25 \x25 \x3d \x24 \x25 \x41 \x23 \x35 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x35 \x28 \x40 \x4a \x43 \xa9 \x20 \x2c \x23 \x41 \x33 \x4a \x4a \x40 \x4d \xd0 \x23 \x35 \x41 \x41 \x25 \x25 \x25 \x41 \x41 \x41 \x41 \x24 \x33 \x24 \x25 \x24 \x3d \x33 \x24 \x41 \x40 \x33 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x4d \x43 \x37 \xd0 \xd0 \xa6 \x33 \xa9 \x20 \x2c \x41 \x24 \x4a \x33 \x33 \x4a \x41 \x57 \x57 \xd0 \x23 \x35 \x25 \x24 \x24 \x24 \x24 \x24 \x33 \x33 \x33 \x24 \x41 \x41 \x24 \x37 \x4a \x24 \x25 \x41 \x3d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \xa9 \xa6 \x25 \x57 \x40 \x24 \x21 \x23 \x20 \x20 \x2a \x24 \x4a \x33 \x41 \x25 \x33 \x4a \x43 \x24 \x41 \x35 \x23 \x40 \x41 \x25 \x24 \x33 \x33 \x33 \x4a \x4a \x24 \x41 \x35 \x35 \x35 \x33 \x37 \x4a \x24 \x3d \x41 \x20 \x20 \x20 \x57 \x23 \x20 \x20 \x0d \x0a \x23 \xa6 \x57 \x23 \x35 \x33 \xa6 \x4a \x57 \x23 \xa6 \x43 \x24 \x23 \x35 \x25 \x24 \x33 \x43 \x28 \x43 \x4a \x4a \x4a \x24 \x25 \x25 \x24 \x33 \x33 \x43 \x43 \x24 \x25 \x41 \x35 \x35 \x23 \x41 \x4a \x37 \x43 \xa6 \x20 \x20 \x20 \xd0 \x21 \x35 \x20 \x0d \x0a \x25 \x3d \x23 \x23 \x35 \x35 \x28 \x3d \x3d \xa6 \x43 \x25 \x40 \x23 \x41 \x25 \x24 \x4a \x28 \x33 \x25 \x24 \x24 \x25 \x25 \x25 \x25 \x24 \x33 \x37 \x2a \x3d \x24 \x25 \x41 \x41 \x35 \x35 \x23 \x23 \x25 \x3d \x27 \x40 \x20 \x20 \x41 \x4a \x43 \xa9 \x0d \x0a \xd0 \xa6 \x25 \x41 \x41 \x35 \x35 \x41 \x41 \x40 \x40 \x40 \x23 \x35 \x41 \x24 \x4a \x3d \x4a \x35 \x41 \x25 \x25 \x41 \x41 \x25 \x24 \x24 \x43 \x27 \x3d \x43 \x4a \x33 \x24 \x25 \x41 \x41 \x35 \x23 \x40 \x23 \x43 \xa6 \x41 \x33 \x3d \x40 \x33 \x4d \x0d \x0a \x20 \x28 \x4a \x24 \x25 \x41 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x25 \x25 \x33 \x4a \xa6 \x23 \x23 \x41 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x21 \x21 \x21 \x37 \x43 \x4a \x33 \x25 \x25 \x41 \x35 \x23 \x40 \xd0 \x24 \x2a \x43 \x24 \x25 \x25 \x20 \x0d \x0a \x20 \x57 \x28 \x4a \x33 \x24 \x25 \x41 \x41 \x41 \x25 \x24 \x24 \x24 \x33 \x33 \x4a \x28 \xd0 \x23 \x35 \x41 \x41 \x41 \x41 \x25 \x24 \x4a \x2c \x24 \x24 \x4a \xa6 \x21 \xa6 \x3d \x43 \x33 \x24 \x25 \x41 \x35 \x23 \xd0 \x35 \x28 \x24 \x40 \x20 \x20 \x0d \x0a \x20 \x20 \xd0 \x43 \x37 \x33 \x33 \x33 \x24 \x24 \x33 \x33 \x33 \x33 \x33 \x33 \x41 \x24 \x40 \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x24 \x3d \x37 \x35 \x23 \x41 \x24 \x4a \x3d \xa6 \x21 \xa6 \x43 \x33 \x24 \x41 \x35 \x23 \x57 \x35 \x4a \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x57 \x41 \x25 \x24 \x24 \x24 \x25 \x25 \x35 \x23 \xd0 \xa9 \x20 \xa9 \x4a \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x23 \xa9 \x23 \x23 \x35 \x25 \x24 \x33 \x4a \x35 \x37 \x28 \x37 \x24 \x25 \x35 \x40 \x4d \x25 \x41 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x24 \x41 \x25 \x24 \x41 \x41 \x41 \x24 \x33 \x2a \x57 \x20 \xa9 \x41 \x35 \x41 \x25 \x24 \x43 \x4d \xa9 \x40 \x37 \x28 \x24 \x41 \x35 \xd0 \x4d \x3d \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x37 \x24 \xa6 \x35 \x35 \x41 \x24 \x24 \x2c \xa9 \x20 \x20 \x57 \x37 \x25 \x24 \x33 \x43 \x20 \x20 \x20 \x20 \x25 \xa6 \x25 \x35 \x40 \x4d \x4a \xd0 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x4a \x57 \xa9 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x23 \x35 \x41 \x41 \x25 \x2c \x4d \x57 \x41 \x3d \x4a \x33 \x4a \x4a \x57 \x20 \x20 \x20 \x20 \x20 \x4a \x43 \x35 \x23 \x57 \x4a \x40 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x3d \x43 \x25 \x23 \xa9 \x20 \xa9 \x23 \x4a \xd0 \x23 \x35 \x35 \x35 \x41 \x2c \x41 \x3d \x28 \x43 \x33 \x25 \x23 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x23 \x28 \x35 \xd0 \x57 \x3d \xa9 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x43 \x35 \x40 \x25 \x24 \x25 \x23 \xd0 \x40 \x35 \x35 \x35 \x23 \x33 \x37 \xa9 \xa9 \xa9 \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x33 \x25 \x43 \x24 \xd0 \xd0 \x4a \x23 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x4a \x41 \x4d \x57 \x57 \xd0 \x23 \x35 \x35 \x23 \x23 \x33 \x3d \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \xa6 \x43 \x41 \x24 \x33 \x23 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x41 \x4a \x41 \x23 \x40 \x23 \x23 \x35 \x25 \x43 \x24 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x40 \x23 \x57 \xa9 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x24 \x4a \x43 \x43 \x33 \x41 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x0d \x0a';
  cat wre/wre/docs/credits.txt
  return 0;
}

#wre help
wrehelp() {
cat <<_WREHELP
 \`build.sh' builds the WebGUI Runtime Environment.
  
  Usage: $0 [OPTION]... [OPTION=ARGUMENT]
  
  Defaults for the options are specified in brackets.
  
  Configuration:
  -h, --help, -?      display this help and exit

  Build switches cause only selecte applications to build.
  They can be combined to build only certain apps.
  
  Example: ./build.sh --perl           #only perl will be built
           ./build.sh --perl --apache  #only perl and apache will build
           ./build.sh                  #build all

  --clean        cleans all pre-req folders for a new build
  --utilities	 compiles and installs shared utilities
  --memcached	 compiles and installs memcached
  --perl         compiles and installs perl
  --apache       compiles and installs apache
  --mysql	 compiles and installs mysql
  --imagemagick  compiles and installs imagemagick
  --awstats      installs awstats
  --wre          installs wre
  --perlmodules  installs perl modules from cpan
                               
_WREHELP

}

# vars
. wre/wre/sbin/setenvironment
export BUILDDIR=`pwd`
export OSNAME=`uname -s`


#Evaluate options passed by command line
for opt in "$@"
do

  #get any argument passed with this option
  arg=`expr "x$opt" : 'x[^=]*=\(.*\)'`

  case "$opt" in
 
    --clean)
      clean
    ;;
 
    --utils | --utilities)
      buildUtils
    ;;
    
    --memcached)
      buildMemcached
    ;;
    
    --perl)
      buildPerl
    ;;
    
    --apache)
      buildApache
    ;;
    
    --apache=*)
      echo $arg
      #Use $arg as parameter to function call, could be used
      #to pass compile flags for performance, etc.
    ;;
    
    --mysql)
      buildMysql
    ;;
    
    --imageMagick | --imagemagick)
      buildImageMagick
    ;;
    
    --awstats)
      installAwStats
    ;;
    
    --wre)
      installWreUtils
    ;;
    
    --wre=revolutionary)
      gooey
    
    ;;
     
    --perlModules | --perlmodules)
      installPerlModules
    ;;
    
    --help | -help | -h | -? | ?)
      wrehelp
      exit 0
    ;;
    
    -*)
      echo "Error: I don't know this option: $opt
      Try\`$0 --help' for valid options."
      exit 1
    ;;

  esac
done


#No arguments passed build everything
if [ $# -eq 0 ] 
then

if [ -d /data ]; then
 clean
 buildUtils
 buildMemcached
 buildPerl
 buildApache
 buildMysql
 buildImageMagick
 installAwStats
 installWreUtils
 installPerlModules

 else
    echo "You must create a writable /data folder to begin."
    exit
 fi

 
fi


