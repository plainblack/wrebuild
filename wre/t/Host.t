use lib '../lib';
use strict;
use Test::More tests => 3;
use WRE::Config;
use WRE::Host;

my $config = WRE::Config->new();
my $host = WRE::Host->new(wreConfig=>$config);
isa_ok($host, "WRE::Host");
isa_ok($host->wreConfig, "WRE::Config");

my $hostname = `hostname`;
chomp $hostname;
is($host->getHostname, $hostname, "getHostname()");

