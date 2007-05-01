#!/bin/bash

# error
checkError(){
   if [ $1 -ne 0 ];
   then
       echo "WRE ERROR: "$2" did not complete successfully."
       exit
   fi
}

printHeader(){
    echo 
    echo --------------------------------------------------
    echo Building $1
    echo --------------------------------------------------
    echo
}

# most programs build the same
# param 1: folder name
# param 2: configure params
# param 3: make install params

buildProgram() {
	cd $1
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
    fi	
	./configure --prefix=$WRE_ROOT/prereqs $2; checkError $? "$1 configure"
	make; checkError $? "$1 make"
	make install $3; checkError $? "$1 make install"
	cd ..	
}
                 
# utilities
buildUtils(){
    printHeader "Utilities"
	mkdir -p $WRE_ROOT/prereqs/bin
	cd source
	
	# lftp
	buildProgram "lftp-3.5.10" "" "exec_prefix=$WRE_ROOT/prereqs"

	# zlib
	buildProgram "zlib-1.2.3" "--shared"

	# openssl
	cd openssl-0.9.8e
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
    fi	
	./config --prefix=$WRE_ROOT/prereqs ; checkError $? "openssl configure"
	make; checkError $? "openssl make"
	make install; checkError $? "openssl make install"
	cd ..	

	# libtool
	buildProgram "libtool-1.5.22"

	# catdoc
	cd catdoc-0.94
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
        fi	
	./configure --prefix=$WRE_ROOT/prereqs --disable-wordview --without-wish --with-input=utf-8 --with-output=utf-8 --disable-charset-check --disable-langinfo; checkError $? "catdoc Configure"
	make; checkError $? "catdoc make"
	cd src
	make install; checkError $? "catdoc make install src"
	cd ../docs
	make install; checkError $? "catdoc make install docs"
	cd ../charsets
	make install; checkError $? "catdoc make install charsets"
	cd ../..

	# expat
	buildProgram "expat-2.0.0"

	# xpdf
	buildProgram "xpdf-3.02" "--without-x"

	# aspell
	buildProgram "aspell-0.60.5" "" "exec_prefix=$WRE_ROOT/prereqs"
	cd aspell-en-0.51-1
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
        fi	
	./configure --vars ASPELL=$WRE_ROOT/prereqs/bin/aspell WORD_LIST_COMPRESS=$WRE_ROOT/prereqs/bin/word-list-compress; checkError $? "aspell dictionary Configure"
	make; checkError $? "aspell dictionary make"
	make install; checkError $? "aspell dictionary make install"

	cd $WRE_BUILDDIR
}

# perl
buildPerl(){
	printHeader "Perl"
	mkdir -p $WRE_ROOT/prereqs/bin
	mkdir -p $WRE_ROOT/prereqs/man/man1
	mkdir -p $WRE_ROOT/prereqs/lib
	mkdir -p $WRE_ROOT/prereqs/include
	cd source/perl-5.8.8
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
        fi	
	./Configure -Dprefix=$WRE_ROOT/prereqs -des; checkError $? "Perl Configure" 
	make; checkError $? "Perl make"
	#make test; checkError $? "Perl make test"
	make install; checkError $? "Perl make install"
	cd $WRE_BUILDDIR
}


