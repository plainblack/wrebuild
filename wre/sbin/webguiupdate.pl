#!/data/wre/prereqs/perl/bin/perl

use strict;
use warnings;
use Parse::PlainConfig;
use LWP::UserAgent;
use File::Path;
use Archive::Tar;
use HTTP::Request;
use JSON;

startUp();
our $prefs = getPrefs();
my $doUpgrade = checkUpgrade();
doBackup() if ($doUpgrade);
my $file = getWebGUI();
decompressArchive($file);
doGotchas() if ($doUpgrade);
setPrefs($prefs);
doUpgrade() if ($doUpgrade);
shutDown($file);



#----------------------------------------
sub checkUpgrade {
	printTest("Checking for existing install");
	if (-f $prefs->{webguiHome}."/lib/WebGUI.pm") {
		printResult("Upgrading");
		my $reallyDoIt = prompt("There is already an installation at ".$prefs->{webguiHome}.". Are you sure you wish to perform the upgrade?","y","y","n");
		if ($reallyDoIt eq "y") {
			return 1;
		} else {
			failAndExit("Aborting upgrade!");
		}
	} else {
		printResult("New Install");
		return 0;
	}
}

#----------------------------------------
sub decompressArchive {
	my $webguiArchiveFile = shift;
	printTest("Decompressing WebGUI archive");
	File::Path::mkpath($prefs->{basePath});
	chdir($prefs->{basePath});
        Archive::Tar->extract_archive($webguiArchiveFile,1);
	if (Archive::Tar->error) {
		failAndExit("Failed! ".Archive::Tar->error);
	} else {
		printResult("OK");
	}
}

#----------------------------------------
sub doBackup {
	my $answer = prompt("Would you like to back up your existing files before we do the upgrade?","y","y","n");
	if ($answer eq "y") {
		$prefs->{backupDir} = prompt("Where would you like to store your backups?",$prefs->{backupDir});
		printTest("Backing up files");
		File::Path::mkpath($prefs->{backupDir});
		# whe should check if a backup already exists to prevent overwriting old backups
		system("cp -Rfp ".$prefs->{webguiHome}." ".$prefs->{backupDir}.'/WebGUI-'.time());
		printResult("OK");
	}
}

#----------------------------------------
sub doGotchas {
	my $answer = prompt("Many times an upgrade will come with gotchas to let you know about things you should deal with before and after the upgrade. Would you like to read the gotchas now?","y","y","n");
	if ($answer eq "n") {
		print "Be sure to look at the gotchas at some point. They are in ".$prefs->{webguiHome}."/docs/gotcha.txt\n";
	} else {
		print "\n\nPress ENTER to page down. Type 'quit' when you're done reading.\n\n";
		open(FILE,"<".$prefs->{webguiHome}."/docs/gotcha.txt");
		my $i = 0;
		while (<FILE>) {
			print $_;
			if ($i == 20) {
				$i = 0;
				my $input = <STDIN>;
				chomp($input);
				if ($input eq "quit") {
					last;
				}
			}
			$i++;
		} 
		close(FILE);
	}
}

#----------------------------------------
sub doUpgrade {
	my $answer = prompt("Do you want me to start the upgrade script?","n","y","n");
	if ($answer eq "y") {
		chdir($prefs->{webguiHome}."/sbin");
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		my $mysql_args = "--host=" . $config->get('db-host') ;
		if ($config->get('db-port')) {
			$mysql_args .= " --port=" . $config->get('db-port') ;
		}
		system("/data/wre/prereqs/perl/bin/perl upgrade.pl --doit --mysql='/data/wre/prereqs/mysql/bin/mysql $mysql_args' --mysqldump='/data/wre/prereqs/mysql/bin/mysqldump $mysql_args' --override");
	}
}

#----------------------------------------
sub failAndExit {
	my $exitmessage = shift;
	print $exitmessage."\n\n";
	exit;
}

#----------------------------------------
sub getFromMirror {
	my $mirrorUrl = shift;
	my $webguiVersion = shift;
	printTest("Downloading from mirror");
	my $downloadUserAgent = LWP::UserAgent->new;
        my $downloadRequest = HTTP::Request->new(GET => $mirrorUrl);
        my $downloadResponse = $downloadUserAgent->request($downloadRequest);
	if ($downloadResponse->is_error) {
		printResult("Failed! Couldn't get file.");
		return "";
	} else {
		printResult("OK");
	}
	printTest("Writing file to tempspace");
	$file = "/data/wre/var/webgui-".$webguiVersion.".tar.gz";
	if (open(FILE,">$file")) {
		binmode FILE;
		print FILE $downloadResponse->content;
		close(FILE);
		printResult("OK");
	} else {
		failAndExit("Failed!");
	}
	return $file;
}

