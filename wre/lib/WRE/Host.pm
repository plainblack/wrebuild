package WRE::Host;

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
use Carp qw(croak);
use Class::InsideOut qw(new public);
use Socket;
use Sys::Hostname;


{ # begin inside out object


#-------------------------------------------------------------------

=head2 getHostname ( )

Returns the hostname of this box. Note that this is not foolproof.

=cut

sub getHostname {
    my $self = shift;
    return hostname() || 'localhost'; 
}

#-------------------------------------------------------------------

=head2 getIp ( )

Gets the IP address of the box. Note that this isn't foolproof.

=cut

sub getIp {
    my $self = shift;
    return inet_ntoa(scalar gethostbyname( $self->getHostname )); 
}

#-------------------------------------------------------------------

=head2 getSubnet ( )

Returns the subnet (in CIDR) of the primary inteface for this box. Note that this is not 100% foolproof. It's more of an
educated guess.

=cut

sub getSubnet {
    my $self = shift;
    return $self->getIp . '/32' ; 
}

#-------------------------------------------------------------------

=head2 new ( wreConfig => $config )

Constructor.

=head3 wreConfig

A reference to a WRE Configuration object.

=cut

# auto created by Class::InsideOut


#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE cconfig.

=cut

public wreConfig => my %wreConfig;




} # end inside out object

1;
