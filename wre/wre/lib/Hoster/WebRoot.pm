package Hoster::WebRoot;

use strict;
use File::Path;

#------------------------------
sub create {
	my ($opts) = @_;
	mkpath($opts->{'domain-home'}.'/'.$opts->{sitename}.'/awstats');
	mkpath($opts->{'domain-home'}.'/'.$opts->{sitename}.'/logs');
	mkpath($opts->{'domain-home'}.'/'.$opts->{sitename}.'/public/uploads');
	# note we pipe to /dev/null because there's not always files in /www/uploads and we don't want user's to get scared that some error has occured
	system("cp -R ".$opts->{'webgui-home'}.'/www/uploads/* '.$opts->{'domain-home'}.'/'.$opts->{sitename}.'/public/uploads/ >/dev/null 2> /dev/null');
	system($opts->{'chown'}." -R ".$opts->{'apache-user'}." ".$opts->{'domain-home'}.'/'.$opts->{sitename}.'/public/uploads');
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	my $path = $opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname};
	if (-e $path) {
		rmtree($path);
		$path = $opts->{'domain-home'}.'/'.$opts->{domain};
		if (-e $path) {
			opendir(DIR,$path);
			my @files = readdir(DIR);
			closedir(DIR);
			unless (scalar(@files) > 2) {
				rmdir $path;
			}
		}
	}
	$path = $opts->{'domain-home'}.'/'.$opts->{sitename};
	if (-e $path) {
		rmtree($opts->{'domain-home'}.'/'.$opts->{sitename});
	}
}


1;

