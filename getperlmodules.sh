#!/bin/bash

# This script will help you get all needed perlmodules
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir -p source/perlmodules
cd source/perlmodules

# http://search.cpan.org/dist/Net_SSLeay.pm/
wget http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/Net_SSLeay.pm-1.30.tar.gz
tar zxf Net_SSLeay.pm-1.30.tar.gz

# http://search.cpan.org/dist/Compress-Raw-Zlib/
wget http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/Compress-Raw-Zlib-2.015.tar.gz
tar zxf Compress-Raw-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/IO-Compress-Base/
wget http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/IO-Compress-Base-2.015.tar.gz
tar zxf IO-Compress-Base-2.015.tar.gz

# http://search.cpan.org/dist/IO-Compress-Zlib/
wget http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/IO-Compress-Zlib-2.015.tar.gz
tar zxf IO-Compress-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/Compress-Zlib/
wget http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/Compress-Zlib-2.015.tar.gz
tar zxf Compress-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/Proc-ProcessTable/
wget http://search.cpan.org/CPAN/authors/id/D/DU/DURIST/Proc-ProcessTable-0.45.tar.gz
tar zxf Proc-ProcessTable-0.45.tar.gz

# http://search.cpan.org/dist/BSD-Resource/
wget http://search.cpan.org/CPAN/authors/id/J/JH/JHI/BSD-Resource-1.2902.tar.gz
tar zxf BSD-Resource-1.2902.tar.gz

# http://search.cpan.org/dist/URI/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/URI-1.37.tar.gz
tar zxf URI-1.37.tar.gz

# http://search.cpan.org/dist/IO-Zlib/
wget http://search.cpan.org/CPAN/authors/id/T/TO/TOMHUGHES/IO-Zlib-1.09.tar.gz
tar zxf IO-Zlib-1.09.tar.gz

# http://search.cpan.org/dist/HTML-Tagset/
wget http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz
tar zxf HTML-Tagset-3.20.tar.gz

# http://search.cpan.org/dist/HTML-Parser/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTML-Parser-3.60.tar.gz
tar zxf HTML-Parser-3.60.tar.gz

# http://search.cpan.org/dist/libwww-perl/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/libwww-perl-5.824.tar.gz
tar zxf libwww-perl-5.824.tar.gz

# http://search.cpan.org/dist/CGI.pm/
wget http://search.cpan.org/CPAN/authors/id/L/LD/LDS/CGI.pm-3.42.tar.gz
tar zxf CGI.pm-3.42.tar.gz

# http://search.cpan.org/dist/Digest-HMAC/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Digest-HMAC-1.01.tar.gz
tar zxf Digest-HMAC-1.01.tar.gz

# http://search.cpan.org/dist/Digest-MD5/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Digest-MD5-2.38.tar.gz
tar zxf Digest-MD5-2.38.tar.gz

# http://search.cpan.org/dist/Digest-SHA1/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Digest-SHA1-2.11.tar.gz
tar zxf Digest-SHA1-2.11.tar.gz

# http://search.cpan.org/dist/Module-Build/
wget http://search.cpan.org/CPAN/authors/id/E/EW/EWILHELM/Module-Build-0.31012.tar.gz
tar zxf Module-Build-0.31012.tar.gz

# http://search.cpan.org/dist/Params-Validate/
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Params-Validate-0.91.tar.gz
tar zxf Params-Validate-0.91.tar.gz

# http://search.cpan.org/dist/DateTime-Locale/
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/DateTime-Locale-0.42.tar.gz
tar zxf DateTime-Locale-0.42.tar.gz

# http://search.cpan.org/dist/Class-Singleton/
wget http://search.cpan.org/CPAN/authors/id/A/AB/ABW/Class-Singleton-1.4.tar.gz
tar zxf Class-Singleton-1.4.tar.gz

# http://search.cpan.org/dist/DateTime-TimeZone/
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/DateTime-TimeZone-0.84.tar.gz
tar zxf DateTime-TimeZone-0.84.tar.gz

# http://search.cpan.org/dist/Time-Local/
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Time-Local-1.1901.tar.gz
tar zxf Time-Local-1.1901.tar.gz

# http://search.cpan.org/dist/Test-Simple/
wget http://search.cpan.org/CPAN/authors/id/M/MS/MSCHWERN/Test-Simple-0.86.tar.gz
tar zxf Test-Simple-0.86.tar.gz

# http://search.cpan.org/dist/Devel-Symdump/
wget http://search.cpan.org/CPAN/authors/id/A/AN/ANDK/Devel-Symdump-2.08.tar.gz
tar zxf Devel-Symdump-2.08.tar.gz

# http://search.cpan.org/dist/Pod-Escapes/
wget http://search.cpan.org/CPAN/authors/id/S/SB/SBURKE/Pod-Escapes-1.04.tar.gz
tar zxf Pod-Escapes-1.04.tar.gz

# http://search.cpan.org/dist/ExtUtils-CBuilder/
wget http://search.cpan.org/CPAN/authors/id/K/KW/KWILLIAMS/ExtUtils-CBuilder-0.24.tar.gz
tar zxf ExtUtils-CBuilder-0.24.tar.gz

