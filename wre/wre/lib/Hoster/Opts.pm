package Hoster::Opts;

use strict;
use Getopt::Long;
use Parse::PlainConfig;
use String::Random qw(random_string);

#------------------------------
sub get {
	my ($hosterHome) = @_;
	my (%arg,%site,%flag);
	my $cache = Parse::PlainConfig->new( 'FILE' => $hosterHome.'/var/hoster.arg.cache', 'PURGE' => 1);
	foreach ($cache->directives) {
    		$arg{$_} = $cache->get($_);
	}
	GetOptions(
		'wre-restart=s'=>\$arg{'wre-restart'},
		'apache-user=s'=>\$arg{'apache-user'},
		'admin-db-user=s'=>\$arg{'admin-db-user'},
		'chown=s'=>\$arg{'chown'},
		'domain-home=s'=>\$arg{'domain-home'},
		'gateway-template=s'=>\$arg{'gateway-template'},
		'awstats-template=s'=>\$arg{'awstats-template'},
		'mysql-client=s'=>\$arg{'mysql-client'},
		'tar=s'=>\$arg{'tar'},
		'gzip=s'=>\$arg{'gzip'},
		'gunzip=s'=>\$arg{'gunzip'},
		'awstats-configs=s'=>\$arg{'awstats-configs'},
		'vh-home=s'=>\$arg{'vh-home'},
		'vh-modperl-template=s'=>\$arg{'vh-modperl-template'},
		'vh-modproxy-template=s'=>\$arg{'vh-modproxy-template'},
		'webgui-conf-template=s'=>\$arg{'webgui-conf-template'},
		'db-host=s'=>\$arg{'db-host'},
		'webgui-home=s'=>\$arg{'webgui-home'},
		'admin-db-pass=s'=>\$flag{'admin-db-pass'},
		'help'=>\$flag{help},
		'no-wre-restart'=>\$flag{'no-wre-restart'},
		'no-cache'=>\$flag{'no-cache'},
		'print-values'=>\$flag{'print-values'},
		'print-vars'=>\$flag{'print-vars'},
		'var0=s'=>\$flag{var0},
		'var1=s'=>\$flag{var1},
		'var2=s'=>\$flag{var2},
		'var3=s'=>\$flag{var3},
		'var4=s'=>\$flag{var4},
		'var5=s'=>\$flag{var5},
		'var6=s'=>\$flag{var6},
		'var7=s'=>\$flag{var7},
		'var8=s'=>\$flag{var8},
		'var9=s'=>\$flag{var9},
		'all'=>\$flag{'all'},
		'sitename=s'=>\$site{sitename},
		'site-db-user=s'=>\$site{'site-db-user'},
		'site-db-pass=s'=>\$site{'site-db-pass'}
		);
	unless ($flag{'no-cache'}) {
		$cache->set(%arg);
		$cache->write;
	}
	my %options = (%arg,%site,%flag);
	$options{'hoster-home'} = $hosterHome;
	return \%options;
}

#------------------------------
sub generate {
	my $options = $_[0];
	$options->{'webgui-base-conf'} = $options->{'webgui-home'}.'/etc/WebGUI.conf.original';
	$options->{'db-name'} = $options->{hostname} = $options->{domain} = $options->{sitename};
	$options->{'db-name'} =~ s/\./_/g;
	$options->{'db-name'} =~ s/\-/_/g;
	$options->{hostname} =~ s/^(.*?)\..*?$/$1/;
	$options->{domain} =~ s/^.*?\.(.*?)$/$1/;
	$options->{'site-db-user'} = random_string("cccccccc") if ($options->{'site-db-user'} eq "");
	$options->{'site-db-pass'} = random_string("cCncCncCncCn") if ($options->{'site-db-pass'} eq "");
	return $options;
}

#------------------------------
sub printVars {
	my $opts = $_[0];
	my @temp;
	foreach my $key (keys %{$opts}) {
		push(@temp,$key);
	}
	@temp = sort(@temp);
	print join("\n",@temp)."\n";
}

#------------------------------
sub printValues {
	my $opts = $_[0];
	foreach my $key (keys %{$opts}) {
		print $key." = ".$opts->{$key}."\n";
	}
}


1;
