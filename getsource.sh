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

http://downloads.sourceforge.net/project/awstats/AWStats/7.0/awstats-7.0.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fawstats%2Ffiles%2FAWStats%2F7.0%2F&ts=1336517955&use_mirror=iweb

# awstats http://awstats.sourceforge.net/
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/awstats/awstats-7.0.tar.gz
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
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/expat/expat-2.1.0.tar.gz
tar zxf expat-2.1.0.tar.gz

# freetype portable font engine http://freetype.sourceforge.net/index2.html
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/freetype/freetype-2.4.9.tar.bz2
tar jxf freetype-2.4.9.tar.bz2

# gnutls transport layer security http://www.gnu.org/software/gnutls/
wget -t 4 -nv ftp://ftp.gnu.org/pub/gnu/gnutls/gnutls-2.12.19.tar.bz2
tar jxf gnutls-2.12.19.tar.bz2

# httpd apache webserver http://httpd.apache.org/
wget -t 4 -nv http://www.apache.org/dist/httpd/httpd-2.4.2.tar.gz
tar zxf httpd-2.4.2.tar.gz

# lftp sophisticated ftp client http://lftp.yar.ru/
wget -t 4 -nv http://ftp.yars.free.net/pub/source/lftp/old/lftp-4.3.6.tar.gz
tar zxf lftp-4.3.6.tar.gz

# libiconv unicode conversion tool http://www.gnu.org/software/libiconv/
wget -t 4 -nv http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar zxf libiconv-1.14.tar.gz

# libjpeg image manipulation http://www.ijg.org/
wget -t 4 -nv http://www.ijg.org/files/jpegsrc.v8c.tar.gz
tar zxf jpegsrc.v8c.tar.gz
mv jpeg-8 libjpeg-8

# lcms color management http://www.littlecms.com/
wget -t 4 -nv http://sourceforge.net/projects/lcms/files/lcms/2.2.3/lcms-2.2.3.tar.gz/download
tar zxf lcms-2.2.3.tar.gz
.3
# graphviz graph generator http://www.graphviz.org/
wget -t 4 -nv http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.24.0.tar.gz
tar xfz graphviz-2.24.0.tar.gz

# libpng image manipulation http://www.libpng.org/pub/png/libpng.html
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/libpng/libpng-1.5.10.tar.bz2
tar jxf libpng-1.5.10.tar.bz2

# gnu libtool http://www.gnu.org/software/libtool/
wget -t 4 -nv http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
tar zxf libtool-2.4.2.tar.gz

# libgif image manipulation http://sourceforge.net/projects/giflib/
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/giflib/giflib-4.1.6.tar.bz2
tar jxf giflib-4.1.6.tar.bz2

# libgcrypt crypt library http://www.gnupg.org/download/
wget -t 4 -nv ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.4.6.tar.bz2
tar jxf libgcrypt-1.4.6.tar.bz2

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
wget -t 4 -nv http://downloads.mysql.com/archives/mysql-5.0/mysql-5.0.89.tar.gz
tar zxf mysql-5.0.89.tar.gz

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
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/libpng/zlib-1.2.6.tar.bz2
tar jxf zlib-1.2.6.tar.bz2

# git http://git-scm.com/download
wget -t 4 -nv http://git-core.googlecode.com/files/git-1.7.10.1.tar.gz
tar jxf git-1.7.6.tar.bz2

# http://curl.haxx.se/
wget -t 4 -nv http://curl.haxx.se/download/curl-7.25.0.tar.bz2
tar jxf curl-7.25.0.tar.bz2

rm -f *.gz *.tgz *.bz2 *.zip



