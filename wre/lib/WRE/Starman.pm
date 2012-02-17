package WRE::Starman;

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
use Proc::ProcessTable;

=head1 ISA

WRE::Service

=cut

{ # begin inside out object



#-------------------------------------------------------------------

=head getName () 

Returns human readable name.

=cut

sub getName {
    return "Starman";
}

#-------------------------------------------------------------------

=head killRunaways () 

Kills any processes that are larger than the maxMemory setting in the config file. Returns the number of processes
killed.

=cut

sub killRunaways {
    my $self = shift;
    my $killed = 0;
    my $processTable = Proc::ProcessTable->new;
    my $maxMemory = $self->wreConfig->get("starman/maxMemory");
    foreach my $process (@{$processTable->table}) {
        next unless ($process->cmndline =~ /starman/);
        if ($process->size >= $maxMemory) {
            $killed += $process->kill(9);
        }
    }
    return $killed;
}


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if Starman is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $starman = $self->wreConfig->get("starman");
    my $userAgent = LWP::UserAgent->new;
    $userAgent->agent("wre/1.0");
    $userAgent->timeout($starman->{connectionTimeout});
    my $header = HTTP::Headers->new;
    my $url = "http://".$starman->{defaultHostname}.":".$starman->{port}."/";
    my $request = HTTP::Request->new( GET => $url, $header);
    my $response = $userAgent->request($request);
    if ($response->is_success || $response->code eq "401") {
        return 1;
	} 
    croak "starman received error code ".$response->code." with message ".$response->error_as_HTML;
    return 0;
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not.

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub start {
    my $self = shift;
    my $count = 0;
    my $success = 0;
    my $config = $self->wreConfig;
    my $host = WRE::Host->new(wreConfig=>$config);
    unless ($config->get("starman/port") > 1024 || $host->isPrivilegedUser) {
        croak "You are not an administrator on this machine so you cannot start services with ports 1-1024.";
    }
    my $cmd = "";
    #start_server --pid-file=/data/wre/var/run/starman.pid --port=8081 --status=/data/wre/var/run/starman.status -- starman  --preload-app /data/WebGUI/app.psgi
    $cmd = $config->getRoot("/prereqs/bin/start_server")
         . " --pid-file="     . $config->getRoot("var/run/starman.pid")
         . " --status="  . $config->getRoot("var/run/starman.status")
         . " --port="    . $config->get("starman/port")
         . " --" #Beginning of the starman specific configurations
         . " starman"
         . " --preload-app"
         . " --access-log=" . $config->getRoot("var/logs/starman.log")
         . " --error-log=" . $config->getRoot("var/logs/starman_error.log")
         . " --workers=" . $config->get("starman/workers")
         . " --user=" . $config->get("user")
         . ' ' . $config->getRoot("sbin/wre.psgi") . " & "
         ;
    system($cmd); # catch command line output
    while ($count++ < 10 && !$success) {
        sleep(1);
        eval {$success = $self->ping };
    }
    if ($success) {
        $config->set("wreMonitor/starmanAdministrativelyDown", 0);
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
    $config->set("wreMonitor/starmanAdministrativelyDown", 1);
    my $host = WRE::Host->new(wreConfig=>$config);
    unless ($config->get("starman/port") > 1024 || $host->isPrivilegedUser) {
        croak "You are not an administrator on this machine so you cannot stop services with ports 1-1024.";
    }
    open my $pid_file, $config->getRoot('var/run/starman.pid') or
        croak "Unable open PID file ".$config->getRoot('var/run/starman.pid')." for reading $!\n";
    my $pid = do { local $/; <$pid_file> };
    close $pid_file;
    kill "TERM", $pid;
    while ($count++ < 10 && $success) {
        sleep(1);
        eval { $success = !$self->ping };
    }
    if ($success) {
        $config->set("wreMonitor/starmanAdministrativelyDown", 1);
    }
    return $success;
}

} # end inside out object

1;
