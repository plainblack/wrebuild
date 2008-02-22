use lib '../lib';
use strict;
use Test::More tests => 10;
use WRE::Config;
use WRE::Modperl;

my $wreConfig = WRE::Config->new();
my $modperl = WRE::Modperl->new(wreConfig=>$wreConfig);
isa_ok($modperl, "WRE::Modperl");
is(eval{$modperl->ping}, undef, "modperl is supposed to be down.");
isnt(eval{$modperl->ping}, 1, "modperl is supposed to be down. False positive.");
is($modperl->start, 1, "Start modperl.");
isnt(eval{$modperl->ping}, 0, "modperl is supposed to be up. False negative.");
is(eval{$modperl->ping}, 1, "modperl is supposed to be up.");
is($modperl->restart, 1, "Restart modperl.");
is(eval{$modperl->ping}, 1, "modperl is supposed to be up.");
is($modperl->stop, 1, "Stop modperl.");
is(eval{$modperl->ping}, undef, "modperl is supposed to be down.");

