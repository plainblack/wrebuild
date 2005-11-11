package Hoster::WebGUIDatabase;

use strict;

#------------------------------
sub backup {
	my ($opts) = @_;
	my $cmd = $opts->{'mysql-client'};
	if ($opts->{'admin-db-user'}) {
		$cmd .= ' -u'.$opts->{'admin-db-user'};
	}
	if ($opts->{'admin-db-pass'}) {
		$cmd .= ' -p'.$opts->{'admin-db-pass'};
	}
	$cmd .= ' -D '.$opts->{'db-name'}.' > '.$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/backups/db.sql';
	system($cmd);
	system($opts->{gzip}.' '.$opts->{'domain-home'}.'/'.$opts->{domain}.'/'.$opts->{hostname}.'/backups/db.sql');
}

#------------------------------
sub create {
	my ($opts) = @_;
	my $cmd = $opts->{'mysql-client'};
	if ($opts->{'admin-db-user'}) {
		$cmd .= ' -u'.$opts->{'admin-db-user'};
	}
	if ($opts->{'admin-db-pass'}) {
		$cmd .= ' -p'.$opts->{'admin-db-pass'};
	}
	$cmd .= ' -e "create database '.$opts->{'db-name'}.'; grant all privileges on '.$opts->{'db-name'}
		.'.* to '.$opts->{'site-db-user'}.'@localhost identified by \''.$opts->{'site-db-pass'}.'\'"';
	system($cmd);
	$cmd = $opts->{'mysql-client'}.' -D '.$opts->{'db-name'};
	if ($opts->{'site-db-user'}) {
		$cmd .= ' -u'.$opts->{'site-db-user'};
	}
	if ($opts->{'site-db-pass'}) {
		$cmd .= ' -p'.$opts->{'site-db-pass'};
	}
	$cmd .= ' < '.$opts->{'webgui-home'}.'/docs/create.sql';
	system($cmd);
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	my $cmd = $opts->{'mysql-client'};
	if ($opts->{'admin-db-user'}) {
		$cmd .= ' -u'.$opts->{'admin-db-user'};
	}
	if ($opts->{'admin-db-pass'}) {
		$cmd .= ' -p'.$opts->{'admin-db-pass'};
	}
	$cmd .= ' -e "drop database '.$opts->{'db-name'}.'; use mysql; delete from user where user=\''.$opts->{'site-db-user'}
		.'\'; delete from db where user=\''.$opts->{'site-db-user'}.'\'"';
	system($cmd);
}

1;

