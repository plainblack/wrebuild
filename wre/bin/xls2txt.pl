#!/data/wre/prereqs/bin/perl
use strict;
use lib '/data/wre/lib';

use POSIX ':sys_wait_h';
use WRE::Config;

my $wreConfig = WRE::Config->new;
my $waitFor = 15;

my $file = shift @ARGV;
my $endTime = time() + $waitFor;

# use open to get the pid, we won't be giving it any input
my $childPid = open my $fh, "|-", $wreConfig->getRoot('prereqs/bin/xls2csv') . " $file"
    or die "Error calling xls2csv! $!";

while (time() < $endTime) {
    # check if child exited
    if (waitpid(-1, WNOHANG)) {
        # there was an error
        if ($?) {
            warn "xls2csv returned an error!\n";
            exit $?;
        }
        close $fh;
        exit;
    }
    # sleep for 50ms
    select(undef, undef, undef, 0.050);
}

# There was a timeout, kill child and bail
kill 9, $childPid;
close $fh;
die "Timed out while running xls2csv!\n";
