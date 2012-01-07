#!/data/wre/prereqs/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use lib '/data/wre/lib';
use WRE::Config;
use WRE::File;
use WRE::Host;
use Getopt::Long ();
use Pod::Usage ();

my $help;

use 5.010;

Getopt::Long::GetOptions(
    'help'=>\$help
);

Pod::Usage::pod2usage( verbose => 2 ) if $help;

#-------------------------------------------------------------------
# server daemon
my $config = WRE::Config->new;
my $host   = WRE::Host->new(wreConfig => $config);
my $file   = WRE::File->new(wreConfig => $config);

say "Setting up demo files";
$file->makePath($config->getDomainRoot("/demo"));
$file->copy($config->getRoot("/var/setupfiles/demo.nginx"), $config->getRoot("/etc/demo.nginx"), 
    { force => 1, templateVars=>{ sitename=>$config->get("demo/hostname") } });

say "Setting up nginx main config";
$file->copy($config->getRoot("/var/setupfiles/nginx.conf"),
    $config->getRoot("/etc/nginx.conf"),
    { force => 1, templateVars=>{osName=>$host->getOsName} });
say "Setting up nginx per-site config";
$file->copy($config->getRoot("/var/setupfiles/nginx.template"),
    $config->getRoot("/var/nginx.template"),
    { force => 1 });
say "Setting up mime.types file";
$file->copy($config->getRoot("/var/setupfiles/mime.types"),
    $config->getRoot("/etc/mime.types"),
    { force => 1 });

say "Setting up logrotate file";
$file->copy($config->getRoot("/var/setupfiles/wre.logrotate"),
    $config->getRoot("/etc/wre.logrotate"),
    { force => 1 });

say "Setting up Spectre config";
$file->copy($config->getWebguiRoot("/etc/spectre.conf.original"), $config->getWebguiRoot("/etc/spectre.conf"),
    { force => 1 });
$file->changeOwner($config->getWebguiRoot("/etc"));

say "Creating log and run directory";
$file->makePath($config->getRoot("/var/logs"));
$file->makePath($config->getRoot("/var/run"));

__END__

=head1 NAME

wresetup.pl

=head1 SYNOPSIS

./wresetup.pl --configFile=/data/wre/etc/wre.conf

=head1 DESCRIPTION

Takes a wre.conf file as input and templates base configurations for nginx, logrotate, spectre.

=over

=item B<--help>

Shows this documentation and then exits.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut

