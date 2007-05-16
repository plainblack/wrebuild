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
use lib '../lib';
use Carp;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use Path::Class;
use WRE::Spectre;
use WRE::Mysql;
use WRE::Config;

#-------------------------------------------------------------------
# server daemon
my $daemon = HTTP::Daemon->new || croak "Couldn't start server.";
print "Please contact me at: <URL:", $daemon->url, ">\n";
while (my $connection = $daemon->accept) {
    while (my $request = $connection->get_request) {
        my $state = {
            request     => $request,
            connection  => $connection,
            daemon      => $daemon,
            config      => WRE::Config->new,
        };
        my $handler = $request->url->path;
        $handler =~ s{^/(.*)}{$1};
        if ($handler eq "" || $handler !~ m/^[A-Za-z]+$/) {
            $handler = "listSites";
        }
        $handler = "www_".$handler;
        no strict;
        &$handler($state);
        use strict;
    }
    $connection->close;
    undef($connection);
}

#-------------------------------------------------------------------
# this takes care of www_ methods that are called accidentally or maliciously
sub AUTOLOAD {
	our $AUTOLOAD;
    www_listSites(@_);
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
    <a href="/listSites" $sites>Sites</a>
    <a href="/listServices" $services>Services</a>
    <a href="/listSettings" $settings>Settings</a>
    <a href="/listTemplates" $templates>Templates</a>
    <a href="/listUtilities" $utilities>Utilities</a>
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
    $content = '<html><head><title>WRE Console</title><link rel="stylesheet" href="/css" type="text/css"
    /></head> <body><div id="contentWrapper">'.$content.'</div><div id="credits">&copy; 2005-2007 <a
    href="http://www.plainblack.com/">Plain Black Corporation</a>. All rights reserved.</div></body></html>';
    my $response = HTTP::Response->new();
    $response->header("Content-Type" => "text/html");
    $response->content($content);
    $state->{connection}->send_response($response);
}


#-------------------------------------------------------------------
sub www_css {
    my $state = shift;
    $state->{connection}->send_file_response("/data/wre/var/wreconsole.css");
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
    my $status = shift;
    my $content = getNavigation("services");
    $content .= '<div class="status">'.$status.'</div>';
    $content .= '<table class="items">
    <tr>
        <td>Apache Modproxy</td>
        <td>
             <form action="/startModproxy" method="post">
                <input type="submit" value="Start" />
             </form>
             <form action="/stopModproxy" method="post">
                <input type="submit" value="Stop" />
             </form>
             <form action="/restartModproxy" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Apache Modperl</td>
        <td>
             <form action="/startModperl" method="post">
                <input type="submit" value="Start" />
             </form>
             <form action="/stopModperl" method="post">
                <input type="submit" value="Stop" />
             </form>
             <form action="/restartModperl" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>MySQL</td>
        <td>
             <form action="/startMysql" method="post">
                <input type="submit" value="Start" />
             </form>
             <form action="/stopMysql" method="post">
                <input type="submit" value="Stop" />
             </form>
             <form action="/restartMysql" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Spectre</td>
        <td>';
    my $spectre = WRE::Spectre->new($state->{config});
    if ($spectre->ping) {
            $content .= ' <form action="/stopSpectre" method="post">
                <input type="submit" value="Stop" />
             </form>';
    } else {
             $content .= '<form action="/startSpectre" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartSpectre" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    </table>';
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
             <form action="/addSite" method="post">
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
             <form action="/editWebguiConfig" method="post">
                <input type="hidden" name="config" value="$filename" />
                <input type="submit" value="Edit WebGUI Config" />
             </form>
             <form action="/editApacheConfig" method="post">
                <input type="hidden" name="config" value="$filename" />
                <input type="submit" value="Edit Apache Config" />
             </form>
             <form action="/deleteSite" method="post">
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

#-------------------------------------------------------------------
sub www_restartModperl {
    my $state = shift;
    my $service = WRE::Modperl->new($state->{config});
    my $status = "Modperl restarted.";
    unless ($service->restart) {
        $status = "Modperl did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new($state->{config});
    my $status = "Spectre restarted.";
    unless ($service->restart) {
        $status = "Spectre did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new($state->{config});
    my $status = "Spectre started.";
    unless ($service->start) {
        $status = "Spectre did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new($state->{config});
    my $status = "Spectre stopped.";
    unless ($service->stop) {
        $status = "Spectre did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

