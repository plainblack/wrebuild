#!/data/wre/prereqs/bin/perl

use strict;
use lib '/data/wre/lib';
use WRE::Config;
use WRE::Mysql;

my $config = WRE::Config->new;


# updating mysql config
print "\tUpdating MySQL config file.";
system("/data/wre/prereqs/bin/perl -i -p -e's[skip-innodb][]g' /data/wre/etc/my.cnf");
print "\tOK\n";

# upgrading mysql
print "\tUpgrading MySQL tables to 5.1...\n";
my $mysql = WRE::Mysql->new({wreConfig=>$config});
$mysql->start;
print "Enter your MySQL ".$config->get("mysql")->{adminUser}." password.\n";
system("/data/wre/prereqs/bin/mysql_upgrade -u".$config->get("mysql")->{adminUser}." -p");
print "\tOK\n";


# changing version number
my $version = "0.9.0";
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
