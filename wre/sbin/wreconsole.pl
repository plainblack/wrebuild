#!/data/wre/prereqs/bin/perl

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
use lib '/data/wre/lib';
use Carp qw(carp croak);
use CGI;
use Digest::MD5;
use File::Which qw(which);
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use JSON qw(from_json to_json);
use Path::Class;
use String::Random qw(random_string);
use WRE::Config;
use WRE::File;
use WRE::Host;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Site;
use WRE::Spectre;
use WRE::WebguiUpdate;


#-------------------------------------------------------------------
# server daemon
my $wreConfig = WRE::Config->new;
my $host = WRE::Host->new(wreConfig => $wreConfig);
my $osname = $host->getOsName;
my %serverProperties = (
    ReuseAddr   => 1,
    MultiHomed  => 1,
    LocalAddr   => undef,
    LocalPort   => 60834,
    );
if ($osname eq "darwin" || $osname eq "freebsd") {
    $serverProperties{ReusePort} = 1;
}

my $daemon = HTTP::Daemon->new(%serverProperties) || croak "Couldn't start server.";
print "Please contact me at:\n\t", $daemon->url, "\n";
while (my $connection = $daemon->accept) {
    while (my $request = $connection->get_request) {
        my $state = {
            request     => $request,
            connection  => $connection,
            daemon      => $daemon,
            config      => $wreConfig,
            cgi         => parseRequest($request),
        };
        my $handler = $request->url->path;
        $handler =~ s{^/(.*)}{$1};
        if ($handler eq "" || $handler !~ m/^[A-Za-z]+$/) {
            if ( -d $wreConfig->getWebguiRoot ) {
                $handler = "listSites";
            }
            else {
                $handler = "setup";
            }
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
    <!-- a href="/listUtilities" $utilities>Utilities</a -->
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
    ${$htmlRef} =~ s/\"/&quot;/xmsg;
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
    /></head> <body><div id="contentWrapper">'.$content.'</div><div id="footerOverline"></div><div id="credits">&copy; 2005-2007 <a
    href="http://www.plainblack.com/">Plain Black Corporation</a>. All rights reserved.</div></body></html>';
    my $response = HTTP::Response->new();
    $response->header("Content-Type" => "text/html");
    $response->content($content);
    $state->{connection}->send_response($response);
    $state->{connection}->force_last_request;
}


#-------------------------------------------------------------------
sub www_css {
    my $state = shift;
    $state->{connection}->send_file_response($state->{config}->getRoot("/var/wreconsole.css"));
}

#-------------------------------------------------------------------
sub www_addSite {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("sites");
    my $cgi = $state->{cgi};
    $content .= '
    <h1>Add A Site</h1>
    <div class="status">'.$status.'</div>
    <p>Adding a site requires you to restart modperl, modproxy, and Spectre.</p>
    <form action="/addSiteSave" method="post">
    <table>
    <tr>
        <td>Admin Database Password</td>
        <td><input type="password" name="adminPassword" value="'.$cgi->param("adminPassword").'" /> <span class="subtext">Required</span></td>
    </tr>
    <tr>
        <td>Site Name</td>
        <td><input type="text" name="sitename" value="'.$cgi->param("sitename").'" /> <span class="subtext">Required</span></td>
    </tr>
    <tr>
        <td>Site Database User</td>
        <td><input type="text" name="siteDatabaseUser" value="'.$cgi->param("siteDatabaseUser").'" /> <span class="subtext">Will be auto generated if left
        blank.</span></td>
    </tr>
    <tr>
        <td>Site Database Password</td>
        <td><input type="password" name="siteDatabasePassword" value="'.$cgi->param("siteDatabasePassword").'" /> <span class="subtext">Will be auto generated if
        left blank.</td>
    </tr>
    <tr>
        <td>Custom Variables</td>
        <td>
            var0 <input type="text" name="var0" value="'.$cgi->param("var0").'" /><br />
            var1 <input type="text" name="var1" value="'.$cgi->param("var1").'" /><br />
            var2 <input type="text" name="var2" value="'.$cgi->param("var2").'" /><br />
            var3 <input type="text" name="var3" value="'.$cgi->param("var3").'" /><br />
            var4 <input type="text" name="var4" value="'.$cgi->param("var4").'" /><br />
            var5 <input type="text" name="var5" value="'.$cgi->param("var5").'" /><br />
            var6 <input type="text" name="var6" value="'.$cgi->param("var6").'" /><br />
            var7 <input type="text" name="var7" value="'.$cgi->param("var7").'" /><br />
            var8 <input type="text" name="var8" value="'.$cgi->param("var8").'" /><br />
            var9 <input type="text" name="var9" value="'.$cgi->param("var9").'" /><br />
        </td>
    </tr>
    </table>
    <input type="submit" class="saveButton" value="Create Site" onclick="this.value=\'Adding...\';" />
    </form>
    ';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_addSiteSave {
    my $state = shift;
    my $cgi = $state->{cgi};
    my $site = WRE::Site->new(
        wreConfig       => $state->{config}, 
        sitename        => $cgi->param("sitename"), 
        adminPassword   => $cgi->param("adminPassword")
        );
    if (eval {$site->checkCreationSanity}) {
        $site->create({
            siteDatabaseUser        => $cgi->param("siteDatabaseUser"),
            siteDatabasePassword    => $cgi->param("siteDatabasePassword"),
            var0                    => $cgi->param("var0"),
            var1                    => $cgi->param("var1"),
            var2                    => $cgi->param("var2"),
            var3                    => $cgi->param("var3"),
            var4                    => $cgi->param("var4"),
            var5                    => $cgi->param("var5"),
            var6                    => $cgi->param("var6"),
            var7                    => $cgi->param("var7"),
            var8                    => $cgi->param("var8"),
            var9                    => $cgi->param("var9"),
            });
        return www_listSites($state, $site->sitename." was created. Don't forget to restart the web servers and Spectre.");
    } 
    else {
        return www_addSite($state, "Site could not be created because ".$@);
    }
}

#-------------------------------------------------------------------
sub www_deleteSite {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("sites");
    my $cgi = $state->{cgi};
    $content .= '
    <h1>Delete A Site</h1>
    <div class="status">'.$status.'</div>
    <p>Are you sure you wish to delete this site and all it\'s content and users? This cannot be undone, once you
    click on the button below.</p>
    <p>Adding a site requires you to restart modperl, modproxy, and Spectre.</p>
    <form action="/deleteSiteSave" method="post">
    <input type="hidden" name="filename" value="'.$cgi->param("filename").'" />
    <table>
    <tr>
        <td>Site</td>
        <td>'.$cgi->param("filename").'</td>
    </tr>
    <tr>
        <td>Admin Database Password</td>
        <td><input type="password" name="adminPassword" value="'.$cgi->param("adminPassword").'" /> <span class="subtext">Required</span></td>
    </tr>
    </table>
    <input type="submit" class="deleteButton" value="Delete Site" onclick="this.value=\'Deleting...\';" />
    </form>
    ';
    sendResponse($state, $content);
}


#-------------------------------------------------------------------
sub www_deleteSiteSave {
    my $state = shift;
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $site = WRE::Site->new(
        wreConfig       => $state->{config}, 
        sitename        => $sitename, 
        adminPassword   => $state->{cgi}->param("adminPassword")
        );
    if (eval{$site->checkDeletionSanity}) {
        $site->delete;
        www_listSites($state, $sitename." deleted."); 
    } 
    else {
        return www_deleteSite($state, $sitename." could not be created because ".$@);
    }
    my $status = $sitename." deleted.";
}

#-------------------------------------------------------------------
sub www_editSettings {
    my $state = shift;
    my $status = shift;
    my $config = $state->{config};
    my $content = getNavigation("settings");
    my $configOverrides = JSON->new->pretty(1)->encode($config->get("webgui/configOverrides"));
    my $logs = $config->get("logs");
    my $apache = $config->get("apache");
    my $wreMonitor = $config->get("wreMonitor");
    my $webstats = $config->get("webstats");
    my $backup = $config->get("backup");
    my $demo = $config->get("demo");
    makeHtmlFormSafe(\$configOverrides); 
    $content .= '<p class="status">'.$status.'</p><form method="post" action="/editSettingsSave">
        <p><input type="submit" class="saveButton" value="Save" /></p>

        <fieldset><legend>Apache</legend>

        <p>
        Default Hostname<br />
        <input type="text" name="apacheDefaultHostname" value="'.$apache->{defaultHostname}.'" /> 
        <span class="subtext">The hostname the WRE will check to see if Apache is alive. </span>
        </p>

        <p>
        Connection Timeout<br />
        <input type="text" name="apacheConnectionTimeout" value="'.$apache->{connectionTimeout}.'" /> 
        <span class="subtext">How long the WRE will wait when checking to see if Apache is alive before
        deciding to give up.</span>
        </p>

        <p>
        Max Memory<br />
        <input type="text" name="apacheMaxMemory" value="'.$apache->{maxMemory}.'" /> 
        <span class="subtext">The amount of the servers memory (in bytes) that the WRE will allow Apache/mod_perl processes
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
        <fieldset><legend>Logs</legend>

        <p>
        Number of Rotations<br />
        <input type="text" name="logRotations" value="'.$logs->{rotations}.'" /> 
        <span class="subtext">How many old sets of logs should be kept around?</span>
        </p>
        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>Demo</legend>

        <p>
        Enable?<br />
        <input type="radio" name="enableDemo" value="1" '.(($demo->{enabled} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="enableDemo" value="0" '.(($demo->{enabled} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Do you want to enable the WebGUI demo server?</span>
        </p>

        <p>
        Hostname<br />
        <input type="text" name="demoHost" value="'.$demo->{hostname}.'" /> 
        <span class="subtext">What do you want the hostname of your demo server to be?</span>
        </p>

        <p>
        Duration<br />
        <input type="text" name="demoDuration" value="'.$demo->{duration}.'" /> 
        <span class="subtext">How many days should each demo last?</span>
        </p>
        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>Web Statistics</legend>

        <p>
        Enable?<br />
        <input type="radio" name="enableWebstats" value="1" '.(($webstats->{enabled} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="enableWebstats" value="0" '.(($webstats->{enabled} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Do you want the WRE to keep track of web statistics?</span>
        </p>

        <p>
        Hostname<br />
        <input type="text" name="webstatsHost" value="'.$webstats->{hostname}.'" /> 
        <span class="subtext">What do you want the WRE to use as a hostname for your web stats server?</span>
        </p>
        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>Backups</legend>

        <p>
        Enable?<br />
        <input type="radio" name="enableBackups" value="1" '.(($backup->{enabled} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="enableBackups" value="0" '.(($backup->{enabled} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Do you want the WRE to perform backups?</span>
        </p>

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
        Items To Backup<br />
        <input type="radio" name="backupFullWre" value="1" '.(($backup->{items}{fullWre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFullWre" value="0" '.(($backup->{items}{fullWre} != 1) ? 'checked="1"' : '').' />No
        - Full WRE<br />
        <input type="radio" name="backupSmallWre" value="1" '.(($backup->{items}{smallWre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupSmallWre" value="0" '.(($backup->{items}{smallWre} != 1) ? 'checked="1"' : '').' />No
        - Only WRE Configuration Information<br />
        <input type="radio" name="backupDomains" value="1" '.(($backup->{items}{domainsFolder} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupDomains" value="0" '.(($backup->{items}{domainsFolder} != 1) ? 'checked="1"' : '').' />No
        - Domains Folders<br />
        <input type="radio" name="backupWebgui" value="1" '.(($backup->{items}{webgui} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupWebgui" value="0" '.(($backup->{items}{webgui} != 1) ? 'checked="1"' : '').' />No
        - WebGUI<br />
        <input type="radio" name="backupMysql" value="1" '.(($backup->{items}{mysql} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupMysql" value="0" '.(($backup->{items}{mysql} != 1) ? 'checked="1"' : '').' />No
        - MySQL Data<br />
        </p>

        <p>
        External Scripts<br />
        <textarea name="externalScripts">'.join("\n", @{$backup->{externalScripts}}).'</textarea>
        <span class="subtext">The paths to some external scripts that you\'d like to run as part of the backup
            process. One per line.</span>
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
        Host<br />
        <input type="text" name="backupFtpHost" value="'.$backup->{ftp}{hostname}.'" /> 
        <span class="subtext">The hostname of the FTP server you wish to back up files to.</span>
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
sub www_editSettingsSave {
    my $state           = shift;
    my $cgi             = $state->{cgi};
    my $config          = $state->{config};
    my $file            = WRE::File->new(wreConfig=>$config);
    my $status          = "";

    # webgui 
    $config->set("webgui/configOverrides", JSON::from_json($cgi->param("webguiConfigOverrides")));
    
    # logs
    $config->set("logs/rotations", $cgi->param("logRotations"));
    
    # wre monitor
    my $notifyString    = $cgi->param("wreMonitorNotify");
    $notifyString       =~ s/\s+//g;
    my @notify          = split(",", $notifyString); 
    $config->set("wreMonitor/notify", \@notify);
    $config->set("wreMonitor/items/modperl", $cgi->param("wreMonModperl"));
    $config->set("wreMonitor/items/modproxy", $cgi->param("wreMonModproxy"));
    $config->set("wreMonitor/items/mysql", $cgi->param("wreMonMysql"));
    $config->set("wreMonitor/items/runaway", $cgi->param("wreMonRunaway"));
    $config->set("wreMonitor/items/spectre", $cgi->param("wreMonSpectre"));

    # webstats
    $config->set("webstats/hostname", $cgi->param("webstatsHost"));
    # have to enable web stats
    if ($config->get("webstats/enabled") == 0 && $cgi->param("enableWebstats") == 1) {
        $file->copy($config->getRoot("/var/setupfiles/stats.modproxy"), $config->getRoot("/etc/stats.modproxy"), 
            { force => 1, templateVars=> { sitename=>$config->get("webstats/hostname") } });
        $status .= "Webstats settings changed. You must restart modproxy for these changes to take effect.<br />";
    }
    # have to disable webstats
    elsif ($config->get("webstats/enabled") == 1 && $cgi->param("enableWebstats") == 0) {
        $file->delete($config->getRoot("/etc/stats.modproxy"));
        $status .= "Webstats settings changed. You must restart modproxy for these changes to take effect.<br />";
    }
    $config->set("webstats/enabled", $cgi->param("enableWebstats"));

    # backups
    my @externalScripts         = split("\n", $cgi->param("externalScripts"));
    $config->set("backup/externalScripts", \@externalScripts);
    $config->set("backup/path", $cgi->param("backupPath"));
    # have to enable 
    if ($config->get("backup/enabled") == 0 && $cgi->param("enableBackups") == 1) {
        $file->copy($config->getRoot("/var/setupfiles/backup.exclude"), $config->getRoot("/etc/backup.exclude"), 
            { force => 1 });
    }
    # have to disable 
    elsif ($config->get("webstats/enabled") == 1 && $cgi->param("enableWebstats") == 0) {
        $file->delete($config->getRoot("/etc/backup.exclude"));
    }
    $config->set("backup/enabled", $cgi->param("enableBackups"));
    $config->set("backup/rotations", $cgi->param("backupRotations"));
    $config->set("backup/items/fullWre", $cgi->param("backupFullWre"));
    $config->set("backup/items/smallWre", $cgi->param("backupSmallWre"));
    $config->set("backup/items/mysql", $cgi->param("backupMysql"));
    $config->set("backup/items/webgui", $cgi->param("backupWebgui"));
    $config->set("backup/items/domainsFolder", $cgi->param("backupDomains"));
    $config->set("backup/ftp/enabled", $cgi->param("backupFtpEnabled"));
    $config->set("backup/ftp/user", $cgi->param("backupFtpUser"));
    $config->set("backup/ftp/password", $cgi->param("backupFtpPassword"));
    $config->set("backup/ftp/usePassiveTransfers", $cgi->param("backupFtpPassive"));
    my $path = $cgi->param("backupFtpPath");
    $path = ($path eq "/") ? "." : $path;
    $config->set("backup/ftp/path", $path);
    $config->set("backup/ftp/hostname", $cgi->param("backupFtpHost"));
    $config->set("backup/ftp/rotations", $cgi->param("backupFtpRotations"));

    # demo
    $config->set("demo/hostname", $cgi->param("demoHost"));
    # have to enable demos
    if ($config->get("demo/enabled") == 0 && $cgi->param("enableDemo") == 1) {
        $file->makePath($config->getDomainRoot("/demo"));
        $file->copy($config->getRoot("/var/setupfiles/demo.modproxy"), $config->getRoot("/etc/demo.modproxy"), 
            { force => 1, templateVars=>{ sitename=>$config->get("demo/hostname") } });
        $file->copy($config->getRoot("/var/setupfiles/demo.modperl"), $config->getRoot("/etc/demo.modperl"), 
            { force => 1, templateVars=>{ sitename=>$config->get("demo/hostname") } });
        $status .= "Demo settings changed. You must restart modproxy and modperl for these changes to take effect.<br />";
    }
    # have to disable demos
    elsif ($config->get("demo/enabled") == 1 && $cgi->param("enableDemo") == 0) {
        $file->delete($config->getRoot("/etc/demo.modproxy"));
        $file->delete($config->getRoot("/etc/demo.modperl"));
        $status .= "Demo settings changed. You must restart modproxy and modperl for these changes to take effect.<br />";
    }
    $config->set("demo/enabled", $cgi->param("enableDemo"));
    $config->set("demo/duration", $cgi->param("demoDuration"));

    # apache
    $config->set("apache/defaultHostname", $cgi->param("apacheDefaultHostname"));
    $config->set("apache/maxMemory", $cgi->param("apacheMaxMemory"));
    $config->set("apache/connectionTimeout", $cgi->param("apacheConnectionTimeout"));

    $status .= "Settings Saved.<br />";
    return www_editSettings($state, $status);
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
    my $file = WRE::File->new(wreConfig=>$state->{config});
    my $template;
    eval { $template = $file->slurp($state->{config}->getRoot("/var/".$filename)) };
    if ($@) {
        carp "Couldn't open template file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe($template);
    $content .= '
        <form action="/editTemplateSave" method="post">
        <input type="submit" class="saveButton" value="Save" /> 
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="template">'.$$template.'</textarea><br />
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
    my $file = WRE::File->new(wreConfig=>$state->{config});
    my $status = $filename." saved.";
    eval { $file->spit($state->{config}->getRoot("/var/".$filename), $state->{cgi}->param("template")) };
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
    my $file = WRE::File->new(wreConfig=>$state->{config});
    my $contents;
    eval { $contents = $file->slurp($state->{config}->getWebguiRoot("/etc/".$filename)) };
    if ($@) {
        carp "Couldn't open template file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe($contents);
    $content .= '
        <p>Making a modification of these files requires a restart of modperl and modproxy afterwards, and sometimes also a restart
        of Spectre after that.</p>
        <form action="/editSiteSave" method="post">
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="webgui">'.$$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" />  <br /><br />
    ';
    $$contents = '';
    eval { $contents = $file->slurp($state->{config}->getRoot("/etc/".$sitename.".modproxy")) };
    if ($@) {
        carp "Couldn't open $sitename.modproxy file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe($contents);
    $content .= '
        <div><b>'.$sitename.'.modproxy</b></div>
        <textarea name="modproxy">'.$$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
    ';
    $$contents = '';
    eval { $contents = $file->slurp($state->{config}->getRoot("/etc/".$sitename.".modperl")) };
    if ($@) {
        carp "Couldn't open $sitename.modperl file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe($contents);
    $content .= '
        <div><b>'.$sitename.'.modperl</b></div>
        <textarea name="modperl">'.$$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
    ';
    $$contents = '';
    eval { $contents = $file->slurp($state->{config}->getRoot("/etc/awstats.".$sitename.".conf")) };
    if ($@) {
        carp "Couldn't open awstats.$sitename.conf file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe($contents);
    $content .= '
        <div><b>awstats.'.$sitename.'.conf</b></div>
        <textarea name="awstats">'.$$contents.'</textarea><br />
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
    my $file = WRE::File->new(wreConfig=>$state->{config});
    my $status = $sitename." saved.";
    eval { $file->spit($state->{config}->getWebguiRoot("/etc/".$filename), $state->{cgi}->param("webgui")) };
    if ($@) {
        $status = "Couldn't save $filename. $@";
        carp $status;
    }
    eval { $file->spit($state->{config}->getRoot("/etc/".$sitename.".modproxy"), $state->{cgi}->param("modproxy")) };
    if ($@) {
        $status = "Couldn't save $sitename.modproxy. $@";
        carp $status;
    }
    eval { $file->spit($state->{config}->getRoot("/etc/".$sitename.".modperl"), $state->{cgi}->param("modperl")) };
    if ($@) {
        $status = "Couldn't save $sitename.modperl. $@";
        carp $status;
    }
    eval { $file->spit($state->{config}->getRoot("/etc/awstats.".$sitename.".conf"), $state->{cgi}->param("awstats")) };
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
    my $host = WRE::Host->new(wreConfig => $state->{config});
    unless ($host->isPrivilegedUser) {
        $content .= q|<p class="status"><b>WARNING:</b> Because you are not an administrator on this machine, you
            will not be able to start or stop services on ports 1-1024.</p>|;
    }
    $content .= '<table class="items">
    <tr>
        <td>MySQL</td>
        <td>';
    my $mysql = WRE::Mysql->new(wreConfig=>$state->{config});
    if (eval{$mysql->ping}) {
        $content .= '
             <form action="/stopMysql" method="post">
                <input type="submit" class="deleteButton" value="Stop" onclick="this.value=\'Stopping...\'" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startMysql" method="post">
                <input type="submit" class="saveButton" value="Start" onclick="this.value=\'Starting...\'" />
             </form>';
    }
    $content .= '
             <form action="/restartMysql" method="post">
                <input type="submit" value="Restart" onclick="this.value=\'Restarting...\'" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Apache Modperl</td>
        <td>';
    my $modperl = WRE::Modperl->new(wreConfig=>$state->{config});
    if (eval{$modperl->ping}) {
        $content .= '
             <form action="/stopModperl" method="post">
                <input type="submit" class="deleteButton" value="Stop" onclick="this.value=\'Stopping...\'" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startModperl" method="post">
                <input type="submit" class="saveButton" value="Start" onclick="this.value=\'Starting...\'" />
             </form>';
    }
    $content .= '
             <form action="/restartModperl" method="post">
                <input type="submit" value="Restart" onclick="this.value=\'Restarting...\'" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Apache Modproxy</td>
        <td>';
    my $modproxy = WRE::Modproxy->new(wreConfig=>$state->{config});
    if (eval{$modproxy->ping}) {
        $content .= '
             <form action="/stopModproxy" method="post">
                <input type="submit" class="deleteButton" value="Stop" onclick="this.value=\'Stopping...\'" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startModproxy" method="post">
                <input type="submit" class="saveButton" value="Start" onclick="this.value=\'Starting...\'" /> (Requires Modperl in order to start.)
             </form>';
    }
    $content .= '
             <form action="/restartModproxy" method="post">
                <input type="submit" value="Restart" onclick="this.value=\'Restarting...\'" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Spectre</td>
        <td>';
    my $spectre = WRE::Spectre->new(wreConfig=>$state->{config});
    if (eval{$spectre->ping}) {
            $content .= ' <form action="/stopSpectre" method="post">
                <input type="submit" class="deleteButton" value="Stop" onclick="this.value=\'Stopping...\'" />
             </form>';
    } 
    else {
             $content .= '<form action="/startSpectre" method="post">
                <input type="submit" class="saveButton" value="Start" onclick="this.value=\'Starting...\'" />
             </form>';
    }
    $content .= '
             <form action="/restartSpectre" method="post">
                <input type="submit" value="Restart" onclick="this.value=\'Restarting...\'" />
             </form>
         </td>
    </tr>
    <tr>
        <td>WRE Console</td>
        <td><form action="/stopConsole" method="post">
              <input type="submit" class="deleteButton" value="Stop" onclick="this.value=\'Stopping...\'" />
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
    if (-e $folder) {
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
                    <input type="submit" class="deleteButton" value="Delete" />
                 </form>
                </td></tr>|;
        }  
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
    my $service = WRE::Modperl->new(wreConfig=>$state->{config});
    my $status = "Modperl restarted.";
    unless ($service->restart) {
        $status = "Modperl did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new(wreConfig=>$state->{config});
    my $status = "Modproxy restarted.";
    unless ($service->restart) {
        $status = "Modproxy did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartMysql {
    my $state = shift;
    my $service = WRE::Mysql->new(wreConfig=>$state->{config});
    my $status = "MySQL restarted.";
    unless ($service->restart) {
        $status = "MySQL did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new(wreConfig=>$state->{config});
    my $status = "Spectre restarted.";
    unless ($service->restart) {
        $status = "Spectre did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_setup {
    my $state = shift;
    my $out = qq| <div id="tabsWrapper"> <div id="logo">WRE Console</div> <div id="navUnderline"></div> </div> |;
    my $config = $state->{config};
    my $host = WRE::Host->new(wreConfig=>$config);
    my $cgi = $state->{cgi};
    my $file = WRE::File->new(wreConfig=>$config);

    # copy css into place
    $file->copy($config->getRoot("/var/setupfiles/wreconsole.css"),
        $config->getRoot("/var/wreconsole.css"));

    # deal with data form posted
    my $collectedJson = $cgi->param("collected");
    my $collected = JSON::from_json($collectedJson);
    foreach my $key ($cgi->param) {
        next if $key eq "collected" || $key eq "step";
        $collected->{$key} = $cgi->param($key);
    }
    $collectedJson = JSON::to_json($collected);
    makeHtmlFormSafe(\$collectedJson);

    # apache stuff
    if ($cgi->param("step") eq "apache") {
        if ($host->getOsName ne "windows" && !(getpwnam $collected->{wreUser})) {
            $out .= qq|<p class="status">There is no user $collected->{wreUser} on this system, please create it or go
                back and change the user you'd like to run the WRE under.</p>|;
        }
        my $apache = $config->get("apache");
        $out .= '<h1>Apache</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="mysql">
            <input type="hidden" name="collected" value="'.$collectedJson.'" />
            <p>
            mod_proxy Port <br />
            <input type="text" name="modproxyPort" value="'.($collected->{modproxyPort} || $apache->{modproxyPort}).'" />
            </p>
            <p>
            mod_perl Port <br />
            <input type="text" name="modperlPort" value="'.($collected->{modperlPort} || $apache->{modperlPort}).'" />
            </p>
            <input type="button" class="deleteButton" value="&laquo; Previous" onclick="this.form.step.value=\'\';this.form.submit()" />
            <input type="submit" class="saveButton" value="Next &raquo;" />
            </form>
            ';
    }

    # mysql stuff
    elsif ($cgi->param("step") eq "mysql") {
        if (-f "/etc/my.cnf") {
            $out .= q|<p class="status">There is a file at /etc/my.cnf that you must move or it will interfere with the WRE.</p>|;
        }
        if (-f "/my.ini") {
            $out .= q|<p class="status">There is a file at /my.ini that you must move or it will interfere with the WRE.</p>|;
        }
        my $mysql = $config->get("mysql");
        $out .= '<h1>MySQL</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="webgui">
            <input type="hidden" name="collected" value="'.$collectedJson.'" />
            <p>
            Host <br />
            <input type="text" name="mysqlHost" value="'.($collected->{mysqlHost} || $mysql->{hostname}).'" />
            </p>
            <p>
            Port <br />
            <input type="text" name="mysqlPort" value="'.($collected->{mysqlPort} || $mysql->{port}).'" />
            </p>
            <p>
            Admin User <br />
            <input type="text" name="mysqlAdminUser" value="'.($collected->{mysqlAdminUser} || $mysql->{adminUser}).'" />
            </p>
            <p>
            Admin Password <br />
            <input type="text" name="mysqlAdminPassword" value="'.($collected->{mysqlAdminPassword} || "123qwe").'" />
            </p>
            <input type="button" class="deleteButton" value="&laquo; Previous"
            onclick="this.form.step.value=\'apache\';this.form.submit();" />
            <input type="submit" class="saveButton" value="Next &raquo;" />
            </form>
            ';
    }

    # webgui stuff
    elsif ($cgi->param("step") eq "webgui") {
        $out .= '<h1>WebGUI</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="finish">
            <input type="hidden" name="collected" value="'.$collectedJson.'" />
            <p>
            What are the subnets WebGUI can expect Spectre to connect from? <br />
            <input type="text" name="spectreSubnets" value="'.($collected->{spectreSubnets} || eval{$host->getSubnet}).'" />
            <div class="subtext">We have guessed for you, so you can accept that if you do not know what to put
                here. If there are multiple IP addresses assigned to this machine, then do a comma separated list
                like: 10.0.0.1/32,10.11.0.1/32,192.168.1.44/32
            </p>
            <input type="button" class="deleteButton" value="&laquo; Previous"
            onclick="this.form.step.value=\'mysql\';this.form.submit();" />
            <input type="submit" class="saveButton" value="Next &raquo;" />
            </form>
            ';
    }

    # ready to install 
    elsif ($cgi->param("step") eq "finish") {
        $out .= '<h1>Ready To Install</h1>
            <p>The WRE is now ready to configure itself and install WebGUI.</p>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="install">
            <input type="hidden" name="manualWebguiInstall" value="0">
            <input type="hidden" name="collected" value="'.$collectedJson.'" />
            <p style="width: 60%;">
                If you would like to modify settings before the installation press the button below.<br />
                <input type="button" class="deleteButton" value="&laquo; Previous" class="deleteButton"
                    onclick="this.form.step.value=\'webgui\';this.form.submit();" />
            </p>
            <p style="width: 60%;">
                If you would like the WRE to automatically download and install WebGUI, then press the button below.<br />
                <input type="submit" class="saveButton" value="Automated Install &raquo;" />
            </p>
            <p style="width: 60%;">
                If you would like to install WebGUI manually yourself, then do so now, and press the button below
                when finished.<br />
                <input type="button" value="Manual Install &raquo;" class="saveButton"
                    onclick="this.form.manualWebguiInstall.value=\'1\';this.form.submit();" />
            </p>
            <p style="width: 60%;">
            </form>
            ';
    }

    # ready to install 
    elsif ($cgi->param("step") eq "install") {
        my $crlf = "\015\012";
        my $socket = $state->{connection};
        
        # disable buffer caching
        select $socket;
        $| = 1; 

        # header
        $socket->send_basic_header; 
        print $socket "Content-Type: text/html$crlf";
        print $socket $crlf;
        print $socket "<h1>Configuring Your WRE Server</h1>$crlf";
        $file->makePath($config->getRoot("/var/logs"));

        # config file
        print $socket "<p>Updating WRE config.</p><blockquote>$crlf";
        $config->set("user", $collected->{wreUser});
        $config->set("tar", which("tar"));
        $config->set("gzip", which("gzip"));
        $config->set("gunzip", which("gunzip"));
        $config->set("ipcs", which("ipcs"));
        $config->set("grep", which("grep"));
        my $mysql                   = $config->get("mysql");
        $mysql->{adminUser}         = $collected->{mysqlAdminUser};
        $mysql->{hostname}          = $collected->{mysqlHost};
        $mysql->{port}              = $collected->{mysqlPort};
        $config->set("mysql", $mysql);
        my $backup                  = $config->get("backup");
        my $mysqlBackupPassword     = random_string("cCncCncCncCn");
        $backup->{mysql}{password}  = $mysqlBackupPassword;
        $config->set("backup", $backup);
        my $apache                  = $config->get("apache");
        $apache->{modperlPort}      = $collected->{modperlPort};
        $apache->{modproxyPort}     = $collected->{modproxyPort};
        $config->set("apache", $apache);
        my $webgui                  = $config->get("webgui");
        my $spectreSubnetsString    = $collected->{spectreSubnets};
        $spectreSubnetsString =~ s/\s+//g;
        my @spectreSubnets = split(",", $spectreSubnetsString);
        push(@spectreSubnets, "127.0.0.1/32");
        $webgui->{configOverrides}{spectreSubnets} = \@spectreSubnets;
        $config->set("webgui", $webgui);
        print $socket "</blockquote>$crlf";

        # mysql
        print $socket "<p>Configuring MySQL.</p><blockquote>$crlf";
        if ($collected->{mysqlHost} eq "localhost" || $collected->{mysqlHost} eq "127.0.0.1") {
            my $mysql = WRE::Mysql->new(wreConfig=>$config);
            print $socket "<p>Creating default databases</p>";
            $file->makePath($config->getRoot("/var/mysqldata"));
            chdir($config->getRoot("/prereqs"));
            if ($host->getOsName eq "windows") {
                $file->copy($config->getRoot("/var/setupfiles/my.cnf"),
                    $config->getRoot("/etc/my.ini"),
                    { force => 1, templateVars=>{osName=>$host->getOsName} });
                $file->copy($config->getRoot("/prereqs/data/"),
                    $config->getRoot("/var/mysqldata/"),
                    { force => 1, recursive => 1 });
                system($config->getRoot("/sbin/services/windows/mysql-install.bat"));
            }
            else {
                $file->copy($config->getRoot("/var/setupfiles/my.cnf"),
                    $config->getRoot("/etc/my.cnf"),
                    { force => 1, processTemplate=>1 });
                system(file("bin/mysql_install_db")->stringify." --user=".$collected->{wreUser}." --port=" . $collected->{mysqlPort});
            }
            print $socket "<p>Starting MySQL</p>";
            $mysql->start;
            print $socket "<p>Connecting</p>";
            my $db = eval{ $mysql->getDatabaseHandle(username=>"root", password=>undef)};
            if ($@) {
                print $socket "<p>Couldn't connect to MySQL to configure it.</p>".$@;
            }
            else {
                print $socket "<p>Setting Privileges</p>";
                $db->do("use mysql");
                $db->do("delete from user where user=''");
                $db->do("delete from user where user='root'");
                $db->do("grant all privileges on *.* to ".$collected->{mysqlAdminUser}."\@'localhost' identified by '".$collected->{mysqlAdminPassword}."' with grant option");
                $db->do("grant all privileges on test.* to test\@'localhost' identified by 'test'");
                $db->do("grant select, lock tables, show databases on *.* to backup\@'localhost' identified by '".$mysqlBackupPassword."'");
                $db->do("flush privileges");
                print $socket "<p>Disconnecting</p>";
                $db->disconnect;
             }
        }
        else {
            $config->set("wreMonitor/items/mysql", 0);
            print $socket "<p>Connecting</p>";
            my $db = eval { $mysql->getDatabaseHandle(password=>$collected->{mysqlAdminPassword}, username=>$collected->{mysqlAdminUser})};
            if ($@) {
                print $socket "<p>Couldn't connect to remote MySQL server to configure it.</p>".$@;
            }
            else {
                print $socket "<p>Setting Privileges</p>";
                $db->do("grant all privileges on test.* to test\@'%' identified by 'test'");
                $db->do("grant select, lock tables, show on *.* to backup\@'%' identified by '".$mysqlBackupPassword."'");
                $db->do("flush privileges");
                print $socket "<p>Disconnecting</p>";
                $db->disconnect;
            }            
        }
        print $socket "</blockquote>$crlf";
        
        # apache
        print $socket "<p>Configuring Apache.</p><blockquote>$crlf";
        my %modperlVars = (
            StartServers        => 5,
            MinSpareServers     => 5,
            MaxSpareServers     => 10,
            MaxClients          => 20, 
            MaxRequestsPerChild => 1000,
            ServerTokens        => "Minor",
            );
        if ($collected->{devOnly}) {
            %modperlVars = (
                StartServers            => 2,
                MinSpareServers         => 2,
                MaxSpareServers         => 5,
                MaxClients              => 5, 
                MaxRequestsPerChild     => 100,
                ServerTokens            => "Full",
                );
        }
        $modperlVars{osName} = $host->getOsName;
        $modperlVars{devOnly} = $collected->{devOnly};
        $file->copy($config->getRoot("/var/setupfiles/modperl.conf"),
            $config->getRoot("/etc/modperl.conf"),
            { force => 1, templateVars=>\%modperlVars });
        $file->copy($config->getRoot("/var/setupfiles/modproxy.conf"),
            $config->getRoot("/etc/modproxy.conf"),
            { force => 1, templateVars=>{osName=>$host->getOsName} });
        $file->copy($config->getRoot("/var/setupfiles/mime.types"),
            $config->getRoot("/etc/mime.types"),
            { force => 1 });
        $file->copy($config->getRoot("/var/setupfiles/modperl.pl"),
            $config->getRoot("/etc/modperl.pl"),
            { force => 1 });
        $file->copy($config->getRoot("/var/setupfiles/modperl.template"),
            $config->getRoot("/var/modperl.template"),
            { force => 1 });
        $file->copy($config->getRoot("/var/setupfiles/modproxy.template"),
            $config->getRoot("/var/modproxy.template"),
            { force => 1 });
        $file->copy($config->getRoot("/var/setupfiles/awstats.template"),
            $config->getRoot("/var/awstats.template"),
            { force => 1 });
        print $socket "</blockquote>$crlf";

        # configuring webgui
        print $socket "<p>Configuring WebGUI.</p><blockquote>$crlf";
        unless ($collected->{manualWebguiInstall}) {
            my $update = WRE::WebguiUpdate->new(wreConfig=>$config);

            print $socket "<p>Determining lastest version of WebGUI.</p>$crlf";
            my $version = $update->getLatestVersionNumber;

            print $socket "<p>Locating a mirror.</p>$crlf";
            my $mirrors = $update->getMirrors($version);

            print $socket "<p>Downloading WebGUI. Please be patient, this can take a while.</p>$crlf";
            my $download = $update->downloadFile($mirrors->{plainblack}{url});

            print $socket "<p>Extracting WebGUI. Please be patient, this can take a while.</p>$crlf";
            eval { $update->extractArchive($download) };
            if ($@ && $host->getOsName ne "windows") {
                print $socket "<p>Had some errors extracting WebGUI. $@</p>$crlf";
            }
            elsif ($@ && $host->getOsName eq "windows") {
                print STDERR "\nNOTICE:\nYou can safely ignore all the tar extraction errors above. They\nare do to the differences between *nix and Windows file systems.\n";
            }
        }
        eval {
            open my $in, '<', $config->getWebguiRoot("/etc/log.conf.original")
                or die "Unable to open '" . $config->getWebguiRoot("/etc/log.conf.original") . "': $!\n";
            open my $out, '>', $config->getWebguiRoot("/etc/log.conf")
                or die "Unable to open '" . $config->getWebguiRoot("/etc/log.conf") . "': $!\n";
            while (my $line = <$in>) {
                $line =~ s{/var/log/webgui\.log}{ $config->getRoot("/var/logs/webgui.log") }ge;
                print {$out} $line;
            }
            close $out;
            close $in;
        };
        print $socket "Error: $@<br />"
            if $@;
        
        $file->copy($config->getWebguiRoot("/etc/spectre.conf.original"), $config->getWebguiRoot("/etc/spectre.conf"),
            { force => 1 });
        $file->changeOwner($config->getWebguiRoot("/etc"));
        print $socket "</blockquote>$crlf";

        # dev server stuff
        if ($collected->{devOnly}) {
            print $socket "<p>Configuring Developer Site</p><blockquote>$crlf";
            my $site = WRE::Site->new(
                wreConfig       => $config,
                sitename        => "dev.localhost.localdomain",
                adminPassword   => $collected->{mysqlAdminPassword},
                );
            if (eval {$site->checkCreationSanity}) {
                $site->create;
                print $socket "<p>Please add <b>dev.localhost.localdomain</b> to your /etc/hosts file.</p>$crlf";
            }
            else {
                print $socket "<p>Site couldn't be created because $@.</p>$crlf";
            }
            print $socket "</blockquote>$crlf";
        }

        # windows service stuff
        if ($host->getOsName eq "windows") {
            print $socket "<p>Installing Windows services.</p>$crlf";
            system($config->getRoot("/sbin/services/windows/modperl-install.bat"));
            system($config->getRoot("/sbin/services/windows/modproxy-install.bat"));
            system($config->getRoot("/sbin/services/windows/spectre-install.bat"));
        }

        # status
        print $socket "<h1>Configuration Complete</h1>
            <p>Please add the following maintenance scripts to your crontab:</p>
            <pre>    0 0 * * * /data/wre/sbin/logrotate.pl
    */3 * * * * /data/wre/sbin/wremonitor.pl
    0 2 * * * /data/wre/sbin/backup.pl</pre>
            <p><a href=\"/\">Click here to manage your WRE server.</a></p>$crlf";

        # done
        $socket->force_last_request;
        return;
    }

    # WRE
    else {
        $out .= '<h1>WRE</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="apache">
            <input type="hidden" name="collected" value="'.$collectedJson.'" />
            <p>
            WRE Operating System User<br />
            <input type="text" name="wreUser" value="'.($collected->{wreUser} || $config->get("user")).'" />
            </p>
            <p>
            Do you want to configure this WRE as a development only environment?<br />
            <input type="radio" name="devOnly" value="1" />Yes &nbsp;
            <input type="radio" name="devOnly" value="0" checked="1" />No
            </p>
            <input type="submit" class="saveButton" value="Next &raquo;" />
            </form> ';
    }
    sendResponse($state, $out);
}

#-------------------------------------------------------------------
sub www_startModperl {
    my $state = shift;
    my $service = WRE::Modperl->new(wreConfig=>$state->{config});
    my $status = "Modperl started.";
    unless (eval {$service->start} ) {
        $status = "Modperl did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new(wreConfig=>$state->{config});
    my $status = "Modproxy started.";
    unless (eval {$service->start}) {
        $status = "Modproxy did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startMysql {
    my $state = shift;
    my $service = WRE::Mysql->new(wreConfig=>$state->{config});
    my $status = "MySQL started.";
    unless (eval {$service->start}) {
        $status = "MySQL did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new(wreConfig=>$state->{config});
    my $status = "Spectre started.";
    unless (eval {$service->start}) {
        $status = "Spectre did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopConsole {
    my $state = shift;
    my $crlf = "\015\012";
    my $socket = $state->{connection};
        
    # disable buffer caching
    select $socket;
    $| = 1; 

    # header
    $socket->send_basic_header; 
    print $socket "Content-Type: text/html$crlf";
    print $socket $crlf;
    print $socket <<STOP;
    <html><head>
    <style type="text/css">
    body { background-color: #5566cc; color: #ffffff; font-family: sans-serif; }
    </style>
    <title>WRE Console has shutdown.</title>
    <body>
    <h1>WRE Console has shutdown.</h1>
    </body>
    </html>
    $crlf
STOP
    exit;
}

#-------------------------------------------------------------------
sub www_stopModperl {
    my $state = shift;
    my $service = WRE::Modperl->new(wreConfig=>$state->{config});
    my $status = "Modperl stopped.";
    unless ($service->stop) {
        $status = "Modperl did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new(wreConfig=>$state->{config});
    my $status = "Modproxy stopped.";
    unless ($service->stop) {
        $status = "Modproxy did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopMysql {
    my $state = shift;
    my $service = WRE::Mysql->new(wreConfig=>$state->{config});
    my $status = "MySQL stopped.";
    unless ($service->stop) {
        $status = "MySQL did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new(wreConfig=>$state->{config});
    my $status = "Spectre stopped.";
    unless ($service->stop) {
        $status = "Spectre did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}


