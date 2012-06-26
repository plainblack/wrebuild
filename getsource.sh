#!/bin/bash

# This script will help you get all needed sources 
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir source
cd source

# ncurses http://www.gnu.org/software/ncurses/
wget -t 4 -nv http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz
tar xfz ncurses-5.9.tar.gz

# readline http://tiswww.case.edu/php/chet/readline/rltop.html
wget -t 4 -nv ftp://ftp.cwru.edu/pub/bash/readline-6.2.tar.gz
tar xfz readline-6.2.tar.gz

# tiff for image magick http://www.libtiff.org/
wget -t 4 -nv ftp://ftp.remotesensing.org/pub/libtiff/tiff-3.9.6.tar.gz
tar xfz tiff-3.9.6.tar.gz

# imagemagick http://www.imagemagick.org/script/index.php
wget -t 4 -nv ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
tar zxf ImageMagick.tar.gz

# image magick color profile
wget -t 4 -nv http://www.imagemagick.org/source/colors.xml

# aspell dictionary http://aspell.net/
wget -t 4 -nv ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz
tar zxf aspell-0.60.6.1.tar.gz

# aspell-en
wget -t 4 -nv ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell6-en-6.0-0.tar.bz2
tar jxf aspell6-en-6.0-0.tar.bz2

