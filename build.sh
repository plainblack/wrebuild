#!/bin/bash

#wre help
wrehelp() {
cat <<_WREHELP
 \`build.sh' builds the WebGUI Runtime Environment.

  Usage: $0 [OPTIONS] [PACKAGES]

  Build switches cause only select applications to build.
  They can be combined to build only certain apps.

  Example: ./build.sh --perl            # only perl will be built
           ./build.sh --perl --nginx    # only perl and nginx will build
           ./build.sh --all             # build all (except wdk)

  Options:

  --all             builds all packages
  --clean           cleans all pre-req folders for a new build
  --help            displays this screen

  Packages:         (must be built in the order shown below)

  --utilities       compiles and installs shared utilities
  --perl            compiles and installs perl
  --nginx           compiles and installs nginx
  --imagemagick     compiles and installs image magick
  --perlmodules     installs perl modules from cpan
  --wre             installs WebGUI Runtime Environment scripts and API

_WREHELP

}

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
        export WRE_BUILD_UTILS=1
        export WRE_BUILD_PERL=1
        export WRE_BUILD_NGINX=1
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

    --nginx)
        export WRE_BUILD_NGINX=1
    ;;

    --imageMagick | --imagemagick)
        export WRE_BUILD_IMAGEMAGICK=1
    ;;

    --wre)
        export WRE_BUILD_WRE=1
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
    export PREFIX="$WRE_ROOT/prereqs"
    export CC="gcc"
    export CXX="g++"
    export LD="ld"
    export CPPFLAGS="-I$PREFIX/include" 
    export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
    export CXXFLAGS="$CPPFLAGS -O3 -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
    export LIBS="-L$PREFIX/lib"
    export LD_LIBRARY_PATH="$PREFIX/include"
    export PERLCFGOPTS="-Aldflags=\"-L$PREFIX/lib\""

    # --cache-file speeds up configure a lot
    rm /tmp/Configure.cache
    export CFG_CACHE=""  #"--cache-file=/tmp/Configure.cache"  

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
            VERSION=`uname -r | cut -d. -f1` 
            if [ $VERSION == "10" ]; then
                export WRE_OSTYPE="Snow Leopard"
                export MACOSX_DEPLOYMENT_TARGET=10.6
                export CFLAGS="-m32 -arch i386 -g -Os -pipe -no-cpp-precomp $CFLAGS"
                export CCFLAGS="-m32 -arch i386 -g -Os -pipe -no-cpp-precomp $CCFLAGS"
                export CXXFLAGS="-m32 -arch i386 -g -Os -pipe $CXXFLAGS"
                export LDFLAGS="-m32 -arch i386 -bind_at_load $LDFLAGS"
                export CFG_LIBGCRYPT="--disable-asm"
                export PERLCFGOPTS="-Ald=\"-m32\" -Accflags=\"-m32\" -Aldflags=\"-m32\" -Acppflags=\"-m32\""
            fi
            if [ $VERSION == "9" ]; then
                export WRE_OSTYPE="Leopard"
            fi 
            if [ $VERSION == "8" ]; then
                export WRE_OSTYPE="Tiger"
            fi 
        ;;
    esac

    ### Program-specific options
    # Perl ./Config options
    export PERLCFGOPTS="$PERLCFGOPTS -Dprefix=$PREFIX -des"

    # ImageMagick options
    case "$WRE_OSNAME" in
        FreeBSD | OpenBSD)
            export IM_OPTION="--without-threads"
        ;;
    esac

    # made folders than don't exist
    mkdir -p $PREFIX/man/man1
    mkdir -p $PREFIX/conf
    mkdir -p $PREFIX/lib
    mkdir -p $PREFIX/libexec
    mkdir -p $PREFIX/include
    mkdir -p $PREFIX/var
    mkdir -p $PREFIX/bin

else
    echo "You must create a writable /data folder to begin."
    exit 0
fi


# error
checkError(){
    if [ $1 -ne 0 ];
    then
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
 	echo "##############################################"
        echo "WRE ERROR: "$2" did not complete successfully."
 	echo "##############################################"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        exit
    fi
}

printHeader(){
    echo "### ----------------------------------- ###"
    echo "#### Building $1       "
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
    echo "Configuring $1 with GNUMAKE=$WRE_MAKE $4 ./configure --prefix=$PREFIX $2"
    ./configure --prefix=$PREFIX $2; checkError $? "$1 configure"
    $WRE_MAKE; checkError $? "$1 make"
    $WRE_MAKE install $3; checkError $? "$1 make install"
    cd ..
}

# utilities
buildUtils(){
    printHeader "Utilities"
    cd source

    # catdoc
    cd catdoc-0.94.2
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi
    CATDOCARGS="--disable-wordview --without-wish --with-input=utf-8 \
        --with-output=utf-8 --disable-charset-check --disable-langinfo"
    ./configure $CFG_CACHE --prefix=$PREFIX $CATDOCARGS; checkError $? "catdoc Configure"
    $WRE_MAKE; checkError $? "catdoc make"
    cd src
    $WRE_MAKE install; checkError $? "catdoc make install src"
    cd ../docs
    $WRE_MAKE install; checkError $? "catdoc make install docs"
    cd ../charsets
    $WRE_MAKE install; checkError $? "catdoc make install charsets"
    cd ../..

    # xpdf
    buildProgram "xpdf-3.03" "$CFG_CACHE --without-x"

    cd $WRE_BUILDDIR
}

# perl
buildPerl(){
    printHeader "Perl"
    cd source/perl-5.14.2
    if [ "$WRE_CLEAN" == 1 ]; then
            $WRE_MAKE distclean
            $WRE_MAKE clean
    fi
    ./Configure $PERLCFGOPTS; checkError $? "Perl Configure" 
    $WRE_MAKE; checkError $? "Perl make"
    $WRE_MAKE install; checkError $? "Perl make install"
    cd $WRE_BUILDDIR
}

# nginx
buildNginx(){
    printHeader "nginx"
    cd source
    cd nginx-1.0.11
    #./configure --prefix=$PREFIX --with-pcre=../pcre-8.20 --with-http_ssl_module --with-openssl=../openssl-1.0.0e; checkError $? "nginx Configure"
    ./configure --prefix=$PREFIX --with-pcre=../pcre-8.20 --with-http_ssl_module; checkError $? "nginx Configure"
    $WRE_MAKE; checkError $? "nginx make"
    $WRE_MAKE install; checkError $? "nginx make install"

    cd $WRE_BUILDDIR
}


# Image Magick
buildImageMagick(){

    printHeader "Image Magick"
    cd source

    # lib xml
    buildProgram "libxml2-2.7.7" "$CFG_CACHE"

    # lib jpeg
    cd jpeg-8c
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi
    ./configure $CFG_CACHE --enable-shared --prefix=$PREFIX; checkError $? "libjpeg Configure"
    $WRE_MAKE; checkError $? "libjpeg make"
    $WRE_MAKE install; checkError $? "libjpeg make install"
    cd ..

    # freetype
    buildProgram "freetype-2.4.8" "-enable-shared $CFG_CACHE"

    # lib ungif
    buildProgram "giflib-4.1.6" "--enable-shared $CFG_CACHE"

    # lib png
    buildProgram "libpng-1.5.7" "--enable-shared $CFG_CACHE"

    # graphviz
    buildProgram "graphviz-2.24.0" "$CFG_CACHE --enable-static --with-libgd=no --with-mylibgd=no --disable-java --disable-swig --disable-perl --disable-python --disable-php --disable-ruby --disable-sharp --disable-python23 --disable-python24 --disable-python25 --disable-r --disable-tcl --disable-guile --disable-io --disable-lua --disable-ocaml"
    ln -s $PREFIX/bin/dot_static $PREFIX/bin/dot 

    # image magick
    cd ImageMagick-* # when you update this version number, update the one below as well
    printHeader "Image Magick"
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi
    GNUMAKE=$WRE_MAKE ./configure LD=ld --enable-delegate-build LDFLAGS=-L$PREFIX/lib CPPFLAGS=-I$PREFIX/include --enable-shared --prefix=$PREFIX --with-jpeg --with-png --with-perl --without-x --with-xml
    $WRE_MAKE; checkError $? "Image Magick make"
    $WRE_MAKE install; checkError $? "Image Magick make install"

}

# most perl modules are installed the same way
# param1: module directory
# param2: parameters to pass to Makefile.PL
installPerlModule() {
    cd $1
    printHeader "PM $1 with $2"
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi
    perl Makefile.PL $2 CCFLAGS="$CFLAGS"; checkError $? "$1 Makefile.PL"
    $WRE_MAKE; checkError $? "$1 make"
    #$WRE_MAKE test; checkError $? "$1 make test"
    $WRE_MAKE install; checkError $? "$1 make install"
    cd ..
}

installPerlModules () {
    printHeader "Perl Modules"
    cd source/perlmodules
    export PERL_MM_USE_DEFAULT=1 # makes it so perl modules don't ask questions
    cpan App::cpanminus
    cpanm Task::WebGUI
    if [ "$WRE_OSTYPE" != "Leopard" ] && [ "$WRE_OSTYPE" != "Snow Leopard" ]; then
        cpanm http://backpan.perl.org/authors/id/D/DU/DURIST/Proc-ProcessTable-0.44.tar.gz
    fi
    # detecting shared memory properly on 2.6 kernels
    if [ "$WRE_OSNAME" == "Linux" ]; then
        cpanm Linux::Smaps
    fi

    cd $WRE_BUILDDIR
}




#wre utils
installWreUtils(){
    printHeader "WebGUI Runtime Environment Core and Utilities"
    cp -Rf wre /data/
}

# make the WRE distro smaller by getting rid of non-essential stuff
makeItSmall(){
    printHeader "Making WRE smaller"
    rm -Rf $PREFIX/man
    rm -Rf $PREFIX/manual
    rm -Rf $PREFIX/README.TXT
    rm -Rf $PREFIX/docs
    rm -Rf $PREFIX/share/doc
    rm -Rf $PREFIX/share/gtk-doc
    rm -Rf $PREFIX/share/man
    rm -Rf $PREFIX/share/ImageMagick*
    rm -Rf $WRE_ROOT/etc/original
    rm -Rf $WRE_ROOT/etc/extra
}

#
# build stuff
if [ "$WRE_BUILD_UTILS" == 1 ]; then
    buildUtils
fi
if [ "$WRE_BUILD_PERL" == 1 ]; then
    buildPerl
fi
if [ "$WRE_BUILD_NGINX" == 1 ]; then
    buildNginx
fi
if [ "$WRE_BUILD_IMAGEMAGICK" == 1 ]; then
    buildImageMagick
fi
if [ "$WRE_BUILD_PM" == 1 ]; then
    installPerlModules
fi
if [ "$WRE_BUILD_WRE" == 1 ]; then
    installWreUtils
fi
makeItSmall
printHeader "Complete And Successful"



