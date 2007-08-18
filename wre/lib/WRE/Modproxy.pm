package WRE::Modproxy;

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
use Class::InsideOut qw(new);
use HTTP::Request;
use HTTP::Headers;
use LWP::UserAgent;

=head1 ISA

WRE::Service

=cut


#-------------------------------------------------------------------

=head getName () 

Returns human readable name.

=cut

sub getName {
    return "Apache/mod_proxy";
}


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if Modproxy is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $wreConfig = $self->wreConfig;
    my $apache = $wreConfig->get("apache");
    my $userAgent = new LWP::UserAgent;
    $userAgent->agent("wre/1.0");
    $userAgent->timeout($apache->{connectionTimeout});
    my $header = new HTTP::Headers;
    my $request = new HTTP::Request(
        GET => "http://".$apache->{defaultHostname}.":".$apache->{modproxyPort}."/", $header
        );
    my $response = $userAgent->request($request);
    if ($response->is_success || $response->code eq "401") {
        return 1;
	} 
    croak "Modproxy received error code ".$response->code." with message ".$response->error_as_HTML;
    return 0;
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not.

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub start {
    my $self = shift;
    my $wreConfig = $self->wreConfig;
    unless ($wreConfig->get("apache/modperlPort") > 1024 || $wreConfig->isPrivilegedUser) {
        croak "You are not an administrator on this machine so you cannot start services with ports 1-1024.";
    }
    my $count = 0;
    my $success = 0;
    my $cmd = $wreConfig->getRoot("/prereqs/bin/apachectl")." -f ".$wreConfig->getRoot("/etc/modproxy.conf") 
        ." -D WRE-modproxy -E ".$wreConfig->getRoot("/var/logs/modproxy.error.log")." -k start";
    `$cmd`; # catch command line output
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

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub stop {
    my $self = shift;
    my $count = 0;
    my $success = 1;
    my $wreConfig = $self->wreConfig;
    my $cmd = $wreConfig->getRoot("/prereqs/bin/apachectl")." -f ".$wreConfig->getRoot("/etc/modproxy.conf")
        ." -D WRE-modproxy -k stop";
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 1) {
        eval {$success = $self->ping};
        $count++;
    }
    return !$success;
}




1;
