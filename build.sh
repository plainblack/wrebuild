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

    # aspell
    buildProgram "aspell-0.60.6" "" "exec_prefix=$PREFIX"
    cd aspell6-en-6.0-0
    if [ "$WRE_CLEAN" == 1 ]; then
        $WRE_MAKE distclean
        $WRE_MAKE clean
    fi  
    ./configure --vars ASPELL=$PREFIX/bin/aspell WORD_LIST_COMPRESS=$PREFIX/bin/word-list-compress; checkError $? "aspell-en configure"
    $WRE_MAKE; checkError $? "aspell-en make"
    $WRE_MAKE install ; checkError $? "aspell-en make install"

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
    GNUMAKE=$WRE_MAKE ./configure LD=ld --enable-delegate-build LDFLAGS=-L$PREFIX/lib CPPFLAGS=-I$PREFIX/include --enable-shared --prefix=/data/apps --with-jpeg --with-png --with-gif --with-perl --without-x --with-xml
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
        cpanm Proc::ProcessTable
    fi
    installPerlModule "Text-Aspell-0.09" "LIBS='-laspell'"
    # detecting shared memory properly on 2.6 kernels
    if [ "$WRE_OSNAME" == "Linux" ]; then
        cpanm Linux::Smaps
    fi

    cd $WRE_BUILDDIR
}




