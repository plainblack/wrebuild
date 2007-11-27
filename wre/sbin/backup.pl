#!/data/wre/prereqs/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use lib '/data/wre/lib';
use Net::FTP;
use Path::Class;
use WRE::Config;
use WRE::File;
use WRE::Mysql;

my $config  = WRE::Config->new;
my $util    = WRE::File->new(wreConfig => $config);

# are backups enabled
exit unless $config->get("backup/enabled");

rotateBackupFiles($config);
backupMysql($config);
backupDomains($config);
backupWebgui($config);
backupWre($config);
runExternalScripts($config);
compressBackups($config);
copyToFtp($config);


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
sub copyToFtp {
    my $config      = shift;

    # should we run?
    return undef unless $config->get("backup/ftp/enabled");

	my $now         = time;
    my $passive     = $config->get("backup/ftp/usePassiveTransfers");
    my $host        = $config->get("backup/ftp/hostname");
    my $path        = $config->get("backup/ftp/path");
    my $user        = $config->get("backup/ftp/user");
    my $pass        = $config->get("backup/ftp/password");

    # do rotations
	my $ftp = Net::FTP->new($host,Passive=>$passive);
	$ftp->login($user,$pass) or die "Could not connect to FTP server: $@\n";
	if ($path) {
		$ftp->cwd($path) or die "Could not change to $path directory: $@\n";
	}
	my @dirs = $ftp->ls;
	@dirs = sort(@dirs);
	my $i = scalar(@dirs);
    my $copiesToKeep = $config->get("backup/ftp/rotations");
	foreach my $dir (@dirs) {
		last if ($i < $copiesToKeep);
		$ftp->rmdir($dir,1);
		$i--;
	}
	$ftp->mkdir($now);
	$ftp->quit;

    # do transfer
	my $passivecmd = $passive ? "" : "set ftp:passive-mode off; ";
	system($config->getRoot('/prereqs/bin/lftp').' -e "'.$passivecmd.'mput -O '.$now.' '
        .file($config->get("backup/path"),'/*.gz')->stringify.'; exit" -u '.$user.','.$pass.' ftp://'.$host.$path);
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



