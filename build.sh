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
  cd source/utils/lftp-3.3.4
  make distclean
  make clean
  cd ../zlib-1.2.3
  make distclean
  make clean
  cd ../openssl-0.9.7j
  make distclean
  make clean
  cd ../libtool-1.5.22
  make distclean
  make clean
  cd ../catdoc-0.94
  make distclean
  make clean
  cd ../expat-2.0.0
  make distclean
  make clean
  cd ../xpdf-3.01
  make distclean
  make clean
  cd $BUILDDIR
 #memcached
  cd source/memcached/libevent-1.1a
  make distclean
  make clean
  cd ../memcached-1.1.12
  make distclean
  make clean
  cd $BUILDDIR
 #perl
  cd source/perl/perl-5.8.8
  make distclean
  make clean
  cd $BUILDDIR
 #apache 
  cd source/apache/httpd-2.0.59
  make distclean
  make clean
  rm -Rf server/exports.c 
  rm -Rf server/export_files
  cd ../modperl-2.0.2
  make distclean
  make clean
  cd $BUILDDIR
 #mysql
  cd source/mysql/mysql-5.0.24
  make distclean
  cd $BUILDDIR
 #image magick
  cd source/imagemagick/ImageMagick-6.2.7
  make distclean
  make clean
  cd ../libpng-1.2.10
  make distclean
  make clean 
  cd ../libungif-4.1.4
  make distclean 
  make clean 
  cd ../libjpeg-6b
  make distclean 
  make clean 
  cd ../freetype-2.1.10
  make distclean 
  make clean 
  cd $BUILDDIR
 #perl modules
  cd perl/modules
  cd ../libapreq2-2.0.7
  make distclean
  make clean
  cd ../compresszlib
  make distclean
  make clean
  cd ../netssleay
  make distclean
  make clean
  cd $BUILDDIR
}

# utilities
buildUtils(){
	echo Building Utilities
	mkdir -p /data/wre/prereqs/utils/bin
	cd source/utils/lftp-3.3.4
	./configure --prefix=/data/wre/prereqs/utils; checkError $? "lftp Configure"
	make; checkError $? "lftp make"
	make install exec_prefix=/data/wre/prereqs/utils; checkError $? "lftp make install"
	cd ../zlib-1.2.3
	./configure --prefix=/data/wre/prereqs/utils --shared; checkError $? "zlib Configure"
	make; checkError $? "zlib make"
	make install; checkError $? "zlib make install"
	cd ../openssl-0.9.7j
	./config --prefix=/data/wre/prereqs/utils; checkError $? "OpenSSL Configure"
	make; checkError $? "OpenSSL make"
	make test; checkError $? "OpenSSL make test"
	make install; checkError $? "OpenSSL make install"
	cd ../libtool-1.5.22
	./configure --prefix=/data/wre/prereqs/utils; checkError $? "libtool Configure"
	make; checkError $? "libtool make"
	make install; checkError $? "libtool make install"
	cd ../catdoc-0.94
	./configure --prefix=/data/wre/prereqs/utils --disable-wordview --without-wish --with-input=utf-8 --with-output=utf-8 --disable-charset-check --disable-langinfo; checkError $? "catdoc Configure"
	make; checkError $? "catdoc make"
	cd src
	make install; checkError $? "catdoc make install src"
	cd ../docs
	make install; checkError $? "catdoc make install docs"
	cd ../charsets
	make install; checkError $? "catdoc make install charsets"
	cd ..
	cd ../expat-2.0.0
	./configure --prefix=/data/wre/prereqs/utils; checkError $? "expat Configure"
	make; checkError $? "expat make"
	make install; checkError $? "expat make install"
	cd ../xpdf-3.01
	./configure --without-x --prefix=/data/wre/prereqs/utils; checkError $? "pdftotext Configure"
	make; checkError $? "pdftotext make"
	make install; checkError $? "pdftotext make install"
	echo /data/wre/prereqs/utils/bin/pdftotext \$@ \$@.txt > /data/wre/prereqs/utils/bin/pdf2txt
	echo /bin/cat \$@.txt >> /data/wre/prereqs/utils/bin/pdf2txt
	echo /bin/rm -f \$@.txt >> /data/wre/prereqs/utils/bin/pdf2txt
	chmod 755 /data/wre/prereqs/utils/bin/pdf2txt
	cd $BUILDDIR
}

