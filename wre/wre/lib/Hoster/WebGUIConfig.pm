package Hoster::WebGUIConfig;

use lib '/data/WebGUI/lib';
use strict;
use Hoster::Template;
use WebGUI::Config;
use JSON;

#------------------------------
sub create {
	my ($opts) = @_;
	my $overrides = jsonToObj(Hoster::Template::process($opts->{'webgui-conf-template'},$opts));
	system("cp -f /data/WebGUI/etc/WebGUI.conf.original ".$opts->{'webgui-home'}.'/etc/'.$opts->{'sitename'}.".conf");
	my $config = WebGUI::Config->new("/data/WebGUI",$opts->{'sitename'}.".conf");
        foreach (keys %{$overrides}) {
                $config->set($_, $overrides->{$_});
        }
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	my $config = WebGUI::Config->new("/data/WebGUI", $opts->{'sitename'}.".conf");
	$opts->{'db-name'} = $config->get("dsn");
	$opts->{'db-name'} =~ s/^DBI:mysql:(.*?);host=.*$/$1/;
	$opts->{'db-host'} = $config->get("dsn");
	$opts->{'db-host'} =~ s/^DBI:mysql:.*?;host=(.*)$/$1/;
	$opts->{'site-db-user'} = $config->get("dbuser");
	$opts->{'site-db-pass'} = $config->get("dbpass");
	unlink($opts->{'webgui-home'}.'/etc/'.$opts->{'sitename'}.".conf");
}


1;

