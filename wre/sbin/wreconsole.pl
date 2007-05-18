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
use JSON qw(objToJson jsonToObj);
use Path::Class;
use WRE::Config;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Spectre;

#-------------------------------------------------------------------
# server daemon
my $daemon = HTTP::Daemon->new(
    ReusePort   => 1,
    ReuseAddr   => 1,
    MultiHomed  => 1,
    LocalAddr   => "10.0.0.182",
    LocalPort   => 60834,
    ) || croak "Couldn't start server.";
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
    <a href="/editSettings" $settings>Settings</a>
    <a href="/listTemplates" $templates>Templates</a>
    <a href="/listUtilities" $utilities>Utilities</a>
    <div id="logo">WRE Console</div>
    <div id="navUnderline"></div>
    </div>
    |;
    return $content;
}

#-------------------------------------------------------------------
sub makeHtmlFormSafe {
    my $htmlRef = shift;
    ${$htmlRef} =~ s/\&/&amp;/xmsg;
    ${$htmlRef} =~ s/\>/&gt;/xmsg;
    ${$htmlRef} =~ s/\</&lt;/xmsg;
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
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/} || $filename eq "spectre.conf" || $filename eq "log.conf") {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $status = $sitename." deleted.";
    www_listSites($state, $status); 
}

#-------------------------------------------------------------------
sub www_editSettings {
    my $state = shift;
    my $config = $state->{config};
    my $content = getNavigation("settings");
    my $configOverrides = objToJson($config->get("webgui")->{configOverrides}, 
        {pretty => 1, indent => 4, autoconv=>0, skipinvalid=>1}); 
    my $wreMonitor = $config->get("wreMonitor");
    my $backup = $config->get("backup");
    my $demo = $config->get("demo");
    makeHtmlFormSafe(\$configOverrides); 
    $content .= '<form method="post" action="/editSettingsSave">
        <p><input type="submit" class="saveButton" value="Save" /></p>

        <fieldset><legend>Apache</legend>

        <p>
        Default Hostname<br />
        <input type="text" name="apacheDefaultHostname" value="'.$config->get("apache")->{defaultHostname}.'" /> 
        <span class="subtext">The hostname the WRE will check to see if Apache is alive. </span>
        </p>

        <p>
        Connection Timeout<br />
        <input type="text" name="apacheConnectionTimeout" value="'.$config->get("apache")->{connectionTimeout}.'" /> 
        <span class="subtext">How long the WRE will wait when checking to see if Apache is alive before
        deciding to give up.</span>
        </p>

        <p>
        Max Memory<br />
        <input type="text" name="apacheMaxMemoryPercent" value="'.$config->get("apache")->{maxMemoryPercent}.'" /> 
        <span class="subtext">The percentage of the servers memory that the WRE will allow Apache processes
        to use before killing them.</span>
        </p>

        </fieldset>
        
        <p><input type="submit" class="saveButton" value="Save" /></p>

        <fieldset><legend>WebGUI</legend>

        <p>
        Config File Overrides<br />
        <textarea name="webguiConfigOverrides">'.$configOverrides.'</textarea> 
        <span class="subtext">What settings should be overriden in the default WebGUI config file when creating a
        new site.</span>
        </p>

        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>WRE Monitor</legend>

        <p>
        Email Address<br />
        <input type="text" name="wreMonitorNotify" value="'.join(", ", @{$wreMonitor->{notify}}).'" /> 
        <span class="subtext">Email address to alert when site goes down. Comma separated list.</span>
        </p>

        <p>
        Seconds Between Checks<br />
        <input type="text" name="wreMonitorSecondsBetweenChecks" value="'.$wreMonitor->{secondsBetweenChecks}.'" /> 
        <span class="subtext">After an alert has been sounded, how long to wait until checking again to see if its
        back up.</span>
        </p>

        <p>
        Items To Monitor<br />
        <input type="radio" name="wreMonModproxy" value="1" '.(($wreMonitor->{items}{modproxy} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonModproxy" value="0" '.(($wreMonitor->{items}{modproxy} != 1) ? 'checked="1"' : '').' />No
        - modproxy<br />
        <input type="radio" name="wreMonModperl" value="1" '.(($wreMonitor->{items}{modperl} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonModperl" value="0" '.(($wreMonitor->{items}{modperl} != 1) ? 'checked="1"' : '').' />No
        - modperl<br />
        <input type="radio" name="wreMonMysql" value="1" '.(($wreMonitor->{items}{mysql} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonMysql" value="0" '.(($wreMonitor->{items}{mysql} != 1) ? 'checked="1"' : '').' />No
        - MySQL<br />
        <input type="radio" name="wreMonSpectre" value="1" '.(($wreMonitor->{items}{spectre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonSpectre" value="0" '.(($wreMonitor->{items}{spectre} != 1) ? 'checked="1"' : '').' />No
        - Spectre<br />
        <input type="radio" name="wreMonRunaway" value="1" '.(($wreMonitor->{items}{runaway} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonRunaway" value="0" '.(($wreMonitor->{items}{runaway} != 1) ? 'checked="1"' : '').' />No
        - Runaway Processes<br />
        </p>

        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>Backups</legend>

        <p>
        Path<br />
        <input type="text" name="backupPath" value="'.$backup->{path}.'" /> 
        <span class="subtext">The path to the folder you wish to back up files to.</span>
        </p>

        <p>
        Rotations<br />
        <input type="text" name="backupRotations" value="'.$backup->{rotations}.'" /> 
        <span class="subtext">How many copies of the backup should we keep at one time.</span>
        </p>

        <p>
        Compress<br />
        <input type="radio" name="backupCompress" value="1" '.(($backup->{compress} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupCompress" value="0" '.(($backup->{compress} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Should the backup be compressed.</span>
        </p>

        <p>
        Items To Backup<br />
        <input type="radio" name="backupFullWre" value="1" '.(($backup->{items}{fullWre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFullWre" value="0" '.(($backup->{items}{fullWre} != 1) ? 'checked="1"' : '').' />No
        - modproxy<br />
        <input type="radio" name="backupSmallWre" value="1" '.(($backup->{items}{smallWre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupSmallWre" value="0" '.(($backup->{items}{smallWre} != 1) ? 'checked="1"' : '').' />No
        - modperl<br />
        <input type="radio" name="backupDomains" value="1" '.(($backup->{items}{domainsFolder} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupDomains" value="0" '.(($backup->{items}{domainsFolder} != 1) ? 'checked="1"' : '').' />No
        - MySQL<br />
        <input type="radio" name="backupWebgui" value="1" '.(($backup->{items}{webgui} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupWebgui" value="0" '.(($backup->{items}{webgui} != 1) ? 'checked="1"' : '').' />No
        - Spectre<br />
        <input type="radio" name="backupMysql" value="1" '.(($backup->{items}{mysql} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupMysql" value="0" '.(($backup->{items}{mysql} != 1) ? 'checked="1"' : '').' />No
        - Runaway Processes<br />
        </p>

        <fieldset><legend>FTP</legend>
        <p>
        Enabled<br />
        <input type="radio" name="backupFtpEnabled" value="1" '.(($backup->{ftp}{enabled} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFtpEnabled" value="0" '.(($backup->{ftp}{enabled} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Should the backup be pushed to an FTP server.</span>
        </p>

        <p>
        Passive Transfers<br />
        <input type="radio" name="backupFtpPassive" value="1" '.(($backup->{ftp}{usePassiveTransfers} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFtpPassive" value="0" '.(($backup->{ftp}{usePassiveTransfers} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Should the FTP use passive transfers.</span>
        </p>

        <p>
        Rotations<br />
        <input type="text" name="backupFtpRotations" value="'.$backup->{ftp}{rotations}.'" /> 
        <span class="subtext">How many copies of the backup should we keep on the FTP server at one time.</span>
        </p>

        <p>
        Path<br />
        <input type="text" name="backupFtpPath" value="'.$backup->{ftp}{path}.'" /> 
        <span class="subtext">The path to the folder on the FTP server you wish to back up files to.</span>
        </p>

        <p>
        Auth<br />
        <input type="text" name="backupFtpUser" value="'.$backup->{ftp}{user}.'" /> 
        <input type="password" name="backupFtpPassword" value="'.$backup->{ftp}{password}.'" /> 
        <span class="subtext">The username and password of the FTP server.</span>
        </p>

        </fieldset>

        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
    </form>';
    return sendResponse($state, $content);
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
    makeHtmlFormSafe(\$template);
    $content .= '
        <form action="/editTemplateSave" method="post">
        <input type="submit" class="saveButton" value="Save" /> 
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="template">'.$template.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> 
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
sub www_editSite {
    my $state = shift;
    my $content = getNavigation("sites");
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/} || $filename eq "spectre.conf" || $filename eq "log.conf") {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $contents;
    eval { $contents = read_file($state->{config}->getWebguiRoot("/etc/".$filename)) };
    if ($@) {
        carp "Couldn't open template file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <p>Making a modification of these files requires a restart of modperl and modproxy afterwards, and sometimes also a restart
        of Spectre after that.</p>
        <form action="/editSiteSave" method="post">
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="webgui">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" />  <br /><br />
    ';
    eval { $contents = read_file($state->{config}->getRoot("/etc/".$sitename.".modproxy")) };
    if ($@) {
        carp "Couldn't open $sitename.modproxy file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <div><b>'.$sitename.'.modproxy</b></div>
        <textarea name="modproxy">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
    ';
    eval { $contents = read_file($state->{config}->getRoot("/etc/".$sitename.".modperl")) };
    if ($@) {
        carp "Couldn't open $sitename.modperl file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <div><b>'.$sitename.'.modperl</b></div>
        <textarea name="modperl">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
    ';
    eval { $contents = read_file($state->{config}->getRoot("/etc/awstats.".$sitename.".conf")) };
    if ($@) {
        carp "Couldn't open awstats.$sitename.conf file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <div><b>awstats.'.$sitename.'.conf</b></div>
        <textarea name="awstats">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> 
        </form>
    ';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_editSiteSave {
    my $state = shift;
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $status = $sitename." saved.";
    eval { write_file($state->{config}->getWebguiRoot("/etc/".$filename), $state->{cgi}->param("webgui")) };
    if ($@) {
        $status = "Couldn't save $filename. $@";
        carp $status;
    }
    eval { write_file($state->{config}->getRoot("/etc/".$sitename.".modproxy"), $state->{cgi}->param("modproxy")) };
    if ($@) {
        $status = "Couldn't save $sitename.modproxy. $@";
        carp $status;
    }
    eval { write_file($state->{config}->getRoot("/etc/".$sitename.".modperl"), $state->{cgi}->param("modperl")) };
    if ($@) {
        $status = "Couldn't save $sitename.modperl. $@";
        carp $status;
    }
    eval { write_file($state->{config}->getRoot("/etc/awstats.".$sitename.".conf"), $state->{cgi}->param("awstats")) };
    if ($@) {
        $status = "Couldn't save awstats.$sitename.conf. $@";
        carp $status;
    }
    www_listSites($state, $status);
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
    <tr>
        <td>WRE Console</td>
        <td><form action="/stopConsole" method="post">
              <input type="submit" value="Stop" />
             </form>
        </td>
    </table>';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listSites {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("sites") . q|
             <form action="/addSite" method="post">
                <input type="submit" value="Add Site" />
             </form>
        <table class="items">|;
    $content .= '<div class="status">'.$status.'</div>';
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
             <form action="/editSite" method="post">
                <input type="hidden" name="filename" value="$filename" />
                <input type="submit" value="Edit" />
             </form>
             <form action="/deleteSite" method="post">
                <input type="hidden" name="filename" value="$filename" />
                <input type="submit" 
                    onclick="return confirm('Are you sure you wish to delete this site and all it\\\'s content and users?');"
                    class="deleteButton" value="Delete" />
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
    my $status = shift;
    my $content = getNavigation("utilities");
    $content .= '<div class="status">'.$status.'</div>';
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
sub www_stopConsole {
    my $state = shift;
    sendResponse($state, '<h1>WRE Console has shutdown.</h1>');
    exit;
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

