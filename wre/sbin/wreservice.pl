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
use WRE::Host;
use WRE::Starman;
use WRE::Nginx;
use WRE::Mysql;
use WRE::Spectre;

$|=1;   # turn off buffering

my ($quiet, $help, $verbose) = "";
my (@start, @stop, @restart, @status) = ();

GetOptions(
    "help"                      => \$help,
    "start|begin=s{1,4}"        => \@start,
    "stop|end|shutdown=s{1,4}"  => \@stop,
    "restart|cycle=s{1,4}"      => \@restart,
    "status|ping=s{1,4}"        => \@status,
    "verbose"                   => \$verbose,
    "quiet"                     => \$quiet,
    );

if ($help || !(scalar(@start) || scalar(@stop) || scalar(@restart) || scalar(@status))) {
    print <<STOP;
Usage: $0 --[action] [service] [service] [service]

Service Names:

    all             A shortcut that represents all the services.

    starman         The starman service which runs WebGUI.

    nginx           The nginx service which provides performance and security
                    services for WebGUI.

    mysql           WebGUI's database engine.

    spectre         WebGUI's workflow governor.

    web             A shortcut that represents both starman and nginx.

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
    if (grep /^starman|modperl|all|web$/, @stop) {
        printSuccess(sub{WRE::Starman->new(wreConfig=>$config)->stop}, "Stop starman");
    }
    if (grep /^mysql|all$/, @stop) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->stop}, "Stop MySQL");
    }
}

if (scalar(@start)) {
    if (grep /^mysql|all$/, @start) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->start}, "Start MySQL");
    }
    if (grep /^starman|modperl|all|web$/, @start) {
        printSuccess(sub{WRE::Starman->new(wreConfig=>$config)->start}, "Start starman");
    }
    if (grep /^nginx|modproxy|all|web$/, @start) {
        printSuccess(sub{WRE::Nginx->new(wreConfig=>$config)->start}, "Start nginx");
    }
    if (grep /^spectre|all$/, @start) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->start}, "Start S.P.E.C.T.R.E.");
    }
}

if (scalar(@restart)) {
    if (grep /^mysql|all$/, @restart) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->restart}, "Restart MySQL");
    }
    if (grep /^starman|modperl|all|web$/, @restart) {
        printSuccess(sub{WRE::Starman->new(wreConfig=>$config)->restart}, "Restart starman");
    }
    if (grep /^nginx|modproxy|all|web$/, @restart) {
        printSuccess(sub{WRE::Nginx->new(wreConfig=>$config)->restart}, "Restart nginx");
    }
    if (grep /^spectre|all$/, @restart) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->restart}, "Restart S.P.E.C.T.R.E.");
    }
}

if (scalar(@status)) {
    if (grep /^mysql|all$/, @status) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->ping}, "Ping MySQL");
    }
    if (grep /^starman|modperl|all|web$/, @status) {
        printSuccess(sub{WRE::Starman->new(wreConfig=>$config)->ping}, "Ping starman");
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

