#!/data/wre/prereqs/bin/perl

use strict;
use lib '/data/wre/lib';
use WRE::Config;

my $config = WRE::Config->new;


# changing version number
my $version = "0.8.4";
print "\tUpdating version number to $version.";
$config->set("version",$version);
print "\tOK\n";

#example($config);

#sub example {
#    my $config = shift;
#    print "\tDoing something...";
#    # .. do work here ..
#    print "\tOK\n";
#}
