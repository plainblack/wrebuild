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
use Carp qw(carp croak);
use CGI;
use File::Slurp;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use Path::Class;
use WRE::Config;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Spectre;

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
            cgi         => parseRequest($request),
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
sub parseRequest {
    my $request = shift;
    my $method = $request->method;
    if ( $method eq 'GET' || $method eq 'HEAD' ) {
        return CGI->new( $request->uri->equery );
    }
    elsif ( $method eq 'POST' ) {
        my $contentType = $request->content_type;
        if ( ! $contentType || $contentType eq "application/x-www-form-urlencoded" ) {
            return CGI->new( $request->content );
        }
        elsif ( $contentType eq "multipart/form-data") {
            carp "Can't process multi-part data.";
        }
        else {
            carp "Invalid content type: $contentType";
        }
    }
    else {
        carp "Unsupported method: $method"; 
    }
    return {};
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
    $state->{connection}->send_file_response($state->{config}->getRoot("/var/wreconsole.css"));
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
sub www_editTemplate {
    my $state = shift;
    my $content = getNavigation("templates");
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.template$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $template;
    eval { $template = read_file($state->{config}->getRoot("/var/".$filename)) };
    if ($@) {
        carp "Couldn't open template file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    $template =~ s/\&/&amp;/xmsg;
    $template =~ s/\>/&gt;/xmsg;
    $template =~ s/\</&lt;/xmsg;
    $content .= '
        <form action="/editTemplateSave" method="post">
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="template" style="width: 700px; height: 400px;">'.$template.'</textarea><br />
        <input type="submit" value="Save" /> 
        </form>
    ';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_editTemplateSave {
    my $state = shift;
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.template$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $status = $filename." saved.";
    eval { write_file($state->{config}->getRoot("/var/".$filename), $state->{cgi}->param("template")) };
    if ($@) {
        $status = "Couldn't save $filename. $@";
        carp $status;
    }
    www_listTemplates($state, $status);
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
        <td>';
    my $modproxy = WRE::Modproxy->new($state->{config});
    if ($modproxy->ping) {
        $content .= '
             <form action="/stopModproxy" method="post">
                <input type="submit" value="Stop" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startModproxy" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartModproxy" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Apache Modperl</td>
        <td>';
    my $modperl = WRE::Modperl->new($state->{config});
    if ($modperl->ping) {
        $content .= '
             <form action="/stopModperl" method="post">
                <input type="submit" value="Stop" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startModperl" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartModperl" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>MySQL</td>
        <td>';
    my $mysql = WRE::Mysql->new($state->{config});
    if ($mysql->ping) {
        $content .= '
             <form action="/stopMysql" method="post">
                <input type="submit" value="Stop" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startMysql" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
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
    } 
    else {
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
    my $folder = dir($state->{config}->getWebguiRoot('/etc')) || carp "Couldn't open WebGUI configs folder.";
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
    my $status = shift;
    my $content = getNavigation("templates");
    $content .= '<div class="status">'.$status.'</div>';
    $content .= q| <table class="items">|;
    my $folder = dir($state->{config}->getRoot("/var")) || carp "Couldn't open wre templates folder.";
    while (my $file = $folder->next) {
        next if $file->is_dir;
        my $filename = $file->basename;
        next unless $filename =~ m/\.template$/;
        $content .= qq|<tr><td>$filename</td> <td>
             <form action="/editTemplate" method="post">
                <input type="hidden" name="filename" value="$filename" />
                <input type="submit" value="Edit" />
             </form>
            </td></tr>|;
    }
    $content .= q|</table>|;
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
sub www_restartModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new($state->{config});
    my $status = "Modproxy restarted.";
    unless ($service->restart) {
        $status = "Modproxy did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartMysql {
    my $state = shift;
    my $service = WRE::Mysql->new($state->{config});
    my $status = "MySQL restarted.";
    unless ($service->restart) {
        $status = "MySQL did not restart successfully. ".$@;
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
sub www_startModperl {
    my $state = shift;
    my $service = WRE::Modperl->new($state->{config});
    my $status = "Modperl started.";
    unless ($service->start) {
        $status = "Modperl did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new($state->{config});
    my $status = "Modproxy started.";
    unless ($service->start) {
        $status = "Modproxy did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startMysql {
    my $state = shift;
    my $service = WRE::Mysql->new($state->{config});
    my $status = "MySQL started.";
    unless ($service->start) {
        $status = "MySQL did not start successfully. ".$@;
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
sub www_stopModperl {
    my $state = shift;
    my $service = WRE::Modperl->new($state->{config});
    my $status = "Modperl stopped.";
    unless ($service->stop) {
        $status = "Modperl did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new($state->{config});
    my $status = "Modproxy stopped.";
    unless ($service->stop) {
        $status = "Modproxy did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopMysql {
    my $state = shift;
    my $service = WRE::Mysql->new($state->{config});
    my $status = "MySQL stopped.";
    unless ($service->stop) {
        $status = "MySQL did not stop successfully. ".$@;
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

