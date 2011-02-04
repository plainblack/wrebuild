#!/data/wre/prereqs/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2009 Plain Black Corporation.
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

my $config  = WRE::Config->new;
my $util    = WRE::File->new(wreConfig => $config);
my $help;

Getopt::Long::GetOptions(
        'help'=>\$help
);

Pod::Usage::pod2usage( verbose => 2 ) if $help;

# are backups enabled
exit unless $config->get("backup/enabled");

rotateBackupFiles($config);
backupMysql($config);
backupDomains($config);
backupWebgui($config);
backupWre($config);
backupCustom($config);
runExternalScripts($config);
compressBackups($config);
copyToRemote($config);
#removeBackupFiles($config);

#-------------------------------------------------------------------
sub backupCustom {
    my $config          = shift;
    
    return undef unless $config->get("backup/items/custom");
    
    my $backupDir   = dir($config->get("backup/path"));
    my $customFile      = $config->getWebguiRoot("/sbin/preload.custom");
    open FILE, $customFile or die $!;
    my @lines           = <FILE>;
    my @customDirs;
    foreach my $line (@lines) {
        if ($line =~ /^\//) {
            my $backupFile = join("",map { ucfirst($_) } split /\//, $line);
            chomp $backupFile;

            eval { $util->tar(
                file    => $backupDir->file($backupFile.".tar")->stringify,
                stuff   => [$line],
            )};
            print $@."\n" if ($@);
        }
        else {
            next;
        }
    }
}

#-------------------------------------------------------------------
sub backupDomains {
    my $config          = shift;

    # should we run?
    return undef unless $config->get("backup/items/domainsFolder");

    my $domainsRoot     = dir($config->getDomainRoot);

    # get domains to backup
	opendir(DIR, $domainsRoot->stringify);
	my @domains = readdir(DIR);
	closedir(DIR);

    # create tarballs
	my $tar         = $config->get("tar");
	my $backupDir   = dir($config->get("backup/path"));
    my $excludes    = $config->getRoot("/etc/backup.exclude");
	foreach my $domain (@domains) {
		next if ($domain eq "." || $domain eq ".." || $domain eq "demo");
        eval {$util->tar(
            exclude     => $excludes,
            file        => $backupDir->file($domain.".tar")->stringify,
            stuff       => [$domainsRoot->subdir($domain)->stringify],
            )};
        print $@."\n" if ($@);
	}
}

#-------------------------------------------------------------------
sub backupMysql {
    my $config = shift;

    # should we run?
    return undef unless $config->get("backup/items/mysql");

    # disable wremonitor to prevent false positives
    $config->set("wreMonitor/modproxyAdministrativelyDown", 1);
    $config->set("wreMonitor/modperlAdministrativelyDown", 1);


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
		next if ($name =~ /^demo\d/);
		next if ($name =~ /^test$/);

        # create dump
        $mysql->dump(
            database    => $name, 
            path        => $backupDir->file($name.".sql")->stringify
            );
	}
	$db->disconnect;

    # re-enable WRE monitor
    $config->set("wreMonitor/modperlAdministrativelyDown", 0);
    $config->set("wreMonitor/modproxyAdministrativelyDown", 0);
}

#-------------------------------------------------------------------
sub backupWebgui {
    my $config = shift;

    # should we run?
    return undef unless $config->get("backup/items/webgui");

    # create tarball
    eval {$util->tar(
        exclude     => $config->getRoot("/etc/backup.exclude"),
        file        => file($config->get("backup/path"), "webgui.tar")->stringify,
        stuff       => [$config->getWebguiRoot],
        )};
    print $@."\n" if ($@);
}

#-------------------------------------------------------------------
sub backupWre {
    my $config  = shift;
    my $full    = $config->get("backup/items/fullWre");
    my $small   = $config->get("backup/items/smallWre");

    # should we run?
    return undef unless ($full || $small);

    # whole thing or just configs?
    my $pathToBackup = ($full) ? $config->getRoot : $config->getRoot("/etc");

    # create tarball
    eval {$util->tar(
        exclude     => $config->getRoot("/etc/backup.exclude"),
        file        => file($config->get("backup/path"), "wre.tar")->stringify,
        stuff       => [$pathToBackup],
        )};
    print $@."\n" if ($@);
}

#-------------------------------------------------------------------
sub compressBackups {
    my $config      = shift;
	my $gzip        = file($config->get("gzip"))->stringify;
	my $backupDir   = dir($config->get("backup/path"));

    # compress files
	system("$gzip -f ".$backupDir->file("*.sql")->stringify);
	system("$gzip -f ".$backupDir->file("*.tar")->stringify);
}

