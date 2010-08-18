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
use CPAN;
use List::Util;
use Path::Class;
use WRE::Config;
use WRE::File;
use WRE::WebguiUpdate;

$|=1;

my $config  = WRE::Config->new;
my $update  = WRE::WebguiUpdate->new(wreConfig=>$config);
my $file    = WRE::File->new(wreConfig=>$config);


my $doUpgrade = checkUpgrade();
deployNewVersion();
doUpgrade() if ($doUpgrade);
printResult("Finished!");

#-------------------------------------------------------------------
sub checkUpgrade {
	printTest("Checking for existing install");
	if (-f $config->getWebguiRoot("/lib/WebGUI.pm")) {
		printResult("Upgrading");
		my $reallyDoIt = prompt("There is already an installation at ".$config->getWebguiRoot.". Are you sure you wish to perform the update?","y","y","n");
		if ($reallyDoIt eq "y") {
            doBackup();
			return 1;
		} 
		failAndExit("Aborting update!");
	} 
	printResult("New Install");
	return 0;
}

#-------------------------------------------------------------------
sub deployNewVersion {
    my $archive = whereFrom();
	printTest("Decompressing WebGUI archive");
    eval {$update->extractArchive($archive)};
	if ($@) {
		failAndExit("Failed! ".$@);
	}
	printResult("OK");
}

#-------------------------------------------------------------------
sub doBackup {
	my $answer = prompt("Would you like to back up your existing files before we do the update?","y","y","n");
	if ($answer eq "y") {
        my $backupPath = dir(promptWithPref("backupPath", "Where would you like to store your backups?"));
		printTest("Backing up files");
        $file->makePath($backupPath->stringify);
        eval { $file->tar(
            file    => $backupPath->file("webgui-".time().".tar.gz")->stringify,
            stuff   => [ $config->getWebguiRoot ],
            gzip    => 1,
            )};
        if ($@) {
            failAndExit("Couldn't create backup because ".$@);
        }
		printResult("OK");
	}
}

#-------------------------------------------------------------------
sub doGotchas {
	my $answer = prompt("Often an upgrade will come with gotchas to let you know about things you should deal with before and after the upgrade. Would you like to read the gotchas now?","y","y","n");
	if ($answer eq "n") {
		print "Be sure to look at the gotchas at some point. They are in ".$config->getWebguiRoot("/docs/gotcha.txt")."\n";
	} 
    else {
		print "\n\nPress ENTER to page down. Type 'quit' when you're done reading.\n\n";
		open(my $gotchas,"<",$config->getWebguiRoot("/docs/gotcha.txt"));
		my $i = 0;
		while (my $line = <$gotchas>) {
			print $line;
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
		close($gotchas);
	}
}

#-------------------------------------------------------------------
sub doUpgrade {
    doGotchas();
	my $answer = prompt("Do you want me to start the upgrade script?","n","y","n");
	if ($answer eq "y") {
		chdir($config->getWebguiRoot("/sbin"));
		system($config->getRoot("/prereqs/bin/perl")." upgrade.pl --doit");
	}
}

#-------------------------------------------------------------------
sub failAndExit {
	my $exitmessage = shift;
	print $exitmessage."\n\n";
	exit;
}

#-------------------------------------------------------------------
sub getFromMirror {
    my $url = shift;
	printTest("Downloading from mirror");
    my $path = eval { $update->downloadFile($url) };
    if ($@) {
        failAndExit("Couldn't download because $@");
    }
    printResult("OK");
	return $path;
}

#-------------------------------------------------------------------
sub getMirrors {
	my $webguiVersion = shift;
	printTest("Getting mirrors list");
    my $mirrors = eval {$update->getMirrors($webguiVersion)};
    if ($@) {
        failAndExit("Failed! ".$@);
    }
	printResult("OK");
	return $mirrors;
}

#-------------------------------------------------------------------
sub printTest {
	my $test = shift;
	print sprintf("%-40s", $test.": ");
}

#-------------------------------------------------------------------
sub printResult {
	my $result = shift;
	print "$result\n";
}

#-------------------------------------------------------------------
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
    if ($answer eq "" || ($#answers > 0 && !(defined List::Util::first { $answer eq $_ } @answers))) {
	    $answer = prompt($question,$default,@answers);
    }
	return $answer;
}

#-------------------------------------------------------------------
sub promptWithPref {
    my ($prefName, $question, @answers) = @_;
    my $fullPrefName = "webguiUpdate/".$prefName;
    $config->set(
        $fullPrefName,
        prompt($question, $config->get($fullPrefName), @answers),
        );
    return $config->get($fullPrefName);
}

#-------------------------------------------------------------------
sub whereFrom {
    my $whereFrom = promptWithPref("whereFrom", "Have you already downloaded WebGUI or should I get it from the Internet?", qw(local mirror));
	if ($whereFrom eq "local") {
		return whereIsIt();
	} 
    else {
		my $path = "";
		while ($path eq "") {
			$path = getFromMirror(whichMirror(whichVersion()));
		}
		return $path;
	}
}

#-------------------------------------------------------------------
sub whereIsIt {
	my $path = file(
        prompt("Please type the path to the WebGUI file (/path/to/webgui-x.x.x-stable.tar.gz):")
        )->stringify;
	if (-f $path) {
		return $path;
	}
    else {
        printResult("No file at $path");
		return whereIsIt();
	}
}


#-------------------------------------------------------------------
sub whichMirror {
	my $mirrors = getMirrors(shift);
	my $legend = "";
	my @mirrorsList = ();
	foreach my $key (keys %{$mirrors}) {
		$legend .= $key ." = ".$mirrors->{$key}{location}."\n";
		push(@mirrorsList, $key);
	}
	my $mirror = promptWithPref("whichMirror", $legend."\nWhich server would you like to download from?",@mirrorsList);
	return $mirrors->{$mirror}{url};
}

#-------------------------------------------------------------------
sub whichVersion {
	printTest("Getting current WebGUI version");
    my $version = eval {$update->getLatestVersionNumber};
    if ($@) {
		printResult("Failed! Continuing without it.");
    }
    else {
		printResult("OK");
	}
	return prompt("Which version do you want to install?",$version);
}





