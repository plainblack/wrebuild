#!/bin/bash

#wre help
wrehelp() {
cat <<_WREHELP
 \`build.sh' builds the WebGUI Runtime Environment.

  Usage: $0 [OPTIONS] [PACKAGES]

  Build switches cause only select applications to build.
  They can be combined to build only certain apps.

  Example: ./build.sh --nginx           # only nginx will be built
           ./build.sh --all             # build all

  Options:

  --all             builds all packages
  --clean           cleans all pre-req folders for a new build
  --help            displays this screen

  Packages:         (must be built in the order shown below)

  --perlmodules     installs perl modules from cpan
  --nginx           compiles and installs nginx
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
        export WRE_BUILD_NGINX=1
        export WRE_BUILD_AWSTATS=1
        export WRE_BUILD_WRE=1
        export WRE_BUILD_PM=1
    ;;

    --nginx)
        export WRE_BUILD_NGINX=1
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


# most perl modules are installed the same way
# param1: module directory
# param2: parameters to pass to Makefile.PL
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
if [ "$WRE_BUILD_NGINX" == 1 ]; then
    buildNginx
fi
if [ "$WRE_BUILD_PM" == 1 ]; then
    installPerlModules
fi
if [ "$WRE_BUILD_WRE" == 1 ]; then
    installWreUtils
fi
makeItSmall
printHeader "Complete And Successful"



