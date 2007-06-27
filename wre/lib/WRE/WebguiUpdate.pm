package WRE::WebguiUpdate;

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
use Archive::Tar;
use Carp qw(croak);
use Class::InsideOut qw(new public);
use HTTP::Headers;
use HTTP::Request;
use JSON;
use LWP::UserAgent;
use WRE::Host;


{ # begin inside out object



#-------------------------------------------------------------------

=head2 getLatestVersionNumber ( )

Returns the version number of the most recent WebGUI release.

=cut

sub getLatestVersionNumber {
    my $self = shift;
    my $host = WRE::Host->new(wreConfig=>$self->wreConfig);
    my $ua = new LWP::UserAgent;
    $ua->timeout(30);
    my $header = new HTTP::Headers;
    my $referer = "http://webgui.install.getversion/".$host->getHostname;
    $header->referer($referer);
    my $request = new HTTP::Request (GET => "http://update.webgui.org/latest-version.txt", $header);
    my $response = $ua->request($request);
    my $version = $response->content;
    chomp $version;
    if ($response->is_error) {
        croak "Couldn't fetch latest version number because ".$response->error_as_HTML;
    }
    if ($version eq "") {
        croak "Something bad happened. Version fetched is blank.";
    }
    return $version;
}



#-------------------------------------------------------------------

=head2 getMirrorsList ( version )

Returns a hash reference of available mirrors for a particular version.

=head3 version

A version number for WebGUI.

=cut

sub getMirrorsList {
    my $version = shift;
    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new(GET => 'http://update.webgui.org/getmirrors.pl?version='.$version);
    my $response = $ua->request($request);
    if ($response->is_error) {
        croak "Couldn't fetch mirrors list for version $version because ".$response->error_as_HTML;
    }
    my $mirrors = $response->content;
    return jsonToObj($mirrors);
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

public wreConfig => my %config;




} # end inside out object

1;
