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
# param 4: compiler flags

buildProgram() {
	cd $1
    printHeader $1
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
  		$WRE_MAKE clean
    fi	
    echo "Configuring $1 with GNUMAKE=$WRE_MAKE $4 ./configure --prefix=$WRE_ROOT/prereqs LDFLAGS=-L$WRE_ROOT/prereqs/lib CPPFLAGS=-I$WRE_ROOT/prereqs/include $2"
	GNUMAKE=$WRE_MAKE $4 ./configure --prefix=$WRE_ROOT/prereqs LDFLAGS=-L$WRE_ROOT/prereqs/lib CPPFLAGS=-I$WRE_ROOT/prereqs/include $2; checkError $? "$1 configure"
	$WRE_MAKE; checkError $? "$1 make"
	$WRE_MAKE install $3; checkError $? "$1 make install"
	cd ..	
}

# utilities
buildUtils(){
    printHeader "Utilities"
	cd source
	
    # libtool
    buildProgram "libtool-2.2.6"

    # openssl
    cd openssl-0.9.8l 
    printHeader "openssl"
    if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
 		$WRE_MAKE clean
    fi	
    if [ "$WRE_IA64" == 1 ]; then
	    # this may be safe for all options, but 32-bit versions don't need it, and 64-bit ones do
	    SSLCFGOPTS="CFLAGS=\"-fPIC\" CXXFLAGS=\"-fPIC\" "
    fi
	$SSLCFGOPTS ./config --prefix=$WRE_ROOT/prereqs shared; checkError $? "openssl configure"
	$WRE_MAKE; checkError $? "openssl make"
	$WRE_MAKE install; checkError $? "openssl make install"
	cd ..	

    # ncurses
    buildProgram "ncurses-5.7" "--with-shared"

    # zlib
    buildProgram "zlib-1.2.3" "--shared"

    # rsync
    buildProgram "rsync-3.0.6"

    # libiconv
    if [ "$WRE_OSNAME" != "Darwin" ] && [ "$WRE_OSTYPE" != "Leopard" ]; then
        buildProgram "libiconv-1.13"
    fi

    # libgpg-error
    buildProgram "libgpg-error-1.7"

    # libgcrypt
    buildProgram "libgcrypt-1.4.4"

    # gnutls
    buildProgram "gnutls-2.8.5"

    # expat
    buildProgram "expat-2.0.1"

    # lib xml
    buildProgram "libxml2-2.7.6"

    # readline
    buildProgram "readline-6.0"

    # lftp
    buildProgram "lftp-3.7.15" "--with-libiconv-prefix=$WRE_ROOT/prereqs --with-openssl=$WRE_ROOT/prereqs" "" "env CFLAGS=-I$WRE_ROOT/prereqs/include CPPFLAGS=-I$WRE_ROOT/prereqs/include LDFLAGS=-L$WRE_ROOT/prereqs/lib"
    
	# catdoc
	cd catdoc-0.94.2
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
  		$WRE_MAKE clean
     fi	
	./configure --prefix=$WRE_ROOT/prereqs --disable-wordview --without-wish --with-input=utf-8 --with-output=utf-8 --disable-charset-check --disable-langinfo; checkError $? "catdoc Configure"
	$WRE_MAKE; checkError $? "catdoc make"
	cd src
	$WRE_MAKE install; checkError $? "catdoc make install src"
	cd ../docs
	$WRE_MAKE install; checkError $? "catdoc make install docs"
	cd ../charsets
	$WRE_MAKE install; checkError $? "catdoc make install charsets"
	cd ../..

	# xpdf
	buildProgram "xpdf-3.02" "--without-x"

	# curl
	buildProgram "curl-7.19.7" "--with-ssl=$WRE_ROOT/prereqs --with-zlib=$WRE_ROOT/prereqs --with-gnutls=$WRE_ROOT/prereqs --with-libssh2$WRE_ROOT/prereqs"

	cd $WRE_BUILDDIR
}

# perl
buildPerl(){
	printHeader "Perl"
	cd source/perl-5.10.1
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
  		$WRE_MAKE clean
    fi	
    if [ "$WRE_IA64" == 1]; then
        # this may be safe for all options, but 32-bit versions don't need it, and 64-bit ones do
        PERLCFGOPTS="-Accflags=\"-fPIC\""
    fi
	./Configure -Dprefix=$WRE_ROOT/prereqs -des $PERLCFGOPTS; checkError $? "Perl Configure" 
	$WRE_MAKE; checkError $? "Perl make"
	$WRE_MAKE install; checkError $? "Perl make install"
	cd $WRE_BUILDDIR
}

# git
buildGit(){
	printHeader "Git"
	cd source/git-1.6.5.3
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
  		$WRE_MAKE clean
	fi
	./configure --prefix=$WRE_ROOT/prereqs --with-zlib=$WRE_ROOT/prereqs --with-perl=$WRE_ROOT/prereqs LDFLAGS=-L$WRE_ROOT/prereqs/lib CPPFLAGS=-I$WRE_ROOT/prereqs/include ; checkError $? "Git Configure"
	$WRE_MAKE; checkError $? "Git make"
	$WRE_MAKE install; checkError $? "Git make install"
	cd $WRE_BUILDDIR
}


