#!/data/wre/prereqs/bin/perl

use strict;
use lib '/data/wre/lib';
use WRE::Config;

my $config = WRE::Config->new;

# changing version number
my $version = "0.8.3";
print "\tUpdating version number to $version.";
$config->set("version",$version);
print "\tOK\n";

setCorrectImageMagickConfig($config);
sub setCorrectImageMagickConfig {
    my $config = shift;
    require WRE::Host;
    require File::Spec;
    my $host = WRE::Host->new(wreConfig => $config);
    return
        unless $host->getOsName eq 'windows';
    print "\tSetting correct ImageMagick registry values...\n";
    require Win32::TieRegistry;
    my $regKey = Win32::TieRegistry->Open("LMachine", {Delimiter=>"/"})->CreateKey("SOFTWARE/ImageMagick/6.3.7/Q:8");
    my %values = (
        BinPath             => File::Spec->catpath('c:', $config->getRoot('prereqs/bin')),
        ConfigurePath       => File::Spec->catpath('c:', $config->getRoot('prereqs/bin/config')),
        LibPath             => File::Spec->catpath('c:', $config->getRoot('prereqs/bin')),
        CoderModulesPath    => File::Spec->catpath('c:', $config->getRoot('prereqs/bin/modules/coders')),
        FilterModulesPath   => File::Spec->catpath('c:', $config->getRoot('prereqs/bin/modules/filters')),
    );
    while (my ($key, $value) = each %values) {
        delete $regKey->{"/$key"};
        $regKey->{"/$key"} = $value;
    }
    print "\tOK\n";
}
