use lib '../lib';
use strict;
use Test::More tests => 10;
use WRE::Config;
use Path::Class;

my $config = WRE::Config->new();
isa_ok($config, "WRE::Config");
is($config->getRoot, dir("/data/wre")->stringify, "Default WRE root is /data/wre");
is($config->getRoot("x/y"), dir("/data/wre/x/y")->stringify, "WRE root append without slash");
is($config->getRoot("/x/y"), dir("/data/wre/x/y")->stringify, "WRE root append with slash");
is($config->getWebguiRoot, dir("/data/WebGUI")->stringify, "Default WebGUI root is /data/WebGUI");
is($config->getWebguiRoot("x/y"), dir("/data/WebGUI/x/y")->stringify, "WebGUI root append without slash");
is($config->getWebguiRoot("/x/y"), dir("/data/WebGUI/x/y")->stringify, "WebGUI root append with slash");
is($config->getDomainRoot, dir("/data/domains")->stringify, "Default domains root is /data/domains");
is($config->getDomainRoot("x/y"), dir("/data/domains/x/y")->stringify, "domains root append without slash");
is($config->getDomainRoot("/x/y"), dir("/data/domains/x/y")->stringify, "domains root append with slash");


