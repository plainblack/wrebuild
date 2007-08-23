#!/data/wre/prereqs/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2007 Plain Black Corporation.
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

my ($all, $help, $verbose);
$|=1;

GetOptions(
	'all'=>\$all,
	'help'=>\$help,
	'verbose'=>\$verbose
);

if ($help) {
	print <<STOP;

	Usage: $0

	Options:

	--all		Deletes all the demos.

	--help		Display this message.

	--verbose	Let's you know what's going on behind the scenes.

STOP
}

print "START UP.\n" if ($verbose);
print "Reading demo config.\n" if ($verbose);
my $config = WRE::Config->new;
my $file = WRE::File->new(wreConfig=>$config);
print "Getting the list of demo sites.\n" if ($verbose);
opendir(my $demodir, $config->getWebguiRoot("/etc"));
my @demos = ();
foreach my $file (readdir($demodir)) {
    next unless $file =~ m/^demo/;
    my $config = eval {Config::JSON->new($config->getWebguiRoot("/etc/".$file)) };
    if ($@) {
        print "Error reading $file\n" if ($verbose);
    }
    else {
        push @demos, $config;
    }
}
closedir($demodir);

print "Deleting demos.\n" if ($verbose);
foreach my $demo (@demos) {
    my $demoId = $demo->getFilename;
    $demoId =~ s/(demo.*)\.conf/$1/;
	if ($all || time() - $demo->get("demoCreated") > $config->get("demo/duration") * 60 * 60 * 24) {
		print "Deleting Site: ".$demoId."\n" if ($verbose);

        # database
		print "\tConnecting to database.\n" if ($verbose);
        my $databaseName = $demo->get("dsn");
        $databaseName =~ s/^DBI\:mysql\:(\w+).*$/$1/i; 
        my $databaseUser = $demo->get("dbuser");
        my $mysql = WRE::Mysql->new(wreConfig=>$config);
        my $db = eval{$mysql->getDatabaseHandle(
            password=>$config->get("demo/password"),
            username=>$config->get("demo/user")
            )};
        if ($@) {
            print "\tCan't connect to database, so can't delete site.\n" if ($verbose);
        }
        else {
		    print "\tDropping database.\n" if ($verbose);
            eval{$db->do("drop database $databaseName")};
		    print "\tError: $@\n" if ($@ && $verbose);
		    print "\tRevoking database privileges.\n" if ($verbose);
            eval{$db->do("revoke all privileges on ".$databaseName.".* from '".$databaseUser."'\@'%'")};
		    print "\tError: $@\n" if ($@ && $verbose);
            $db->disconnect;

            # web root
            print "\tDeleting Web Root.\n" if ($verbose);
            $file->delete($config->getDomainRoot("/demo/".$demoId));

            # webgui
            print "\tDeleting WebGUI Config.\n" if ($verbose);
            $file->delete($demo->getFilePath);

		    print "\tFinished deleting $demoId\n" if ($verbose);
        }
	}
    else {
		print "Skipping Site: ".$demoId."\n" if ($verbose);
	}
}
print "COMPLETE.\n" if ($verbose);

