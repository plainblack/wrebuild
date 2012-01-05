#!/bin/bash

# This script will help you get all needed sources 
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir source
cd source

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.20.tar.gz
tar xfz pcre-8.20.tar.gz

wget http://nginx.org/download/nginx-1.0.11.tar.gz
tar xfz nginx-1.0.11.tar.gz

# imagemagick http://www.imagemagick.org/script/index.php
wget -t 4 -nv ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
tar zxf ImageMagick.tar.gz

# aspell dictionary http://aspell.net/
wget -t 4 -nv ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.tar.gz
tar zxf aspell-0.60.6.tar.gz

# aspell-en
wget -t 4 -nv ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell6-en-6.0-0.tar.bz2
tar jxf aspell6-en-6.0-0.tar.bz2

# catdoc .doc and .xls converter http://vitus.wagner.pp.ru/software/catdoc/
wget -t 4 -nv http://ftp.wagner.pp.ru/pub/catdoc/catdoc-0.94.2.tar.gz
tar zxf catdoc-0.94.2.tar.gz

# freetype portable font engine http://freetype.sourceforge.net/index2.html
wget -t 4 -nv http://download.savannah.gnu.org/releases/freetype/freetype-2.4.8.tar.gz
tar zxf freetype-2.4.8.tar.gz 

# libjpeg image manipulation http://www.ijg.org/
wget http://www.ijg.org/files/jpegsrc.v8c.tar.gz
tar xfz jpegsrc.v8c.tar.gz

# graphviz graph generator http://www.graphviz.org/
wget -t 4 -nv http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.24.0.tar.gz
tar xfz graphviz-2.24.0.tar.gz

# libpng image manipulation http://www.libpng.org/pub/png/libpng.html
wget ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.7.tar.gz
tar xfz libpng-1.5.7.tar.gz

# libgif image manipulation http://sourceforge.net/projects/giflib/
wget -t 4 -nv http://surfnet.dl.sourceforge.net/sourceforge/giflib/giflib-4.1.6.tar.bz2
tar jxf giflib-4.1.6.tar.bz2

# libxml2 xml c parser http://www.xmlsoft.org/
wget ftp://anonymous@xmlsoft.org/libxml2/libxml2-sources-2.7.7.tar.gz
tar xfz libxml2-sources-2.7.7.tar.gz

# perl programming language http://www.cpan.org/src/README.html
wget -t 4 -nv http://www.cpan.org/src/perl-5.14.2.tar.gz
tar zxf perl-5.14.2.tar.gz

# xpdf pdf generator http://www.foolabs.com/xpdf/download.html
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.03.tar.gz
tar xfz xpdf-3.03.tar.gz

