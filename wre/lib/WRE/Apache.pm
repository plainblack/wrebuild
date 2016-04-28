package WRE::Apache;

#-------------------------------------------------------------------
# WRE is Copyright 2005-2008 Plain Black Corporation.
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

{ # begin inside out object



#-------------------------------------------------------------------

=head base ([$action]) 

Get's the base command line invocation for this service and make sure that the user has permission
to start services.

service httpd %s or systemctl %s httpd

=head2 $action

If an action (start, stop, etc) is passed, then the full command will be constructed and returned.

=cut

sub base {
    my $self = shift;
    my $action = shift;
    my $wreConfig = $self->wreConfig;
    my $host = WRE::Host->new(wreConfig=>$wreConfig);
    unless ($wreConfig->get("apache/port") > 1024 || $host->isPrivilegedUser) {
        croak "You are not an administrator on this machine so you cannot start services with ports 1-1024.";
    }
    my $base = $self->systemd ? "systemctl %s httpd" : "service httpd %s";
    if ($action) {
        $base = sprintf $base, $action;
    }
    return $base;
}

#-------------------------------------------------------------------

=head getName () 

Returns human readable name.

=cut

sub getName {
    return "Apache/mod_perl";
}

#-------------------------------------------------------------------

=head2 graceful ( )

Performs a graceful restart of this service.

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub graceful {
    my $self = shift;
    my $cmd = $self->base( $self->systemd ? 'reload' : 'graceful');
    my $count = 0;
    my $success = 0;
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 0) {
        sleep(1);
        eval {$success = $self->ping};
        $count++;
    }
    return $success;
}

#-------------------------------------------------------------------

=head killRunaways () 

Kills any processes that are larger than the maxMemory setting in the config file. Returns the number of processes
killed.

=cut

sub killRunaways {
    my $self = shift;
    eval { require Proc::ProcessTable; };
    if ($@) { # can't check if this module doesn't exist (eg: windows)
        return 0;
    }
    my $killed = 0;
    my $processTable = Proc::ProcessTable->new;
    my $maxMemory = $self->wreConfig->get("apache/maxMemory");
    foreach my $process (@{$processTable->table}) {
        next unless ($process->cmndline =~ /httpd.*/);
        if ($process->size >= $maxMemory) {
            $killed += $process->kill(9);
        }
    }
    return $killed;
}


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if Modperl is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $apache = $self->wreConfig->get("apache");
    my $userAgent = LWP::UserAgent->new;
    $userAgent->agent("wre/1.0");
    $userAgent->timeout($apache->{connectionTimeout});
    my $header = HTTP::Headers->new;
    my $url = "http://".$apache->{defaultHostname}.":".$apache->{port}."/";
    my $request = HTTP::Request->new( GET => $url, $header);
    my $response = $userAgent->request($request);
    if ($response->is_success || $response->code eq "401") {
        return 1;
	} 
    croak "Modperl received error code ".$response->code." with message ".$response->error_as_HTML;
    return 0;
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not.

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub start {
    my $self = shift;
    my $cmd = $self->base('start');
    my $count = 0;
    my $success = 0;
    my $config = $self->wreConfig;
    `$cmd`; # catch command line output
    $config->set("wreMonitor/apacheAdministrativelyDown", 0);
    while ($count < 10 && $success == 0) {
        sleep(1);
        eval {$success = $self->ping };
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
    my $config = $self->wreConfig;
    $config->set("wreMonitor/apacheAdministrativelyDown", 1);
    my $cmd = $self->base('stop');
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 1) {
        eval { $success = $self->ping };
        $count++;
    }
    return $success;
}




} # end inside out object

1;