# apache
buildApache(){
	printHeader "Apache"
    cd source

	# apache
	cd httpd-2.2.14
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
 		$WRE_MAKE clean
  		rm -Rf server/exports.c 
  		rm -Rf server/export_files
    fi	
	./configure --prefix=$WRE_ROOT/prereqs --with-included-apr --with-z=$WRE_ROOT/prereqs --sysconfdir=$WRE_ROOT/etc --localstatedir=$WRE_ROOT/var --enable-rewrite=shared --enable-deflate=shared --enable-ssl --with-ssl=$WRE_ROOT/prereqs --enable-proxy=shared --with-mpm=prefork --enable-headers --disable-userdir --disable-imap --disable-negotiation --disable-actions --enable-expires=shared; checkError $? "Apache Configure"
    if [ "$WRE_OSNAME" == "Darwin" ] && [ "$WRE_OSTYPE" == "Leopard" ]; then
        $WRE_ROOT/prereqs/bin/perl -i -p -e's[#define APR_HAS_SENDFILE          1][#define APR_HAS_SENDFILE          0]g' srclib/apr/include/apr.h
    fi
	$WRE_MAKE; checkError $? "Apache make"
	$WRE_MAKE install; checkError $? "Apache make install"
    rm -f $WRE_ROOT/etc/highperformance-std.conf
    rm -f $WRE_ROOT/etc/highperformance.conf
    rm -f $WRE_ROOT/etc/httpd-std.conf 
    rm -f $WRE_ROOT/etc/httpd.conf 
    rm -f $WRE_ROOT/etc/ssl-std.conf
    rm -f $WRE_ROOT/etc/ssl.conf

	# modperl
	cd ../mod_perl-2.0.4
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
  		$WRE_MAKE clean
    fi	
	perl Makefile.PL MP_APXS=$WRE_ROOT/prereqs/bin/apxs; checkError $? "mod_perl Configure"
	$WRE_MAKE; checkError $? "mod_perl make"
	$WRE_MAKE install; checkError $? "mod_perl make install"
    cd ..

	cd $WRE_BUILDDIR
}


# mysql
buildMysql(){
	printHeader "MySQL"
	cd source/mysql-5.0.87
	if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
    fi	
    if [ "$WRE_IA64" == 1 ]; then
        # this may be safe for all options, but 32-bit versions don't need it, and 64-bit ones do
        MYSQLCFGOPTS="-fPIC"
    fi
    if [ "$WRE_OSNAME" == "Linux" ]; then
        MYSQLBUILDOPTS="--with-named-curses-libs=$WRE_ROOT/prereqs/lib/libncurses.so"
    fi
      CC=gcc CFLAGS="-O3 $MYSQLCFGOPTS -fno-omit-frame-pointer" CXX=g++ CXXFLAGS="-O3 $MYSQLCFGOPTS -fno-omit-frame-pointer -felide-constructors -fno-exceptions -fno-rtti" ./configure --prefix=$WRE_ROOT/prereqs --sysconfdir=$WRE_ROOT/etc --localstatedir=$WRE_ROOT/var/mysqldata --with-extra-charsets=all --enable-thread-safe-client --enable-local-infile --disable-shared --enable-assembler --with-readline --without-debug --enable-largefile=yes --with-ssl --with-mysqld-user=webgui --with-unix-socket-path=$WRE_ROOT/var/mysqldata/mysql.sock --without-docs --without-man $MYSQLBUILDOPTS; checkError $? "MySQL Configure"
        echo $WRE_MAKE
	$WRE_MAKE; checkError $? "MySQL make"
	$WRE_MAKE install; checkError $? "MySQL make install"
	cd $WRE_BUILDDIR
}


# Image Magick
buildImageMagick(){
    printHeader "Image Magick"
    cd source

    # lib jpeg
    cd libjpeg-7
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
  	    $WRE_MAKE clean
    fi	
    ./configure --enable-shared --prefix=$WRE_ROOT/prereqs; checkError $? "libjpeg Configure"
#    $WRE_ROOT/prereqs/bin/perl -i -p -e's[./libtool][libtool]g' Makefile
    $WRE_MAKE; checkError $? "libjpeg make"
    $WRE_MAKE install; checkError $? "libjpeg make install"
    cd ..

    # freetype
    buildProgram "freetype-2.3.11" "--enable-shared"

    # lib ungif
    buildProgram "giflib-4.1.6" "--enable-shared"

    # tiff 
    buildProgram "tiff-3.8.2" "--enable-shared"

    # lib png
    buildProgram "libpng-1.2.35" "LDFLAGS=-L$WRE_ROOT/prereqs/lib CPPFLAGS=-I$WRE_ROOT/prereqs/include --enable-shared"

    # lcms 
    buildProgram "lcms-1.18" "--enable-shared"

    # graphviz
    buildProgram "graphviz-2.24.0" "--enable-static --enable-shared --with-libgd=no --with-mylibgd=no --disable-java --disable-swig --disable-perl --disable-python --disable-php --disable-ruby --disable-sharp --disable-python23 --disable-python24 --disable-python25 --disable-r --disable-tcl --disable-guile --disable-io --disable-lua --disable-ocaml"
    ln -s $WRE_ROOT/prereqs/bin/dot_static $WRE_ROOT/prereqs/bin/dot 


    # image magick
   
    WRE_IM_VERSION=6.5.7-10
    cd ImageMagick-$WRE_IM_VERSION
    printHeader "Image Magick"
    if [ "$WRE_CLEAN" == 1 ]; then
		$WRE_MAKE distclean
  		$WRE_MAKE clean
    fi	
    case "$WRE_OSNAME" in
        FreeBSD | OpenBSD)
            export IM_OPTION="--without-threads"
        ;;
    esac 
    GNUMAKE=$WRE_MAKE ./configure LD=ld --prefix=$WRE_ROOT/prereqs --enable-delegate-build LDFLAGS=-L$WRE_ROOT/prereqs/lib CPPFLAGS=-I$WRE_ROOT/prereqs/include --enable-shared --with-gvc --with-jp2 --with-jpeg --with-png --with-perl --with-lcms --with-tiff --without-x GVC_CFLAGS=-I$WRE_ROOT/prereqs/include/graphviz GVC_LIBS="-L$WRE_ROOT/prereqs/lib -lgvc -lgraph -lcdt" $IM_OPTION; checkError $? "Image Magick configure"
    if [ "$WRE_OSNAME" == "Darwin" ]; then
        # technically this is only for Darwin i386, but i don't know how to detect that
        $WRE_ROOT/prereqs/bin/perl -i -p -e's[\#if defined\(PNG_USE_PNGGCCRD\) \&\& defined\(PNG_ASSEMBLER_CODE_SUPPORTED\) \\][#if FALSE]g' coders/png.c
    fi
    $WRE_MAKE; checkError $? "Image Magick make"
    $WRE_MAKE install; checkError $? "Image Magick make install"

    cd $WRE_BUILDDIR
    cp source/colors.xml $WRE_ROOT/prereqs/lib/ImageMagick-$WRE_IM_VERSION/config/
}

