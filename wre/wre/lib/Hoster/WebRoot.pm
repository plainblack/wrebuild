package Hoster::WebRoot;

use strict;
use Hoster::Gateway;
use File::Path;

#------------------------------
sub backup {
	my ($opts) = @_;
	system($opts->{tar}.' cfz '.$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/backups/uploads.tar.gz '.$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/public/uploads');
}


#------------------------------
sub create {
	my ($opts) = @_;
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/awstats');
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/backups');
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/logs');
	mkpath($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/public/uploads');
	system($opts->{'chown'}." ".$opts->{'apache-user'}." ".$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/public/uploads');
	Hoster::Gateway::create($opts);
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	rmtree($opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname});
}


1;

