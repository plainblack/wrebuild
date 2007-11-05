#!/data/wre/prereqs/bin/perl

use strict;
use lib '/data/wre/lib';
use WRE::Config;
use WRE::File;
use WRE::Host;

my $config = WRE::Config->new;


# changing version number
my $version = "0.8.1";
print "\tUpdating version number to $version.";
$config->set("version",$version);
print "\tOK\n";

updateMysql($config);



sub updateMysql {
    my $config = shift;
    print "\tUpdating MySQL config file to support shorter search terms. See gotcha.txt.";
    my $file = WRE::File->new(wreConfig=>$config);
    my $host = WRE::Host->new(wreConfig=>$config);
    my $filename = ($host->getOsName eq "windows") ? "my.ini" : "my.cnf";
    my $path = $config->getRoot("/etc/".$filename);
    my $mycnf = $file->slurp($path);
    ${$mycnf} =~ s{\[mysqld\]}{[mysqld]\nft_min_word_len=2}xmg;
    $file->spit($path, $mycnf);
    print "\tOK\n";
}


