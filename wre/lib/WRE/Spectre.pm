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
use Carp qw(croak);
use Class::InsideOut qw(register id public);
use Config::JSON;
use POE::Component::IKC::ClientLite;

=head1 ISA

WRE::Service

=cut


#-------------------------------------------------------------------

=head getName () 

Returns human readable name.

=cut

sub getName {
    return "S.P.E.C.T.R.E.";
}


#-------------------------------------------------------------------

=head2 spectreConfig ( )

Returns a reference to the Spectre Config object.

=cut

public spectreConfig => my %spectreConfig;

#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE Config object.

=cut

public wreConfig => my %wreConfig;


#-------------------------------------------------------------------

=head2 new ( wreConfig => $config )

Constructor.

=head3 wreConfig

A WRE::Config object.

=cut

sub new {
    my $class = shift;
    my %options = @_;
    my $self = WRE::Service->new(@_);
    register($self, $class);
    $wreConfig{id $self} = $options{wreConfig};
    $spectreConfig{id $self} = Config::JSON->new($options{wreConfig}->getWebguiRoot("/etc/spectre.conf"));
    return $self;
}


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if spectre is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $spectreConfig = $self->spectreConfig;
    my $remote = create_ikc_client(
        port    => $spectreConfig->get("port"),
        ip      => $spectreConfig->get("ip"),
        name    => rand(100000),
        timeout => 10
        );
    unless ($remote) {
        croak "Couldn't connect to Spectre because ".$POE::Component::IKC::ClientLite::error;
        return 0;
    }
    my $result = $remote->post_respond('admin/ping');
    $remote->disconnect;
    unless (defined $result) {
        croak "Didn't get a response from Spectre because ".$POE::Component::IKC::ClientLite::error;
        return 0;
    }
    undef $remote;
    if ($result eq "pong") {
        return 1;
    } else {
        croak "Received '".$result."' when we expected 'pong'.";
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
    my $wreConfig = $self->wreConfig;
    chdir $wreConfig->getWebguiRoot("/sbin");
    my $cmd = $wreConfig->getRoot("/prereqs/bin/perl")." spectre.pl --daemon";
    system($cmd);
    while ($count < 10 && $success == 0) {
        sleep(1);
        eval {$success = $self->ping};
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
    my $success = 1;
    my $wreConfig = $self->wreConfig;
    chdir($wreConfig->getWebguiRoot("/sbin"));
    my $cmd = $wreConfig->getRoot("/prereqs/bin/perl")." spectre.pl --shutdown";
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 1) {
        sleep(1);
        eval{$success = !$self->ping};
        $count++;
    }
    return $success;
}




1;
