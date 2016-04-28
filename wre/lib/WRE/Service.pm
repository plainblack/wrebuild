package WRE::Service;

#-------------------------------------------------------------------
# WRE is Copyright 2005-2011 Plain Black Corporation.
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

{ # begin inside out object


#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE cconfig.

=cut

public wreConfig => my %config;


#-------------------------------------------------------------------

=head2 getName () 

Returns a human readable name for this service. This must be overridden by the subclass.

=cut

sub getName {
    croak "getName() was not overridden by the subclass as directed.";
}


#-------------------------------------------------------------------

=head2 new ( wreConfig => $config )

Constructor.

=head3 wreConfig

A reference to a WRE Configuration object.

=cut

# auto created by Class::InsideOut


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if spectre is running, or a 0 if it is not. Must be overridden by all subclasses.

=cut

sub ping {
    croak "Subclass didn't override as directed.";
}

#-------------------------------------------------------------------

=head2 restart ( )

Returns a 1 if the restart was successful, or a 0 if it was not. Shouldn't need to be overriden or extended in most
circumstances.

=cut

sub restart {
    my $self = shift;
    if ($self->stop) {
        return $self->start;
    }
    return 0;
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not. Must be overridden by all subclasses.

=cut

sub start {
    croak "Subclass didn't override as directed.";
}

#-------------------------------------------------------------------

=head2 stop ( )

Returns a 1 if the stop was successful, or a 0 if it was not. Must be overriden by all subclasses.

=cut

sub stop {
    croak "Subclass didn't override as directed.";
}

#-------------------------------------------------------------------

=head2 systemd ( )

Returns a 1 if the flag in the config file has been set to indicate that this host uses systemd for process management instead of init.

=cut

sub systemd {
    my $self = shift;
    return $self->wreConfig->get('systemd') ? 1 : 0;
}



} # end inside out object

1;
