package Hoster::AWStats;

use strict;
use Hoster::Template;

#------------------------------
sub create {
	my ($opts) = @_;
	open(FILE,">".$opts->{'awstats-configs'}.'/awstats.'.$opts->{'sitename'}.'.conf');
	print FILE Hoster::Template::process($opts->{'awstats-template'},$opts);
	close(FILE);
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	unlink($opts->{'awstats-configs'}.'/awstats.'.$opts->{'sitename'}.'.conf');
}

1;

