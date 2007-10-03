#!/data/wre/prereqs/bin/perl
use strict;
use POSIX ':sys_wait_h';

my $wreRoot = '/data/wre/';
my $waitFor = 5;

my $file = shift @ARGV;
my $endTime = time() + $waitFor;

my $childPid = open my $fh, "-|", "${wreRoot}prereqs/bin/catppt $file" or die "Error calling catppt!";
my $rin = '';
vec($rin, fileno($fh), 1) = 1;
while (1) {
    if (waitpid(-1, WNOHANG)) {
        if ($?) {
            die "catppt returned an error!";
        }
        last;
    }
    my $ret = select(my $rout = $rin, undef, undef, $endTime - time());
    if (time() > $endTime) {
        kill 9, $childPid;
        close $fh;
        die "Timed out while running catppt!";
    }
    if ($ret) {
        sysread($fh, my $data, 1024);
        print $data;
    }
}

