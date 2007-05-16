#!/data/wre/prereqs/bin/perl

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
use Carp;
use Config::JSON;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use Path::Class;

#-------------------------------------------------------------------
# server daemon
my $daemon = HTTP::Daemon->new || croak "Couldn't start server.";
print "Please contact me at: <URL:", $daemon->url, ">\n";
while (my $connection = $daemon->accept) {
    while (my $request = $connection->get_request) {
        my $state = {
            request => $request,
            connection => $connection,
            daemon => $daemon
            };
        my $handler = getHandler($request->url->path);
        &$handler($state);
        #if ($request->method eq 'GET' and $request->url->path eq "/xyzzy") {
            # remember, this is *not* recommended practice :-)
        #    printHeader($c);
            #$c->send_file_response("/etc/passwd");
        #}
       # else {
       #     $connection->send_error(RC_FORBIDDEN)
       # }
    }
    $connection->close;
    undef($connection);
}

#-------------------------------------------------------------------
sub getHandler {
    my $url = shift;
    my %handlers = (
        "/add-site" => \&www_addSite,
        "/delete-site" => \&www_deleteSite,
        "/edit-webgui-config" => \&www_editWebguiConfig,
        "/edit-apache-config" => \&www_editApacheConfig,
        "/list-templates" => \&www_listTemplates,
        "/list-services" => \&www_listServices,
        "/list-utilities" => \&www_listUtilities,
        "/list-settings" => \&www_listSettings,
        "/list-sites" => \&www_listSites,
        "/wre.css" => \&www_getCss,
    );
    my $handler = $handlers{$url};
    unless (defined $handler) {
        $handler = \&www_listSites;
    }
    return $handler;
}


#-------------------------------------------------------------------
sub getNavigation {
    my $section = shift || "sites";
    my $toggle = 'class="sectionOn"';
    my $sites = ($section eq "sites") ? $toggle : '';
    my $services = ($section eq "services") ? $toggle : '';
    my $settings = ($section eq "settings") ? $toggle : '';
    my $templates = ($section eq "templates") ? $toggle : '';
    my $utilities = ($section eq "utilities") ? $toggle : '';
    my $content = qq|
    <div id="tabsWrapper">
    <a href="/list-sites" $sites>Sites</a>
    <a href="/list-services" $services>Services</a>
    <a href="/list-settings" $settings>Settings</a>
    <a href="/list-templates" $templates>Templates</a>
    <a href="/list-utilities" $utilities>Utilities</a>
    <div id="logo">WRE Console</div>
    <div id="navUnderline"></div>
    </div>
    |;
    return $content;
}


#-------------------------------------------------------------------
sub sendResponse {
    my $state = shift;
    my $content = shift;
    $content = '<html><head><title>WRE Console</title><link rel="stylesheet" href="/wre.css" type="text/css"
    /></head> <body><div id="contentWrapper">'.$content.'</div><div id="credits">&copy; 2005-2007 <a
    href="http://www.plainblack.com/">Plain Black Corporation</a>. All rights reserved.</div></body></html>';
    my $response = HTTP::Response->new();
    $response->header("Content-Type" => "text/html");
    $response->content($content);
    $state->{connection}->send_response($response);
}


#-------------------------------------------------------------------
sub www_getCss {
    my $state = shift;
    $state->{connection}->send_file_response("/data/wre/var/wre.css");
}

#-------------------------------------------------------------------
sub www_addSite {
    my $state = shift;
    my $content = getNavigation("sites");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_deleteSite {
    my $state = shift;
    my $content = getNavigation("sites");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_editApacheConfig {
    my $state = shift;
    my $content = getNavigation("sites");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_editWebguiConfig {
    my $state = shift;
    my $content = getNavigation("sites");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listServices {
    my $state = shift;
    my $content = getNavigation("services");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listSettings {
    my $state = shift;
    my $content = getNavigation("settings");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listSites {
    my $state = shift;
    my $content = getNavigation("sites") . q|
             <form action="/add-site" method="post">
                <input type="submit" value="Add Site" />
             </form>
        <table class="items">|;
    my $folder = dir('','data','WebGUI','etc') || carp "Couldn't open WebGUI configs folder.";
    while (my $file = $folder->next) {
        next if $file->is_dir;
        my $filename = $file->basename;
        next unless $filename =~ m/\.conf$/;
        next if $filename eq "spectre.conf";
        next if $filename eq "log.conf";
        my $sitename = $filename;
        $sitename =~ s/^(.*)\.conf$/$1/;
        $content .= qq|<tr><td>$sitename</td> <td>
             <form action="/edit-webgui-config" method="post">
                <input type="hidden" name="config" value="$filename" />
                <input type="submit" value="Edit WebGUI Config" />
             </form>
             <form action="/edit-apache-config" method="post">
                <input type="hidden" name="config" value="$filename" />
                <input type="submit" value="Edit Apache Config" />
             </form>
             <form action="/delete-site" method="post">
                <input type="hidden" name="config" value="$filename" />
                <input type="submit" value="Delete Site" />
             </form>
            </td></tr>|;
    }
    $content .= q|</table>|;
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listTemplates {
    my $state = shift;
    my $content = getNavigation("templates");
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listUtilities {
    my $state = shift;
    my $content = getNavigation("utilities");
    sendResponse($state, $content);
}


