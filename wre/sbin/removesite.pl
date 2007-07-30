#!/data/wre/prereqs/perl/bin/perl

my $wreRoot = '/data/wre';

use lib $wreRoot.'/lib';
use strict;
use GetOpt::Long;
use WRE::Config;
use WRE::Site;

$| = 1; 

my $config = WRE::Config->new();
my ($sitename, $adminPassword, $help) = "";
GetOptions(
    "help"                  => \$help,
    "sitename=s"            => \$sitename,
    "adminPassword=s"       => \$adminPassword,
    );

my $dbAdminUser = $config->get("mysql")->{adminUser};

if ($help || $adminPassword eq "" || $sitename eq "") {
    print <<STOP;
Usage: perl $0 --sitename=www.example.com --adminPassword=123qwe

Options:

 --adminPassword    The password for the "$dbAdminUser" in your MySQL database.

 --help             This message.

 --sitename         The name of the site you'd like to delete. For example: www.example.com 
                    or intranet.example.com

STOP
}


my $site = WRE::Site->new(
    wreConfig       => $config,
    sitename        => $sitename,
    adminPassword   => $adminPassword,
    );
if ($site->checkDeletionSanity) {
    $site->delete;
    print $site->getSitename." was deleted. Don't forget to restart the web servers and Spectre.\n";
} 
else {
    print $site->getSitename." could not be deleted because: ".$!."\n";
}



