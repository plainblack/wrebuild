package WRE::Spectre;

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
use Class::InsideOut qw(register id public);
use Config::JSON;
use POE::Component::IKC::ClientLite;
use List::Util qw(sum max);
use JSON qw(decode_json);
use WRE::Host;

=head1 ISA

WRE::Service

=cut


#-------------------------------------------------------------------

=head2 getName () 

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
    $wreConfig->set("wreMonitor/spectreAdministrativelyDown", 0);
    my $host = WRE::Host->new(wreConfig => $wreConfig);
    my $cmd = "";
    if ($host->getOsName eq "windows") {
        $cmd = "net start WREspectre";
    }
    else {
        chdir $wreConfig->getWebguiRoot("/sbin");
        $cmd = $wreConfig->getRoot("/prereqs/bin/perl")." spectre.pl --daemon";
    }
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
    $wreConfig->set("wreMonitor/spectreAdministrativelyDown", 1);
    my $host = WRE::Host->new(wreConfig => $wreConfig);
    my $cmd = "";
    if ($host->getOsName eq "windows") {
        $cmd = "net stop WREspectre";
    }
    else {
        chdir($wreConfig->getWebguiRoot("/sbin"));
        $cmd = $wreConfig->getRoot("/prereqs/bin/perl")." spectre.pl --shutdown";
    }
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 1) {
        sleep(1);
        eval{$success = !$self->ping};
        $count++;
    }
    return $success;
}

#-------------------------------------------------------------------

=head2 getStatusReport

Connect to spectre using IKC, get the status report in JSON format, parse it,
and return it. Croaks on error.

=cut

sub getStatusReport {

    my $self = shift;
    my $spectreConfig = $self->spectreConfig;

    # connect to spectre
    my $remote = create_ikc_client(
        port=>$spectreConfig->get("port"),
        ip=>$spectreConfig->get("ip"),
        name=>rand(100000),
        timeout=>10
    );

    # log an error if we can't
    unless($remote) {
        croak "Couldn't connect to spectre: " . $POE::Component::IKC::ClientLite::error;
    }

    # call the event that'll get us our data, store it.
    my $result = $remote->post_respond('workflow/getJsonStatus');

    # if it's undef, something went wrong.
    unless(defined $result) {
        croak "Couldn't call workflow/getJsonStatus via IKC: " . $POE::Component::IKC::ClientLite::error;
    }

    # Disconnect and delete the connection object.
    $remote->disconnect;
    undef $remote;

    # Finally, return the data in a Perl data structure.
    return decode_json($result);
}

#-------------------------------------------------------------------

=head2 getWorkflowsPerSite ( [ statusReport ] )

Processes a status report as returned by B<getStatusReport> and returns a data
structure representing the number of workflows each site is currently
managing. The data structure is a hashref, with the keys being site names and
the values being the number of workflows, across all queues, that site is
currently managing.

=head3 statusReport

The report as returned from B<getStatusReport>.

=cut

sub getWorkflowsPerSite {
    my $self = shift;
    my $report = shift;
    my $workflowsPerSite = {};

    # for each site...
    foreach my $site (keys %{$report}) {
        $workflowsPerSite->{$site} = 0;

        foreach my $queue (values %{ $report->{$site} }) {
            $workflowsPerSite += scalar @$queue;
        }
    }
    return $workflowsPerSite;
}

#-------------------------------------------------------------------

=head2 getPriorities ( [ statusReport ] )

Processes a status report as returned by B<getStatusReport>, and report on the
highest priority workflow across all sites. Returns a scalar numeric value of
the highest priority workflow across all sites.

=head3 statusReport

The report as returned from B<getStatusReport>.

=cut

sub getPriorities {
    my $self = shift;
    my $report = shift;
    my $priorities = {};
    my $maxPriority;

    # for each site...
    foreach my $site (values %$report) {

        # for each queue...
        foreach my $queue (values %$site) {
            my $queueMax = max map { $_->{workingPriority} } @$queue;
            $maxPriority = $queueMax
                if $maxPriority > $queueMax;
        }
    }
    return $maxPriority;
}

1;

