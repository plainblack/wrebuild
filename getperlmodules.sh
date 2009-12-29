#!/bin/bash

# This script will help you get all needed perlmodules
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir -p source/perlmodules
cd source/perlmodules

# edit this to use your local cpan mirror http://www.cpan.org/SITES.html
#CPANMIRROR=http://search.cpan.org/CPAN
CPANMIRROR=http://archive.cs.uu.nl/mirror/CPAN

wget -t 4 -nv $CPANMIRROR/authors/id/A/AN/ANDYA/Test-Harness-3.17.tar.gz
tar zxf Test-Harness-3.17.tar.gz

# http://search.cpan.org/dist/Locales/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DM/DMUEY/Locales-0.15.tar.gz
tar zxf Locales-0.15.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/D/DW/DWHEELER/Text-Diff-HTML-0.06.tar.gz
tar zxf Text-Diff-HTML-0.06.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/C/CD/CDOLAN/CAM-PDF-1.52.tar.gz
tar zxf CAM-PDF-1.52.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/M/MH/MHOSKEN/Text-PDF-0.29a.tar.gz
tar zxf Text-PDF-0.29a.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/S/SI/SIFUKURT/Crypt-RC4-2.02.tar.gz
tar zxf Crypt-RC4-2.02.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MART/Net-OpenID-Consumer-1.03.tar.gz
tar zxf Net-OpenID-Consumer-1.03.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/B/BR/BRADFITZ/LWPx-ParanoidAgent-1.04.tar.gz
tar zxf LWPx-ParanoidAgent-1.04.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/B/BT/BTROTT/Crypt-DH-0.06.tar.gz
tar zxf Crypt-DH-0.06.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/T/TE/TELS/math/Math-BigInt-FastCalc-0.19.tar.gz
tar zxf Math-BigInt-FastCalc-0.19.tar.gz 

wget -t 4 -nv $CPANMIRROR/authors/id/I/IN/INGY/YAML-0.68.tar.gz
tar zxf YAML-0.68.tar.gz 

# http://search.cpan.org/dist/Class-Member/
wget -t 4 -nv $CPANMIRROR/authors/id/O/OP/OPI/Class-Member-1.6.tar.gz
tar zxf Class-Member-1.6.tar.gz 

# http://search.cpan.org/dist/Linux-Smaps/
wget -t 4 -nv $CPANMIRROR/authors/id/O/OP/OPI/Linux-Smaps-0.06.tar.gz
tar zxf Linux-Smaps-0.06.tar.gz 

# http://search.cpan.org/dist/GraphViz/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LB/LBROCARD/GraphViz-2.04.tar.gz
tar zxf GraphViz-2.04.tar.gz 

# http://search.cpan.org/dist/IPC-Run/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADAMK/IPC-Run-0.82.tar.gz
tar zxf IPC-Run-0.82.tar.gz

# http://search.cpan.org/dist/Readonly/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RO/ROODE/Readonly-1.03.tar.gz
tar zxf Readonly-1.03.tar.gz

# http://search.cpan.org/dist/Algorithm-C3/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BL/BLBLACK/Algorithm-C3-0.07.tar.gz
tar zxf Algorithm-C3-0.07.tar.gz

# http://search.cpan.org/dist/Class-C3-XS/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/Class-C3-XS-0.11.tar.gz
tar zxf Class-C3-XS-0.11.tar.gz

# http://search.cpan.org/dist/Class-C3/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/Class-C3-0.21.tar.gz
tar zxf Class-C3-0.21.tar.gz

# http://search.cpan.org/dist/XML-TreePP/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KA/KAWASAKI/XML-TreePP-0.38.tar.gz
tar zxf XML-TreePP-0.38.tar.gz

# http://search.cpan.org/dist/XML-FeedPP/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KA/KAWASAKI/XML-FeedPP-0.40.tar.gz
tar zxf XML-FeedPP-0.40.tar.gz

# http://search.cpan.org/dist/Net_SSLeay.pm/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/Net_SSLeay.pm-1.30.tar.gz
tar zxf Net_SSLeay.pm-1.30.tar.gz

# http://search.cpan.org/dist/Compress-Raw-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/Compress-Raw-Zlib-2.015.tar.gz
tar zxf Compress-Raw-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/IO-Compress-Base/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/IO-Compress-Base-2.015.tar.gz
tar zxf IO-Compress-Base-2.015.tar.gz

# http://search.cpan.org/dist/IO-Compress-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/IO-Compress-Zlib-2.015.tar.gz
tar zxf IO-Compress-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/Compress-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/Compress-Zlib-2.015.tar.gz
tar zxf Compress-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/Proc-ProcessTable/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DU/DURIST/Proc-ProcessTable-0.44.tar.gz
tar zxf Proc-ProcessTable-0.44.tar.gz

