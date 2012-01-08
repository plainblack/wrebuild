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

if ($config->get('demo/enabled') {
    say "Setting up demo files";
    $file->makePath($config->getDomainRoot("/demo"));
    $file->copy($config->getRoot("/var/setupfiles/demo.nginx"), $config->getRoot("/etc/demo.nginx"),
        { force => 1, templateVars=>{ sitename=>$config->get("demo/hostname") } });
}
else {
    say "Skipping demo files";
}



__END__

=head1 NAME

wredemosetup.pl

=head1 SYNOPSIS

./wredemosetup.pl

=head1 DESCRIPTION

Sets up the demo server on this instance by installing various config files and servers.

=over

=item B<--help>

Shows this documentation and then exits.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut

