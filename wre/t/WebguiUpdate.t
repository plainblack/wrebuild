use lib '../lib';
use strict;
use Test::More tests => 6;
use WRE::Config;
use WRE::WebguiUpdate;

my $config = WRE::Config->new();
my $update = WRE::WebguiUpdate->new(wreConfig=>$config);
isa_ok($update, "WRE::WebguiUpdate");
isa_ok($update->wreConfig, "WRE::Config");

my $version = $update->getLatestVersionNumber;
like($version, qr/^\d+\.\d+\.\d+\-\w+$/, "getLatestVersionNumber()");
my $list = $update->getMirrors($version);
like($list->{plainblack}{url}, qr/$version/, "getMirrors()");
my $path = $update->downloadFile($list->{plainblack}{url});
ok(-f $path, "downloadFile()");

SKIP: {
    skip("decompression test, because it may accidentally destroy someone's webgui installation", 1);
}