# http://search.cpan.org/dist/BSD-Resource/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JH/JHI/BSD-Resource-1.2902.tar.gz
tar zxf BSD-Resource-1.2902.tar.gz

# http://search.cpan.org/dist/URI/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/URI-1.51.tar.gz
tar zxf URI-1.51.tar.gz

# http://search.cpan.org/dist/IO-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TO/TOMHUGHES/IO-Zlib-1.09.tar.gz
tar zxf IO-Zlib-1.09.tar.gz

# http://search.cpan.org/dist/HTML-Tagset/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz
tar zxf HTML-Tagset-3.20.tar.gz

# http://search.cpan.org/dist/HTML-Tree/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETEK/HTML-Tree-3.23.tar.gz
tar zxf HTML-Tree-3.23.tar.gz

# http://search.cpan.org/dist/HTML-Parser/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/HTML-Parser-3.64.tar.gz
tar zxf HTML-Parser-3.64.tar.gz

# http://search.cpan.org/dist/libwww-perl/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/libwww-perl-5.834.tar.gz
tar zxf libwww-perl-5.834.tar.gz

# http://search.cpan.org/dist/CGI.pm/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LD/LDS/CGI.pm-3.42.tar.gz
tar zxf CGI.pm-3.42.tar.gz

# http://search.cpan.org/dist/Digest-HMAC/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/Digest-HMAC-1.01.tar.gz
tar zxf Digest-HMAC-1.01.tar.gz

# http://search.cpan.org/dist/Digest-MD5/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/Digest-MD5-2.39.tar.gz
tar zxf Digest-MD5-2.39.tar.gz

# http://search.cpan.org/dist/Digest-SHA1/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/Digest-SHA1-2.12.tar.gz
tar zxf Digest-SHA1-2.12.tar.gz

# http://search.cpan.org/dist/Module-Build/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EW/EWILHELM/Module-Build-0.31012.tar.gz
tar zxf Module-Build-0.31012.tar.gz

# http://search.cpan.org/dist/Params-Validate/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Params-Validate-0.91.tar.gz
tar zxf Params-Validate-0.91.tar.gz

# http://search.cpan.org/dist/DateTime-Locale/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-Locale-0.42.tar.gz
tar zxf DateTime-Locale-0.42.tar.gz

# http://search.cpan.org/dist/Class-Singleton/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AB/ABW/Class-Singleton-1.4.tar.gz
tar zxf Class-Singleton-1.4.tar.gz

# http://search.cpan.org/dist/DateTime-TimeZone/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-TimeZone-0.84.tar.gz
tar zxf DateTime-TimeZone-0.84.tar.gz

# http://search.cpan.org/dist/Time-Local/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Time-Local-1.1901.tar.gz
tar zxf Time-Local-1.1901.tar.gz

# http://search.cpan.org/dist/Test-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHWERN/Test-Simple-0.94.tar.gz
tar zxf Test-Simple-0.94.tar.gz

# http://search.cpan.org/dist/Devel-Symdump/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AN/ANDK/Devel-Symdump-2.08.tar.gz
tar zxf Devel-Symdump-2.08.tar.gz

# http://search.cpan.org/dist/Pod-Escapes/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SB/SBURKE/Pod-Escapes-1.04.tar.gz
tar zxf Pod-Escapes-1.04.tar.gz

# http://search.cpan.org/dist/ExtUtils-CBuilder/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KW/KWILLIAMS/ExtUtils-CBuilder-0.24.tar.gz
tar zxf ExtUtils-CBuilder-0.24.tar.gz

# http://search.cpan.org/dist/Pod-Coverage/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCLAMP/Pod-Coverage-0.19.tar.gz
tar zxf Pod-Coverage-0.19.tar.gz

# http://search.cpan.org/dist/Pod-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DW/DWHEELER/Pod-Simple-3.10.tar.gz
tar zxf Pod-Simple-3.10.tar.gz

# http://search.cpan.org/dist/podlators/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RR/RRA/podlators-2.2.2.tar.gz
tar zxf podlators-2.2.2.tar.gz

# http://search.cpan.org/dist/DateTime/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-0.4501.tar.gz
tar zxf DateTime-0.4501.tar.gz

# http://search.cpan.org/dist/DateTime-Format-Strptime/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RI/RICKM/DateTime-Format-Strptime-1.0800.tgz
tar zxf DateTime-Format-Strptime-1.0800.tgz

# http://search.cpan.org/dist/HTML-Template/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SA/SAMTREGAR/HTML-Template-2.9.tar.gz
tar zxf HTML-Template-2.9.tar.gz

# http://search.cpan.org/dist/Crypt-SSLeay/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DL/DLAND/Crypt-SSLeay-0.57.tar.gz
tar zxf Crypt-SSLeay-0.57.tar.gz

