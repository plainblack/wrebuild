#!/data/wre/prereqs/bin/perl
use strict;
use POSIX ':sys_wait_h';

my $wreRoot = '/data/wre/';
my $waitFor = 5;

my $file = shift @ARGV;
my $endTime = time() + $waitFor;

my $childPid = open my $fh, "-|", "${wreRoot}prereqs/bin/pdf2txt $file $file.txt" or die "Error calling pdf2txt!";
my $rin = '';
vec($rin, fileno($fh), 1) = 1;
while (1) {
    if (waitpid(-1, WNOHANG)) {
        if ($?) {
            die "pdf2txt returned an error!";
        }
        last;
    }
    my $ret = select(my $rout = $rin, undef, undef, $endTime - time());
    if (time() > $endTime) {
        kill 9, $childPid;
        close $fh;
        die "Timed out while running pdf2txt!";
    }
    if ($ret) {
        sysread($fh, my $data, 1024);
        print $data;
    }
}

open my $fh, "<", "$file.txt" or die "Cannot find results file!";
while (my $line = <$fh>) {
    print $line;
}
close $fh;
unlink "$file.txt";

