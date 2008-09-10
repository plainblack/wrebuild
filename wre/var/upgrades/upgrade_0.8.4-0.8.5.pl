#!/data/wre/prereqs/bin/perl

use strict;
use lib '/data/wre/lib';
use WRE::Config;

my $config = WRE::Config->new;


# changing version number
my $version = "0.8.5";
print "\tUpdating version number to $version.";
$config->set("version",$version);
print "\tOK\n";

checkTemplateFiles($config);

sub checkTemplateFiles {
    my $config = shift;
    print "\tChecking template files for changes...";
    my $file = WRE::File->new(wreConfig=>$config);
    push my @change $file->copy($config->getRoot('var/setupfiles/modproxy.template'),$config->getRoot('var/modproxy.template'));
    push my @change $file->copy($config->getRoot('var/setupfiles/modperl.template'),$config->getRoot('var/modperl.template'));
    push my @change $file->copy($config->getRoot('var/setupfiles/awstats.template'),$config->getRoot('var/awstats.template'));
    if (scalar(@change)) {
        print "There are some changes in the templates. Please confirm:\n".join("\n", @change)."\n";
    }
    print "\tOK\n";
}
