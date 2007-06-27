use lib '../lib';
use strict;
use Test::More tests => 10;
use WRE::Config;
use WRE::Modproxy;

my $wreConfig = WRE::Config->new();
my $modproxy = WRE::Modproxy->new(wreConfig=>$wreConfig);
ok(defined $modproxy, "Create modproxy object");
is($modproxy->ping, 0, "modproxy is supposed to be down.");
isnt($modproxy->ping, 1, "modproxy is supposed to be down. False positive.");
is($modproxy->start, 1, "Start modproxy.");
isnt($modproxy->ping, 0, "modproxy is supposed to be up. False negative.");
is($modproxy->ping, 1, "modproxy is supposed to be up.");
is($modproxy->restart, 1, "Restart modproxy.");
is($modproxy->ping, 1, "modproxy is supposed to be up.");
is($modproxy->stop, 1, "Stop modproxy.");
is($modproxy->ping, 0, "modproxy is supposed to be down.");

