#!/data/wre/prereqs/bin/perl
use strict;
use lib '/data/wre/lib';

use POSIX ':sys_wait_h';
use WRE::Config;

my $wreConfig = WRE::Config->new;
my $waitFor = 5;

my $file = shift @ARGV;
my $endTime = time() + $waitFor;
$| = 1;

my $childPid = fork();
unless ($childPid) {
    my $ret = system "c:\\ff.bat -s us-ascii $file";
    #my $ret = system $wreConfig->getRoot('prereqs/bin/catdoc') . " -s us-ascii $file";
	die "Error calling catdoc! $!"
		if $ret;
    exit;
}
while (time() < $endTime) {
    if (waitpid(-1, WNOHANG)) {
        exit $?;
    }
}
kill 9, $childPid;
die "Timeout!";
