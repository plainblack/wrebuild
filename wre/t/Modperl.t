use lib '../lib';
use strict;
use Test::More tests => 10;
use WRE::Config;
use WRE::Modperl;

my $wreConfig = WRE::Config->new();
my $modperl = WRE::Modperl->new(wreConfig=>$wreConfig);
ok(defined $modperl, "Create modperl object");
is($modperl->ping, 0, "modperl is supposed to be down.");
isnt($modperl->ping, 1, "modperl is supposed to be down. False positive.");
is($modperl->start, 1, "Start modperl.");
isnt($modperl->ping, 0, "modperl is supposed to be up. False negative.");
is($modperl->ping, 1, "modperl is supposed to be up.");
is($modperl->restart, 1, "Restart modperl.");
is($modperl->ping, 1, "modperl is supposed to be up.");
is($modperl->stop, 1, "Stop modperl.");
is($modperl->ping, 0, "modperl is supposed to be down.");

