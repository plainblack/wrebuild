#!/data/wre/prereqs/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use lib '/data/wre/lib';
use strict;
use Getopt::Long;
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
Usage: $0 --sitename=www.example.com --adminPassword=123qwe

Options:

 --adminPassword    The password for the "$dbAdminUser" in your MySQL database.

 --help             This message.

 --sitename         The name of the site you'd like to delete. For example: www.example.com 
                    or intranet.example.com

STOP
    exit;
}


my $site = WRE::Site->new(
    wreConfig       => $config,
    sitename        => $sitename,
    adminPassword   => $adminPassword,
    );
if (eval {$site->checkDeletionSanity}) {
    $site->delete;
    print $site->sitename." was deleted. Don't forget to restart the web servers and Spectre.\n";
} 
else {
    print $site->sitename." could not be deleted because: ".$@."\n";
}



