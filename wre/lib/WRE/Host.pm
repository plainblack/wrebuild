package WRE::Host;

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
use Net::hostent;
use Socket;
use Sys::Hostname;



=head1 METHODS

The following methods are available from this package.

=cut

#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE cconfig.

=cut

public wreConfig => my %wreConfig;


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

Gets the IP address of the box. Note that this isn't foolproof. Croaks if it can't determine one.

=cut

sub getIp {
    my $self = shift;
    my $hostname = $self->getHostname;
    my $host = gethostbyname($hostname);  # object return
    if (defined $host) {
        return inet_ntoa($host->addr);
    }
    croak "Cannot determine IP address of $hostname.";
    return undef;
}

#-------------------------------------------------------------------

=head2 getOsName ( )

Returns the operating system's name.

=cut

sub getOsName {
    my $os = $^O;
    if ($os =~ /MSWin32/i || $os =~ /^Win/i) {
        return "windows";
    }
    return $os;
}


#-------------------------------------------------------------------

=head2 getOsType ( )

Returns the type of operating system. So for example, for linux OSes, it will return "RedHat" or "Gentoo" or
"Ubuntu".

=cut

sub getOsType {
    my $self = shift;
    if ($self->getOsName eq "linux") {
        if ( -f "/etc/redhat-release" ) {
            return "RedHat";
        }
        elsif ( -f "/etc/fedora-release" ) {
            return "Fedora";
        } 
        elsif ( -f "/etc/slackware-release" || -f "/etc/slackware-version" ) {
            return "Slackware";
        }
        elsif ( -f "/etc/debian_release" || -f "/etc/debian_version" ) {
            return "Debian";
        }
        elsif ( -f "/etc/mandrake-release" ) {
            return "Mandrake";
        }
        elsif ( -f "/etc/yellowdog-release" ) {
            return "YellowDog";
        }
        elsif ( -f "/etc/gentoo-release" ) {
            return "Gentoo";
        }
        elsif ( -f "/etc/lsb-release" ) {
            return "Ubuntu";
        }
    }
    return undef; 
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

=head2 isPrivilegedUser ()

Returns a boolean indicating whether the current user is a privileged user for the operating system.

=cut

sub isPrivilegedUser {
    my $self = shift;
    if ($self->getOsName eq "windows" || $< == 0) {
        return 1;
    }
    return 0;
}

#-------------------------------------------------------------------

=head2 new ( wreConfig => $config )

Constructor.

=head3 wreConfig

A reference to a WRE Configuration object.

=cut

# auto created by Class::InsideOut



1;
