package Hoster::WebRoot;

use strict;
use File::Path;

#------------------------------
sub create {
	my ($opts) = @_;
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/awstats');
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/logs');
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/public/uploads');
	system($opts->{'chown'}." ".$opts->{'apache-user'}." ".$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/public/uploads');
	system("cp -R ".$opts->{'webgui-home'}.'/www/uploads/* '.$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/public/uploads/');
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	rmtree($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname});
}


1;

