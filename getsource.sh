#!/bin/bash

# This script will help you get all needed sources 
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir source
cd source

# ncurses
wget -t 4 -nv http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.7.tar.gz
tar xfz ncurses-5.7.tar.gz
# readline
wget -t 4 -nv ftp://ftp.cwru.edu/pub/bash/readline-6.0.tar.gz
tar xfz readline-6.0.tar.gz

# imagemagick
wget -t 4 -nv ftp://ftp.nluug.nl/pub/ImageMagick/ImageMagick-6.4.9-4.tar.bz2
tar jxf ImageMagick-6.4.9-4.tar.bz2

# aspell dictionary
wget -t 4 -nv ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.tar.gz
tar zxf aspell-0.60.6.tar.gz

# aspell-en
wget -t 4 -nv ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell6-en-6.0-0.tar.bz2
tar jxf aspell6-en-6.0-0.tar.bz2

# awstats
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/awstats/awstats-6.9.tar.gz
tar zxf awstats-6.9.tar.gz
perl -ni -e 'print unless /^\s*if . !\$FileConfig/ .. /^\s+}/; print $_.qq/\t\terror("Could not open config file");\n\t}\n/ if /^\s*if . !\$FileConfig/;' awstats-6.9/wwwroot/cgi-bin/awstats.pl

# catdoc .doc and .xls converter
wget -t 4 -nv http://ftp.wagner.pp.ru/pub/catdoc/catdoc-0.94.2.tar.gz
tar zxf catdoc-0.94.2.tar.gz

# oracle berkeley db
wget -t 4 -nv http://freshmeat.net/redir/berkeleydb/694/url_tgz/db-4.7.25.tar.gz
tar zxf db-4.7.25.tar.gz

# expat xml parser
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/expat/expat-2.0.1.tar.gz
tar zxf expat-2.0.1.tar.gz

# freetype portable font engine
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/freetype/freetype-2.3.8.tar.bz2
tar jxf freetype-2.3.8.tar.bz2

# gnutls transport layer security
wget -t 4 -nv ftp://ftp.gnu.org/pub/gnu/gnutls/gnutls-2.6.4.tar.bz2
tar jxf gnutls-2.6.4.tar.bz2


# httpd apache webserver
wget -t 4 -nv http://apache.mirror.transip.nl/httpd/httpd-2.2.11.tar.bz2
tar jxf httpd-2.2.11.tar.bz2

# lftp sophisticated ftp client
wget -t 4 -nv http://ftp.yars.free.net/pub/source/lftp/lftp-3.7.8.tar.bz2
tar jxf lftp-3.7.8.tar.bz2

# libiconv unicode conversion tool
wget -t 4 -nv http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.12.tar.gz
tar zxf libiconv-1.12.tar.gz

# libjpeg image manipulation
wget -t 4 -nv http://freshmeat.net/redir/libjpeg/5665/url_tgz/jpegsrc.v6b.tar.gz
tar zxf jpegsrc.v6b.tar.gz
mv jpeg-6b libjpeg-6b

# graphviz graph generator
wget -t 4 -nv http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.22.1.tar.gz
tar xfz graphviz-2.22.1.tar.gz

# libpng image manipulation
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/libpng/libpng-1.2.34.tar.bz2
tar jxf libpng-1.2.34.tar.bz2

# gnu libtool
wget -t 4 -nv http://ftp.gnu.org/gnu/libtool/libtool-2.2.6a.tar.gz
tar zxf libtool-2.2.6a.tar.gz

# libgif image manipulation
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/giflib/giflib-4.1.6.tar.bz2
tar jxf giflib-4.1.6.tar.bz2

# libgcrypt crypt library
wget -t 4 -nv ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.4.4.tar.bz2
tar jxf libgcrypt-1.4.4.tar.bz2

# libgpg-error error messages
wget -t 4 -nv ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.7.tar.bz2
tar jxf libgpg-error-1.7.tar.bz2

# libxml2 xml c parser
wget -t 4 -nv ftp://xmlsoft.org/libxml2/libxml2-2.7.3.tar.gz
tar zxf libxml2-2.7.3.tar.gz

# modperl apache perl module
wget -t 4 -nv http://perl.apache.org/dist/mod_perl-2.0-current.tar.gz
tar zxf mod_perl-2.0-current.tar.gz

# mysql database server
wget -t 4 -nv http://dev.mysql.com/get/Downloads/MySQL-5.1/mysql-5.1.32.tar.gz/from/http://mirror.leaseweb.com/mysql/
tar zxf mysql-5.1.32.tar.gz

# openssl ssl toolkit
wget -t 4 -nv http://www.openssl.org/source/openssl-0.9.8j.tar.gz
tar zxf openssl-0.9.8j.tar.gz

# perl programming language
wget -t 4 -nv http://www.cpan.org/src/perl-5.10.0.tar.gz
tar zxf perl-5.10.0.tar.gz

# perlmodules
# SEE SEPARATE SCRIPT

# xpdf pdf generator
wget -t 4 -nv ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.02.tar.gz
tar zxf xpdf-3.02.tar.gz

# patches TODO: incorporate in WRE
wget -t 4 -nv ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.02pl1.patch
wget -t 4 -nv ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.02pl2.patch

# zlib compression library
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/libpng/zlib-1.2.3.tar.bz2
tar jxf zlib-1.2.3.tar.bz2

# rsync
wget -t 4 -nv http://rsync.samba.org/ftp/rsync/rsync-3.0.5.tar.gz
tar xfz rsync-3.0.5.tar.gz