# http://search.cpan.org/dist/Pod-Coverage/
wget http://search.cpan.org/CPAN/authors/id/R/RC/RCLAMP/Pod-Coverage-0.19.tar.gz
tar zxf Pod-Coverage-0.19.tar.gz

# http://search.cpan.org/dist/Pod-Simple/
wget http://search.cpan.org/CPAN/authors/id/A/AR/ARANDAL/Pod-Simple-3.07.tar.gz
tar zxf Pod-Simple-3.07.tar.gz

# http://search.cpan.org/dist/podlators/
wget http://search.cpan.org/CPAN/authors/id/R/RR/RRA/podlators-2.2.2.tar.gz
tar zxf podlators-2.2.2.tar.gz

# http://search.cpan.org/dist/DateTime/
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/DateTime-0.4501.tar.gz
tar zxf DateTime-0.4501.tar.gz

# http://search.cpan.org/dist/DateTime-Format-Strptime/
wget http://search.cpan.org/CPAN/authors/id/R/RI/RICKM/DateTime-Format-Strptime-1.0800.tgz
tar zxf DateTime-Format-Strptime-1.0800.tgz

# http://search.cpan.org/dist/HTML-Template/
wget http://search.cpan.org/CPAN/authors/id/S/SA/SAMTREGAR/HTML-Template-2.9.tar.gz
tar zxf HTML-Template-2.9.tar.gz

# http://search.cpan.org/dist/Crypt-SSLeay/
wget http://search.cpan.org/CPAN/authors/id/D/DL/DLAND/Crypt-SSLeay-0.57.tar.gz
tar zxf Crypt-SSLeay-0.57.tar.gz

# http://search.cpan.org/dist/String-Random/
wget http://search.cpan.org/CPAN/authors/id/S/ST/STEVE/String-Random-0.22.tar.gz
tar zxf String-Random-0.22.tar.gz

# http://search.cpan.org/dist/Time-HiRes/
wget http://search.cpan.org/CPAN/authors/id/J/JH/JHI/Time-HiRes-1.9719.tar.gz
tar zxf Time-HiRes-1.9719.tar.gz

# http://search.cpan.org/dist/Text-Balanced/
wget http://search.cpan.org/CPAN/authors/id/D/DC/DCONWAY/Text-Balanced-v2.0.0.tar.gz
tar zxf Text-Balanced-v2.0.0.tar.gz

# http://search.cpan.org/dist/Tie-IxHash/
wget http://search.cpan.org/CPAN/authors/id/G/GS/GSAR/Tie-IxHash-1.21.tar.gz
tar zxf Tie-IxHash-1.21.tar.gz

# http://search.cpan.org/dist/Tie-CPHash/
wget http://search.cpan.org/CPAN/authors/id/C/CJ/CJM/Tie-CPHash-1.04.tar.gz
tar zxf Tie-CPHash-1.04.tar.gz

# http://search.cpan.org/dist/Error/
wget http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF/Error-0.17015.tar.gz
tar zxf Error-0.17015.tar.gz

# http://search.cpan.org/dist/HTML-Highlight/
wget http://search.cpan.org/CPAN/authors/id/T/TR/TRIPIE/HTML-Highlight-0.20.tar.gz
tar zxf HTML-Highlight-0.20.tar.gz

# http://search.cpan.org/dist/HTML-TagFilter/
wget http://search.cpan.org/CPAN/authors/id/W/WR/WROSS/HTML-TagFilter-1.03.tar.gz
tar zxf HTML-TagFilter-1.03.tar.gz

# http://search.cpan.org/dist/IO-String/
wget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/IO-String-1.08.tar.gz
tar zxf IO-String-1.08.tar.gz

# http://search.cpan.org/dist/Archive-Tar/
wget http://search.cpan.org/CPAN/authors/id/K/KA/KANE/Archive-Tar-1.44.tar.gz
tar zxf Archive-Tar-1.44.tar.gz

# http://search.cpan.org/dist/Archive-Zip/
wget http://search.cpan.org/CPAN/authors/id/A/AD/ADAMK/Archive-Zip-1.26.tar.gz
tar zxf Archive-Zip-1.26.tar.gz

# http://search.cpan.org/dist/XML-NamespaceSupport/
wget http://search.cpan.org/CPAN/authors/id/R/RB/RBERJON/XML-NamespaceSupport-1.09.tar.gztar zxf XML-NamespaceSupport-1.09.tar.gz

# http://search.cpan.org/dist/XML-Parser/
wget http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT/XML-Parser-2.36.tar.gz
tar zxf XML-Parser-2.36.tar.gz

# http://search.cpan.org/dist/XML-SAX/
wget http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-SAX-0.96.tar.gz
tar zxf XML-SAX-0.96.tar.gz

# http://search.cpan.org/dist/XML-SAX-Expat/
wget http://search.cpan.org/CPAN/authors/id/B/BJ/BJOERN/XML-SAX-Expat-0.40.tar.gz
tar zxf XML-SAX-Expat-0.40.tar.gz

# http://search.cpan.org/dist/XML-Simple/
wget http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-Simple-2.18.tar.gz
tar zxf XML-Simple-2.18.tar.gz

# ... more to come





