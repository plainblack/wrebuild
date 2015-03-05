#!/usr/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2012 Plain Black Corporation.
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
my ($var1, $var2, $var3, $var4, $var5, $var6, $var7, $var8, $var9, $var0, $sitename, $adminPassword, 
    $dbUser, $dbPassword, $dbName, $help, $fromConfig) = "";
GetOptions(
    "help"                  => \$help,
    "var1=s"                => \$var1,    
    "var2=s"                => \$var2,    
    "var3=s"                => \$var3,    
    "var4=s"                => \$var4,    
    "var5=s"                => \$var5,    
    "var6=s"                => \$var6,    
    "var7=s"                => \$var7,    
    "var8=s"                => \$var8,    
    "var9=s"                => \$var9,    
    "var0=s"                => \$var0,    
    "sitename=s"            => \$sitename,
    "adminPassword=s"       => \$adminPassword,
    "databaseUser=s"        => \$dbUser,
    "databasePassword=s"    => \$dbPassword, 
    "databaseName=s"        => \$dbName,
    "fromConfig=s"          => \$fromConfig,
    );

my $dbAdminUser = $config->get("mysql/adminUser");

if ($help || $adminPassword eq "" || ($sitename eq "" && $fromConfig eq '')) {
    print <<STOP;
Usage: $0 --sitename=www.example.com --adminPassword=123qwe

Options:

 --adminPassword    The password for the "$dbAdminUser" in your MySQL database.

 --databaseUser     The username you'd like created to access this site's database.

 --databasePassword The password you'd like created to access this site's database.

 --databaseName     The name of the database to create in MySQL (defaults to www_site_com for the domain www.site.com).

 --help             This message.

 --sitename         The name of the site you'd like to create. For example: www.example.com 
                    or intranet.example.com

 --fromConfig       Pull the sitename, dbUser and dbPassword from the referenced config file to build a new site.  Then,
                    it replaces the newly created config file with the old config file.  Handy for moving sites to
                    new servers.

 --var0-9           A series of variables you can use to arbitrary information into the site
                    creation process. These variables will be exposed to all templates used to
                    create this site.

STOP
    exit;
}

if ($fromConfig) {
    use Config::JSON;
    my $webguiConfig = Config::JSON->new($fromConfig);
    $sitename     ||= $webguiConfig->get('sitename')->[0];
    $dbUser       ||= $webguiConfig->get('dbuser');
    $dbPassword   ||= $webguiConfig->get('dbpass');
}


my $site = WRE::Site->new(
    wreConfig       => $config,
    sitename        => $sitename,
    adminPassword   => $adminPassword,
    databaseName    => $dbName,
    );
if (eval {$site->checkCreationSanity}) {
    $site->create({
        databaseUser        => $dbUser,
        databasePassword    => $dbPassword,
        var0                => $var0,
        var1                => $var1,
        var2                => $var2,
        var3                => $var3,
        var4                => $var4,
        var5                => $var5,
        var6                => $var6,
        var7                => $var7,
        var8                => $var8,
        var9                => $var9,
        });
    if ($fromConfig) {
        ##Get the spectre information from the newly created config file.
        use Config::JSON;
        my $new_config = Config::JSON->new($config->getWebguiRoot('etc/'.$sitename.".conf"));
        my $spectreSubnets  = $new_config->get('spectreSubnets');
        undef $new_config;

        ##Copy the file over
        printf "copying file from %s to %s\n", $fromConfig, $config->getWebguiRoot('etc/'.$sitename.".conf");
        use WRE::File;
        my $file = WRE::File->new(wreConfig=>$config);
        $file->copy($fromConfig, $config->getWebguiRoot('etc/'.$sitename.".conf"), { force => 1 });

        ##Update the spectre information in the old config
        print "Setting new spectre information into old config\n";
        my $orig_config = Config::JSON->new($config->getWebguiRoot('etc/'.$sitename.".conf"));
        $orig_config->set('spectreSubnets', $spectreSubnets);
    }
    print $site->sitename." was created. Don't forget to restart the web servers and Spectre.\n";
} 
else {
    print $site->sitename." could not be created because: ".$@."\n";
}



