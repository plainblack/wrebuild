use lib '../lib';
use strict;
use Test::More tests => 10;
use WRE::Config;
use WRE::Spectre;

my $wreConfig = WRE::Config->new();
my $spectre = WRE::Spectre->new(wreConfig=>$wreConfig);
isa_ok($spectre, "WRE::Spectre");
is(eval{$spectre->ping}, undef, "Spectre is supposed to be down.");
isnt(eval{$spectre->ping}, 1, "Spectre is supposed to be down. False positive.");
is($spectre->start, 1, "Start spectre.");
isnt(eval{$spectre->ping}, 0, "Spectre is supposed to be up. False negative."); 
is(eval{$spectre->ping}, 1, "Spectre is supposed to be up.");
is($spectre->restart, 1, "Restart spectre.");
is(eval{$spectre->ping}, 1, "Spectre is supposed to be up.");
is($spectre->stop, 1, "Stop spectre.");
is(eval{$spectre->ping}, undef, "Spectre is supposed to be down.");
