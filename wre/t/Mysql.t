use lib '../lib';
use strict;
use Test::More tests => 8;
use WRE::Config;
use WRE::Mysql;

my $wreConfig = WRE::Config->new();
my $mysql = WRE::Mysql->new($wreConfig);
ok(defined $mysql, "Create mysql object");
is($mysql->ping, 0, "MySQL is supposed to be down.");
is($mysql->start, 1, "Start mysql.");
is($mysql->ping, 1, "MySQL is supposed to be up.");
is($mysql->restart, 1, "Restart mysql.");
is($mysql->ping, 1, "MySQL is supposed to be up.");
is($mysql->stop, 1, "Stop mysql.");
is($mysql->ping, 0, "MySQL is supposed to be down.");

