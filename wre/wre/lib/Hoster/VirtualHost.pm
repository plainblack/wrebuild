package Hoster::VirtualHost;

use strict;
use Hoster::Template;

#------------------------------
sub create {
	my ($opts) = @_;
	open(FILE,">".$opts->{'vh-home'}.'/'.$opts->{'sitename'}.'.modperl');
	print FILE Hoster::Template::process($opts->{'vh-modperl-template'},$opts);
	close(FILE);
	open(FILE,">".$opts->{'vh-home'}.'/'.$opts->{'sitename'}.'.modproxy');
	print FILE Hoster::Template::process($opts->{'vh-modproxy-template'},$opts);
	close(FILE);
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	unlink($opts->{'vh-home'}.'/'.$opts->{'sitename'}.'.modperl');
	unlink($opts->{'vh-home'}.'/'.$opts->{'sitename'}.'.modproxy');
}

1;

