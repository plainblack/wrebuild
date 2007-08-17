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
use Getopt::Long;
use WRE::Config;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Spectre;

$|=1;   # turn off buffering

my ($help, $verbose) = "";
my (@start, @stop, @restart, @status) = ();

GetOptions(
    "help"                      => \$help,
    "start|begin=s{1,4}"        => \@start,
    "stop|end|shutdown=s{1,4}"  => \@stop,
    "restart|cycle=s{1,4}"      => \@restart,
    "status|ping=s{1,4}"        => \@status,
    "verbose"                   => \$verbose,
    );

if ($help || !(scalar(@start) || scalar(@stop) || scalar(@restart) || scalar(@status))) {
    print <<STOP;
Usage: $0 --[action] [service] [service] [service]

Service Names:

    all             A shortcut that represents all the services.

    modperl         The Apache mod_perl service which runs WebGUI.

    modproxy        The Apache mod_proxy service which provides performance and security
                    services for WebGUI.

    mysql           WebGUI's database engine.

    spectre         WebGUI's workflow governor.

    web             A shortcut that represents both modperl and modproxy.

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

    --verbose       Print out additional information about failures.

STOP
}

my $config = WRE::Config->new;

if (scalar(@stop)) {
    if (grep /^spectre|all$/, @stop) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->stop}, "Stop S.P.E.C.T.R.E.");
    }
    if (grep /^modproxy|all|web$/, @stop) {
        printSuccess(sub{WRE::Modproxy->new(wreConfig=>$config)->stop}, "Stop mod_proxy");
    }
    if (grep /^modperl|all|web$/, @stop) {
        printSuccess(sub{WRE::Modperl->new(wreConfig=>$config)->stop}, "Stop mod_perl");
    }
    if (grep /^mysql|all$/, @stop) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->stop}, "Stop MySQL");
    }
}

if (scalar(@start)) {
    if (grep /^mysql|all$/, @start) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->start}, "Start MySQL");
    }
    if (grep /^modperl|all|web$/, @start) {
        printSuccess(sub{WRE::Modperl->new(wreConfig=>$config)->start}, "Start mod_perl");
    }
    if (grep /^modproxy|all|web$/, @start) {
        printSuccess(sub{WRE::Modproxy->new(wreConfig=>$config)->start}, "Start mod_proxy");
    }
    if (grep /^spectre|all$/, @start) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->start}, "Start S.P.E.C.T.R.E.");
    }
}

if (scalar(@restart)) {
    if (grep /^mysql|all$/, @restart) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->restart}, "Restart MySQL");
    }
    if (grep /^modperl|all|web$/, @restart) {
        printSuccess(sub{WRE::Modperl->new(wreConfig=>$config)->restart}, "Restart mod_perl");
    }
    if (grep /^modproxy|all|web$/, @restart) {
        printSuccess(sub{WRE::Modproxy->new(wreConfig=>$config)->restart}, "Restart mod_proxy");
    }
    if (grep /^spectre|all$/, @restart) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->restart}, "Restart S.P.E.C.T.R.E.");
    }
}

if (scalar(@status)) {
    if (grep /^mysql|all$/, @status) {
        printSuccess(sub{WRE::Mysql->new(wreConfig=>$config)->ping}, "Ping MySQL");
    }
    if (grep /^modperl|all|web$/, @status) {
        printSuccess(sub{WRE::Modperl->new(wreConfig=>$config)->ping}, "Ping mod_perl");
    }
    if (grep /^modproxy|all|web$/, @status) {
        printSuccess(sub{WRE::Modproxy->new(wreConfig=>$config)->ping}, "Ping mod_proxy");
    }
    if (grep /^spectre|all$/, @status) {
        printSuccess(sub{WRE::Spectre->new(wreConfig=>$config)->ping}, "Ping S.P.E.C.T.R.E.");
    }
}

#-------------------------------------------------------------------
sub printSuccess {
    my $action = shift;
    my $description = shift;
    print sprintf("%-22s", $description.":"); 
    if (eval { &$action }) {
        print "OK\n";
    }
    else {
        print "FAILED!\n";
        print "Additional information: ".$@."\n" if ($verbose);
    }
}