# memcached
buildMemcached(){
        echo Building memcached
        mkdir -p /data/wre/prereqs/memcached/bin
        mkdir -p /data/wre/prereqs/memcached/lib
        cd source/memcached/libevent-1.1a
        ./configure --prefix=/data/wre/prereqs/memcached; checkError $? "libevent Configure"
        make; checkError $? "libevent make"
        make install; checkError $? "libevent make install"
        cd ../memcached-1.1.12
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
	cd source/perl/perl-5.8.8
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
	cd source/apache/httpd-2.0.59
	case $OSNAME in
		Linux)
			# insists upon using it's own zlib and ours, which won't work, so temporarily hiding ours
			mv /data/wre/prereqs/utils/include/zlib.h /data/wre/prereqs/utils/include/zlib.h.ignore
			;;
	esac
	./configure --prefix=/data/wre/prereqs/apache --enable-rewrite=shared --enable-deflate=shared --enable-ssl --with-ssl=/data/wre/prereqs/utils --enable-proxy=shared --with-mpm=prefork --enable-headers --disable-userdir --disable-imap --disable-negotiation --disable-actions; checkError $? "Apache Configure"
	make; checkError $? "Apache make"
	make install; checkError $? "Apache make install"
	case $OSNAME in
		Linux)
		mv /data/wre/prereqs/utils/include/zlib.h.ignore /data/wre/prereqs/utils/include/zlib.h
			;;
	esac
	cd ../mod_perl-2.0.2
	perl Makefile.PL MP_APXS=/data/wre/prereqs/apache/bin/apxs; checkError $? "mod_perl Configure"
	make; checkError $? "mod_perl make"
# The tests fail on all systems even on good builds
#	case $OSNAME in
#		Darwin | SunOS)
#			#tests fail for some reason even after a good build
#			;;
#		*)
#			make test; checkError $? "mod_perl make test"
#			;;
#	esac
	make install; checkError $? "mod_perl make install"
	cd $BUILDDIR
	echo "webgui/package   wgpkg" >> /data/wre/prereqs/apache/conf/mime.types
}


# mysql
buildMysql(){
	echo Building MySQL
	mkdir -p /data/wre/prereqs/mysql/bin
	mkdir -p /data/wre/prereqs/mysql/man/man1
	mkdir -p /data/wre/prereqs/mysql/lib
	mkdir -p /data/wre/prereqs/mysql/libexec
	mkdir -p /data/wre/prereqs/mysql/include
	mkdir -p /data/wre/prereqs/mysql/var
	cd source/mysql/mysql-5.0.24
	CC=gcc CFLAGS="-O3 -fno-omit-frame-pointer" CXX=g++ CXXFLAGS="-O3 -fno-omit-frame-pointer -felide-constructors -fno-exceptions -fno-rtti" ./configure --prefix=/data/wre/prereqs/mysql --with-extra-charsets=all --enable-thread-safe-client --enable-local-infile --disable-shared --enable-assembler --with-readline --without-debug --enable-large-files=yes --enable-largefile=yes --with-openssl=/data/wre/prereqs/utils --with-unix-socket-path=/data/wre/prereqs/mysql/mysql.sock; checkError $? "MySQL Configure"
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
	cd source/imagemagick/libjpeg-6b
	./configure --enable-shared --prefix=/data/wre/prereqs/imagemagick; checkError $? "Image Magick libjpeg Configure"
	perl -i -p -e's[./libtool][libtool]g' Makefile
	make; checkError $? "Image Magick libjpeg make"
	make install; checkError $? "Image Magick libjpeg make install"
	cd ../freetype-2.1.10
	./configure --enable-shared --prefix=/data/wre/prereqs/imagemagick; checkError $? "Image Magick freetype Configure"
	make; checkError $? "Image Magick freetype make"
	make install; checkError $? "Image Magick freetype make install"
	cd ../libungif-4.1.4
	./configure --enable-shared --prefix=/data/wre/prereqs/imagemagick; checkError $? "Image Magick libungif Configure"
	make; checkError $? "Image Magick libungif make"
	make install; checkError $? "Image Magick libungif make install"
	cd ../libpng-1.2.10
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
	cd ../ImageMagick-6.2.7
	./configure --prefix=/data/wre/prereqs/imagemagick --enable-delegate-build LDFLAGS='-L/data/wre/prereqs/imagemagick/lib' CPPFLAGS='-I/data/wre/prereqs/imagemagick/include' --enable-shared=yes --with-jp2=yes --with-jpeg=yes --with-png=yes --with-perl=yes --with-x=no
	checkError $? "Image Magick Configure"
	make; checkError $? "Image Magick make"
	make install; checkError $? "Image Magick make test"
	cd $BUILDDIR
}


