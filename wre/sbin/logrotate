#!/data/wre/prereqs/perl/bin/perl

#####
## logrotate.pl for the WebGUI Runtime Environment
## based upon perl-logrotate.pl by Aki Tossavainen <cmouse@youzen.ext.b2.fi> (c) 2004
##
# Does a log file rotation as defined by config file.
# Does not break open logfiles, just truncates them.
####

use strict;

# Configuration file to use.
our $config_file = '/data/wre/etc/logrotate.conf';

# Init variables
our @logfiles;

# no compression by default
our $compress = 0;

# 1 week.
our $rotate_time = 604800;

# 5 files
our $rotate_files = 3;

# locations
our $status_file = '/data/wre/var/logrotate.status';

# to avoid complaints
our %status;

sub parse_time($) {
    my ($t) = @_;
    my @time = split / /, $t;
    return 0 if ( @time == 0 );
    return 0 if ( $time[0] =~ /\D/ );
    my $number = $time[0];
    if ( @time > 1 ) {
        $number = $time[0];

        # we have some definition after the number
        # hours
        $number *= 3600 if ( $time[1] eq 'hour' );
        $number *= 3600 if ( $time[1] eq 'hours' );

        # days
        $number *= 86400 if ( $time[1] eq 'day' );
        $number *= 86400 if ( $time[1] eq 'days' );

        # weeks
        $number *= 604800 if ( $time[1] eq 'week' );
        $number *= 604800 if ( $time[1] eq 'weeks' );
    }
    return $number;
}

sub parse_config($) {
    my ($file) = @_;
    open CONFIG, '<' . $file or die("Unable to open config file $file\n");
    while (<CONFIG>) {
        chomp;
        next if ( $_[0] eq '#' );
        my @line = split / /, $_, 2;
        next if ( $line[0] =~ /$\#/ );
        if ( @line > 1 ) {

            # they all take args
            if ( $line[0] eq 'compress' ) {
                if ( $line[1] eq 'yes' || $line[1] eq '1' ) {
                    $compress = 1;
                    next;
                }
                elsif ( $line[1] eq 'no' || $line[1] eq '0' ) {
                    $compress = 0;
                    next;
                }
                die("Invalid value for compress: must be one of yes,1,no,0");
            }
            if ( $line[0] eq 'logfile' ) {
                push( @logfiles, $line[1] );
                next;
            }
            if ( $line[0] eq 'rotate-time' ) {
                die( "Invalid rotate-time '" . $line[1] . "'\n" )
                    if ( ( $rotate_time = parse_time( $line[1] ) ) == 0 );
                next;
            }
            if ( $line[0] eq 'keep-files' ) {
                die("Invalid keep-files") if ( $line[1] =~ /\D/ );
                $rotate_files = $line[1];
                next;
            }
        }
        elsif (@line) {
            die( $line[0] . ": All options have at least 1 parameter" );
        }
    }
    close CONFIG;
}

sub recurseDomainFolder {
    my $path = shift;
    if ( opendir( DIR, $path ) ) {
        my @filelist = readdir(DIR);
        closedir(DIR);
        foreach my $file (@filelist) {
            if ( $file =~ /^access.log$/ ) {
                push( @logfiles, $path . "/" . $file );
            }
            else {
                recurseDomainFolder( $path . "/" . $file )
                    unless ( $file =~ /public$/ || $file eq ".." || $file eq "." );
            }
        }
    }
}

sub findLogFiles {
    push( @logfiles, "/data/wre/prereqs/apache/logs/modperl.error.log" );
    push( @logfiles, "/data/wre/prereqs/apache/logs/modproxy.error.log" );
    push( @logfiles, "/data/wre/prereqs/apache/logs/modrewrite.log" );
    push( @logfiles, "/data/wre/var/wremonitor.log" );
    push( @logfiles, "/data/wre/var/webgui.log" );
    recurseDomainFolder("/data/domains");
}

parse_config($config_file);
findLogFiles();

if ($compress) {
    use Compress::Zlib;
}

# read status file
if ( !-e $status_file ) {
    open STATUS, '>' . $status_file or die("Unable to create status file\n");
    close STATUS;
}

open STATUS, '<' . $status_file or die("Unable to open status file\n");
while (<STATUS>) {
    chomp;
    my @line = split / /;
    if ( @line == 2 ) {
        $status{ $line[0] } = $line[1];
    }
}
close STATUS;

# now that we know what we are expected to do, we'll start
for my $logfile (@logfiles) {

    # first we try to read the entire log file into memory. then we
    # instantly truncate it, 'move' all the existing logfiles +1 forward
    # and create possibly compressed .0.bz2 file.
    # simple eh?
    # first we check the status file, maybe it doesn't need rotating as of yet
    next if ( defined( $status{$logfile} ) && ( time - $status{$logfile} < $rotate_time ) );

    # open file.
    if ( open LOGFILE, '<' . $logfile ) {

        # good... reel it in.
        my @data = <LOGFILE>;
        close LOGFILE;
        if ( ( open LOGFILE, '>', $logfile ) ) {

            # truncate worked. proceed.
            my $str = join "", @data;
            if ($compress) {
                $str = Compress::Zlib::memGzip($str);
            }

            # juggle files
            for my $i ( 0 .. ( $rotate_files - 2 ) ) {

                # to avoid making keep-files + 1 files...
                my $n = $rotate_files - $i - 1;

                # if we use compressed files, we check this.
                if ($compress) {
                    if ( -e $logfile . '.' . $n . '.gz' ) {
                        unlink $logfile . '.' . $n . '.gz';
                    }
                    rename $logfile . '.' . ( $n - 1 ) . '.gz', $logfile . '.' . $n . '.gz';
                }
                else {

                    # and if not, this.
                    if ( -e $logfile . '.' . $n ) {
                        unlink $logfile . '.' . $n;
                    }
                    rename $logfile . '.' . ( $n - 1 ), $logfile . '.' . $n;
                }
            }

            # create the .0 file
            if ($compress) {
                if ( !( open LOGFILE, '>' . $logfile . '.0.gz' ) ) {
                    print "Unable to open $logfile.0.gz - placing it back to your logfile\n";
                    open LOGFILE, '>>' . $logfile;
                    print LOGFILE Compress::Zlib::memGunzip($str);
                    close LOGFILE;
                    next;
                }
            }
            else {
                if ( !( open LOGFILE, '>' . $logfile . '.0' ) ) {
                    print "Unable to open $logfile.0.gz - placing it back to your logfile\n";
                    open LOGFILE, '>>' . $logfile;
                    print LOGFILE Compress::Zlib::memGunzip($str);
                    close LOGFILE;
                    next;
                }
            }
            print LOGFILE $str;
            close LOGFILE;

            # marking it rotated if it's really rotated.
            $status{$logfile} = time;

            # and that's it.
        }
        else {
            print "Unable to truncate file $logfile\n";
        }
    }
    else {
        print "Unable to open file $logfile\n";
    }
}

# write status file.
open STATUS, '>' . $status_file or die("Unable to write status information to $status_file\n");

for my $logfile (@logfiles) {
    print STATUS $logfile . ' ' . $status{$logfile} . "\n";
}
close STATUS;