# http://search.cpan.org/dist/String-Random/
wget -t 4 -nv $CPANMIRROR/authors/id/S/ST/STEVE/String-Random-0.22.tar.gz
tar zxf String-Random-0.22.tar.gz

# http://search.cpan.org/dist/Time-HiRes/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JH/JHI/Time-HiRes-1.9719.tar.gz
tar zxf Time-HiRes-1.9719.tar.gz

# http://search.cpan.org/dist/Text-Balanced/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DC/DCONWAY/Text-Balanced-v2.0.0.tar.gz
tar zxf Text-Balanced-v2.0.0.tar.gz

# http://search.cpan.org/dist/Tie-IxHash/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GS/GSAR/Tie-IxHash-1.21.tar.gz
tar zxf Tie-IxHash-1.21.tar.gz

# http://search.cpan.org/dist/Tie-CPHash/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CJ/CJM/Tie-CPHash-1.04.tar.gz
tar zxf Tie-CPHash-1.04.tar.gz

# http://search.cpan.org/dist/Error/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SH/SHLOMIF/Error-0.17015.tar.gz
tar zxf Error-0.17015.tar.gz

# http://search.cpan.org/dist/HTML-Highlight/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TR/TRIPIE/HTML-Highlight-0.20.tar.gz
tar zxf HTML-Highlight-0.20.tar.gz

# http://search.cpan.org/dist/HTML-TagFilter/
wget -t 4 -nv $CPANMIRROR/authors/id/W/WR/WROSS/HTML-TagFilter-1.03.tar.gz
tar zxf HTML-TagFilter-1.03.tar.gz

# http://search.cpan.org/dist/IO-String/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/IO-String-1.08.tar.gz
tar zxf IO-String-1.08.tar.gz

# http://search.cpan.org/dist/Archive-Tar/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KA/KANE/Archive-Tar-1.44.tar.gz
tar zxf Archive-Tar-1.44.tar.gz

# http://search.cpan.org/dist/Archive-Zip/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADAMK/Archive-Zip-1.26.tar.gz
tar zxf Archive-Zip-1.26.tar.gz

# http://search.cpan.org/dist/XML-NamespaceSupport/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RB/RBERJON/XML-NamespaceSupport-1.09.tar.gz
tar zxf XML-NamespaceSupport-1.09.tar.gz

# http://search.cpan.org/dist/XML-Parser/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSERGEANT/XML-Parser-2.36.tar.gz
tar zxf XML-Parser-2.36.tar.gz

# http://search.cpan.org/dist/XML-SAX/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GR/GRANTM/XML-SAX-0.96.tar.gz
tar zxf XML-SAX-0.96.tar.gz

# http://search.cpan.org/dist/XML-SAX-Expat/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BJ/BJOERN/XML-SAX-Expat-0.40.tar.gz
tar zxf XML-SAX-Expat-0.40.tar.gz

# http://search.cpan.org/dist/XML-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GR/GRANTM/XML-Simple-2.18.tar.gz
tar zxf XML-Simple-2.18.tar.gz

# http://search.cpan.org/dist/XML-RSSLite/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JP/JPIERCE/XML-RSSLite-0.11.tgz
tar zxf XML-RSSLite-0.11.tgz

# http://search.cpan.org/dist/SOAP-Lite/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MK/MKUTTER/SOAP-Lite-0.710.08.tar.gz
tar zxf SOAP-Lite-0.710.08.tar.gz

# http://search.cpan.org/dist/DBI/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TI/TIMB/DBI-1.607.tar.gz
tar zxf DBI-1.607.tar.gz

# http://search.cpan.org/dist/DBD-mysql/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CA/CAPTTOFU/DBD-mysql-4.010.tar.gz
tar zxf DBD-mysql-4.010.tar.gz

# http://search.cpan.org/dist/Convert-ASN1/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Convert-ASN1-0.22.tar.gz
tar zxf Convert-ASN1-0.22.tar.gz

# http://search.cpan.org/dist/HTML-TableExtract/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSISK/HTML-TableExtract-2.10.tar.gz
tar zxf HTML-TableExtract-2.10.tar.gz

# http://search.cpan.org/dist/Finance-Quote/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EC/ECOCODE/Finance-Quote-1.17.tar.gz
tar zxf Finance-Quote-1.17.tar.gz

# http://search.cpan.org/dist/JSON-XS/
wget -t 4 -nv $CPANMIRROR/authors/id/M/ML/MLEHMANN/JSON-XS-2.26.tar.gz
tar zxf JSON-XS-2.26.tar.gz

# http://search.cpan.org/dist/JSON/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MAKAMAKA/JSON-2.12.tar.gz
tar zxf JSON-2.12.tar.gz