#perl modules
installPerlModules(){
	echo Installing Perl Modules
	cd source/perl/modules
	cd Net_SSLeay.pm-1.25
	perl Makefile.PL /data/wre/prereqs/utils; checkError $? "Net::SSLeay Makefile.PL"
	make; checkError $? "Net:::SSLeay make"
	make install; checkError $? "Net::SSLeay make install"
	cd ../Compress-Zlib-1.39
	perl Makefile.PL; checkError $? "Compress::Zlib Makefile.PL"
	make; checkError $? "Compress::Zlib make"
	make install; checkError $? "Compress::Zlib make install"
	cd ../Proc-ProcessTable-0.40
	perl Makefile.PL; checkError $? "Proc::ProcessTable Makefile.PL"
	make; checkError $? "Proc::ProcessTable make"
	make install; checkError $? "Proc::ProcessTable make install"
	cd ../BSD-Resource-1.25
	perl Makefile.PL; checkError $? "BSD::Resource Makefile.PL"
	make; checkError $? "BSD::Resource make"
	make install; checkError $? "BSD::Resource make install"
	cd ../URI-1.35
	perl Makefile.PL; checkError $? "URI Makefile.PL"
	make; checkError $? "URI make"
	make install; checkError $? "URI make install"
	cd ../IO-Zlib-1.04
	perl Makefile.PL; checkError $? "IO::Zlib Makefile.PL"
	make; checkError $? "IO::Zlib make"
	make install; checkError $? "IO::Zlib make install"
	cd ../HTML-Tagset-3.10
	perl Makefile.PL; checkError $? "HTML::Tagset Makefile.PL"
	make; checkError $? "HTML::Tagset make"
	make install; checkError $? "HTML::Tagset make install"
	cd ../HTML-Parser-3.54
	perl Makefile.PL; checkError $? "HTML::Parser Makefile.PL"
	make; checkError $? "HTML::Parser make"
	make install; checkError $? "HTML::Parser make install"
	cd ../libwww-perl-5.805
	perl Makefile.PL -n; checkError $? "LWP Makefile.PL"
	make; checkError $? "LWP make"
	make install; checkError $? "LWP make install"
	cd ../CGI.pm-3.20
	perl Makefile.PL; checkError $? "CGI Makefile.PL"
	make; checkError $? "CGI make"
	make install; checkError $? "CGI make install"
	cd ../Digest-HMAC-1.01
	perl Makefile.PL; checkError $? "Digest::HMAC Makefile.PL"
	make; checkError $? "Digest::HMAC make"
	make install; checkError $? "Digest::HMAC make install"
	cd ../Digest-MD5-2.36
	perl Makefile.PL; checkError $? "Digest::MD5 Makefile.PL"
	make; checkError $? "Digest::MD5 make"
	make install; checkError $? "Digest::MD5 make install"
	cd ../Digest-SHA1-2.11
	perl Makefile.PL; checkError $? "Digest::SHA1 Makefile.PL"
	make; checkError $? "Digest::SHA1 make"
	make install; checkError $? "Digest::SHA1 make install"
	cd ../Module-Build-0.28
	perl Makefile.PL; checkError $? "Module::Build Makefile.PL"
	make; checkError $? "Module::Bulid make"
	make install; checkError $? "Module::Build make install"
	cd ../Params-Validate-0.81 
	perl Makefile.PL; checkError $? "Params::Validate Makefile.PL"
	make; checkError $? "Params::Validate make"
	make install; checkError $? "Params::Validate make install"
	cd ../DateTime-Locale-0.22
	perl Makefile.PL; checkError $? "DateTime::Locale Makefile.PL"
	make; checkError $? "DateTime::Locale make"
	make install; checkError $? "DateTime::Locale make install"
	cd ../Class-Singleton-1.03
	perl Makefile.PL; checkError $? "Class::Singleton Makefile.PL"
	make; checkError $? "Class::Singleton make"
	make install; checkError $? "Class::Singleton make install"
	cd ../DateTime-TimeZone-0.45
	perl Makefile.PL; checkError $? "DateTime::TimeZone Makefile.PL"
	make; checkError $? "DateTime::TimeZone make"
	make install; checkError $? "DateTime::TimZone make install"
	cd ../Time-Local-1.12
	perl Makefile.PL; checkError $? "Time::Local Makefile.PL"
	make; checkError $? "Time::Local make"
	make install; checkError $? "Time::Local make install"
	cd ../Test-Simple-0.62
	perl Makefile.PL; checkError $? "Test::More Makefile.PL"
	make; checkError $? "Test::More make"
	make install; checkError $? "Test::More make install"
	cd ../Devel-Symdump-2.06
	perl Makefile.PL; checkError $? "Devel::Symdump Makefile.PL"
	make; checkError $? "Devel::Symdump make"
	make install; checkError $? "Devel::Symdump make install"
	cd ../Pod-Escapes-1.04
	perl Makefile.PL; checkError $? "Pod::Escapes Makefile.PL"
	make; checkError $? "Pod::Escapes make"
	make install; checkError $? "Pod::Escapes make install"
	cd ../ExtUtils-CBuilder-0.18
	perl Makefile.PL; checkError $? "ExtUtils::CBuilder Makefile.PL"
	make; checkError $? "ExtUtils::CBuilder make"
	make install; checkError $? "ExtUtils::CBuilder make install"
	cd ../Pod-Coverage-0.17
	perl Makefile.PL; checkError $? "Pod::Coverage Makefile.PL"
	make; checkError $? "Pod::Coverage make"
	make install; checkError $? "Pod::Coverage make install"
	cd ../Pod-Simple-3.04
	perl Makefile.PL; checkError $? "Pod::Simple Makefile.PL"
	make; checkError $? "Pod::Simple make"
	make install; checkError $? "Pod::Simple make install"
	cd ../podlators-2.0.4
	perl Makefile.PL; checkError $? "Pod::Man Makefile.PL"
	make; checkError $? "Pod::Man make"
	make install; checkError $? "Pod::Man make install"
	cd ../DateTime-0.30
	perl Makefile.PL; checkError $? "DateTime Makefile.PL"
	make; checkError $? "DateTime make"
	make install; checkError $? "DateTime make install"
	cd ../DateTime-Format-Strptime-1.0700
	perl Makefile.PL; checkError $? "DateTime::Format::Strptime Makefile.PL"
	make; checkError $? "DateTime::Format::Strptime make"
	make install; checkError $? "DateTime::Format::Strptime make install"
	cd ../DateTime-Cron-Simple-0.2
	perl Makefile.PL; checkError $? "DateTime::Cron::Simple Makefile.PL"
	make; checkError $? "DateTime::Cron::Simple make"
	make install; checkError $? "DateTime::Cron::Simple make install"
	cd ../DateManip-5.44
	perl Makefile.PL; checkError $? "DateManip Makefile.PL"
	make; checkError $? "DateManip make"
	make install; checkError $? "DateManip make install"
	cd ../HTML-Template-2.8
	perl Makefile.PL; checkError $? "HTML::Template Makefile.PL"
	make; checkError $? "HTML::Template make"
	make install; checkError $? "HTML::Template make install"
	cd ../Crypt-SSLeay-0.51
	perl Makefile.PL; checkError $? "Crypt::SSLeay Makefile.PL"
	make; checkError $? "Crypt::SSLeay make"
	make install; checkError $? "Crypt::SSLeay make install"
	cd ../ParsePlainConfig-1.7a
	perl Makefile.PL; checkError $? "Parse::PlainConfig Makefile.PL"
	make; checkError $? "Parse::PlainConfig make"
	make install; checkError $? "Parse::PlainConfig make install"
	cd ../String-Random-0.21
	perl Build.PL; checkError $? "String::Random Makefile.PL"
	perl Build; checkError $? "String::Random make"
	perl Build install; checkError $? "String::Random make install"
	cd ../Time-HiRes-1.87
	perl Makefile.PL; checkError $? "Time::HiRes Makefile.PL"
	make; checkError $? "Time::HiRes make"
	make install; checkError $? "Time::HiRes make install"
	cd ../Text-Balanced-1.97
	perl Makefile.PL; checkError $? "Text::Balanced Makefile.PL"
	make; checkError $? "Text::Balanced make"
	make install; checkError $? "Text::Balanced make install"
	cd ../Tie-IxHash-1.21
	perl Makefile.PL; checkError $? "Tie::IxHash Makefile.PL"
	make; checkError $? "Tie::IxHash make"
	make install; checkError $? "Tie::IxHash make install"
	cd ../Tie-CPHash-1.02
	perl Makefile.PL; checkError $? "Tie::CPHash Makefile.PL"
	make; checkError $? "Tie::CPHash make"
	make install; checkError $? "Tie::CPHash make install"
	cd ../Error-0.15009
	perl Makefile.PL; checkError $? "Error Makefile.PL"
	make; checkError $? "Error make"
	make install; checkError $? "Error make install"
	cd ../Cache-Cache-1.04
	perl Makefile.PL; checkError $? "Cache::Cache Makefile.PL"
	make; checkError $? "Cache::Cache make"
	make install; checkError $? "Cache::Cache make install"
	cd ../HTML-Highlight-0.20
	perl Makefile.PL; checkError $? "HTML::Highlight Makefile.PL"
	make; checkError $? "HTML::Highlight make"
	make install; checkError $? "HTML::Highlight make install"
	cd ../HTML-TagFilter-1.03
	perl Makefile.PL; checkError $? "HTML::TagFilter Makefile.PL"
	make; checkError $? "HTML::TagFilter make"
	make install; checkError $? "HTML::TagFilter make install"
	cd ../IO-String-1.08
	perl Makefile.PL; checkError $? "IO::String Makefile.PL"
	make; checkError $? "IO::String make"
	make install; checkError $? "IO::String make install"
	cd ../Archive-Tar-1.29
	perl Makefile.PL; checkError $? "Archive::Tar Makefile.PL"
	make; checkError $? "Archive::Tar make"
	make install; checkError $? "Archive::Tar make install"
	cd ../Archive-Zip-1.16
	perl Makefile.PL; checkError $? "Archive::Zip Makefile.PL"
	make; checkError $? "Archive::Zip make"
	make install; checkError $? "Archive::Zip make install"
	cd ../XML-NamespaceSupport-1.09
	perl Makefile.PL; checkError $? "XML::NamespaceSupport Makefile.PL"
	make; checkError $? "XML::NamespaceSupport make"
	make install; checkError $? "XML::NamespaceSupport make install"
	cd ../XML-SAX-0.14
	perl Makefile.PL; checkError $? "XML::SAX Makefile.PL"
	make; checkError $? "XML::SAX make"
	make install; checkError $? "XML::SAX make install"
	cd ../XML-Simple-2.14
	perl Makefile.PL; checkError $? "XML::Simple Makefile.PL"
	make; checkError $? "XML::Simple make"
	make install; checkError $? "XML::Simple make install"
	cd ../XML-RSSLite-0.11
	perl Makefile.PL; checkError $? "XML::RSSLite Makefile.PL"
	make; checkError $? "XML::RSSLite make"
	make install; checkError $? "XML::RSSLite make install"
	cd ../SOAP-Lite-0.67
	perl Makefile.PL --noprompt; checkError $? "SOAP::Lite Makefile.PL"
	make; checkError $? "SOAP::Lite make"
	make install; checkError $? "SOAP::Lite make install"
	cd ../DBI-1.50
	perl Makefile.PL; checkError $? "DBI Makefile.PL"
	make; checkError $? "DBI make"
	make install; checkError $? "DBI make install"
	cd ../DBD-mysql-3.0002
	perl Makefile.PL; checkError $? "DBD::mysql Makefile.PL"
	make; checkError $? "DBD::mysql make"
	make install; checkError $? "DBD::mysql make install"
	cd ../Convert-ASN1-0.20
	perl Makefile.PL; checkError $? "Convert::ASN1 Makefile.PL"
	make; checkError $? "Convert::ASN1 make"
	make install; checkError $? "Convert::ASN1 make install"
	cd ../HTML-TableExtract-2.07
	perl Makefile.PL; checkError $? "HTML::TableExtract Makefile.PL"
	make; checkError $? "HTML::TableExtract make"
	make install; checkError $? "HTML::TableExtract make install"
	cd ../Finance-Quote-1.11
	perl Makefile.PL; checkError $? "Finance::Quote Makefile.PL"
	make; checkError $? "Finance::Quote make"
	make install; checkError $? "Finance::Quote make install"
	cd ../JSON-1.05
	perl Makefile.PL; checkError $? "JSON Makefile.PL"
	make; checkError $? "JSON make"
	make install; checkError $? "JSON make install"
	cd ../IO-Socket-SSL-0.97
	perl Makefile.PL; checkError $? "IO::Socket::SSL Makefile.PL"
	make; checkError $? "IO::Socket::SSL make"
	make install; checkError $? "IO::Socket::SSL make install"
	cd ../perl-ldap-0.33
	perl Makefile.PL; checkError $? "Net::LDAP Makefile.PL"
	make; checkError $? "Net::LDAP make"
	make install; checkError $? "Net::LDAP make install"
	cd ../Log-Log4perl-1.04
	perl Makefile.PL; checkError $? "Log::Log4perl Makefile.PL"
	make; checkError $? "Log::Log4perl make"
	make install; checkError $? "Log::Log4perl make install"
	cd ../POE-0.3401
	perl Makefile.PL --default; checkError $? "POE Makefile.PL"
	make; checkError $? "POE make"
	make install; checkError $? "POE make install"
	cd ../POE-Component-IKC-0.1802
	perl Makefile.PL; checkError $? "POE::Component::IKC Makefile.PL"
	make; checkError $? "POE::Component::IKC make"
	make install; checkError $? "POE::Component::IKC make install"
	cd ../String-CRC32-1.4
	perl Makefile.PL; checkError $? "String::CRC32 Makefile.PL"
	make; checkError $? "String::CRC32 make"
	make install; checkError $? "String::CRC32 make install"
	cd ../Cache-Memcached-1.17
	perl Makefile.PL; checkError $? "Cache::Memcached Makefile.PL"
	make; checkError $? "Cache::Memcached make"
	make install; checkError $? "Cache::Memcached make install"
	cd ../ExtUtils-XSBuilder-0.28
	perl Makefile.PL; checkError $? "ExtUtils::XSBuilder Makefile.PL"
	make; checkError $? "ExtUtils::XSBuilder make"
	make install; checkError $? "ExtUtils::XSBuilder make install"
	cd ../trace-0.51
	perl Makefile.PL; checkError $? "trace Makefile.PL"
	make; checkError $? "trace make"
	make install; checkError $? "trace make install"
	cd ../Clone-0.20
	perl Makefile.PL; checkError $? "Clone Makefile.PL"
	make; checkError $? "Clone make"
	make install; checkError $? "Clone make install"
	cd ../Test-Pod-1.24
	perl Makefile.PL; checkError $? "Test::Pod Makefile.PL"
	make; checkError $? "Test::Pod make"
	make install; checkError $? "Test::Pod make install"
	cd ../Data-Structure-Util-0.11
	perl Makefile.PL; checkError $? "Data::Structure::Util Makefile.PL"
	make; checkError $? "Data::Structure::Util make"
	make install; checkError $? "Data::Structure::Util make install"
	cd ../Parse-RecDescent-1.94
	perl Makefile.PL; checkError $? "Parse::RecDescent Makefile.PL"
	make; checkError $? "Parse::RecDescent make"
	make install; checkError $? "Parse::RecDescent make install"
	cd ../libapreq2-2.07
	./configure --with-apache2-apxs=/data/wre/prereqs/apache/bin/apxs --enable-perl-glue; checkError $? "libapreq2 configure"
	make; checkError $? "libapreq2 make"
	make install; checkError $? "libapreq2 make install"
	cd ../Net-Subnets-0.21
	perl Makefile.PL; checkError $? "Net::Subnets Makefile.PL"
	make; checkError $? "Net::Subnets make"
	make install; checkError $? "Net::Subnets make install"
	cd ../MailTools-1.74
	perl Makefile.PL; checkError $? "MIME tools Makefile.PL"
	make; checkError $? "MIME tools make"
	make install; checkError $? "MIME tools make install"
	cd ../IO-stringy-2.110
	perl Makefile.PL; checkError $? "MIME tools Makefile.PL"
	make; checkError $? "MIME tools make"
	make install; checkError $? "MIME tools make install"
	cd ../MIME-tools-5.420
	perl Makefile.PL; checkError $? "MIME tools Makefile.PL"
	make; checkError $? "MIME tools make"
	make install; checkError $? "MIME tools make install"
	cd ../HTML-Template-Expr-0.07
	perl Makefile.PL; checkError $? "HTML::Template::Expr Makefile.PL"
	make; checkError $? "HTML::Template::Expr make"
	make install; checkError $? "HTML::Template::Expr make install"
	cd ../Template-Toolkit-2.14
	perl Makefile.PL TT_ACCEPT=y TT_DOCS=n TT_SPLASH=n TT_THEME=n TT_EAMPLES=n TT_EXTRAS=n TT_XS_STASH=y TT_XS_DEFAULT=n TT_DBI=n TT_LATEX=n; checkError $? "Template Toolkit Makefile.PL"
	make; checkError $? "Template Toolkit make"
	make install; checkError $? "Template Toolkit make install"
	cd ../Scalar-List-Utils-1.18
	perl Makefile.PL; checkError $? "Scalar::List::Utils Makefile.PL"
	make; checkError $? "Scalar::List::Utils make"
	make install; checkError $? "Scalar::List::Utils make install"
	cd ../Graphics-ColorNames-1.06
	perl Makefile.PL; checkError $? "Graphics::ColorNames Makefile.PL"
	make; checkError $? "Graphics::ColorNames make"
	make install; checkError $? "Graphics::ColorNames make install"
	cd ../Module-Load-0.10
	perl Makefile.PL; checkError $? "Module::Load Makefile.PL"
	make; checkError $? "Module::Load make"
	make install; checkError $? "Module::Load make install"
	cd ../Color-Calc-1.00
	perl Makefile.PL; checkError $? "Color::Calc Makefile.PL"
	make; checkError $? "Color::Calc make"
	make install; checkError $? "Color::Calc make install"
	cd ../DateTime-Format-Mail-0.2901
	perl Makefile.PL; checkError $? "DateTime::Format::Mail Makefile.PL"
	make; checkError $? "DateTime::Format::Mail make"
	make install; checkError $? "DateTime::Format::Mail make install"
	cd ../ParallelUserAgent-2.57
	perl Makefile.PL; checkError $? "LWP::Parallel Makefile.PL"
	make; checkError $? "LWP::Parallel make"
	make install; checkError $? "LWP::Parallel make install"
	cd ../POE-Component-Client-HTTP-0.77
	perl Makefile.PL; checkError $? "POE::Component::Client::HTTP Makefile.PL"
	make; checkError $? "POE::Component::Client::HTTP make"
	make install; checkError $? "POE::Component::Client::HTTP make install"
	cd ../Test-Deep-0.095
	perl Makefile.PL; checkError $? "Test::Deep Makefile.PL"
	make; checkError $? "Test::Deep make"
	make install; checkError $? "Test::Deep make install"
	cd ../Test-MockObject-1.06
	perl Makefile.PL; checkError $? "Test::MockObject Makefile.PL"
	make; checkError $? "Test::MockObject make"
	make install; checkError $? "Test::MockObject make install"
	cd ../UNIVERSAL-isa-0.06
	perl Makefile.PL; checkError $? "UNIVERSAL::isa Makefile.PL"
	make; checkError $? "UNIVERSAL::isa make"
	make install; checkError $? "UNIVERSAL::isa make install"
	cd ../UNIVERSAL-can-1.12
	perl Makefile.PL; checkError $? "UNIVERSAL::can Makefile.PL"
	make; checkError $? "UNIVERSAL::can make"
	make install; checkError $? "UNIVERSAL::can make install"
	cd ../Class-MakeMethods-1.01
	perl Makefile.PL; checkError $? "Class::MakeMethods Makefile.PL"
	make; checkError $? "Class::MakeMethods make"
	make install; checkError $? "Class::MakeMethods make install"
	cd ../MySQL-Diff-0.33
	perl Makefile.PL; checkError $? "MySQL::Diff Makefile.PL"
	make; checkError $? "MySQL::Diff make"
	make install; checkError $? "MySQL::Diff make install"
	cp -f mysqldiff /data/wre/sbin/
	perl -i -p -e's[/usr/bin/perl][/data/wre/prereqs/perl/bin/perl]g' /data/wre/sbin/mysqldiff
	cd $BUILDDIR
}


#awstats
installAwStats(){
	echo Installing AWStats
	cp -RL source/awstats/awstats-6.4 /data/wre/prereqs/awstats
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