#----------------------------------------
sub getMirrors {
	my $webguiVersion = shift;
	printTest("Getting mirrors list");
	my $mirrorListUserAgent = LWP::UserAgent->new;
 	my $mirrorListRequest = HTTP::Request->new(GET => 'http://update.webgui.org/getmirrors.pl?version='.$webguiVersion);
 	my $mirrorListResponse = $mirrorListUserAgent->request($mirrorListRequest);
	if ($mirrorListResponse->is_error) {
		failAndExit("Failed!");
	}
	printResult("OK");
	my $mirrors = $mirrorListResponse->content;
	return jsonToObj($mirrors);
}

#----------------------------------------
sub getPrefs {
	my %prefs = (
		basePath=> '/data',
		webguiHome => '/data/WebGUI',
		backupDir=>'/data/wre/var'
		); 
        my $cache = Parse::PlainConfig->new( 'FILE' => '/data/wre/var/webgui.install.prefs', 'PURGE' => 1);
        foreach my $directive ($cache->directives) {
                $prefs{$directive} = $cache->get($directive);
        }
	return \%prefs;
}

#----------------------------------------
sub getVersion {
	printTest("Getting current WebGUI version");
	my $currentversionUserAgent = new LWP::UserAgent;
	$currentversionUserAgent->timeout(30);
	my $header = new HTTP::Headers;
	my $referer = "http://webgui.install.getversion/".`hostname`;
	chomp $referer;
	$header->referer($referer);
	my $currentversionRequest = new HTTP::Request (GET => "http://update.webgui.org/latest-version.txt", $header);
	my $currentversionResponse = $currentversionUserAgent->request($currentversionRequest);
	my $version = $currentversionResponse->content;
	chomp $version;
	if ($currentversionResponse->is_error || $version eq "") {
		printResult("Failed! Continuing without it.");
	} else {
		printResult("OK");
	}
	return $version;
}


#----------------------------------------
sub getWebGUI {
	return whereFrom();
}


#----------------------------------------
sub isIn {
        my $key = shift;
        $_ eq $key and return 1 for @_;
        return 0;
}


#----------------------------------------
sub printTest {
	my $test = shift;
	print sprintf("%-40s", $test.": ");
}

#----------------------------------------
sub printResult {
	my $result = shift;
	print "$result\n";
}

#----------------------------------------
sub prompt {
	my $question = shift;
	my $default = shift;
	my @answers = @_; # the rest is answers
	print "\n".$question." ";
	print "{".join("|",@answers)."} " if ($#answers > 0);	
	print "[".$default."] " if (defined $default);
	my $answer = <STDIN>;
	chomp $answer;
	$answer = $default if ($answer eq "");
	$answer = prompt($question,$default,@answers) if (($#answers > 0 && !(isIn($answer,@answers))) || $answer eq "");
	return $answer;
}

#----------------------------------------
sub setPrefs {
	my $preference = shift;
        my $cache = Parse::PlainConfig->new( 'FILE' => '/data/wre/var/webgui.install.prefs', 'PURGE' => 1);
	$cache->set(%{$preference});
        $cache->write;
}

#----------------------------------------
sub shutDown {	
	my $backupdir = shift;
	printTest("Cleaning up temp files");
	unlink($backupdir);
	printResult("OK");
	print "\nInstallation complete.\n\n";
}

#----------------------------------------
sub startUp {
	print "\n";
	printTest("Starting WebGUI installer");
	# $| If set to nonzero, forces a flush after every write or print
	$|=1;
	use CPAN;
	printResult("OK");
}

#----------------------------------------
sub whereFrom {
	$prefs->{whereFrom} = prompt("Do you have WebGUI local or should I get it from a mirror?",$prefs->{whereFrom},qw(local mirror));
	if ($prefs->{whereFrom} eq "local") {
		return whereIsIt();
	} else {
		my $version = whichVersion();
		my $file = "";
		while ($file eq "") {
			$file = getFromMirror(whichMirror($version),$version);
		}
		return $file;
	}
}

#----------------------------------------
sub whereIsIt {
	my $path = prompt("Please type the path to the file:");
	if (-f $path) {
		return $path;
	} else {
		whereIsIt();
	}
}


#----------------------------------------
sub whichMirror {
	my ($mirrors) = getMirrors(shift);
	my $legend = "";
	my @mirrorsList = ();
	foreach my $key (keys %{$mirrors}) {
		$legend .= $key ." = ".$mirrors->{$key}{location}."\n";
		push(@mirrorsList, $key);
	}
	my $mirror = prompt($legend."\nWhich mirror would you like to download from?",$prefs->{whichMirror},@mirrorsList);
	$prefs->{whichMirror} = $mirror;
	return $mirrors->{$mirror}{url};
}

#----------------------------------------
sub whichVersion {
	my $currentVersion = getVersion();
	return prompt("Which version do you want to install?",$currentVersion);
}




