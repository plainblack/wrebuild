#!/bin/bash

# This script will help you get all needed sources 
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir source
cd source

# imagemagick
wget ftp://ftp.nluug.nl/pub/ImageMagick/ImageMagick-6.4.9-4.tar.bz2
tar jxf ImageMagick-6.4.9-4.tar.bz2

# aspell dictionary
wget ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.tar.gz
tar zxf aspell-0.60.6.tar.gz

# aspell-en
wget ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell6-en-6.0-0.tar.bz2
tar jxf aspell6-en-6.0-0.tar.bz2

# awstats
wget http://surfnet.dl.sourceforge.net/sourceforge/awstats/awstats-6.9.tar.gz
tar zxf awstats-6.9.tar.gz

# catdoc .doc and .xls converter
wget http://ftp.wagner.pp.ru/pub/catdoc/catdoc-0.94.2.tar.gz
tar zxf catdoc-0.94.2.tar.gz

# oracle berkeley db
wget http://freshmeat.net/redir/berkeleydb/694/url_tgz/db-4.7.25.tar.gz
tar zxf db-4.7.25.tar.gz

# expat xml parser
wget http://surfnet.dl.sourceforge.net/sourceforge/expat/expat-2.0.1.tar.gz
tar zxf expat-2.0.1.tar.gz

# freetype portable font engine
wget http://surfnet.dl.sourceforge.net/sourceforge/freetype/freetype-2.3.8.tar.bz2
tar jxf freetype-2.3.8.tar.bz2

# httpd apache webserver
wget http://apache.mirror.transip.nl/httpd/httpd-2.2.11.tar.bz2
tar jxf httpd-2.2.11.tar.bz2

# lftp sophisticated ftp client
wget http://ftp.yars.free.net/pub/source/lftp/lftp-3.7.8.tar.bz2
tar jxf lftp-3.7.8.tar.bz2

# libjpeg image manipulation
wget http://freshmeat.net/redir/libjpeg/5665/url_tgz/jpegsrc.v6b.tar.gz
tar zxf jpegsrc.v6b.tar.gz

# libpng image manipulation
wget http://surfnet.dl.sourceforge.net/sourceforge/libpng/libpng-1.2.34.tar.bz2
tar jxf libpng-1.2.34.tar.bz2

# gnu libtool
wget http://ftp.gnu.org/gnu/libtool/libtool-1.5.26.tar.gz
tar zxf libtool-1.5.26.tar.gz

# libgif image manipulation
wget http://surfnet.dl.sourceforge.net/sourceforge/giflib/giflib-4.1.6.tar.bz2
tar jxf giflib-4.1.6.tar.bz2

# libxml2 xml c parser
wget ftp://xmlsoft.org/libxml2/libxml2-2.6.32.tar.gz
tar zxf libxml2-2.6.32.tar.gz

# modperl apache perl module
wget http://perl.apache.org/dist/mod_perl-2.0-current.tar.gz
tar zxf mod_perl-2.0-current.tar.gz

# mysql database server
wget http://dev.mysql.com/get/Downloads/MySQL-5.1/mysql-5.1.31.tar.gz/from/http://mirror.leaseweb.com/mysql/
tar zxf mysql-5.1.31.tar.gz

# neon http and webdav client
wget http://www.webdav.org/neon/neon-0.28.3.tar.gz
tar zxf neon-0.28.3.tar.gz

# openssl ssl toolkit
wget http://www.openssl.org/source/openssl-0.9.8j.tar.gz
tar zxf openssl-0.9.8j.tar.gz

# perl programming language
wget http://www.cpan.org/src/perl-5.8.9.tar.gz
tar zxf perl-5.8.9.tar.gz

# perlmodules
# SEE SEPARATE SCRIPT

# subversion source code revision system
wget http://subversion.tigris.org/downloads/subversion-1.5.5.tar.bz2
tar jxf subversion-1.5.5.tar.bz2

# swig script wrapper
wget http://surfnet.dl.sourceforge.net/sourceforge/swig/swig-1.3.38.tar.gz
tar zxf swig-1.3.38.tar.gz

# xpdf pdf generator
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.02.tar.gz
tar zxf xpdf-3.02.tar.gz

# patches TODO: incorporate in WRE
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.02pl1.patch
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.02pl2.patch

# zlib compression library
wget http://surfnet.dl.sourceforge.net/sourceforge/libpng/zlib-1.2.3.tar.bz2
tar jxf zlib-1.2.3.tar.bz2


