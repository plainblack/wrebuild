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
my $childPid = open my $fh, "|-", $wreConfig->getRoot('prereqs/bin/pdf2txt') . " $file $file.txt"
    or die "Error calling pdf2txt! $!";

while (time() < $endTime) {
    # check if child exited
    if (waitpid(-1, WNOHANG)) {
        # there was an error
        if ($?) {
            warn "pdf2txt returned an error!\n";
            exit $?;
        }
        close $fh;
        open my $fh, "<", "$file.txt" or die "Cannot find results file! $!\n";
        while (my $line = <$fh>) {
            print $line;
        }
        close $fh;
        unlink "$file.txt";
        exit;
    }
    # sleep for 50ms
    select(undef, undef, undef, 0.050);
}

# There was a timeout, kill child and bail
kill 9, $childPid;
close $fh;
die "Timed out while running pdf2txt!\n";
