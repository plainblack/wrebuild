#!/data/wre/prereqs/bin/perl
use strict;
use POSIX ':sys_wait_h';

my $wreRoot = '/data/wre/';
my $waitFor = 5;

my $file = shift @ARGV;
my $endTime = time() + $waitFor;

my $childPid = open my $fh, "-|", "${wreRoot}prereqs/bin/xls2csv $file" or die "Error calling xls2csv!";
my $rin = '';
vec($rin, fileno($fh), 1) = 1;
while (1) {
    if (waitpid(-1, WNOHANG)) {
        if ($?) {
            die "xls2csv returned an error!";
        }
        last;
    }
    my $ret = select(my $rout = $rin, undef, undef, $endTime - time());
    if (time() > $endTime) {
        kill 9, $childPid;
        close $fh;
        die "Timed out while running xls2csv!";
    }
    if ($ret) {
        sysread($fh, my $data, 1024);
        print $data;
    }
}

