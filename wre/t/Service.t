use lib '../lib';
use strict;
use Test::More tests => 3;
use WRE::Config;
use WRE::Service;

my $wreConfig = WRE::Config->new();
my $service = WRE::Service->new(wreConfig=>$wreConfig);
isa_ok($service, "WRE::Service");
isa_ok($service->wreConfig, "WRE::Config");
can_ok($service, qw(start stop restart ping));


