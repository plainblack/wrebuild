#!/usr/bin/perl

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

my ($help, $devOnly);

use 5.010;

Getopt::Long::GetOptions(
    'help'    => \$help,
    'devOnly' => \$devOnly,
);

Pod::Usage::pod2usage( verbose => 2 ) if $help;

#-------------------------------------------------------------------
# server daemon
my $config = WRE::Config->new;
my $host   = WRE::Host->new(wreConfig => $config);
my $file   = WRE::File->new(wreConfig => $config);

#say "Setting up nginx main config";
#$file->copy($config->getRoot("/var/setupfiles/nginx.conf"),
#    $config->getRoot("/etc/nginx.conf"),
#    { force => 1, templateVars=>{osName=>$host->getOsName} });
say "Setting up modperl per-site config";
$file->copy($config->getRoot("/var/setupfiles/modperl.template"),
    $config->getRoot("/var/modperl.template"),
    { force => 1 });
say "Setting up nginx per-site config";
$file->copy($config->getRoot("/var/setupfiles/nginx.template"),
    $config->getRoot("/var/nginx.template"),
    { force => 1 });

say "Setting up mod_perl main config for WebGUI";
$file->copy($config->getRoot("/var/setupfiles/webgui.conf"),
    '/etc/httpd/conf.d/webgui.conf',
    { force => 1, templateVars => { devOnly => $devOnly, osName => $host->getOsName, webguiRoot => $config->getRoot(), modperlPort => $config->get('modperl/port') , }, });
$file->copy($config->getRoot("/var/setupfiles/modperl.pl"),
    '/etc/httpd/conf.d/modperl.pl',
    { force => 1, });

#say "Setting up logrotate file";
#$file->copy($config->getRoot("/var/setupfiles/wre.logrotate"),
#    $config->getRoot("/etc/wre.logrotate"),
#    { force => 1, processTemplate => 1, });

say "Setting up Spectre configuration";
eval {
    open my $in, '<', $config->getWebguiRoot("/etc/spectre.conf.original")
        or die "Unable to open '" . $config->getWebguiRoot("/etc/spectre.conf.original") . "': $!\n";
    open my $out, '>', $config->getWebguiRoot("/etc/spectre.conf")
        or die "Unable to open '" . $config->getWebguiRoot("/etc/spectre.conf") . "': $!\n";
    while (my $line = <$in>) {
        $line =~ s{/var/run/spectre\.pid}{ $config->getRoot("/var/run/spectre.pid") }ge;
        print {$out} $line;
    }
    close $out;
    close $in;
};

say "Fixing permissions on the WebGUI etc directory";
$file->changeOwner($config->getWebguiRoot("/etc"));

say "Setting up WebGUI logging";
eval {
    open my $in, '<', $config->getWebguiRoot("/etc/log.conf.original")
        or die "Unable to open '" . $config->getWebguiRoot("/etc/log.conf.original") . "': $!\n";
    open my $out, '>', $config->getWebguiRoot("/etc/log.conf")
        or die "Unable to open '" . $config->getWebguiRoot("/etc/log.conf") . "': $!\n";
    while (my $line = <$in>) {
        $line =~ s{/var/log/webgui\.log}{ $config->getRoot("/var/logs/webgui.log") }ge;
        print {$out} $line;
    }
    close $out;
    close $in;
};

__END__

=head1 NAME

wresetup.pl

=head1 SYNOPSIS

wresetup.pl

=head1 DESCRIPTION

Takes a wre.conf file as input and templates base configurations for nginx, logrotate, spectre.

=over

=item B<--help>

Shows this documentation and then exits.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut

