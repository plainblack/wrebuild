package Hoster::Gateway;

use strict;
use Hoster::Template;

#------------------------------
sub create {
	my ($opts) = @_;
	open(FILE,">".$opts->{'domain-home'}.'/'.$opts->{'domain'}.'/'.$opts->{'hostname'}.'/public/index.pl');
	print FILE Hoster::Template::process($opts->{'gateway-template'},$opts);
	close(FILE);
	chmod(0755,$opts->{'domain-home'}.'/'.$opts->{'domain'}.'/'.$opts->{'hostname'}.'/public/index.pl');
}


1;

