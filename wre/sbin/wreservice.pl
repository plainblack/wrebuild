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
use WRE::Host;
use WRE::Apache;
use WRE::Nginx;
use WRE::Spectre;

$|=1;   # turn off buffering

my ($quiet, $help, $verbose) = "";
my (@start, @stop, @restart, @status, @reload) = ();

GetOptions(
    "help"                      => \$help,
    "start|begin=s{1,4}"        => \@start,
    "stop|end|shutdown=s{1,4}"  => \@stop,
    "restart|cycle=s{1,4}"      => \@restart,
    "reload=s{1,4}"             => \@reload,
    "status|ping=s{1,4}"        => \@status,
    "verbose"                   => \$verbose,
    "quiet"                     => \$quiet,
    );

if ($help || !(scalar(@start) || scalar(@stop) || scalar(@restart) || scalar(@status) || scalar(@reload))) {
    print <<STOP;
Usage: $0 --[action] [service] [service] [service]

Service Names:

    all             A shortcut that represents all the services.

    apache          The apache/modperl service which runs WebGUI.

    nginx           The nginx service which provides performance and security
                    services for WebGUI.

    spectre         WebGUI's workflow governor.

    web             A shortcut that represents both apache and nginx.

Actions:

    --begin         An alias for --start.

    --end           An alias for --stop.

    --ping          An alias for --status.

    --restart       Stops and then starts a service again.

    --shutdown      An alias for --stop.

    --start         Puts a service online.

    --status        Checks to see if a service is currently alive.

    --stop          Takes a service offline.

Options:

    --help          This message.

    --quiet         No output unless there's an error.

    --verbose       Print out additional information about failures.

STOP
}

my $config = WRE::Config->new;
my $host = WRE::Host->new(wreConfig => $config);

unless ($host->isPrivilegedUser || $quiet) {
    print "\nWARNING: Because you are not an administrator on this system, you will not be able to
        start or stop services on ports 1-1024.\n\n";
}

if (scalar(@stop)) {
    if (grep /^spectre|all$/, @stop) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->stop}, "Stop S.P.E.C.T.R.E.");
    }
    if (grep /^nginx|modproxy|all|web$/, @stop) {
        printSuccess(sub{WRE::Nginx->new(wreConfig=>$config)->stop}, "Stop nginx");
    }
    if (grep /^apache|modperl|all|web$/, @stop) {
        printSuccess(sub{WRE::Apache->new(wreConfig=>$config)->stop}, "Stop apache");
    }
}

if (scalar(@start)) {
    if (grep /^apache|modperl|all|web$/, @start) {
        printSuccess(sub{WRE::Apache->new(wreConfig=>$config)->start}, "Start apache");
    }
    if (grep /^nginx|modproxy|all|web$/, @start) {
        printSuccess(sub{WRE::Nginx->new(wreConfig=>$config)->start}, "Start nginx");
    }
    if (grep /^spectre|all$/, @start) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->start}, "Start S.P.E.C.T.R.E.");
    }
}

if (scalar(@restart)) {
    if (grep /^apache|modperl|all|web$/, @restart) {
        printSuccess(sub{WRE::Apache->new(wreConfig=>$config)->restart}, "Restart apache");
    }
    if (grep /^nginx|modproxy|all|web$/, @restart) {
        printSuccess(sub{WRE::Nginx->new(wreConfig=>$config)->restart}, "Restart nginx");
    }
    if (grep /^spectre|all$/, @restart) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->restart}, "Restart S.P.E.C.T.R.E.");
    }
}

if (scalar(@status)) {
    if (grep /^apache|modperl|all|web$/, @status) {
        printSuccess(sub{WRE::Apache->new(wreConfig=>$config)->ping}, "Ping apache");
    }
    if (grep /^nginx|modproxy|all|web$/, @status) {
        printSuccess(sub{WRE::Nginx->new(wreConfig=>$config)->ping}, "Ping nginx");
    }
    if (grep /^spectre|all$/, @status) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->ping}, "Ping S.P.E.C.T.R.E.");
    }
}

#-------------------------------------------------------------------
sub printSuccess {
    my $action = shift;
    my $description = shift;
    print sprintf("%-22s", $description.":") unless ($quiet); 
    if (eval { &$action }) {
        print "OK\n" unless ($quiet);
    }
    else {
        print "FAILED!\n" unless ($quiet);
        print "Additional information: ".$@."\n" if ($verbose);
    }
}