#awstats
installAwStats(){
    printHeader "AWStats"
    cp -RL source/awstats-7.0/* $PREFIX
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

#gooey
gooey() {
  printf '\x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x4d \x57 \xd0 \x57 \x57 \x57 \x4d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x40 \x23 \x23 \x35 \x35 \x35 \x35 \x35 \x35 \x23 \x23 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x57 \x23 \x23 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x35 \x40 \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x4d \x57 \x57 \x4d \x23 \x23 \x23 \x35 \x41 \x41 \x25 \x25 \x24 \x24 \x24 \x33 \x33 \x24 \x24 \x24 \x25 \x41 \x35 \x40 \xd0 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x33 \x24 \x25 \x25 \x41 \x35 \x35 \x41 \x25 \x25 \x24 \x4a \x37 \x37 \x37 \x37 \x37 \x3d \x3d \x3d \x37 \x33 \x24 \x25 \x41 \x23 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x25 \x41 \x35 \x41 \x41 \x25 \x25 \x33 \x33 \x24 \x41 \x41 \x35 \x23 \x40 \x40 \x40 \x40 \x35 \x43 \x43 \x24 \x25 \x41 \x23 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x3d \x33 \x41 \x35 \x35 \x41 \x41 \x41 \x41 \x41 \x35 \x23 \x23 \x23 \x23 \x23 \x23 \x23 \x40 \xd0 \x57 \xd0 \x43 \x4a \x24 \x25 \x23 \x41 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x23 \x41 \x41 \x23 \x23 \x35 \x41 \x41 \x41 \x41 \x41 \x41 \x35 \x35 \x25 \x24 \x33 \x33 \x33 \x33 \x33 \x24 \x35 \x35 \x43 \x25 \x25 \x35 \x25 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x25 \x57 \xd0 \x40 \x40 \x35 \x35 \x41 \x41 \x41 \x41 \x25 \x41 \x33 \x37 \x4a \x24 \x25 \x41 \x41 \x41 \x33 \x2c \x24 \x41 \x24 \x25 \x41 \x35 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \xd0 \x23 \xd0 \x23 \x35 \x41 \x41 \x41 \x25 \x25 \x4a \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \x4a \x25 \x41 \x41 \x41 \x41 \x24 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x28 \xa6 \x25 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x25 \x43 \x41 \x4d \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4a \x4a \x25 \x41 \x41 \x41 \x24 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x2e \x2c \x41 \xd0 \x40 \x35 \x41 \x41 \x41 \x25 \x43 \x35 \x20 \x40 \x43 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x43 \x33 \x25 \x41 \x41 \x25 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x37 \x28 \x23 \xd0 \x23 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x57 \x2a \xa6 \x24 \x57 \x41 \x4d \x20 \x20 \x20 \x20 \x3d \x24 \x25 \x41 \x25 \x4a \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x41 \x25 \x43 \xd0 \x20 \x40 \x27 \x21 \x3d \x21 \xa6 \x4d \x20 \x20 \x20 \x40 \x37 \x24 \x25 \x25 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x35 \x41 \x40 \x40 \x23 \x41 \x41 \x41 \x24 \x43 \x20 \x20 \xa9 \x24 \xa6 \xa6 \x33 \x4d \x20 \x20 \x20 \xa9 \x4a \x33 \x24 \x24 \x4a \x35 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x35 \x23 \x25 \x40 \x40 \x35 \x41 \x41 \x25 \x24 \x4a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \x4a \x33 \x24 \x43 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x33 \x24 \x33 \xd0 \x40 \x35 \x41 \x41 \x25 \x33 \x33 \x20 \x20 \x20 \x20 \xa9 \x20 \x20 \x20 \x20 \xa9 \x35 \x4a \x33 \x33 \x33 \x57 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x40 \x57 \x23 \x35 \x41 \x25 \x24 \x24 \xa9 \x40 \x25 \x4a \x4a \x33 \x25 \x23 \xd0 \x41 \x4a \x33 \x43 \x35 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x37 \x37 \xa9 \x20 \x20 \x4d \x33 \x3d \x28 \x41 \x4d \xd0 \x35 \x41 \x41 \x25 \x24 \x24 \x25 \x35 \x23 \x40 \xd0 \x40 \x23 \x41 \x24 \x33 \x25 \x3d \x35 \x25 \x41 \x35 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \xd0 \x21 \x37 \x41 \x20 \x20 \x4a \x4a \x23 \x25 \x43 \x40 \x4d \x40 \x35 \x41 \x41 \x41 \x35 \x35 \x35 \x23 \x23 \x23 \x23 \x35 \x35 \x25 \x25 \x25 \x3d \x24 \x25 \x41 \x23 \x35 \x23 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x35 \x28 \x40 \x4a \x43 \xa9 \x20 \x2c \x23 \x41 \x33 \x4a \x4a \x40 \x4d \xd0 \x23 \x35 \x41 \x41 \x25 \x25 \x25 \x41 \x41 \x41 \x41 \x24 \x33 \x24 \x25 \x24 \x3d \x33 \x24 \x41 \x40 \x33 \x40 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x4d \x43 \x37 \xd0 \xd0 \xa6 \x33 \xa9 \x20 \x2c \x41 \x24 \x4a \x33 \x33 \x4a \x41 \x57 \x57 \xd0 \x23 \x35 \x25 \x24 \x24 \x24 \x24 \x24 \x33 \x33 \x33 \x24 \x41 \x41 \x24 \x37 \x4a \x24 \x25 \x41 \x3d \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \xa9 \xa6 \x25 \x57 \x40 \x24 \x21 \x23 \x20 \x20 \x2a \x24 \x4a \x33 \x41 \x25 \x33 \x4a \x43 \x24 \x41 \x35 \x23 \x40 \x41 \x25 \x24 \x33 \x33 \x33 \x4a \x4a \x24 \x41 \x35 \x35 \x35 \x33 \x37 \x4a \x24 \x3d \x41 \x20 \x20 \x20 \x57 \x23 \x20 \x20 \x0d \x0a \x23 \xa6 \x57 \x23 \x35 \x33 \xa6 \x4a \x57 \x23 \xa6 \x43 \x24 \x23 \x35 \x25 \x24 \x33 \x43 \x28 \x43 \x4a \x4a \x4a \x24 \x25 \x25 \x24 \x33 \x33 \x43 \x43 \x24 \x25 \x41 \x35 \x35 \x23 \x41 \x4a \x37 \x43 \xa6 \x20 \x20 \x20 \xd0 \x21 \x35 \x20 \x0d \x0a \x25 \x3d \x23 \x23 \x35 \x35 \x28 \x3d \x3d \xa6 \x43 \x25 \x40 \x23 \x41 \x25 \x24 \x4a \x28 \x33 \x25 \x24 \x24 \x25 \x25 \x25 \x25 \x24 \x33 \x37 \x2a \x3d \x24 \x25 \x41 \x41 \x35 \x35 \x23 \x23 \x25 \x3d \x27 \x40 \x20 \x20 \x41 \x4a \x43 \xa9 \x0d \x0a \xd0 \xa6 \x25 \x41 \x41 \x35 \x35 \x41 \x41 \x40 \x40 \x40 \x23 \x35 \x41 \x24 \x4a \x3d \x4a \x35 \x41 \x25 \x25 \x41 \x41 \x25 \x24 \x24 \x43 \x27 \x3d \x43 \x4a \x33 \x24 \x25 \x41 \x41 \x35 \x23 \x40 \x23 \x43 \xa6 \x41 \x33 \x3d \x40 \x33 \x4d \x0d \x0a \x20 \x28 \x4a \x24 \x25 \x41 \x35 \x23 \x40 \x40 \x23 \x35 \x41 \x25 \x25 \x33 \x4a \xa6 \x23 \x23 \x41 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x21 \x21 \x21 \x37 \x43 \x4a \x33 \x25 \x25 \x41 \x35 \x23 \x40 \xd0 \x24 \x2a \x43 \x24 \x25 \x25 \x20 \x0d \x0a \x20 \x57 \x28 \x4a \x33 \x24 \x25 \x41 \x41 \x41 \x25 \x24 \x24 \x24 \x33 \x33 \x4a \x28 \xd0 \x23 \x35 \x41 \x41 \x41 \x41 \x25 \x24 \x4a \x2c \x24 \x24 \x4a \xa6 \x21 \xa6 \x3d \x43 \x33 \x24 \x25 \x41 \x35 \x23 \xd0 \x35 \x28 \x24 \x40 \x20 \x20 \x0d \x0a \x20 \x20 \xd0 \x43 \x37 \x33 \x33 \x33 \x24 \x24 \x33 \x33 \x33 \x33 \x33 \x33 \x41 \x24 \x40 \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x24 \x3d \x37 \x35 \x23 \x41 \x24 \x4a \x3d \xa6 \x21 \xa6 \x43 \x33 \x24 \x41 \x35 \x23 \x57 \x35 \x4a \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x57 \x41 \x25 \x24 \x24 \x24 \x25 \x25 \x35 \x23 \xd0 \xa9 \x20 \xa9 \x4a \x40 \x41 \x41 \x41 \x41 \x25 \x24 \x33 \x21 \x23 \xa9 \x23 \x23 \x35 \x25 \x24 \x33 \x4a \x35 \x37 \x28 \x37 \x24 \x25 \x35 \x40 \x4d \x25 \x41 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x24 \x41 \x25 \x24 \x41 \x41 \x41 \x24 \x33 \x2a \x57 \x20 \xa9 \x41 \x35 \x41 \x25 \x24 \x43 \x4d \xa9 \x40 \x37 \x28 \x24 \x41 \x35 \xd0 \x4d \x3d \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x37 \x24 \xa6 \x35 \x35 \x41 \x24 \x24 \x2c \xa9 \x20 \x20 \x57 \x37 \x25 \x24 \x33 \x43 \x20 \x20 \x20 \x20 \x25 \xa6 \x25 \x35 \x40 \x4d \x4a \xd0 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x40 \x4a \x57 \xa9 \x20 \x20 \x20 \x20 \x40 \x28 \x43 \x23 \x35 \x41 \x41 \x25 \x2c \x4d \x57 \x41 \x3d \x4a \x33 \x4a \x4a \x57 \x20 \x20 \x20 \x20 \x20 \x4a \x43 \x35 \x23 \x57 \x4a \x40 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x3d \x43 \x25 \x23 \xa9 \x20 \xa9 \x23 \x4a \xd0 \x23 \x35 \x35 \x35 \x41 \x2c \x41 \x3d \x28 \x43 \x33 \x25 \x23 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x23 \x28 \x35 \xd0 \x57 \x3d \xa9 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x43 \x35 \x40 \x25 \x24 \x25 \x23 \xd0 \x40 \x35 \x35 \x35 \x23 \x33 \x37 \xa9 \xa9 \xa9 \xa9 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x33 \x25 \x43 \x24 \xd0 \xd0 \x4a \x23 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x4d \x4a \x41 \x4d \x57 \x57 \xd0 \x23 \x35 \x35 \x23 \x23 \x33 \x3d \x4d \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x41 \xa6 \x43 \x41 \x24 \x33 \x23 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x41 \x4a \x41 \x23 \x40 \x23 \x23 \x35 \x25 \x43 \x24 \xa9 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \xa9 \x40 \x23 \x57 \xa9 \x20 \x20 \x20 \x20 \x0d \x0a \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x57 \x35 \x24 \x4a \x43 \x43 \x33 \x41 \xd0 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x20 \x0d \x0a \x0d \x0a';
  cat wre/docs/credits.txt
  exit 0;
}



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
if [ "$WRE_BUILD_AWSTATS" == 1 ]; then
    installAwStats
fi
if [ "$WRE_BUILD_WRE" == 1 ]; then
    installWreUtils
fi
makeItSmall
printHeader "Complete And Successful"



