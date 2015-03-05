#!/usr/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use lib '/data/wre/lib';
use Path::Class;
use WRE::Config;
use WRE::File;
use WRE::Mysql;
use Getopt::Long ();
use Pod::Usage ();
use 5.010;

my $config  = WRE::Config->new;
my $util    = WRE::File->new(wreConfig => $config);
my $help;

Getopt::Long::GetOptions(
        'help'=>\$help
);

Pod::Usage::pod2usage( verbose => 2 ) if $help;

# are backups enabled
exit unless $config->get("backup/enabled");

backupMysql($config);
backupFiles($config);
runExternalScripts($config);
copyToRemote($config);

#-------------------------------------------------------------------
sub backupMysql {
    my $config = shift;

    # should we run?
    return undef unless $config->get("backup/mysql/enabled");

    # disable wremonitor to prevent false positives
    $config->set("wreMonitor/nginxAdministrativelyDown", 1);
    $config->set("wreMonitor/starmanAdministrativelyDown", 1);


    my $mysql       = WRE::Mysql->new(wreConfig=>$config);
    my $db          = $mysql->getDatabaseHandle( 
        password    => $config->get("backup/mysql/password"), 
        username    => $config->get("backup/mysql/user"),
        );
    my $backupDir   = dir($config->get("backup/path"));

    # find databases to back up 
	my $databases = $db->prepare("show databases");
	$databases->execute;
	while (my ($name) = $databases->fetchrow_array) {

        # skip some databases
		next if $name =~ /^demo\d/;
        next if $name ~~ [qw/test information_schema performance_schema/];

        # create dump
        $mysql->dump(
            database    => $name, 
            path        => $backupDir->file($name.".sql")->stringify
            );
	}
	$db->disconnect;

    # re-enable WRE monitor
    $config->set("wreMonitor/starmanAdministrativelyDown", 0);
    $config->set("wreMonitor/nginxAdministrativelyDown", 0);
}

#-------------------------------------------------------------------
sub backupFiles {
    my $config      = shift;
    my $paths       = $config->get("backup/items");
    my $backupDir   = $config->get("backup/path");
    foreach my $path (@{ $paths }) {
        say "rsyncing $path locally...";
        system (qq!nice rsync -a --quiet --exclude=logs --exclude="domains/demo*" --exclude=mysqldata $path $backupDir/backup!);
    }
}

#-------------------------------------------------------------------
sub copyToRemote {
    my $config      = shift;
    # should we run?
    return undef unless $config->get("backup/rsync/enabled");

    my $user        = $config->get("backup/rsync/user");
    my $host        = $config->get("backup/rsync/hostname");
    my $ACCOUNT     = $user . '@' . $host;
    my $rotations   = $config->get("backup/rsync/rotations");
    my $remote_path = $config->get("backup/rsync/remote_path");
    my $paths       = $config->get("backup/items");
    my $backupDir   = $config->get("backup/path");

    # get old versions 
    if ($rotations > 1) {
        say "Removing last remote backup files...";
        my $cmd = "ssh $ACCOUNT rm -rf $remote_path/backup.$rotations";
        system($cmd);

        # rotate backups except for the last one
        for (my $i=$rotations; $i > 1; $i--) {
            my $prev= $i - 1;
            say "Rotating old remote backup $i...";
            $cmd = "ssh $ACCOUNT mv $remote_path/backup.$prev $remote_path/backup.$i";
            system($cmd);
        }
        say "Copying first backup to 1...";
        $cmd = "ssh $ACCOUNT cp -al $remote_path/backup $remote_path/backup.1";
        system($cmd);
    }

    # do transfer
    say "Moving new data over...";
    foreach my $path (@{ $paths }) {
        say "rsyncing $path remotely...";
        system ("rsync -av --chmod=u+rwx $path $ACCOUNT:$remote_path/backup");
    }
}

#-------------------------------------------------------------------
sub runExternalScripts {
    my $config          = shift;
	foreach my $script (@{$config->get("backup/externalScripts")}) {
		system($script);
	}
}


__END__

=head1 NAME

backup - Backup script for a WebGUI instance

=head1 SYNOPSIS

 backup.pl [all options from configuration files]

 backup.pl --help

=head1 DESCRIPTION

This wre script backups all files and databases according to the wre.conf and
backup.exclude files. This script is best run as a root owned cronjob.

Please see L<wre.conf.pod> for the backup options.

The script will ignore the test database, and any database that looks like it might
come from the demo system.  The demo system databases are identified by any name that
starts with "demo" and then a digit, C<^demo\d>.

=over 4

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut
