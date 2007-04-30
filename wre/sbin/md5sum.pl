#!/data/wre/prereqs/perl/bin/perl -T

## $Id: md5sum,v 1.1 2005/09/24 23:18:01 rizen Exp $

$VERSION = 0.1;

use strict;

=head1 NAME

md5sum-perl - generates or checks MD5 message digests

=head1 SYNOPSIS

 md5sum-perl [-bv] [-c [file]] | [file...]

=head1 DESCRIPTION

B<md5sum-perl> is a feature for feature compatible
version of md5sum(1) written in B<Perl>.

B<md5sum> generates or checks MD5 checksums. The algorithm to
generate the checksum is reasonably fast and strong enough
for most cases. Exact specification of the algorithm is in
RFC 1321.

Normally B<md5sum> generates checksums of all files given  to
it as a parameter and prints the checksums followed by the
filenames. If, however, B<-c> is specified, only one filename
parameter  is  allowed. This file should contain checksums
and filenames to which these checksums refer to,  and  the
files  listed  in that file are checked against the checksums
listed there. See option B<-c> for more information.

=head1 OPTIONS

=over 8

=item B<-b>

Use binary mode. In unix environment, only  difference between
this and the normal mode is an asterix
preceding the filename in the output.

=item B<-c>

Check md5sum of all files listed  in  file  against
the  checksum  listed  in the same file. The actual
format of that  file  is  the  same  as  output  of
B<md5sum>.  That is, each line in the file describes a
file. A line looks like:

B<E<lt>MD5 checksumE<gt> E<lt>filenameE<gt>>

So, for example, if a file was created and its message 
digest calculated like so:

B<echo foo E<gt> md5-test-file; md5sum md5-test-file>

B<md5sum> would report:

B<d3b07384d113edec49eaa6238ad5ff00  md5-test-file>

=item B<-v>

Be  more  verbose.  Print  filenames  when checking
(with B<-c>).

=back

=head1 BUGS

The related MD4 message digest  algorithm  was  broken  in
October  1995.  MD5 isn't looking as secure as it used to.

This manpage is not  quite  accurate  and  has  formatting
inconsistent with other manpages.

B<md5sum> does not accept standard options like B<--help>.

=head1 HISTORY

=over 8

=item 0.1

Feature complete beta release.

=item 0.01

Original version; created by h2xs 1.1.1.4 with options:
-ACX -m md5sum

=back

=head1 AUTHOR

B<md5sum>  was  originally  written  by Branko Lankester, and
modified afterwards by Colin Plumb and Ian Jackson <ijackson@gnu.ai.mit.edu>.
Manual  page was added by Juho Vuori <javuori@cc.helsinki.fi>.

B<md5sum-perl> is written by Paul Baker <md5sum@paulbaker.net>
using the B<Digest::MD5> module currently maintained by
Gisle Aas <gisle@ActiveState.com>.

=head1 SEE ALSO

perl(1), md5sum(1), L<Digest::MD5>.

=cut

## Load external modules.
use Digest::MD5;
use Getopt::Long;

## these variables will hold possible commandline options.
my ($opt_b, $opt_c, $opt_v) = ('') x 3;

## parse the commandline with bundling. $parse will be true if all
## went well.
Getopt::Long::Configure('bundling');
my $parse = GetOptions( b => \$opt_b, c => \$opt_c, v => \$opt_v );

## if they specified the -c option, there should be only one file.
if ($opt_c and @ARGV > 1) {
    $parse = 0;
}

## if $parse is false, then improper commandline usage occured.
## print tiny usage message and exit level 2.
unless ($parse) {

    print STDERR
        "usage: md5sum [-bv] [-c [file]] | [file...]\n",
        "Generates or checks MD5 Message Digests\n",
        "    -c  check message digests (default is generate)\n",
        "    -v  verbose, print file names when checking\n",
        "    -b  read files in binary mode\n",
        "The input for -c should be the list of message digests and\n",
        "file names that is printed on stdout by this program when it\n",
        "generates digests.\n";
    exit(2);

}

## see if we are processing stdin
unless (@ARGV) {
    my $use_stdin = 1;
    $ARGV[0] = \$use_stdin;
}

## create Digest::MD5 object to be reused throughout.
my $md5 = Digest::MD5->new;

## what is our exit code
my $exit    = 0;

## check md5sums if -c option specified.
if ($opt_c) {

    ## counters
    my $files   = 0;
    my $failed  = 0;
    my $maxlen  = 0;
    
    ## we are comparing md5sums
    while (<>) {
    
        ## kill line-feed
        chomp;
        ## grab the digest, binary, and filename.
        if (/(\S+)\s+(\*?)(.+)/) {
            
            my $md5sum  = $1;
            my $binary  = $2;
            my $file    = $3;
            my $filelen = length($file);
            
            $maxlen = $filelen if $filelen > $maxlen;
            
            $opt_v and print STDERR $file, ' ' x ($maxlen - $filelen + 1);
            
            ## try and open the file. print error and skip to next file
            ## if file can't be opened.
            my $fh;   
            unless (open($fh, "< $file")) {
                print STDERR q{md5sum: can't open }, $file, "\n";
                $exit = 2;
                next;
            }
            
            ## increment files counter since we opened it.
            ++$files;
            
            ## check for binary
            binmode $fh if $binary;
            
            ## reset MD5 object.
            $md5->reset;
            
            ## load file.
            $md5->addfile($fh);
            
            ## values should be equal if file matches.
            if ($md5sum eq $md5->hexdigest) {
                $opt_v and print STDERR "OK\n";
            }
            ## if not, do failed md5sum stuff
            else {
                if ($opt_v) {
                    print STDERR "FAILED\n";
                }
                else {
                    print STDERR q{md5sum: MD5 check failed for '}, $file, "'\n";
                }
                ## increment failed files counter;
                ++$failed;
                $exit ||= 1;
            }
        }
    }
    
    ## print result message if -v and failures
    if ($failed and $opt_v) {
        print STDERR 'md5sum: ', $failed, ' of ', $files,
            " file(s) failed MD5 check\n";
    }
    
}

## if -c option was not specified we are generating md5sums.
else {
    
    ## loop through all files specified on the commandline or STDIN.
    foreach my $file (@ARGV) {
    
        ## i am the filehandle.
        my $fh;
        
        ## if $file is a reference, that means we are supposed
        ## to process stdin, so set $fh to point to stdin.
        if (ref $file) {
            $fh = \*STDIN;
        }
        ## otherwise open the filename.
        else {
            ## quietly skip over directories.
            next if -d $file;
            
            ## if the open failed, output an error and
            ## skip to next file.
            unless (open($fh, "< $file")) {
                print STDERR $file, ": $!\n";
                next;
            }
        }
        
        ## see if we are doing binary mode.
        binmode $fh if $opt_b;
        
        ## reset MD5 object.
        $md5->reset;
        
        ## load the file.
        $md5->addfile($fh);
        
        my $digest = $md5->hexdigest;
        
        print $digest;
        print $opt_b ? ' *' : '  ', $file unless ref $file;
        print "\n";
        
    }

}

exit($exit);
