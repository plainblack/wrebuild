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
use Carp qw(croak);
use Class::InsideOut qw(new public);
use HTTP::Headers;
use HTTP::Request;
use JSON;
use LWP::UserAgent;
use Path::Class;
use WRE::File;
use WRE::Host;




#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE cconfig.

=cut

public wreConfig => my %config;



#-------------------------------------------------------------------

=head2 downloadFile ( url )

Downloads a file and returns a path to the location it downloaded to. Returns a -1 if it couldn't download the
file, and a -2 if it couldn't write the file.

=cut

sub downloadFile {
    my $self = shift;
    my $url = shift;
    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new(GET => $url);
    my $response = $ua->request($request);
    if ($response->is_error) {
        croak "Couldn't download file because ".$response->error_as_HTML;
        return -1;
    }
    my $file = WRE::File->new(wreConfig=>$self->wreConfig);
    my $path = file($file->makeTempPath,"/webgui.tar.gz")->stringify;
    if (open(my $fh, ">", $path)) {
        binmode $fh;
        print {$fh} $response->content;
        close($fh);
        return $path;
    } 
    else {
        croak "Couldn't write downloaded file to $path because $!";
        return -2;
    }
}

#-------------------------------------------------------------------

=head2 extractArchive ( path )

Extracts the archive over the top of the existing WebGUI installation. Returns 1 if successful and croaks and
returns 0 if not.

=head3 path

The path to the archive to be extracted.

=cut 

sub extractArchive {    
    my $self = shift;
    my $path = shift;
    my $config = $self->wreConfig;
    my $file = WRE::File->new(wreConfig => $config);
    my $root = dir($config->getWebguiRoot);
    $file->makePath($root->stringify);
    my $rootParent = $root->parent;
    eval{$file->untar(
            path    => $rootParent->stringify,
            file    => $path,
            gunzip  => 1,
            )};
    if ($@) {
       croak "Couldn't extract WebGUI archive because ".$@;
       return 0; 
    }
    return 1;
}


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

=head2 getMirrors ( version )

Returns a hash reference of available mirrors for a particular version.

=head3 version

A version number for WebGUI.

=cut

sub getMirrors {
    my $self = shift;
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






1;