# http://search.cpan.org/dist/version/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JP/JPEACOCK/version-0.76.tar.gz
tar zxf version-0.76.tar.gz

# http://search.cpan.org/dist/Path-Class/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KW/KWILLIAMS/Path-Class-0.16.tar.gz
tar zxf Path-Class-0.16.tar.gz

# http://search.cpan.org/dist/Config-JSON/
#wget -t 4 -nv $CPANMIRROR/authors/id/R/RI/RIZEN/Config-JSON-1.3.1.tar.gz
#tar zxf Config-JSON-1.3.1.tar.gz

# http://search.cpan.org/dist/Config-JSON/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RI/RIZEN/Config-JSON-1.5000.tar.gz
tar zxf Config-JSON-1.5000.tar.gz

# http://search.cpan.org/dist/IO-Socket-SSL/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SU/SULLR/IO-Socket-SSL-1.22.tar.gz
tar zxf IO-Socket-SSL-1.22.tar.gz

# http://search.cpan.org/dist/Authen-SASL/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Authen-SASL-2.12.tar.gz
tar zxf Authen-SASL-2.12.tar.gz

# http://search.cpan.org/dist/perl-ldap/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/perl-ldap-0.39.tar.gz
tar zxf perl-ldap-0.39.tar.gz

# http://search.cpan.org/dist/Log-Log4perl/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHILLI/Log-Log4perl-1.20.tar.gz
tar zxf Log-Log4perl-1.20.tar.gz

# http://search.cpan.org/dist/POE/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-1.280.tar.gz
tar zxf POE-1.280.tar.gz

# http://search.cpan.org/dist/POE-Component-IKC/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GW/GWYN/POE-Component-IKC-0.2002.tar.gz
tar zxf POE-Component-IKC-0.2002.tar.gz

# http://search.cpan.org/dist/String-CRC32/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SO/SOENKE/String-CRC32-1.4.tar.gz
tar zxf String-CRC32-1.4.tar.gz

# http://search.cpan.org/dist/ExtUtils-XSBuilder/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GR/GRICHTER/ExtUtils-XSBuilder-0.28.tar.gz
tar zxf ExtUtils-XSBuilder-0.28.tar.gz

# http://search.cpan.org/dist/ExtUtils-MakeMaker/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHWERN/ExtUtils-MakeMaker-6.48.tar.gz
tar zxf ExtUtils-MakeMaker-6.48.tar.gz

# TODO trace to be replaced by: Devel::XRay http://search.cpan.org/dist/Devel-XRay/
wget -t 4 -nv http://backpan.perl.org/authors/id/J/JB/JBISBEE/trace-0.551.tar.gz
tar zxf trace-0.551.tar.gz

# http://search.cpan.org/dist/Clone/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RD/RDF/Clone-0.31.tar.gz
tar zxf Clone-0.31.tar.gz

# http://search.cpan.org/dist/Test-Pod/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/Test-Pod-1.26.tar.gz
tar zxf Test-Pod-1.26.tar.gz

# http://search.cpan.org/dist/Parse-RecDescent/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DC/DCONWAY/Parse-RecDescent-1.96.0.tar.gz
tar zxf Parse-RecDescent-1.96.0.tar.gz

# http://search.cpan.org/dist/libapreq2/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JO/JOESUF/libapreq2-2.08.tar.gz
tar zxf libapreq2-2.08.tar.gz

# http://search.cpan.org/dist/MailTools/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MARKOV/MailTools-2.04.tar.gz
tar zxf MailTools-2.04.tar.gz

# http://search.cpan.org/dist/IO-stringy/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DS/DSKOLL/IO-stringy-2.110.tar.gz
tar zxf IO-stringy-2.110.tar.gz

# http://search.cpan.org/dist/MIME-tools/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DO/DONEILL/MIME-tools-5.427.tar.gz
tar zxf MIME-tools-5.427.tar.gz

# http://search.cpan.org/dist/HTML-Template-Expr/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SA/SAMTREGAR/HTML-Template-Expr-0.07.tar.gz
tar zxf HTML-Template-Expr-0.07.tar.gz

# http://search.cpan.org/dist/Template-Toolkit/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AB/ABW/Template-Toolkit-2.22.tar.gz
tar zxf Template-Toolkit-2.22.tar.gz

# http://search.cpan.org/dist/Scalar-List-Utils/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Scalar-List-Utils-1.19.tar.gz
tar zxf Scalar-List-Utils-1.19.tar.gz

# http://search.cpan.org/dist/Graphics-ColorNames/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RR/RRWO/Graphics-ColorNames-2.11.tar.gz
tar zxf Graphics-ColorNames-2.11.tar.gz

# http://search.cpan.org/dist/Module-Load/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KA/KANE/Module-Load-0.16.tar.gz
tar zxf Module-Load-0.16.tar.gz