# apache
buildApache(){
	printHeader "Apache"
	mkdir -p $WRE_ROOT/prereqs/bin
	mkdir -p $WRE_ROOT/prereqs/man/man1
	mkdir -p $WRE_ROOT/prereqs/lib
	mkdir -p $WRE_ROOT/prereqs/include
	mkdir -p $WRE_ROOT/prereqs/conf

	# apache
	cd source/httpd-2.0.59
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
  		rm -Rf server/exports.c 
  		rm -Rf server/export_files
        fi	
	case $WRE_OSNAME in
		Linux)
			# insists upon using it's own zlib and ours, which won't work, so temporarily hiding ours
			mv $WRE_ROOT/prereqs/include/zlib.h $WRE_ROOT/prereqs/include/zlib.h.ignore
			;;
	esac
	./configure --prefix=$WRE_ROOT/prereqs --sysconfdir=$WRE_ROOT/etc --localstatedir=$WRE_ROOT/var --enable-rewrite=shared --enable-deflate=shared --enable-ssl --with-ssl=$WRE_ROOT/prereqs --enable-proxy=shared --with-mpm=prefork --enable-headers --disable-userdir --disable-imap --disable-negotiation --disable-actions; checkError $? "Apache Configure"
	make; checkError $? "Apache make"
	make install; checkError $? "Apache make install"
	case $WRE_OSNAME in
		Linux)
		mv $WRE_ROOT/prereqs/include/zlib.h.ignore $WRE_ROOT/prereqs/include/zlib.h
			;;
	esac

	# modperl
	cd ../mod_perl-2.0.3
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
        fi	
	perl Makefile.PL MP_APXS=$WRE_ROOT/prereqs/bin/apxs; checkError $? "mod_perl Configure"
	make; checkError $? "mod_perl make"
# The tests fail on all systems even on good builds
#	case $WRE_OSNAME in
#		Darwin | SunOS)
#			#tests fail for some reason even after a good build
#			;;
#		*)
#			make test; checkError $? "mod_perl make test"
#			;;
#	esac
	make install; checkError $? "mod_perl make install"
	cd $WRE_BUILDDIR
	echo "webgui/package   wgpkg" >> $WRE_ROOT/prereqs/conf/mime.types
}


# mysql
buildMysql(){
	printHeader "MySQL"
	mkdir -p $WRE_ROOT/prereqs/bin
	mkdir -p $WRE_ROOT/prereqs/man/man1
	mkdir -p $WRE_ROOT/prereqs/lib
	mkdir -p $WRE_ROOT/prereqs/libexec
	mkdir -p $WRE_ROOT/prereqs/include
	mkdir -p $WRE_ROOT/prereqs/var
	cd source/mysql-5.0.37
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
        fi	
	CC=gcc CFLAGS="-O3 -fno-omit-frame-pointer" CXX=g++ CXXFLAGS="-O3 -fno-omit-frame-pointer -felide-constructors -fno-exceptions -fno-rtti" ./configure --prefix=$WRE_ROOT/prereqs --sysconfdir=$WRE_ROOT/etc --localstatedir=$WRE_ROOT/var --with-extra-charsets=all --enable-thread-safe-client --enable-local-infile --disable-shared --enable-assembler --with-readline --without-debug --enable-large-files=yes --enable-largefile=yes --with-openssl=$WRE_ROOT/prereqs --with-unix-socket-path=$WRE_ROOT/prereqs/mysql.sock; checkError $? "MySQL Configure"
	make; checkError $? "MySQL make"
	make install; checkError $? "MySQL make install"
	cd $WRE_BUILDDIR
}


# Graphics Magick
buildGraphicsMagick(){
	printHeader "Graphics Magick"
	mkdir -p $WRE_ROOT/prereqs/bin
	mkdir -p $WRE_ROOT/prereqs/man/man1
	mkdir -p $WRE_ROOT/prereqs/lib
	mkdir -p $WRE_ROOT/prereqs/include

	# lib jpeg
	cd source/libjpeg-6b
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
        fi	
	./configure --enable-shared --prefix=$WRE_ROOT/prereqs; checkError $? "libjpeg Configure"
	perl -i -p -e's[./libtool][libtool]g' Makefile
	make; checkError $? "libjpeg make"
	make install; checkError $? "libjpeg make install"

	# lib xml
	buildProgram "libxml2-2.6.27"

	# freetype
	buildProgram "freetype-2.3.4" "--enable-shared"

	# lib ungif
	buildProgram "libungif-4.1.4" "--enable-shared"

	# lib png
	cd ../libpng-1.2.16
	if [ "$WRE_CLEAN" == 1 ]; then
		make distclean
  		make clean
        fi	
	case $WRE_OSNAME in
		SunOS)
			cp scripts/makefile.solaris Makefile
			;;
		*)
			cp scripts/makefile.`perl -e "print lc $WRE_OSNAME"` Makefile
			;;
	esac
	perl -i -p -e's[/usr/local][$WRE_ROOT/prereqs]g' Makefile
	make; checkError $? "Graphics Magick libpng make"
	make install; checkError $? "Graphics Magick libpng make install"

	# image magick
	buildProgram "GraphicsMagick-1.1.7" "--enable-delegate-build LDFLAGS='-L$WRE_ROOT/prereqs/lib' CPPFLAGS='-I$WRE_ROOT/prereqs/include' --enable-shared=yes --with-jp2=yes --with-jpeg=yes --with-png=yes --with-perl=yes --with-x=no"

	cd $WRE_BUILDDIR
}

