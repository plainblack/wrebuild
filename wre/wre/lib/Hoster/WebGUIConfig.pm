package Hoster::WebGUIConfig;

use strict;
use Hoster::Template;
use Parse::PlainConfig;
use String::Random qw(random_string);

#------------------------------
sub create {
	my ($opts) = @_;
	my $tempFile = $opts->{'hoster-home'}.'/var/'.random_string("ccccnnncccnnncccnncnccc").".tmp";
	open(FILE,">$tempFile");
	print FILE Hoster::Template::process($opts->{'webgui-conf-template'},$opts);
	close(FILE);
	my $override = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $tempFile, 'PURGE' => 1);
	my $default = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $opts->{'webgui-home'}.'/etc/WebGUI.conf.original', 'PURGE' => 1);
	my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $opts->{'webgui-home'}.'/etc/'.$opts->{'sitename'}.".conf", 'PURGE' => 1);
        foreach ($default->directives) {
                $config->set($_=>$default->get($_));
        }
        foreach ($override->directives) {
                $config->set($_=>$override->get($_));
        }
	$config->write;
	unlink($tempFile);
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $opts->{'webgui-home'}.'/etc/'.$opts->{'sitename'}.".conf", 'PURGE' => 1);
	$opts->{'db-name'} = $config->get("dsn");
	$opts->{'db-name'} =~ s/^DBI:mysql:(.*?)$/$1/;
	$opts->{'site-db-user'} = $config->get("dbuser");
	$opts->{'site-db-pass'} = $config->get("dbpass");
	unlink($opts->{'webgui-home'}.'/etc/'.$opts->{'sitename'}.".conf");
}


1;