# most perl modules are installed the same way
# param1: module directory
# param2: parameters to pass to Makefile.PL
installPerlModule() {
	cd $1
    printHeader "PM $1"
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi   
	perl Makefile.PL $2; checkError $? "$1 Makefile.PL"
	$WRE_MAKE; checkError $? "$1 make"
	$WRE_MAKE install; checkError $? "$1 make install"
	cd ..
}

# some other perl modules are installed the same way
# param1: module directory
# param2: parameters to pass to Makefile.PL
buildPerlModule() {
	cd $1
    printHeader "PM $1"
    if [ "$WRE_CLEAN" == 1 ]; then
        perl Build clean
    fi   
	perl Build.PL $2; checkError $? "$1 Build.PL"
	perl Build; checkError $? "$1 Build"
	perl Build install; checkError $? "$1 Build install"
	cd ..
}

#perl modules
installPerlModules(){
	printHeader "Perl Modules"
	cd source/perlmodules
    export PERL_MM_USE_DEFAULT=1 # makes it so perl modules don't ask questions
	installPerlModule "Net_SSLeay.pm-1.30" "$WRE_ROOT/prereqs"
    installPerlModule "Compress-Raw-Zlib-2.015" # on upgrade modify config.in to point to our libs
    installPerlModule "IO-Compress-Base-2.015"
    installPerlModule "IO-Compress-Zlib-2.015"
	installPerlModule "Compress-Zlib-2.015"  
    if [ "$WRE_OSTYPE" != "Leopard" ]; then
	    installPerlModule "Proc-ProcessTable-0.44"
    fi
	installPerlModule "BSD-Resource-1.2902"
	installPerlModule "URI-1.51"
	installPerlModule "IO-Zlib-1.09"
	installPerlModule "HTML-Tagset-3.20"
	installPerlModule "HTML-Parser-3.64"
	installPerlModule "libwww-perl-5.834" "-n"
	installPerlModule "CGI.pm-3.42"
	installPerlModule "Digest-HMAC-1.01"
	installPerlModule "Digest-MD5-2.39"
	installPerlModule "Digest-SHA1-2.12"
	installPerlModule "Module-Build-0.31012"
	installPerlModule "Params-Validate-0.91"
	installPerlModule "DateTime-Locale-0.42"
	installPerlModule "Class-Singleton-1.4"
	installPerlModule "DateTime-TimeZone-0.84"
	installPerlModule "Time-Local-1.1901"
	installPerlModule "Test-Simple-0.94"
	installPerlModule "Devel-Symdump-2.08"
	installPerlModule "Pod-Escapes-1.04"
	installPerlModule "ExtUtils-CBuilder-0.24"
	installPerlModule "Pod-Coverage-0.19"
	installPerlModule "Pod-Simple-3.10"
	installPerlModule "podlators-2.2.2"
	installPerlModule "DateTime-0.4501"
	installPerlModule "DateTime-Format-Strptime-1.0800"
	installPerlModule "HTML-Template-2.9"
	installPerlModule "Crypt-SSLeay-0.57" "--lib=$WRE_ROOT/prereqs CCFLAGS=-I$WRE_ROOT/prereqs/include" # on upgrade mod Makefile.PL to remove network tests
	buildPerlModule "String-Random-0.22"
	installPerlModule "Time-HiRes-1.9719"
	installPerlModule "Text-Balanced-v2.0.0"
	installPerlModule "Tie-IxHash-1.21"
	installPerlModule "Tie-CPHash-1.04"
	installPerlModule "Error-0.17015"
	installPerlModule "HTML-Highlight-0.20"
	installPerlModule "HTML-TagFilter-1.03"
	installPerlModule "IO-String-1.08"
	installPerlModule "Archive-Tar-1.44"
	installPerlModule "Archive-Zip-1.26"
	installPerlModule "XML-NamespaceSupport-1.09"
    installPerlModule "XML-Parser-2.36" "EXPATLIBPATH=$WRE_ROOT/prereqs/lib EXPATINCPATH=$WRE_ROOT/prereqs/include"
	installPerlModule "XML-SAX-0.96"
	installPerlModule "XML-SAX-Expat-0.40"
	installPerlModule "XML-Simple-2.18"
	installPerlModule "XML-RSSLite-0.11"
	installPerlModule "SOAP-Lite-0.710.08" "--noprompt"
	installPerlModule "DBI-1.607"
	installPerlModule "DBD-mysql-4.010"
	installPerlModule "Convert-ASN1-0.22"
	installPerlModule "HTML-TableExtract-2.10"
	installPerlModule "HTML-Tree-3.23"
	installPerlModule "Finance-Quote-1.17"
	installPerlModule "JSON-XS-2.26"
	installPerlModule "JSON-2.12"
    installPerlModule "version-0.76"
    installPerlModule "Path-Class-0.16"
	installPerlModule "Config-JSON"
	installPerlModule "IO-Socket-SSL-1.22"
	installPerlModule "Text-Iconv-1.7" "LIBS='-L$WRE_ROOT/prereqs/lib' INC='-I$WRE_ROOT/prereqs/include'"
	installPerlModule "XML-Filter-BufferText-1.01"
	installPerlModule "XML-SAX-Writer-0.52"
    export AUTHEN_SASL_VERSION="Authen-SASL-2.12"
    $WRE_ROOT/prereqs/bin/perl -ni -e 'print unless /GSSAPI mechanism/ .. /\],/' $AUTHEN_SASL_VERSION/Makefile.PL
	installPerlModule $AUTHEN_SASL_VERSION
    export LDAP_VERSION="perl-ldap-0.39"
    $WRE_ROOT/prereqs/bin/perl -i -p -e"s[check_module\('Authen::SASL', 2.00\) or print <<\"EDQ\",\"\\\n\";][print <<\"EDQ\",\"\\\n\";]g" $LDAP_VERSION/Makefile.PL
    $WRE_ROOT/prereqs/bin/perl -i -nl -e"print unless /'SASL authentication' => \[/../\],/" $LDAP_VERSION/Makefile.PL
	installPerlModule $LDAP_VERSION
	installPerlModule "Log-Log4perl-1.20"
	installPerlModule "POE-1.280" "--default"
	installPerlModule "POE-Component-IKC-0.2002"
	installPerlModule "String-CRC32-1.4"
	installPerlModule "ExtUtils-XSBuilder-0.28"
    installPerlModule "ExtUtils-MakeMaker-6.48"
	installPerlModule "trace-0.551" # TODO: replace by Devel::XRay
	installPerlModule "Clone-0.31"
	installPerlModule "Test-Pod-1.26"
	installPerlModule "Parse-RecDescent-1.96.0"
    printHeader "libaqpreq2"
	cd libapreq2-2.08
	./configure --with-apache2-apxs=$WRE_ROOT/prereqs/bin/apxs --enable-perl-glue; checkError $? "libapreq2 configure"
	$WRE_MAKE; checkError $? "libapreq2 make"
	$WRE_MAKE install; checkError $? "libapreq2 make install"
	cd ..
	installPerlModule "Net-CIDR-Lite-0.20"
	installPerlModule "MailTools-2.04"
	installPerlModule "IO-stringy-2.110"
	installPerlModule "MIME-tools-5.427"
	installPerlModule "HTML-Template-Expr-0.07"
	installPerlModule "Template-Toolkit-2.22" "TT_ACCEPT=y TT_DOCS=n TT_SPLASH=n TT_THEME=n TT_EAMPLES=n TT_EXTRAS=n TT_XS_STASH=y TT_XS_DEFAULT=n TT_DBI=n TT_LATEX=n"
	installPerlModule "Scalar-List-Utils-1.19"
	installPerlModule "Graphics-ColorNames-2.11"
	installPerlModule "Module-Load-0.16"
	installPerlModule "Color-Calc-1.05"
	installPerlModule "DateTime-Format-Mail-0.3001"
	installPerlModule "Digest-BubbleBabble-0.01"
	installPerlModule "Net-IP-1.25"
	installPerlModule "Net-DNS-0.65" "--noonline-tests"
	installPerlModule "POE-Component-Client-DNS-1.051"
	installPerlModule "POE-Component-Client-Keepalive-0.262"
	installPerlModule "POE-Component-Client-HTTP-0.892"
	installPerlModule "Test-Deep-0.103"
	installPerlModule "Test-MockObject-1.09"
	buildPerlModule "UNIVERSAL-isa-1.03"
	buildPerlModule "UNIVERSAL-can-1.15"
	installPerlModule "Class-MakeMethods-1.01"
	installPerlModule "Locale-US-1.2"
	installPerlModule "Time-Format-1.09"
	installPerlModule "Weather-Com-0.5.3"
	installPerlModule "File-Slurp-9999.13"
	installPerlModule "Text-CSV_XS-0.69"
	installPerlModule "File-Temp-0.21"
	installPerlModule "File-Path-2.07"
	installPerlModule "File-Which-0.05"
	installPerlModule "Class-InsideOut-1.09"
	installPerlModule "HTML-TagCloud-0.34"
	installPerlModule "Set-Infinite-0.63"
	installPerlModule "DateTime-Set-0.26"
	installPerlModule "DateTime-Event-Recurrence-0.16"
	installPerlModule "DateTime-Event-ICal-0.09"
	installPerlModule "MIME-Types-1.27"
	installPerlModule "File-MMagic-1.27"
	buildPerlModule "PathTools-3.29"
	installPerlModule "Module-Find-0.06"
	buildPerlModule "Archive-Any-0.0932"
	installPerlModule "Image-ExifTool-8.00"
	# aspell
    cd ..
	buildProgram "aspell-0.60.6" "" "exec_prefix=$WRE_ROOT/prereqs"
    cd aspell6-en-6.0-0
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi  
    ./configure --vars ASPELL=$WRE_ROOT/prereqs/bin/aspell WORD_LIST_COMPRESS=$WRE_ROOT/prereqs/bin/word-list-compress; checkError $? "aspell-en configure"
    $WRE_MAKE; checkError $? "aspell-en make"
    $WRE_MAKE install ; checkError $? "aspell-en make install"
    cd ../perlmodules
	installPerlModule "Text-Aspell-0.09" "PREFIX=$WRE_ROOT/prereqs CCFLAGS=-I$WRE_ROOT/prereqs/include"
    # back to perl modules
	cd MySQL-Diff-0.33
	perl Makefile.PL; checkError $? "MySQL::Diff Makefile.PL"
	$WRE_MAKE; checkError $? "MySQL::Diff make"
	$WRE_MAKE install; checkError $? "MySQL::Diff make install"
	cp -f mysqldiff $WRE_ROOT/sbin/
	perl -i -p -e's[/usr/bin/perl][$WRE_ROOT/prereqs/bin/perl]g' $WRE_ROOT/sbin/mysqldiff
    cd ..
    installPerlModule "List-MoreUtils-0.22"
    installPerlModule "Scalar-List-Utils-1.19"
    buildPerlModule "Devel-StackTrace-1.20"
    installPerlModule "Class-Data-Inheritable-0.08"
    installPerlModule "Exception-Class-1.26"
    installPerlModule "Algorithm-C3-0.07"
    installPerlModule "Class-C3-XS-0.11"
    installPerlModule "Class-C3-0.21"
    installPerlModule "XML-TreePP-0.38"
    installPerlModule "XML-FeedPP-0.40"
    installPerlModule "Sub-Uplevel-0.2002"
    installPerlModule "Readonly-1.03"
    installPerlModule "Carp-Assert-0.20"
    installPerlModule "Test-Exception-0.27"
    installPerlModule "Carp-Assert-More-1.12"
    installPerlModule "HTTP-Server-Simple-0.38"
    installPerlModule "Test-LongString-0.11"
    installPerlModule "HTTP-Response-Encoding-0.05"
    installPerlModule "Array-Compare-2.01"
    installPerlModule "Tree-DAG_Node-1.06"
    installPerlModule "Test-Warn-0.11"
    installPerlModule "Devel-Cycle-1.10"
    installPerlModule "PadWalker-1.7"
    installPerlModule "Test-Memory-Cycle-1.04"
    installPerlModule "Test-Taint-1.04"
    installPerlModule "WWW-Mechanize-1.54"
    installPerlModule "Test-WWW-Mechanize-1.24"
    installPerlModule "Test-JSON-0.06"
    installPerlModule "IPC-Run-0.82"
    installPerlModule "GraphViz-2.04"
    installPerlModule "Class-Member-1.6"
    # detecting shared memory properly on 2.6 kernels
    if [ "$WRE_OSNAME" == "Linux" ]; then
        installPerlModule "Linux-Smaps-0.06" 
    fi
    # 7.7.5
    installPerlModule "HTML-Packer-0.4"
    installPerlModule "JavaScript-Packer-0.02"
    installPerlModule "CSS-Packer-0.2"
    # 7.7.6
    installPerlModule "Business-Tax-VAT-Validation-0.20"
    installPerlModule "Scope-Guard-0.03"
    # 7.7.7
    installPerlModule "Digest-SHA-5.47"
    installPerlModule "JavaScript-Minifier-XS-0.05"
    installPerlModule "CSS-Minifier-XS-0.03" 
    installPerlModule "Test-Class-0.31"
    # payment modules
    installPerlModule "Crypt-OpenSSL-Random-0.04" "PREFIX=$WRE_ROOT/prereqs CCFLAGS=-I$WRE_ROOT/prereqs/include LIBS='-L$WRE_ROOT/prereqs/lib'"
    installPerlModule "Crypt-OpenSSL-RSA-0.26" "PREFIX=$WRE_ROOT/prereqs CCFLAGS=-I$WRE_ROOT/prereqs/include LIBS='-L$WRE_ROOT/prereqs/lib'"
    installPerlModule "Crypt-CBC-2.30"
    installPerlModule "YAML-0.68"
    installPerlModule "Math-BigInt-FastCalc-0.19"
    installPerlModule "Crypt-DH-0.06"
    installPerlModule "LWPx-ParanoidAgent-1.04"
    installPerlModule "Net-OpenID-Consumer-1.03"
    installPerlModule "Crypt-RC4-2.02"
    installPerlModule "Text-PDF-0.29"
    installPerlModule "CAM-PDF-1.52"
    installPerlModule "Text-Diff-HTML-0.06"
    installPerlModule "Locales-0.13"
    installPerlModule "Test-Harness-3.17"
    # App-Nopaste
    installPerlModule "Params-Util-1.00"
    installPerlModule "Sub-Install-0.925"
    installPerlModule "Data-OptList-0.104"
    installPerlModule "Sub-Exporter-0.982"
    installPerlModule "Devel-GlobalDestruction-0.02"
    installPerlModule "MRO-Compat-0.11"
    installPerlModule "Sub-Name-0.04"
    installPerlModule "Task-Weaken-1.03"
    installPerlModule "Try-Tiny-0.02"
    installPerlModule "Class-MOP-0.95"
    installPerlModule "Moose-0.93"
    installPerlModule "Getopt-Long-Descriptive-0.081"
    installPerlModule "MooseX-Getopt-0.25"
    installPerlModule "WWW-Pastebin-PastebinCom-Create-0.002"
    installPerlModule "Class-Data-Accessor-0.04004"
    installPerlModule "WWW-Pastebin-RafbNet-Create-0.001"
    installPerlModule "Spiffy-0.30"
    installPerlModule "Clipboard-0.09"
    installPerlModule "Mixin-Linewise-0.002"
    installPerlModule "Config-INI-0.014"
    installPerlModule "App-Nopaste-0.17"

	cd $WRE_BUILDDIR
}