#-------------------------------------------------------------------
sub copyToRemote {
    my $config      = shift;
    # should we run?
    return undef unless $config->get("backup/ftp/enabled");
    my $protocol    = $config->get("backup/ftp/protocol") || "ftp";

    my $now         = time;
    my $passive     = $config->get("backup/ftp/usePassiveTransfers");
    my $host        = $config->get("backup/ftp/hostname");
    my $path        = $config->get("backup/ftp/path");
    my $user        = $config->get("backup/ftp/user");
    my $pass        = $config->get("backup/ftp/password");
    my $rotations   = $config->get("backup/ftp/rotations");
    my $extraCommands = '';
    # don't validate local cert
    if ($protocol eq 'https') {
	$extraCommands .= 'set ssl:verify-certificate off; ';
    }

    # a little massage
    $path = ($path eq "/") ? "." : $path; # never let it look at the root of the server

    # get old versions 
    if ($rotations > 1) {
        my $cmd = $config->getRoot('/prereqs/bin/lftp').' -e "cd '.$path.'; ls; exit" -u '.$user.','.$pass.' '.$protocol.'://'.$host.'/';
        my @dirs = ();
	    if (open my $pipe, $cmd.'|') {
            while (my $line = <$pipe>) {
                chomp $line;
                if ($line =~ m/^([drxws-]+)\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+\d+\s+\d+:\d{2}\s+(\w+)/ || $line =~ m/^([drxws-]+)\s+--\s+(\w+)/) {
                    my ($privs, $name) = ($1, $2);
                    # skip non-backup directories
                    next unless ($privs =~ m/^d/);
                    next unless ($name =~ m/^\d+$/);
                    push @dirs, $name;
                }
            }
            close $pipe;
        }
        else {
            die "Couldn't connect to backup server.";
	    }

        # do rotations
	    @dirs = sort(@dirs);
	    my $i = scalar(@dirs);
	    foreach my $dir (@dirs) {
	        last if ($i < $rotations);
            system($config->getRoot('/prereqs/bin/lftp').' -e "rm -r -f '.$path.'/'.$dir.'; exit" -u '.$user.','.$pass.' '.$protocol.'://'.$host);
	        $i--;
	    }
    }

    # deal with passive transfers
    if ($protocol eq 'ftp' && !$passive) {
        $extraCommands .= "set ftp:passive-mode off; ";
    }

    # don't do the rotations folder if we aren't using rotations
    if ($rotations > 1) {
        $extraCommands .= 'mkdir '.$path.'/'.$now.'; mput -O '.$path.'/'.$now;
    }
    else {
        $extraCommands .= 'mput -O '.$path;
    }

    # do transfer
    my $cmd = $config->getRoot('/prereqs/bin/lftp').' -e "'.$extraCommands.' '.file($config->get("backup/path"),'/*.gz')->stringify.'; exit" -u '.$user.','.$pass.' '.$protocol.'://'.$host;
    system($cmd);
}

#-------------------------------------------------------------------
sub removeBackupFiles {
    my $config      = shift;
    my $backupDir   = dir($config->get("backup/path"));
    my $rotations   = $config->get("backup/rotations");
    if ($rotations == 0 ||$rotations == 1) {
        opendir(DIR,$backupDir->stringify);
        my @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
                if ($rotations eq "0") {
                        $backupDir->file($file)->remove;
                }
                elsif ($file =~ /(.*\.)1/ ) {
                        $backupDir->file($file)->remove;
                }
        }
    }
}
#-------------------------------------------------------------------
sub rotateBackupFiles {
    my $config      = shift;
    my $backupDir   = dir($config->get("backup/path"));
    my $rotations   = $config->get("backup/rotations") - 1; # .gz counts as 1

    # get the list of files
	opendir(DIR,$backupDir->stringify);
	my @files = readdir(DIR);
	closedir(DIR);

    # rotate and delete old files
	for (my $i = $rotations; $i > 0; $i--) {
		foreach my $file (@files) {

            # only look at files where their extension is a specific digit
			if ($file =~ /(.*\.)$i$/) {
				my $filefront = $1;

                # get rid of oldest files
				if ($i == $rotations) {
					$backupDir->file($file)->remove;
				} 

                # rotate younger files
                else {
					rename $backupDir->file($file)->stringify, $backupDir->file($filefront.($i+1))->stringify;
				}
			}
		}
	}

    # rotate new files
	foreach my $file (@files) {
		if ($file =~ /\.gz$/) {
			rename $backupDir->file($file)->stringify, $backupDir->file($file.".1")->stringify;
		}
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
backup.exclude files. This script is advised to be run as a root owned cronjob.

Please see L<wre.conf.pod> for the backup options.

=head2 backup.exclude

A file that contains patterns of file locations and filenames that should not be backed up. This is used by the tar --exclude-from option.

=over 4

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
