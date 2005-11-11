#!/data/wre/prereqs/perl/bin/perl

use strict;
use CGI;
use DBI;
use Parse::PlainConfig;

our $cgi = CGI->new;
srand;
my $demoId = time()."_".int(rand(999));
createConfig($demoId);
createFilesystem($demoId);
createDatabase($demoId);
print $cgi->redirect("/demo".$demoId.".pl");

sub createConfig {
	my $demoId = shift;
	my $config = Parse::PlainConfig->new('DELIM' => '=',
                'FILE' => '/data/WebGUI/etc/WebGUI.conf.original',
                'PURGE' => 1);
	$config->set(
		dsn => "DBI:mysql:demo".$demoId,
		dbuser => "demo",
		dbpass => "demo",
		sitename => "demo",
		uploadsURL => "/demo".$demoId,
		uploadsPath => "/data/domains/demo/demo".$demoId
		);
	$config->write("/data/WebGUI/etc/demo".$demoId.".conf");
}
		
sub createFilesystem {
	my $demoId = shift;
	system("mkdir /data/domains/demo/demo".$demoId);
	open(GW,">/data/domains/demo/demo".$demoId.".pl");
	print GW '#!/data/wre/prereqs/perl/bin/perl'."\n";
	print GW 'our ($webguiRoot, $configFile);'."\n";
	print GW 'BEGIN {$configFile="demo'.$demoId.'.conf";$webguiRoot="/data/WebGUI";unshift (@INC, $webguiRoot."/lib");}'."\n";
	print GW 'use CGI::Carp qw(fatalsToBrowser);'."\n";
	print GW 'use strict;'."\n";
	print GW 'use WebGUI;'."\n";
	print GW 'print WebGUI::page($webguiRoot,$configFile);'."\n";
	close(GW);
	system("chmod 755 /data/domains/demo/demo".$demoId.".pl");
}

sub createDatabase {
	my $demoId = shift;
	my $demoConfig = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/etc/demo.conf', 'PURGE' => 1);
	my $dbh = DBI->connect("DBI:mysql:test",$demoConfig->get("adminuser"),$demoConfig->get("adminpass"));
	$dbh->do("create database demo".$demoId);
	$dbh->do("grant all privileges on demo".$demoId.".* to demo\@localhost identified by 'demo'");
	$dbh->do("flush privileges");
	$dbh->disconnect;
	system("/data/wre/prereqs/mysql/bin/mysql -udemo -pdemo demo".$demoId." < ".$demoConfig->get("createScript"));
}


