#!/data/wre/prereqs/perl/bin/perl -w
use strict;
use DBI;
use Parse::PlainConfig;
use File::Path;
use Getopt::Long;

my $all;
my $help;
my $verbose;

GetOptions(
	'all'=>\$all,
	'help'=>\$help,
	'verbose'=>\$verbose
);

if ($help) {
	print <<STOP;

	Usage: $0

	Options:

	--all		Deletes all the demos.

	--help		Display this message.

	--verbose	Let's you know what's going on behind the scenes.

STOP
}

print "START UP.\n" if ($verbose);
print "Reading demo config.\n" if ($verbose);
my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/etc/demo.conf', 'PURGE' => 1);
my $demos = $config->get('sites');
print "Connecting to database.\n" if ($verbose);
my $dsn = "DBI:mysql:test;host=" . $config->get('mysqlhost') ;
if ($config->get('db-port')) {
	$dsn .= ";port=" . $config->get('db-port') ;
}
my $dbh = DBI->connect($dsn,$config->get("adminuser"),$config->get("adminpass"));
my %newDemos = ();
foreach my $demoId (keys %{$demos}) {
	next unless ($demoId); # prevent empty strings from wreaking havoc
	if ($all || time() - $demos->{$demoId} > $config->get("duration") * 60 * 60 * 24) {
		print "OLD: ".$demoId."\n" if ($verbose);
		print "\tDropping database.\n" if ($verbose);
		eval{$dbh->do("drop database ".$demoId);};
		print "Error: $@\n" if ($@ && $verbose);
		print "\tRevoking database privileges.\n" if ($verbose);
		eval{$dbh->do("revoke all privileges on ".$demoId.".* from demo\@localhost");};
		print "Error: $@\n" if ($@ && $verbose);
		my $siteConfig = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/WebGUI/etc/'.$demoId.'.conf', 'PURGE' => 1);
		my $cachePath = $siteConfig->get('fileCacheRoot') || "/tmp/WebGUICache";
		print "\tDeleting /data/WebGUI/etc/".$demoId.".conf\n" if ($verbose);
		unlink("/data/WebGUI/etc/".$demoId.".conf");
		print "\tDeleting /data/domains/demo/".$demoId."\n" if ($verbose);
		rmtree("/data/domains/demo/".$demoId);	
		print "\tDeleting ".$cachePath."/".$demoId.".conf\n" if ($verbose);
		rmtree($cachePath."/".$demoId.".conf");	
		print "\tFinished deleting $demoId\n" if ($verbose);
	} else {
		print "NEW: ".$demoId."\n\tNot deleting.\n" if ($verbose);
		$newDemos{$demoId} = $demos->{$demoId};
	}
}
print "Discoonnecting from database.\n" if ($verbose);
$dbh->disconnect;
print "Updating demo site list in demo config.\n" if ($verbose);
$config->set('sites'=>\%newDemos);
$config->write;
print "COMPLETE.\n" if ($verbose);