# awstats http://awstats.sourceforge.net/
wget -t 4 -nv http://downloads.sourceforge.net/project/awstats/AWStats/7.0/awstats-7.0.tar.gz?user_mirror=autoselect
tar zxf awstats-7.0.tar.gz
cd awstats-7.0/wwwroot
mv cgi-bin/* ./
perl -ni -e 'print unless /^\s*if . !\$FileConfig/ .. /^\s+}/; print $_.qq/\t\terror("Could not open config file");\n\t}\n/ if /^\s*if . !\$FileConfig/;' awstats.pl
perl -0777 -pi -e 's!else\s*{\s+\@PossibleConfigDir\s+=\s+.+?\);!else {\n\t\t\@PossibleConfigDir = ("\$DIR", "/data/wre/etc");!ms;' awstats.pl
cd ../..

# catdoc .doc and .xls converter http://vitus.wagner.pp.ru/software/catdoc/
wget -t 4 -nv http://ftp.wagner.pp.ru/pub/catdoc/catdoc-0.94.2.tar.gz
tar zxf catdoc-0.94.2.tar.gz

# expat xml parser http://expat.sourceforge.net/
wget -t 4 -nv http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz?user_mirror=autoselect
tar zxf expat-2.1.0.tar.gz

# freetype portable font engine http://freetype.sourceforge.net/index2.html
wget -t 4 -nv http://downloads.sourceforge.net/project/freetype/freetype2/2.4.10/freetype-2.4.10.tar.bz2?user_mirror=autoselect
tar jxf freetype-2.4.9.tar.bz2

# nettle, crypto library for gnutls
wget -t 4 -nv ftp://ftp.lysator.liu.se/pub/security/lsh/nettle-2.4.tar.gz
tar zxf nettle-2.4.tar.gz

# p11-kit, PKCS library for gnutls
wget -t 4 -nv http://p11-glue.freedesktop.org/releases/p11-kit-0.12.tar.gz
tar zxf p11-kit-0.12.tar.gz

# gnutls transport layer security http://www.gnu.org/software/gnutls/
wget -t 4 -nv ftp://ftp.gnu.org/pub/gnu/gnutls/gnutls-2.12.19.tar.bz2
tar jxf gnutls-2.12.19.tar.bz2

# PCRE
wget -t 4 -nv ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.30.tar.bz2
tar jxf pcre-8.30.tar.bz2

# httpd apache webserver http://httpd.apache.org/
wget -t 4 -nv http://www.apache.org/dist/httpd/httpd-2.2.22.tar.gz
tar zxf httpd-2.2.22.tar.gz

# lftp sophisticated ftp client http://lftp.yar.ru/
wget -t 4 -nv http://ftp.yars.free.net/pub/source/lftp/lftp-4.3.7.tar.gz
tar zxf lftp-4.3.7.tar.gz

# libiconv unicode conversion tool http://www.gnu.org/software/libiconv/
wget -t 4 -nv http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar zxf libiconv-1.14.tar.gz

# libjpeg image manipulation http://www.ijg.org/
wget -t 4 -nv http://www.ijg.org/files/jpegsrc.v8d.tar.gz
tar zxf jpegsrc.v8d.tar.gz
mv jpeg-8d libjpeg-8

# lcms color management http://www.littlecms.com/
wget -t 4 -nv http://downloads.sourceforge.net/project/lcms/lcms/2.3/lcms2-2.3.tar.gz?user_mirror=autoselect
tar zxf lcms2-2.3.tar.gz

# graphviz graph generator http://www.graphviz.org/
wget -t 4 -nv http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.24.0.tar.gz
tar xfz graphviz-2.24.0.tar.gz

# libpng image manipulation http://www.libpng.org/pub/png/libpng.html
wget -t 4 -nv http://downloads.sourceforge.net/project/libpng/libpng15/1.5.11/libpng-1.5.11.tar.gz?user_mirror=autoselect
tar jxf libpng-1.5.10.tar.bz2

# gnu libtool http://www.gnu.org/software/libtool/
wget -t 4 -nv http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
tar zxf libtool-2.4.2.tar.gz

# libgif image manipulation http://sourceforge.net/projects/giflib/
wget -t 4 -nv http://downloads.sourceforge.net/project/giflib/giflib-5.x/giflib-5.0.0.tar.bz2?user_mirror=autoselect
tar jxf giflib-5.0.0.tar.bz2

# libgcrypt crypt library http://www.gnupg.org/download/
wget -t 4 -nv ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.4.6.tar.bz2
tar jxf libgcrypt-1.4.6.tar.bz2

wget -t 4 -nv ftp://ftp.gmplib.org/pub/gmp-5.0.5/gmp-5.0.5.tar.bz2
tar jxf gmp-5.0.5.tar.bz2

# libgpg-error error messages http://www.gnupg.org/download/
wget -t 4 -nv ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.7.tar.bz2
tar jxf libgpg-error-1.7.tar.bz2

# libxml2 xml c parser http://www.xmlsoft.org/
wget -t 4 -nv ftp://xmlsoft.org/libxml2/libxml2-2.7.8.tar.gz
tar zxf libxml2-2.7.8.tar.gz

# modperl apache perl module http://perl.apache.org
wget -t 4 -nv http://perl.apache.org/dist/mod_perl-2.0-current.tar.gz
tar zxf mod_perl-2.0-current.tar.gz

# mysql database server http://dev.mysql.com/downloads/mysql/5.0.html
wget -t 4 -nv ftp://mirror.services.wisc.edu/mirrors/mysql/Downloads/MySQL-5.1/mysql-5.1.62.tar.gz
tar zxf mysql-5.1.62.tar.gz

# openssl ssl toolkit http://www.openssl.org/
wget -t 4 -nv http://www.openssl.org/source/openssl-1.0.1b.tar.gz
tar zxf openssl-1.0.1b.tar.gz

# perl programming language http://www.cpan.org/src/README.html
wget -t 4 -nv http://www.cpan.org/src/perl-5.14.2.tar.gz
tar zxf perl-5.14.2.tar.gz

# perlmodules
# SEE SEPARATE SCRIPT

# xpdf pdf generator http://www.foolabs.com/xpdf/download.html
wget -t 4 -nv ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.03.tar.gz
tar zxf xpdf-3.03.tar.gz

# zlib compression library http://www.zlib.net/
wget -t 4 -nv http://downloads.sourceforge.net/project/libpng/zlib/1.2.7/zlib-1.2.7.tar.gz?user_mirror=autoselect
tar jxf zlib-1.2.7.tar.bz2

# git http://git-scm.com/download
wget -t 4 -nv http://git-core.googlecode.com/files/git-1.7.10.1.tar.gz
tar zxf git-1.7.10.1.tar.gz

# http://curl.haxx.se/
wget -t 4 -nv http://curl.haxx.se/download/curl-7.25.0.tar.bz2
tar jxf curl-7.25.0.tar.bz2

# Handler Socket
wget -t 4 -nv https://github.com/ahiguti/HandlerSocket-Plugin-for-MySQL/zipball/master
mv master master.zip
unzip master.zip;
mv ahiguti-HandlerSocket-Plugin-for-MySQL-??????? HandlerSocket-Plugin-for-MySQL

##Clean up downloaded files
rm -f *.gz *.tgz *.bz2 *.zip



