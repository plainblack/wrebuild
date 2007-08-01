#!/data/wre/prereqs/bin/perl

use lib '/data/wrebuild/wre/lib';
use strict;
use Getopt::Long;
use WRE::Config;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Spectre;

my ($help) = "";
my (@start, @stop, @restart, @status) = ();

GetOptions(
    "help"              => \$help,
    "start=s{1,4}"      => \@start,
    "stop=s{1,4}"       => \@stop,
    "restart=s{1,4}"    => \@restart,
    "status=s{1,4}"     => \@status,
    );

if ($help || !(scalar(@start) || scalar(@stop) || scalar(@restart) || scalar(@status))) {

}

my $config = WRE::Config->new;

if (scalar(@start)) {
    if (grep /^mysql$/, @start) {
        printSuccess(WRE::Mysql->new(wreConfig=>$config)->start, "Start MySQL");
    }
}

sub printSuccess {
    my $status = shift;
    my $description = shift;
    if ($status) {
        print "$description:\tOK\n";
    }
    else {
        print "$description:\tFAILED!\n";
        print "Additional information: ".$@."\n";
    }
}