#awstats
installAwStats(){
	printHeader "AWStats"
	cp -RL source/awstats-6.95/* $WRE_ROOT/prereqs/
}

#wre utils
installWreUtils(){
	printHeader "WebGUI Runtime Environment Core and Utilities"
	cp -Rf wre /data/
    if [ ! -d "$WRE_ROOT/etc" ]; then
	    mkdir $WRE_ROOT/etc
    fi
}

# make the WRE distro smaller by getting rid of non-essential stuff
makeItSmall(){
    printHeader "Making WRE smaller"
    rm -Rf $WRE_ROOT/prereqs/man
    rm -Rf $WRE_ROOT/prereqs/manual
    rm -Rf $WRE_ROOT/prereqs/sql-bench
    rm -Rf $WRE_ROOT/prereqs/mysql-test
    rm -Rf $WRE_ROOT/prereqs/README.TXT
    rm -Rf $WRE_ROOT/prereqs/docs
    rm -Rf $WRE_ROOT/prereqs/share/doc
    rm -Rf $WRE_ROOT/prereqs/share/gtk-doc
    rm -Rf $WRE_ROOT/prereqs/share/man
    rm -Rf $WRE_ROOT/prereqs/share/ImageMagick*
    rm -Rf $WRE_ROOT/etc/original
    rm -Rf $WRE_ROOT/etc/extra
}

#gooey
gooey() {
  printf '\x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x4d \x57 \xd0 \x57 \x57 \x57 \x4d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x40 \x23 \x23 \x35 \x35 \x35 \x35 \x35 \x35 \x23 \x23 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x57 \x23 \x23 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x35 \x40 \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x57 \x57 \x4d \x23 \x23 \x23 \x35 \x41 \x41 \x25 \x25 \x24 \x24 \x24 \x33 \x33 \x24 \x24 \x24 \x25 \x41 \x35 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x33 \x24 \x25 \x25 \x41 \x35 \x35 \x41 \x25 \x25 \x24 \x4a \x37 \x37 \x37 \x37 \x37 \x3d \x3d \x3d \x37 \x33 \x24 \x25 \x41 \x23 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x25 \x41 \x35 \x41 \x41 \x25 \x25 \x33 \x33 \x24 \x41 \x41 \x35 \x23 \x40 \x40 \x40 \x40 \x35 \x43 \x43 \x24 \x25 \x41 \x23 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x3d \x33 \x41 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x35 \x23 \x23 \x23 \x23 \x23 \x23 \x23 \x40 \xd0 \x57 \xd0 \x43 \x4a \x24 \x25 \x23 \x41 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x23 \x41 \x41 \x23 \x23 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x25 \x24 \x33 \x33 \x33 \x33 \x33 \x24 \x35 \x35 \x43 \x25 \x25 \x35 \x25 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x25 \x57 \xd0 \x40 \x40 \x35 \x35 \x41 \x41 \x41 \x41 \x25 \x41 \x33 \x37 \x4a \x24 \x25 \x41 \x41 \x41 \x33 \x2c \x24 \x41 \x24 \x25 \x41 \x35 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \xd0 \x23 \xd0 \x23 \x35 \x41 \x41 \x41 \x25 \x25 \x4a \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \x4a \x25 \x41 \x41 \x41 \x41 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \xa6 \x25 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x25 \x43 \x41 \x4d \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4a \x4a \x25 \x41 \x41 \x41 \x24 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x2e \x2c \x41 \xd0 \x40 \x35 \x41 \x41 \x41 \x25 \x43 \x35 \x20 \x40 \x43 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x43 \x33 \x25 \x41 \x41 \x25 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \x28 \x23 \xd0 \x23 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x57 \x2a \xa6 \x24 \x57 \x41 \x4d \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x41 \x25 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x43 \xd0 \x20 \x40 \x27 \x21 \x3d \x21 \xa6 \x4d \x20 \x20 \x20 \x40 \x37 \x24 \x25 \x25 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x35 \x41 \x40 \x40 \x23 \x41 \x41 \x41 \x24 \x43 \x20 \x20 \xa9 \x24 \xa6 \xa6 \x33 \x4d \x20 \x20 \x20 \xa9 \x4a \x33 \x24 \x24 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x35 \x23 \x25 \x40 \x40 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \x4a \x33 \x24 \x43 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x33 \x24 \x33 \xd0 \x40 \x35 \x41 \x41 \x25 \x33 \x33 \x20 \x20 \x20 \x20 \xa9 \x20 \x20 \x20 \x20 \xa9 \x35 \x4a \x33 \x33 \x33 \x57 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x40 \x57 \x23 \x35 \x41 \x25 \x24 \x24 \xa9 \x40 \x25 \x4a \x4a \x33 \x25 \x23 \xd0 \x41 \x4a \x33 \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x37 \x37 \xa9 \x20 \x20 \x4d \x33 \x3d \x28 \x41 \x4d \xd0 \x35 \x41 \x41 \x25 \x24 \x24 \x25 \x35 \x23 \x40 \xd0 \x40 \x23 \x41 \x24 \x33 \x25 \x3d \x35 \x25 \x41 \x35 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \xd0 \x21 \x37 \x41 \x20 \x20 \x4a \x4a \x23 \x25 \x43 \x40 \x4d \x40 \x35 \x41 \x41 \x41 \x35 \x35 \x35 \x23 \x23 \x23 \x23 \x35 \x35 \x25 \x25 \x25 \x3d \x24 \x25 \x41 \x23 \x35 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x35 \x28 \x40 \x4a \x43 \xa9 \x20 \x2c \x23 \x41 \x33 \x4a \x4a \x40 \x4d \xd0 \x23 \x35 \x41 \x41 \x25 \x25 \x25 \x41 \x41 \x41 \x41 \x24 \x33 \x24 \x25 \x24 \x3d \x33 \x24 \x41 \x40 \x33 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x4d \x43 \x37 \xd0 \xd0 \xa6 \x33 \xa9 \x20 \x2c \x41 \x24 \x4a \x33 \x33 \x4a \x41 \x57 \x57 \xd0 \x23 \x35 \x25 \x24 \x24 \x24 \x24 \x24 \x33 \x33 \x33 \x24 \x41 \x41 \x24 \x37 \x4a \x24 \x25 \x41 \x3d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \xa9 \xa6 \x25 \x57 \x40 \x24 \x21 \x23 \x20 \x20 \x2a \x24 \x4a \x33 \x41 \x25 \x33 \x4a \x43 \x24 \x41 \x35 \x23 \x40 \x41 \x25 \x24 \x33 \x33 \x33 \x4a \x4a \x24 \x41 \x35 \x35 \x35 \x33 \x37 \x4a \x24 \x3d \x41 \x20 \x20 \x20 \x57 \x23 \x20 \x20 \x0d \x0a \x23 \xa6 \x57 \x23 \x35 \x33 \xa6 \x4a \x57 \x23 \xa6 \x43 \x24 \x23 \x35 \x25 \x24 \x33 \x43 \x28 \x43 \x4a \x4a \x4a \x24 \x25 \x25 \x24 \x33 \x33 \x43 \x43 \x24 \x25 \x41 \x35 \x35 \x23 \x41 \x4a \x37 \x43 \xa6 \x20 \x20 \x20 \xd0 \x21 \x35 \x20 \x0d \x0a \x25 \x3d \x23 \x23 \x35 \x35 \x28 \x3d \x3d \xa6 \x43 \x25 \x40 \x23 \x41 \x25 \x24 \x4a \x28 \x33 \x25 \x24 \x24 \x25 \x25 \x25 \x25 \x24 \x33 \x37 \x2a \x3d \x24 \x25 \x41 \x41 \x35 \x35 \x23 \x23 \x25 \x3d \x27 \x40 \x20 \x20 \x41 \x4a \x43 \xa9 \x0d \x0a \xd0 \xa6 \x25 \x41 \x41 \x35 \x35 \x41 \x41 \x40 \x40 \x40 \x23 \x35 \x41 \x24 \x4a \x3d \x4a \x35 \x41 \x25 \x25 \x41 \x41 \x25 \x24 \x24 \x43 \x27 \x3d \x43 \x4a \x33 \x24 \x25 \x41 \x41 \x35 \x23 \x40 \x23 \x43 \xa6 \x41 \x33 \x3d \x40 \x33 \x4d \x0d \x0a \x20 \x28 \x4a \x24 \x25 \x41 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x25 \x25 \x33 \x4a \xa6 \x23 \x23 \x41 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x21 \x21 \x21 \x37 \x43 \x4a \x33 \x25 \x25 \x41 \x35 \x23 \x40 \xd0 \x24 \x2a \x43 \x24 \x25 \x25 \x20 \x0d \x0a \x20 \x57 \x28 \x4a \x33 \x24 \x25 \x41 \x41 \x41 \x25 \x24 \x24 \x24 \x33 \x33 \x4a \x28 \xd0 \x23 \x35 \x41 \x41 \x41 \x41 \x25 \x24 \x4a \x2c \x24 \x24 \x4a \xa6 \x21 \xa6 \x3d \x43 \x33 \x24 \x25 \x41 \x35 \x23 \xd0 \x35 \x28 \x24 \x40 \x20 \x20 \x0d \x0a \x20 \x20 \xd0 \x43 \x37 \x33 \x33 \x33 \x24 \x24 \x33 \x33 \x33 \x33 \x33 \x33 \x41 \x24 \x40 \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x24 \x3d \x37 \x35 \x23 \x41 \x24 \x4a \x3d \xa6 \x21 \xa6 \x43 \x33 \x24 \x41 \x35 \x23 \x57 \x35 \x4a \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x57 \x41 \x25 \x24 \x24 \x24 \x25 \x25 \x35 \x23 \xd0 \xa9 \x20 \xa9 \x4a \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x23 \xa9 \x23 \x23 \x35 \x25 \x24 \x33 \x4a \x35 \x37 \x28 \x37 \x24 \x25 \x35 \x40 \x4d \x25 \x41 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x24 \x41 \x25 \x24 \x41 \x41 \x41 \x24 \x33 \x2a \x57 \x20 \xa9 \x41 \x35 \x41 \x25 \x24 \x43 \x4d \xa9 \x40 \x37 \x28 \x24 \x41 \x35 \xd0 \x4d \x3d \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x37 \x24 \xa6 \x35 \x35 \x41 \x24 \x24 \x2c \xa9 \x20 \x20 \x57 \x37 \x25 \x24 \x33 \x43 \x20 \x20 \x20 \x20 \x25 \xa6 \x25 \x35 \x40 \x4d \x4a \xd0 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x4a \x57 \xa9 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x23 \x35 \x41 \x41 \x25 \x2c \x4d \x57 \x41 \x3d \x4a \x33 \x4a \x4a \x57 \x20 \x20 \x20 \x20 \x20 \x4a \x43 \x35 \x23 \x57 \x4a \x40 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x3d \x43 \x25 \x23 \xa9 \x20 \xa9 \x23 \x4a \xd0 \x23 \x35 \x35 \x35 \x41 \x2c \x41 \x3d \x28 \x43 \x33 \x25 \x23 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x23 \x28 \x35 \xd0 \x57 \x3d \xa9 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x43 \x35 \x40 \x25 \x24 \x25 \x23 \xd0 \x40 \x35 \x35 \x35 \x23 \x33 \x37 \xa9 \xa9 \xa9 \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x33 \x25 \x43 \x24 \xd0 \xd0 \x4a \x23 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x4a \x41 \x4d \x57 \x57 \xd0 \x23 \x35 \x35 \x23 \x23 \x33 \x3d \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \xa6 \x43 \x41 \x24 \x33 \x23 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x41 \x4a \x41 \x23 \x40 \x23 \x23 \x35 \x25 \x43 \x24 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x40 \x23 \x57 \xa9 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x24 \x4a \x43 \x43 \x33 \x41 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x0d \x0a';
  cat wre/docs/credits.txt
  return 0;
}


#wre help
wrehelp() {
cat <<_WREHELP
 \`build.sh' builds the WebGUI Runtime Environment.
  
  Usage: $0 [OPTIONS] [PACKAGES]

  Build switches cause only select applications to build.
  They can be combined to build only certain apps.
  
  Example: ./build.sh --perl            # only perl will be built
           ./build.sh --perl --apache   # only perl and apache will build
           ./build.sh --all             # build all 

  Options:

  --all             builds all packages
  --clean           cleans all pre-req folders for a new build
  --help            displays this screen
  --ia64            turns on special flags for building on 64-bit systems


  Packages:         (must be built in the order shown below)

  --utilities	    compiles and installs shared utilities
  --perl            compiles and installs perl
  --git		    compiles and installs git
  --apache          compiles and installs apache
  --mysql	        compiles and installs mysql
  --imagemagick     compiles and installs image magick
  --perlmodules     installs perl modules from cpan
  --awstats         installs awstats
  --wre             installs WebGUI Runtime Environment scripts and API
                               
_WREHELP

}

#Evaluate options passed by command line
for opt in "$@"
do

  #get any argument passed with this option
  arg=`expr "x$opt" : 'x[^=]*=\(.*\)'`

  case "$opt" in
 
    --ia64)
      export WRE_IA64=1
    ;;

    --clean)
      export WRE_CLEAN=1
    ;;

    --all)
        export WRE_BUILD_UTILS=1
        export WRE_BUILD_PERL=1
	export WRE_BUILD_GIT=1
        export WRE_BUILD_APACHE=1
        export WRE_BUILD_MYSQL=1
        export WRE_BUILD_IMAGEMAGICK=1
        export WRE_BUILD_AWSTATS=1
        export WRE_BUILD_WRE=1
        export WRE_BUILD_PM=1
    ;;
 
    --utils | --utilities)
        export WRE_BUILD_UTILS=1
    ;;
    
    --perl)
        export WRE_BUILD_PERL=1
    ;;

    --git)
	export WRE_BUILD_GIT=1
    ;;
    
    --apache)
        export WRE_BUILD_APACHE=1
    ;;

# If we wanted to use argument passing on build flags this is how we'd do it
#    --apache=*)
#      echo $arg
#      #Use $arg as parameter to function call, could be used
#      #to pass compile flags for performance, etc.
#    ;;
    
    --mysql)
        export WRE_BUILD_MYSQL=1
    ;;
    
    --imageMagick | --imagemagick)
        export WRE_BUILD_IMAGEMAGICK=1
    ;;
    
    --awstats)
        export WRE_BUILD_AWSTATS=1
    ;;
    
    --wre)
        export WRE_BUILD_WRE=1
    ;;
    
    --wre=revolutionary)
        gooey
        exit 0 
    ;;
     
    --perlModules | --perlmodules | --pm)
        export WRE_BUILD_PM=1
    ;;
    
    --help | -help | -h | -? | ?)
      wrehelp
      exit 0
    ;;
    
    -*)
        echo "Error: I don't know this option: $opt"
        echo
        wrehelp
        exit 1
    ;;

  esac
done

#No arguments passed, display help
if [ $# -eq 0 ]; then
	wrehelp
    exit 0
fi

if [ -d /data ]; then

    # configure environment
    . wre/sbin/setenvironment.sh
    export WRE_BUILDDIR=`pwd`
    export WRE_ROOT=/data/wre

    # deal with operating system inconsistencies
    export WRE_OSNAME=`uname -s`
    case $WRE_OSNAME in
        FreeBSD | OpenBSD)
            export WRE_MAKE=gmake
        ;;
        Linux)
            export WRE_MAKE=make
            if [ -f /etc/redhat-release ]; then
                export WRE_OSTYPE="RedHat"
            fi
            if [ -f /etc/fedora-release ]; then
                export WRE_OSTYPE="Fedora"
            fi
            if [ -f /etc/slackware-release ] || [ -f /etc/slackware-version ]; then
                export WRE_OSTYPE="Slackware"
            fi
            if [ -f /etc/debian_release ] || [ -f /etc/debian_version ]; then
                export WRE_OSTYPE="Debian"
            fi
            if [ -f /etc/mandrake-release ]; then
                export WRE_OSTYPE="Mandrake"
            fi
            if [ -f /etc/yellowdog-release ]; then
                export WRE_OSTYPE="YellowDog"
            fi
            if [ -f /etc/gentoo-release ]; then
                export WRE_OSTYPE="Gentoo"
            fi
            if [ -f /etc/lsb-release ]; then
                export WRE_OSTYPE="Ubuntu"
            fi
        ;;
        Darwin)
            export WRE_MAKE=make
            if [ `uname -r | cut -c 1` == "9" ]; then
                export WRE_OSTYPE="Leopard"
            fi 
            if [ `uname -r | cut -c 1` == "8" ]; then
                export WRE_OSTYPE="Tiger"
            fi 
        ;;
        *)
            export WRE_MAKE=make
        ;;
    esac

    # made folders than don't exist
	mkdir -p $WRE_ROOT/prereqs/man/man1
	mkdir -p $WRE_ROOT/prereqs/conf
	mkdir -p $WRE_ROOT/prereqs/lib
	mkdir -p $WRE_ROOT/prereqs/libexec
	mkdir -p $WRE_ROOT/prereqs/include
	mkdir -p $WRE_ROOT/prereqs/var
	mkdir -p $WRE_ROOT/prereqs/bin

    # build stuff
    if [ "$WRE_BUILD_UTILS" == 1 ]; then
 		buildUtils
    fi
    if [ "$WRE_BUILD_PERL" == 1 ]; then
 		buildPerl
    fi
    if [ "$WRE_BUILD_GIT" == 1 ]; then
 		buildGit
    fi
    if [ "$WRE_BUILD_APACHE" == 1 ]; then
 		buildApache
    fi
    if [ "$WRE_BUILD_MYSQL" == 1 ]; then
 		buildMysql
    fi
    if [ "$WRE_BUILD_IMAGEMAGICK" == 1 ]; then
 		buildImageMagick
    fi
    if [ "$WRE_BUILD_PM" == 1 ]; then
 		installPerlModules
    fi
    if [ "$WRE_BUILD_AWSTATS" == 1 ]; then
 		installAwStats
    fi
    if [ "$WRE_BUILD_WRE" == 1 ]; then
 		installWreUtils
    fi
    makeItSmall
    printHeader "Complete And Successful"
else
  	echo "You must create a writable /data folder to begin."
    exit 0
fi