# most perl modules are installed the same way
# param1: module directory
# param2: parameters to pass to Makefile.PL
installPerlModule() {
	cd $1
	perl Makefile.PL $2; checkError $? "$1 Makefile.PL"
	make; checkError $? "$1 make"
	make install; checkError $? "$1 make install"
	cd ..
}

#perl modules
installPerlModules(){
	printHeader "Perl Modules"
	cd source/perlmodules
	installPerlModule "Net_SSLeay.pm-1.25" "$WRE_ROOT/prereqs"
	installPerlModule "Compress-Zlib-1.39"
	installPerlModule "Proc-ProcessTable-0.40"
	installPerlModule "BSD-Resource-1.25"
	installPerlModule "URI-1.35"
	installPerlModule "IO-Zlib-1.04"
	installPerlModule "HTML-Tagset-3.10"
	installPerlModule "HTML-Parser-3.54"
	installPerlModule "libwww-perl-5.805" "-n"
	installPerlModule "CGI.pm-3.20"
	installPerlModule "Digest-HMAC-1.01"
	installPerlModule "Digest-MD5-2.36"
	installPerlModule "Digest-SHA1-2.11"
	installPerlModule "Module-Build-0.28"
	installPerlModule "Params-Validate-0.81"
	installPerlModule "DateTime-Locale-0.34"
	installPerlModule "Class-Singleton-1.03"
	installPerlModule "DateTime-TimeZone-0.6501"
	installPerlModule "Time-Local-1.12"
	installPerlModule "Test-Simple-0.70"
	installPerlModule "Devel-Symdump-2.06"
	installPerlModule "Pod-Escapes-1.04"
	installPerlModule "ExtUtils-CBuilder-0.18"
	installPerlModule "Pod-Coverage-0.17"
	installPerlModule "Pod-Simple-3.04"
	installPerlModule "podlators-2.0.4"
	installPerlModule "DateTime-0.37"
	installPerlModule "DateTime-Format-Strptime-1.0700"
	installPerlModule "HTML-Template-2.9"
	installPerlModule "Crypt-SSLeay-0.54"
	cd String-Random-0.21
	perl Build.PL; checkError $? "String::Random Makefile.PL"
	perl Build; checkError $? "String::Random make"
	perl Build install; checkError $? "String::Random make install"
	cd ..
	installPerlModule "Time-HiRes-1.9707"
	installPerlModule "Text-Balanced-1.97"
	installPerlModule "Tie-IxHash-1.21"
	installPerlModule "Tie-CPHash-1.02"
	installPerlModule "Error-0.15009"
	installPerlModule "HTML-Highlight-0.20"
	installPerlModule "HTML-TagFilter-1.03"
	installPerlModule "IO-String-1.08"
	installPerlModule "Archive-Tar-1.29"
	installPerlModule "Archive-Zip-1.16"
	installPerlModule "XML-NamespaceSupport-1.09"
	installPerlModule "XML-SAX-0.14"
	installPerlModule "XML-Simple-2.16"
	installPerlModule "XML-RSSLite-0.11"
	installPerlModule "SOAP-Lite-0.67" "--noprompt"
	installPerlModule "DBI-1.54"
	installPerlModule "DBD-mysql-4.004"
	installPerlModule "Convert-ASN1-0.20"
	installPerlModule "HTML-TableExtract-2.07"
	installPerlModule "Finance-Quote-1.13"
	installPerlModule "JSON-1.11"
	installPerlModule "Config-JSON-1.0.3"
	installPerlModule "IO-Socket-SSL-0.97"
	installPerlModule "perl-ldap-0.34"
	installPerlModule "Log-Log4perl-1.10"
	installPerlModule "POE-0.9989" "--default"
	installPerlModule "POE-Component-IKC-0.1904"
	installPerlModule "String-CRC32-1.4"
	installPerlModule "ExtUtils-XSBuilder-0.28"
	installPerlModule "trace-0.51"
	installPerlModule "Clone-0.20"
	installPerlModule "Test-Pod-1.24"
	installPerlModule "Data-Structure-Util-0.11"
	installPerlModule "Parse-RecDescent-1.94"
	cd libapreq2-2.08
	./configure --with-apache2-apxs=$WRE_ROOT/prereqs/bin/apxs --enable-perl-glue; checkError $? "libapreq2 configure"
	make; checkError $? "libapreq2 make"
	make install; checkError $? "libapreq2 make install"
	cd ..
	installPerlModule "Net-Subnets-0.21"
	installPerlModule "MailTools-1.74"
	installPerlModule "IO-stringy-2.110"
	installPerlModule "MIME-tools-5.420"
	installPerlModule "HTML-Template-Expr-0.07"
	installPerlModule "Template-Toolkit-2.14" "TT_ACCEPT=y TT_DOCS=n TT_SPLASH=n TT_THEME=n TT_EAMPLES=n TT_EXTRAS=n TT_XS_STASH=y TT_XS_DEFAULT=n TT_DBI=n TT_LATEX=n"
	installPerlModule "Scalar-List-Utils-1.18"
	installPerlModule "Graphics-ColorNames-1.06"
	installPerlModule "Module-Load-0.10"
	installPerlModule "Color-Calc-1.00"
	installPerlModule "DateTime-Format-Mail-0.2901"
	installPerlModule "Digest-BubbleBabble-0.01"
	installPerlModule "Net-IP-1.25"
	installPerlModule "Net-DNS-0.59"
	installPerlModule "POE-Component-Client-DNS-1.00"
	installPerlModule "POE-Component-Client-Keepalive-0.1000"
	installPerlModule "POE-Component-Client-HTTP-0.82"
	installPerlModule "Test-Deep-0.095"
	installPerlModule "Test-MockObject-1.06"
	installPerlModule "UNIVERSAL-isa-0.06"
	installPerlModule "UNIVERSAL-can-1.12"
	installPerlModule "Class-MakeMethods-1.01"
	installPerlModule "Locale-US-1.1"
	installPerlModule "Weather-Com-Finder-0.5.1"
	installPerlModule "Text-Aspell-0.06" 'PREFIX=$WRE_ROOT/prereqs/lib CCFLAGS=-I$WRE_ROOT/prereqs/include LIBS="-L$WRE_ROOT/prereqs/lib -laspell"'
	cd MySQL-Diff-0.33
	perl Makefile.PL; checkError $? "MySQL::Diff Makefile.PL"
	make; checkError $? "MySQL::Diff make"
	make install; checkError $? "MySQL::Diff make install"
	cp -f mysqldiff $WRE_ROOT/sbin/
	perl -i -p -e's[/usr/bin/perl][$WRE_ROOT/prereqs/bin/perl]g' $WRE_ROOT/sbin/mysqldiff
	cd $WRE_BUILDDIR
}


