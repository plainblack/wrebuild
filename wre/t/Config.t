use lib '../lib';
use strict;
use Test::More tests => 10;
use WRE::Config;

my $config = WRE::Config->new();
is(ref $config, "WRE::Config", "Got a valid object.");
is($config->getRoot, "/data/wre", "Default WRE root is /data/wre");
is($config->getRoot("x/y"), "/data/wre/x/y", "WRE root append without slash");
is($config->getRoot("/x/y"), "/data/wre/x/y", "WRE root append with slash");
is($config->getWebguiRoot, "/data/WebGUI", "Default WebGUI root is /data/WebGUI");
is($config->getWebguiRoot("x/y"), "/data/WebGUI/x/y", "WebGUI root append without slash");
is($config->getWebguiRoot("/x/y"), "/data/WebGUI/x/y", "WebGUI root append with slash");
is($config->getDomainRoot, "/data/domains", "Default domains root is /data/domains");
is($config->getDomainRoot("x/y"), "/data/domains/x/y", "domains root append without slash");
is($config->getDomainRoot("/x/y"), "/data/domains/x/y", "domains root append with slash");


