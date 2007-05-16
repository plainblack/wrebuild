package WRE::Spectre;

#-------------------------------------------------------------------
# WRE is Copyright 2005-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base 'WRE::Service';
use Carp qw(carp);
use Config::JSON;
use POE::Component::IKC::ClientLite;

{ # begin inside out object

my $spectreConfig = {};
my $wreConfig = {};

#-------------------------------------------------------------------

=head2 getConfig ()

Returns a reference to the Config::JSON object for spectre.

=cut

sub getConfig {
    return $spectreConfig;
}

#-------------------------------------------------------------------

=head2 new ( wreConfig )

Constructor.

=head3 wreConfig

A WRE::Config object.

=cut

sub new {
    my $class = shift;
    $wreConfig = shift;
    $spectreConfig = Config::JSON->new($wreConfig->getWebguiRoot("/etc/spectre.conf"));
    bless \do{my $scalar}, $class;
}

#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if spectre is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $remote = create_ikc_client(
        port    => $spectreConfig->get("port"),
        ip      => $spectreConfig->get("ip"),
        name    => rand(100000),
        timeout => 10
        );
    unless ($remote) {
        carp "Couldn't connect to Spectre because ".$POE::Component::IKC::ClientLite::error;
        return 0;
    }
    my $result = $remote->post_respond('admin/ping');
    $remote->disconnect;
    unless (defined $result) {
        carp "Didn't get a response from Spectre because ".$POE::Component::IKC::ClientLite::error;
        return 0;
    }
    undef $remote;
    if ($result eq "pong") {
        return 1;
    } else {
        carp "Received '".$result."' when we expected 'pong'.";
        return 0;
    }
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not.

=cut

sub start {
    my $self = shift;
    my $count = 0;
    my $success = 0;
    chdir($wreConfig->getWebguiRoot("/sbin"));
    system($wreConfig->getRoot("/prereqs/bin/perl")." spectre.pl --daemon");
    while ($count < 10 && $success == 0) {
        sleep(1);
        $success = $self->ping;
        $count++;
    }
    return $success;
}

#-------------------------------------------------------------------

=head2 stop ( )

Returns a 1 if the stop was successful, or a 0 if it was not.

=cut

sub stop {
    my $self = shift;
    my $count = 0;
    my $success = 0;
    chdir($wreConfig->getWebguiRoot("/sbin"));
    system($wreConfig->getRoot("/prereqs/bin/perl")." spectre.pl --shutdown");
    while ($count < 10 && $success == 0) {
        sleep(1);
        $success = !$self->ping;
        $count++;
    }
    return $success;
}



} # end inside out object

1;