# http://search.cpan.org/dist/Color-Calc/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CF/CFAERBER/Color-Calc-1.05.tar.gz
tar zxf Color-Calc-1.05.tar.gz

# http://search.cpan.org/dist/DateTime-Format-Mail/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-Format-Mail-0.3001.tar.gz
tar zxf DateTime-Format-Mail-0.3001.tar.gz

# http://search.cpan.org/dist/Digest-BubbleBabble/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BT/BTROTT/Digest-BubbleBabble-0.01.tar.gz
tar zxf Digest-BubbleBabble-0.01.tar.gz

# http://search.cpan.org/dist/Net-IP/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MANU/Net-IP-1.25.tar.gz
tar zxf Net-IP-1.25.tar.gz

# http://search.cpan.org/dist/Net-DNS/
wget -t 4 -nv $CPANMIRROR/authors/id/O/OL/OLAF/Net-DNS-0.65.tar.gz
tar zxf Net-DNS-0.65.tar.gz

# http://search.cpan.org/dist/POE-Component-Client-DNS/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-Component-Client-DNS-1.051.tar.gz
tar zxf POE-Component-Client-DNS-1.051.tar.gz

# http://search.cpan.org/dist/POE-Component-Client-Keepalive/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-Component-Client-Keepalive-0.262.tar.gz
tar zxf POE-Component-Client-Keepalive-0.262.tar.gz

# http://search.cpan.org/dist/POE-Component-Client-HTTP/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-Component-Client-HTTP-0.893.tar.gz
tar zxf POE-Component-Client-HTTP-0.893.tar.gz

# http://search.cpan.org/dist/Test-Deep/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FD/FDALY/Test-Deep-0.103.tar.gz
tar zxf Test-Deep-0.103.tar.gz

# http://search.cpan.org/dist/Test-MockObject/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHROMATIC/Test-MockObject-1.09.tar.gz
tar zxf Test-MockObject-1.09.tar.gz

# http://search.cpan.org/dist/UNIVERSAL-isa/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHROMATIC/UNIVERSAL-isa-1.03.tar.gz
tar zxf UNIVERSAL-isa-1.03.tar.gz

# http://search.cpan.org/dist/UNIVERSAL-can/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHROMATIC/UNIVERSAL-can-1.15.tar.gz
tar zxf UNIVERSAL-can-1.15.tar.gz

# http://search.cpan.org/~evo/Class-MakeMethods-1.01/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EV/EVO/Class-MakeMethods-1.01.tar.gz
tar zxf Class-MakeMethods-1.01.tar.gz

# http://search.cpan.org/dist/Locale-US/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TB/TBONE/Locale-US-1.2.tar.gz
tar zxf Locale-US-1.2.tar.gz

# http://search.cpan.org/dist/Time-Format/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RO/ROODE/Time-Format-1.09.tar.gz
tar zxf Time-Format-1.09.tar.gz

# http://search.cpan.org/dist/Weather-Com/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SC/SCHNUECK/Weather-Com-0.5.3.tar.gz
tar zxf Weather-Com-0.5.3.tar.gz

# http://search.cpan.org/dist/File-Slurp/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/File-Slurp-9999.13.tar.gz
tar zxf File-Slurp-9999.13.tar.gz

# http://search.cpan.org/dist/Text-CSV_XS/
wget -t 4 -nv $CPANMIRROR/authors/id/H/HM/HMBRAND/Text-CSV_XS-0.69.tgz
tar zxf Text-CSV_XS-0.69.tgz

# http://search.cpan.org/dist/File-Temp/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TJ/TJENNESS/File-Temp-0.21.tar.gz
tar zxf File-Temp-0.21.tar.gz

# http://search.cpan.org/dist/File-Path/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DL/DLAND/File-Path-2.07.tar.gz
tar zxf File-Path-2.07.tar.gz

# http://search.cpan.org/dist/File-Which/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PEREINAR/File-Which-0.05.tar.gz
tar zxf File-Which-0.05.tar.gz

# http://search.cpan.org/dist/Class-InsideOut/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DA/DAGOLDEN/Class-InsideOut-1.09.tar.gz
tar zxf Class-InsideOut-1.09.tar.gz

# http://search.cpan.org/dist/HTML-TagCloud/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LB/LBROCARD/HTML-TagCloud-0.34.tar.gz
tar zxf HTML-TagCloud-0.34.tar.gz

# http://search.cpan.org/dist/Set-Infinite/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/Set-Infinite-0.63.tar.gz
tar zxf Set-Infinite-0.63.tar.gz

# http://search.cpan.org/dist/DateTime-Set/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/DateTime-Set-0.26.tar.gz
tar zxf DateTime-Set-0.26.tar.gz

# http://search.cpan.org/dist/DateTime-Event-Recurrence/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/DateTime-Event-Recurrence-0.16.tar.gz
tar zxf DateTime-Event-Recurrence-0.16.tar.gz

# http://search.cpan.org/dist/DateTime-Event-ICal/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/DateTime-Event-ICal-0.09.tar.gz
tar zxf DateTime-Event-ICal-0.09.tar.gz

# http://search.cpan.org/dist/MIME-Types/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MARKOV/MIME-Types-1.27.tar.gz
tar zxf MIME-Types-1.27.tar.gz

# http://search.cpan.org/dist/File-MMagic/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KN/KNOK/File-MMagic-1.27.tar.gz
tar zxf File-MMagic-1.27.tar.gz

# http://search.cpan.org/dist/PathTools/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SM/SMUELLER/PathTools-3.29.tar.gz
tar zxf PathTools-3.29.tar.gz

# http://search.cpan.org/dist/Module-Find/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CR/CRENZ/Module-Find-0.06.tar.gz
tar zxf Module-Find-0.06.tar.gz

# http://search.cpan.org/dist/Archive-Any/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CM/CMOORE/Archive-Any-0.0932.tar.gz
tar zxf Archive-Any-0.0932.tar.gz

# http://search.cpan.org/dist/Image-ExifTool/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EX/EXIFTOOL/Image-ExifTool-8.00.tar.gz
tar zxf Image-ExifTool-8.00.tar.gz

# http://search.cpan.org/dist/Text-Aspell/
wget -t 4 -nv $CPANMIRROR/authors/id/H/HA/HANK/Text-Aspell-0.09.tar.gz
tar zxf Text-Aspell-0.09.tar.gz

# http://search.cpan.org/dist/MySQL-Diff/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AS/ASPIERS/MySQL-Diff-0.33.tar.gz
tar zxf MySQL-Diff-0.33.tar.gz

# http://search.cpan.org/dist/List-MoreUtils/
wget -t 4 -nv $CPANMIRROR/authors/id/V/VP/VPARSEVAL/List-MoreUtils-0.22.tar.gz
tar zxf List-MoreUtils-0.22.tar.gz

# http://search.cpan.org/dist/Devel-StackTrace/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Devel-StackTrace-1.20.tar.gz
tar zxf Devel-StackTrace-1.20.tar.gz

# http://search.cpan.org/dist/Class-Data-Inheritable/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TM/TMTM/Class-Data-Inheritable-0.08.tar.gz
tar zxf Class-Data-Inheritable-0.08.tar.gz

# http://search.cpan.org/dist/Exception-Class/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Exception-Class-1.26.tar.gz
tar zxf Exception-Class-1.26.tar.gz

# http://search.cpan.org/dist/Sub-Uplevel/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DA/DAGOLDEN/Sub-Uplevel-0.2002.tar.gz
tar zxf Sub-Uplevel-0.2002.tar.gz

# http://search.cpan.org/dist/Carp-Assert/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHWERN/Carp-Assert-0.20.tar.gz
tar zxf Carp-Assert-0.20.tar.gz

# http://search.cpan.org/dist/Test-Exception/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADIE/Test-Exception-0.27.tar.gz
tar zxf Test-Exception-0.27.tar.gz

# http://search.cpan.org/dist/Carp-Assert-More/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/Carp-Assert-More-1.12.tar.gz
tar zxf Carp-Assert-More-1.12.tar.gz

# http://search.cpan.org/dist/HTTP-Server-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JE/JESSE/HTTP-Server-Simple-0.38.tar.gz
tar zxf HTTP-Server-Simple-0.38.tar.gz

# http://search.cpan.org/dist/Test-LongString/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RG/RGARCIA/Test-LongString-0.11.tar.gz
tar zxf Test-LongString-0.11.tar.gz

# http://search.cpan.org/dist/HTTP-Response-Encoding/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DA/DANKOGAI/HTTP-Response-Encoding-0.05.tar.gz
tar zxf HTTP-Response-Encoding-0.05.tar.gz

# http://search.cpan.org/dist/Array-Compare/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DA/DAVECROSS/Array-Compare-2.01.tar.gz
tar zxf Array-Compare-2.01.tar.gz

# http://search.cpan.org/dist/Tree-DAG_Node/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CO/COGENT/Tree-DAG_Node-1.06.tar.gz
tar zxf Tree-DAG_Node-1.06.tar.gz

# http://search.cpan.org/dist/Test-Warn/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHORNY/Test-Warn-0.11.tar.gz
tar zxf Test-Warn-0.11.tar.gz

# http://search.cpan.org/dist/Devel-Cycle/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LD/LDS/Devel-Cycle-1.10.tar.gz
tar zxf Devel-Cycle-1.10.tar.gz

# http://search.cpan.org/dist/PadWalker/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RO/ROBIN/PadWalker-1.7.tar.gz
tar zxf PadWalker-1.7.tar.gz

# http://search.cpan.org/dist/Test-Memory-Cycle/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/Test-Memory-Cycle-1.04.tar.gz
tar zxf Test-Memory-Cycle-1.04.tar.gz

# http://search.cpan.org/dist/Test-Taint/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/Test-Taint-1.04.tar.gz
tar zxf Test-Taint-1.04.tar.gz

# http://search.cpan.org/dist/WWW-Mechanize/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/WWW-Mechanize-1.54.tar.gz
tar zxf WWW-Mechanize-1.54.tar.gz

# http://search.cpan.org/dist/Test-WWW-Mechanize/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/Test-WWW-Mechanize-1.24.tar.gz
tar zxf Test-WWW-Mechanize-1.24.tar.gz

# http://search.cpan.org/dist/Test-JSON/
wget -t 4 -nv $CPANMIRROR/authors/id/O/OV/OVID/Test-JSON-0.06.tar.gz 
tar zxf Test-JSON-0.06.tar.gz

# http://search.cpan.org/dist/HTML-Packer/
wget -t 4 -nv $CPANMIRROR/authors/id/N/NE/NEVESENIN/HTML-Packer-0.4.tar.gz 
tar zxf HTML-Packer-0.4.tar.gz

# http://search.cpan.org/dist/JavaScript-Packer/
wget -t 4 -nv $CPANMIRROR/authors/id/N/NE/NEVESENIN/JavaScript-Packer-0.02.tar.gz
tar zxf JavaScript-Packer-0.02.tar.gz

# http://search.cpan.org/dist/CSS-Packer/
wget -t 4 -nv $CPANMIRROR/authors/id/N/NE/NEVESENIN/CSS-Packer-0.2.tar.gz
tar zxf CSS-Packer-0.2.tar.gz

# http://search.cpan.org/dist/Business-Tax-VAT-Validation/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BP/BPGN/Business-Tax-VAT-Validation-0.20.tar.gz
tar zxf Business-Tax-VAT-Validation-0.20.tar.gz

# http://search.cpan.org/dist/Scope-Guard/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHOCOLATE/Scope-Guard-0.03.tar.gz
tar zxf Scope-Guard-0.03.tar.gz

# http://search.cpan.org/dist/Digest-SHA/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSHELOR/Digest-SHA-5.47.tar.gz
tar zxf Digest-SHA-5.47.tar.gz

# http://search.cpan.org/dist/JavaScript-Minifier-XS/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GT/GTERMARS/JavaScript-Minifier-XS-0.05.tar.gz
tar zxf JavaScript-Minifier-XS-0.05.tar.gz

# http://search.cpan.org/dist/CSS-Minifier-XS/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GT/GTERMARS/CSS-Minifier-XS-0.03.tar.gz
tar zxf CSS-Minifier-XS-0.03.tar.gz

# http://search.cpan.org/dist/Crypt-OpenSSL-Random/
wget -t 4 -nv $CPANMIRROR/authors/id/I/IR/IROBERTS/Crypt-OpenSSL-Random-0.04.tar.gz
tar zxf Crypt-OpenSSL-Random-0.04.tar.gz

# http://search.cpan.org/dist/Crypt-OpenSSL-RSA/
wget -t 4 -nv $CPANMIRROR/authors/id/I/IR/IROBERTS/Crypt-OpenSSL-RSA-0.26.tar.gz
tar zxf Crypt-OpenSSL-RSA-0.26.tar.gz

# http://search.cpan.org/dist/Crypt-CBC/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LD/LDS/Crypt-CBC-2.30.tar.gz
tar zxf Crypt-CBC-2.30.tar.gz

# http://search.cpan.org/dist/Test-Class/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADIE/Test-Class-0.31.tar.gz
tar zxf Test-Class-0.31.tar.gz

# http://search.cpan.org/dist/XML-SAX-Writer/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PERIGRIN/XML-SAX-Writer-0.52.tar.gz
tar zxf XML-SAX-Writer-0.52.tar.gz

# http://search.cpan.org/dist/Text-Iconv/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MP/MPIOTR/Text-Iconv-1.7.tar.gz
tar zxf Text-Iconv-1.7.tar.gz

# http://search.cpan.org/dist/XML-Filter-BufferText/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RB/RBERJON/XML-Filter-BufferText-1.01.tar.gz
tar zxf XML-Filter-BufferText-1.01.tar.gz

# http://search.cpan.org/dist/Net-CIDR-Lite/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DO/DOUGW/Net-CIDR-Lite-0.20.tar.gz
tar zxf Net-CIDR-Lite-0.20.tar.gz

# http://search.cpan.org/dist/Params-Util/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADAMK/Params-Util-1.00.tar.gz
tar zxf Params-Util-1.00.tar.gz

# http://search.cpan.org/dist/Sub-Install/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RJ/RJBS/Sub-Install-0.925.tar.gz
tar zxf Sub-Install-0.925.tar.gz

# http://search.cpan.org/dist/Data-OptList/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RJ/RJBS/Data-OptList-0.104.tar.gz
tar zxf Data-OptList-0.104.tar.gz

# http://search.cpan.org/dist/Sub-Exporter/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RJ/RJBS/Sub-Exporter-0.982.tar.gz
tar zxf Sub-Exporter-0.982.tar.gz

# http://search.cpan.org/dist/Devel-GlobalDestruction/
wget -t 4 -nv $CPANMIRROR/authors/id/N/NU/NUFFIN/Devel-GlobalDestruction-0.02.tar.gz
tar zxf Devel-GlobalDestruction-0.02.tar.gz

# http://search.cpan.org/dist/MRO-Compat/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/MRO-Compat-0.11.tar.gz
tar zxf MRO-Compat-0.11.tar.gz

# http://search.cpan.org/dist/Sub-Name/
wget -t 4 -nv $CPANMIRROR/authors/id/X/XM/XMATH/Sub-Name-0.04.tar.gz
tar zxf Sub-Name-0.04.tar.gz

# http://search.cpan.org/dist/Task-Weaken/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADAMK/Task-Weaken-1.03.tar.gz
tar zxf Task-Weaken-1.03.tar.gz

# http://search.cpan.org/dist/Try-Tiny/
wget -t 4 -nv $CPANMIRROR/authors/id/N/NU/NUFFIN/Try-Tiny-0.02.tar.gz 
tar zxf Try-Tiny-0.02.tar.gz

# http://search.cpan.org/dist/Class-MOP/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/Class-MOP-0.95.tar.gz
tar zxf Class-MOP-0.95.tar.gz

# http://search.cpan.org/dist/Moose/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/Moose-0.93.tar.gz
tar zxf Moose-0.93.tar.gz

# http://search.cpan.org/dist/Getopt-Long-Descriptive/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RJ/RJBS/Getopt-Long-Descriptive-0.081.tar.gz
tar zxf Getopt-Long-Descriptive-0.081.tar.gz

# http://search.cpan.org/dist/MooseX-Getopt/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BO/BOBTFISH/MooseX-Getopt-0.25.tar.gz
tar zxf MooseX-Getopt-0.25.tar.gz

# http://search.cpan.org/dist/WWW-Pastebin-PastebinCom-Create/
wget -t 4 -nv $CPANMIRROR/authors/id/Z/ZO/ZOFFIX/WWW-Pastebin-PastebinCom-Create-0.002.tar.gz
tar zxf WWW-Pastebin-PastebinCom-Create-0.002.tar.gz

# http://search.cpan.org/dist/Class-Data-Accessor/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CL/CLACO/Class-Data-Accessor-0.04004.tar.gz
tar zxf Class-Data-Accessor-0.04004.tar.gz

# http://search.cpan.org/dist/WWW-Pastebin-RafbNet-Create/
wget -t 4 -nv $CPANMIRROR/authors/id/Z/ZO/ZOFFIX/WWW-Pastebin-RafbNet-Create-0.001.tar.gz
tar zxf WWW-Pastebin-RafbNet-Create-0.001.tar.gz

# http://search.cpan.org/dist/Spiffy/
wget -t 4 -nv $CPANMIRROR/authors/id/I/IN/INGY/Spiffy-0.30.tar.gz
tar zxf Spiffy-0.30.tar.gz

# http://search.cpan.org/dist/Clipboard/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KI/KING/Clipboard-0.09.tar.gz
tar zxf Clipboard-0.09.tar.gz

# http://search.cpan.org/dist/Mixin-Linewise/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RJ/RJBS/Mixin-Linewise-0.002.tar.gz
tar zxf Mixin-Linewise-0.002.tar.gz

# http://search.cpan.org/dist/Config-INI/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RJ/RJBS/Config-INI-0.014.tar.gz
tar zxf Config-INI-0.014.tar.gz

# http://search.cpan.org/dist/App-Nopaste/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SA/SARTAK/App-Nopaste-0.17.tar.gz
tar zxf App-Nopaste-0.17.tar.gz

# http://search.cpan.org/dist/Business-PayPal-API-rel/
wget -t 4 -nv $CPANMIRROR/authors/id/H/HE/HEMBREED/Business-PayPal-API-rel-0.69.tar.gz
tar zxf Business-PayPal-API-rel-0.69.tar.gz


rm -f *.gz *.tgz *.bz2 *.zip