#awstats
installAwStats(){
	printHeader "AWStats"
	cp -RL source/awstats-6.6 $WRE_ROOT/prereqs
}

#wre utils
installWreUtils(){
	printHeader "WebGUI Runtime Environment Core and Utilities"
	cp -R wre /data/
	mkdir $WRE_ROOT/etc
}

#gooey
gooey() {
  printf '\x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x4d \x57 \xd0 \x57 \x57 \x57 \x4d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x40 \x23 \x23 \x35 \x35 \x35 \x35 \x35 \x35 \x23 \x23 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x57 \x23 \x23 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x35 \x40 \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x57 \x57 \x4d \x23 \x23 \x23 \x35 \x41 \x41 \x25 \x25 \x24 \x24 \x24 \x33 \x33 \x24 \x24 \x24 \x25 \x41 \x35 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x33 \x24 \x25 \x25 \x41 \x35 \x35 \x41 \x25 \x25 \x24 \x4a \x37 \x37 \x37 \x37 \x37 \x3d \x3d \x3d \x37 \x33 \x24 \x25 \x41 \x23 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x25 \x41 \x35 \x41 \x41 \x25 \x25 \x33 \x33 \x24 \x41 \x41 \x35 \x23 \x40 \x40 \x40 \x40 \x35 \x43 \x43 \x24 \x25 \x41 \x23 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x3d \x33 \x41 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x35 \x23 \x23 \x23 \x23 \x23 \x23 \x23 \x40 \xd0 \x57 \xd0 \x43 \x4a \x24 \x25 \x23 \x41 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x23 \x41 \x41 \x23 \x23 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x25 \x24 \x33 \x33 \x33 \x33 \x33 \x24 \x35 \x35 \x43 \x25 \x25 \x35 \x25 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x25 \x57 \xd0 \x40 \x40 \x35 \x35 \x41 \x41 \x41 \x41 \x25 \x41 \x33 \x37 \x4a \x24 \x25 \x41 \x41 \x41 \x33 \x2c \x24 \x41 \x24 \x25 \x41 \x35 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \xd0 \x23 \xd0 \x23 \x35 \x41 \x41 \x41 \x25 \x25 \x4a \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \x4a \x25 \x41 \x41 \x41 \x41 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \xa6 \x25 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x25 \x43 \x41 \x4d \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4a \x4a \x25 \x41 \x41 \x41 \x24 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x2e \x2c \x41 \xd0 \x40 \x35 \x41 \x41 \x41 \x25 \x43 \x35 \x20 \x40 \x43 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x43 \x33 \x25 \x41 \x41 \x25 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \x28 \x23 \xd0 \x23 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x57 \x2a \xa6 \x24 \x57 \x41 \x4d \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x41 \x25 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x43 \xd0 \x20 \x40 \x27 \x21 \x3d \x21 \xa6 \x4d \x20 \x20 \x20 \x40 \x37 \x24 \x25 \x25 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x35 \x41 \x40 \x40 \x23 \x41 \x41 \x41 \x24 \x43 \x20 \x20 \xa9 \x24 \xa6 \xa6 \x33 \x4d \x20 \x20 \x20 \xa9 \x4a \x33 \x24 \x24 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x35 \x23 \x25 \x40 \x40 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \x4a \x33 \x24 \x43 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x33 \x24 \x33 \xd0 \x40 \x35 \x41 \x41 \x25 \x33 \x33 \x20 \x20 \x20 \x20 \xa9 \x20 \x20 \x20 \x20 \xa9 \x35 \x4a \x33 \x33 \x33 \x57 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x40 \x57 \x23 \x35 \x41 \x25 \x24 \x24 \xa9 \x40 \x25 \x4a \x4a \x33 \x25 \x23 \xd0 \x41 \x4a \x33 \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x37 \x37 \xa9 \x20 \x20 \x4d \x33 \x3d \x28 \x41 \x4d \xd0 \x35 \x41 \x41 \x25 \x24 \x24 \x25 \x35 \x23 \x40 \xd0 \x40 \x23 \x41 \x24 \x33 \x25 \x3d \x35 \x25 \x41 \x35 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \xd0 \x21 \x37 \x41 \x20 \x20 \x4a \x4a \x23 \x25 \x43 \x40 \x4d \x40 \x35 \x41 \x41 \x41 \x35 \x35 \x35 \x23 \x23 \x23 \x23 \x35 \x35 \x25 \x25 \x25 \x3d \x24 \x25 \x41 \x23 \x35 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x35 \x28 \x40 \x4a \x43 \xa9 \x20 \x2c \x23 \x41 \x33 \x4a \x4a \x40 \x4d \xd0 \x23 \x35 \x41 \x41 \x25 \x25 \x25 \x41 \x41 \x41 \x41 \x24 \x33 \x24 \x25 \x24 \x3d \x33 \x24 \x41 \x40 \x33 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x4d \x43 \x37 \xd0 \xd0 \xa6 \x33 \xa9 \x20 \x2c \x41 \x24 \x4a \x33 \x33 \x4a \x41 \x57 \x57 \xd0 \x23 \x35 \x25 \x24 \x24 \x24 \x24 \x24 \x33 \x33 \x33 \x24 \x41 \x41 \x24 \x37 \x4a \x24 \x25 \x41 \x3d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \xa9 \xa6 \x25 \x57 \x40 \x24 \x21 \x23 \x20 \x20 \x2a \x24 \x4a \x33 \x41 \x25 \x33 \x4a \x43 \x24 \x41 \x35 \x23 \x40 \x41 \x25 \x24 \x33 \x33 \x33 \x4a \x4a \x24 \x41 \x35 \x35 \x35 \x33 \x37 \x4a \x24 \x3d \x41 \x20 \x20 \x20 \x57 \x23 \x20 \x20 \x0d \x0a \x23 \xa6 \x57 \x23 \x35 \x33 \xa6 \x4a \x57 \x23 \xa6 \x43 \x24 \x23 \x35 \x25 \x24 \x33 \x43 \x28 \x43 \x4a \x4a \x4a \x24 \x25 \x25 \x24 \x33 \x33 \x43 \x43 \x24 \x25 \x41 \x35 \x35 \x23 \x41 \x4a \x37 \x43 \xa6 \x20 \x20 \x20 \xd0 \x21 \x35 \x20 \x0d \x0a \x25 \x3d \x23 \x23 \x35 \x35 \x28 \x3d \x3d \xa6 \x43 \x25 \x40 \x23 \x41 \x25 \x24 \x4a \x28 \x33 \x25 \x24 \x24 \x25 \x25 \x25 \x25 \x24 \x33 \x37 \x2a \x3d \x24 \x25 \x41 \x41 \x35 \x35 \x23 \x23 \x25 \x3d \x27 \x40 \x20 \x20 \x41 \x4a \x43 \xa9 \x0d \x0a \xd0 \xa6 \x25 \x41 \x41 \x35 \x35 \x41 \x41 \x40 \x40 \x40 \x23 \x35 \x41 \x24 \x4a \x3d \x4a \x35 \x41 \x25 \x25 \x41 \x41 \x25 \x24 \x24 \x43 \x27 \x3d \x43 \x4a \x33 \x24 \x25 \x41 \x41 \x35 \x23 \x40 \x23 \x43 \xa6 \x41 \x33 \x3d \x40 \x33 \x4d \x0d \x0a \x20 \x28 \x4a \x24 \x25 \x41 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x25 \x25 \x33 \x4a \xa6 \x23 \x23 \x41 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x21 \x21 \x21 \x37 \x43 \x4a \x33 \x25 \x25 \x41 \x35 \x23 \x40 \xd0 \x24 \x2a \x43 \x24 \x25 \x25 \x20 \x0d \x0a \x20 \x57 \x28 \x4a \x33 \x24 \x25 \x41 \x41 \x41 \x25 \x24 \x24 \x24 \x33 \x33 \x4a \x28 \xd0 \x23 \x35 \x41 \x41 \x41 \x41 \x25 \x24 \x4a \x2c \x24 \x24 \x4a \xa6 \x21 \xa6 \x3d \x43 \x33 \x24 \x25 \x41 \x35 \x23 \xd0 \x35 \x28 \x24 \x40 \x20 \x20 \x0d \x0a \x20 \x20 \xd0 \x43 \x37 \x33 \x33 \x33 \x24 \x24 \x33 \x33 \x33 \x33 \x33 \x33 \x41 \x24 \x40 \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x24 \x3d \x37 \x35 \x23 \x41 \x24 \x4a \x3d \xa6 \x21 \xa6 \x43 \x33 \x24 \x41 \x35 \x23 \x57 \x35 \x4a \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x57 \x41 \x25 \x24 \x24 \x24 \x25 \x25 \x35 \x23 \xd0 \xa9 \x20 \xa9 \x4a \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x23 \xa9 \x23 \x23 \x35 \x25 \x24 \x33 \x4a \x35 \x37 \x28 \x37 \x24 \x25 \x35 \x40 \x4d \x25 \x41 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x24 \x41 \x25 \x24 \x41 \x41 \x41 \x24 \x33 \x2a \x57 \x20 \xa9 \x41 \x35 \x41 \x25 \x24 \x43 \x4d \xa9 \x40 \x37 \x28 \x24 \x41 \x35 \xd0 \x4d \x3d \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x37 \x24 \xa6 \x35 \x35 \x41 \x24 \x24 \x2c \xa9 \x20 \x20 \x57 \x37 \x25 \x24 \x33 \x43 \x20 \x20 \x20 \x20 \x25 \xa6 \x25 \x35 \x40 \x4d \x4a \xd0 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x4a \x57 \xa9 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x23 \x35 \x41 \x41 \x25 \x2c \x4d \x57 \x41 \x3d \x4a \x33 \x4a \x4a \x57 \x20 \x20 \x20 \x20 \x20 \x4a \x43 \x35 \x23 \x57 \x4a \x40 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x3d \x43 \x25 \x23 \xa9 \x20 \xa9 \x23 \x4a \xd0 \x23 \x35 \x35 \x35 \x41 \x2c \x41 \x3d \x28 \x43 \x33 \x25 \x23 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x23 \x28 \x35 \xd0 \x57 \x3d \xa9 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x43 \x35 \x40 \x25 \x24 \x25 \x23 \xd0 \x40 \x35 \x35 \x35 \x23 \x33 \x37 \xa9 \xa9 \xa9 \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x33 \x25 \x43 \x24 \xd0 \xd0 \x4a \x23 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x4a \x41 \x4d \x57 \x57 \xd0 \x23 \x35 \x35 \x23 \x23 \x33 \x3d \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \xa6 \x43 \x41 \x24 \x33 \x23 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x41 \x4a \x41 \x23 \x40 \x23 \x23 \x35 \x25 \x43 \x24 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x40 \x23 \x57 \xa9 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x24 \x4a \x43 \x43 \x33 \x41 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x0d \x0a';
  cat wre/wre/docs/credits.txt
  return 0;
}

buildAll() {
	if [ -d /data ]; then
 		buildUtils
 		buildPerl
 		buildApache
 		buildMysql
 		buildGraphicsMagick
 		installAwStats
 		installWreUtils
 		installPerlModules
 	else
    		echo "You must create a writable /data folder to begin."
 	fi
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
           ./build.sh --all            #build all

  --clean        cleans all pre-req folders for a new build
  --utilities	 compiles and installs shared utilities
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
. wre/sbin/setenvironment.sh
export WRE_BUILDDIR=`pwd`
export WRE_OSNAME=`uname -s`
export WRE_ROOT=/data/wre

#Evaluate options passed by command line
for opt in "$@"
do

  #get any argument passed with this option
  arg=`expr "x$opt" : 'x[^=]*=\(.*\)'`

  case "$opt" in
 
    --clean)
      export WRE_CLEAN=1
    ;;

    --all)
	buildAll
	exit 0
    ;;
 
    --utils | --utilities)
      buildUtils
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
    
    --graphicsMagick | --graphicsmagick)
      buildGraphicsMagick
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
if [ $# -eq 0 ]; then
	wrehelp
fi



