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

use lib '/data/wre/lib';
use strict;
use Carp;
use Getopt::Long;
use WRE::Config;

$|=1;   # turn off buffering

my ($help) = "";


if ($help) {
    print <<STOP;
Usage: $0 

Upgrades WRE configuration files after applying a new code base.

Options:

    --help          This message.

STOP
}

my $config = WRE::Config->new;

# Find upgrade files.
my %upgrade;
print "\nLooking for upgrades...\n";
my $upgradesPath = $config->getRoot("/var/upgrades");
opendir(DIR,$upgradesPath) or die "Couldn't open $upgradesPath\n";
my @files = readdir(DIR);
closedir(DIR);
foreach my $file (@files) {
    # ignore stuff that doesn't match our upgrade file pattern
    if ($file =~ /^upgrade_(\d+\.\d+\.\d+)-(\d+\.\d+\.\d+)\.(pl)$/) {
        if ($3 eq "pl") {
            print "\tFound upgrade executable from $1 to $2.\n";
            $upgrade{$1}{pl} = $file;
        }
        $upgrade{$1}{to} = $2;
    }
}

# what's our current version
my $currentVersion = $config->get("version");

# are any upgrades necessary
while ($upgrade{$currentVersion}{to}) {
    chdir $upgradesPath;
    # lets run it and see what happens
    print "Attempting upgrade from $currentVersion to $upgrade{$currentVersion}{to}.\n";
    print $^X." ".$upgrade{$currentVersion}{pl}."\n";
    unless (system($^X." ".$upgrade{$currentVersion}{pl})) {
        print "Upgrade from $currentVersion to $upgrade{$currentVersion}{to} completed successfully.\n";
        $currentVersion = $upgrade{$currentVersion}{to};
    }
    else {
        croak "Something bad happened during the upgrade from $currentVersion to $upgrade{$currentVersion}{to}.";
    }
}

print "Complete.\n";

