use lib '../lib';
use strict;
use Test::More tests => 11;
use WRE::Config;
use WRE::Spectre;

my $wreConfig = WRE::Config->new();
my $spectre = WRE::Spectre->new(wreConfig=>$wreConfig);
isa_ok($spectre, "WRE::Spectre");
is(ref $spectre->getConfig, "Config::JSON", "Can fetch spectre config object.");
is($spectre->ping, 0, "Spectre is supposed to be down.");
isnt($spectre->ping, 1, "Spectre is supposed to be down. False positive.");
is($spectre->start, 1, "Start spectre.");
isnt($spectre->ping, 0, "Spectre is supposed to be up. False negative."); 
is($spectre->ping, 1, "Spectre is supposed to be up.");
is($spectre->restart, 1, "Restart spectre.");
is($spectre->ping, 1, "Spectre is supposed to be up.");
is($spectre->stop, 1, "Stop spectre.");
is($spectre->ping, 0, "Spectre is supposed to be down.");
