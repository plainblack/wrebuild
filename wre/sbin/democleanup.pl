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

use strict;
use lib '/data/wre/lib';
use Getopt::Long;
use WRE::Config;
use WRE::File;
use WRE::Mysql;
use WRE::Apache;
use 5.010;

my ($all, $help, $verbose);
$|=1;

GetOptions(
	'all'=>\$all,
	'help'=>\$help,
	'verbose'=>\$verbose
);

if ($help) {
	say <<STOP;

	Usage: $0

	Options:

	--all		Deletes all the demos.

	--help		Display this message.

	--verbose	Let's you know what's going on behind the scenes.

STOP
}

say "START UP." if ($verbose);
say "Reading demo config." if ($verbose);
my $config = WRE::Config->new;
my $file = WRE::File->new(wreConfig=>$config);
say "Getting the list of demo sites." if ($verbose);
opendir(my $demodir, $config->getWebguiRoot("/etc"));
my @demos = ();
foreach my $file (readdir($demodir)) {
    next unless $file =~ m/^demo/;
    my $config = eval {Config::JSON->new($config->getWebguiRoot("/etc/".$file)) };
    if ($@) {
        say "Error reading $file" if ($verbose);
    }
    else {
        push @demos, $config;
    }
}
closedir($demodir);

say "Deleting demos." if ($verbose);
foreach my $demo (@demos) {
    my $demoId = $demo->getFilename;
    $demoId =~ s/(demo.*)\.conf/$1/;
	if ($all || time() - $demo->get("demoCreated") > $config->get("demo/duration") * 60 * 60 * 24) {
		say "Deleting Site: ".$demoId."" if ($verbose);

        # database
		say "\tConnecting to database." if ($verbose);
        my $databaseName = $demo->get("dsn");
        $databaseName =~ s/^DBI\:mysql\:(\w+).*$/$1/i; 
        my $databaseUser = $demo->get("dbuser");
        my $mysql = WRE::Mysql->new(wreConfig=>$config);
        my $db = eval{$mysql->getDatabaseHandle(
            password=>$config->get("demo/password"),
            username=>$config->get("demo/user")
            )};
        if ($@) {
            say "\tCan't connect to database, so can't delete site." if ($verbose);
        }
        else {
		    say "\tDropping database." if ($verbose);
            eval{$db->do("drop database $databaseName")};
		    say "\tError: $@" if ($@ && $verbose);
		    say "\tRevoking database privileges." if ($verbose);
            eval{$db->do("revoke all privileges on ".$databaseName.".* from '".$databaseUser."'\@'%'")};
		    say "\tError: $@" if ($@ && $verbose);
            $db->disconnect;

            # web root
            say "\tDeleting Web Root." if ($verbose);
            $file->delete($config->getDomainRoot("/demo/".$demoId));

            # webgui
            say "\tDeleting WebGUI Config." if ($verbose);
            $file->delete($demo->getFilePath);

		    say "\tFinished deleting $demoId" if ($verbose);
        }
	}
    else {
		say "Skipping Site: ".$demoId if ($verbose);
	}
}
say "Restarting Apache" if $verbose;
if (eval { WRE::Apache->new(wreConfig=>$config)->restart; }) {
    say "OK" if $verbose;
}
else {
    say "Failed: $@";
}
say "COMPLETE." if ($verbose);

