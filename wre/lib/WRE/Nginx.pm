package WRE::Nginx;

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
use base 'WRE::Service';
use Carp qw(croak);
use Class::InsideOut qw(new);
use HTTP::Request;
use HTTP::Headers;
use LWP::UserAgent;
use WRE::Host;

=head1 ISA

WRE::Service

=cut


#-------------------------------------------------------------------

=head getName () 

Returns human readable name.

=cut

sub getName {
    return "Nginx";
}


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if Nginx is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $wreConfig = $self->wreConfig;
    my $nginx = $wreConfig->get("nginx");
    my $userAgent = new LWP::UserAgent;
    $userAgent->agent("wre/1.0");
    $userAgent->timeout($nginx->{connectionTimeout});
    my $header = new HTTP::Headers;
    my $url = "http://".$nginx->{defaultHostname}.":".$nginx->{port}."/";
    my $request = new HTTP::Request( GET => $url, $header); 
    my $response = $userAgent->request($request);
    if ($response->is_success || $response->code eq "401") {
        return 1;
	} 
    croak "Nginx received error code ".$response->code." with message ".$response->error_as_HTML;
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
    my $host = WRE::Host->new(wreConfig=>$wreConfig);
    unless ($wreConfig->get("nginx/port") > 1024 || $host->isPrivilegedUser) {
        croak "You are not an administrator on this machine so you cannot start services with ports 1-1024.";
    }
    my $cmd = $wreConfig->getRoot("/prereqs/sbin/nginx")." -c ".$wreConfig->getRoot("/etc/nginx.conf");
    my $count   = 0;
    my $success = 0;
    `$cmd`; # catch command line output
    while ($count < 10 && !$success) {
        sleep(1);
        eval {$success = $self->ping};
        $count++;
    }
    if ($success) {
        $wreConfig->set("wreMonitor/nginxAdministrativelyDown", 0);
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
    my $wreConfig = $self->wreConfig;
    my $host = WRE::Host->new(wreConfig=>$wreConfig);
    unless ($wreConfig->get("nginx/port") > 1024 || $host->isPrivilegedUser) {
        croak "You are not an administrator on this machine so you cannot stop services with ports 1-1024.";
    }
    my $cmd = $wreConfig->getRoot("/prereqs/sbin/nginx")." -c ".$wreConfig->getRoot("/etc/modproxy.conf")." stop";
    `$cmd`; # catch command line output
    my $count = 0;
    my $success = 0;
    while ($count < 10 && !$success) {
        $success = !(eval {$self->ping});
        $count++;
    }
    if ($success) {
        $wreConfig->set("wreMonitor/modproxyAdministrativelyDown", 1);
    }
    return $success;
}

1;
