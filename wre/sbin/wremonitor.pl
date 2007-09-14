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

$| = 1;

use strict;
use lib '/data/wre/lib';
use Net::SMTP;
use WRE::Config;
use WRE::File;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Spectre;

my $config = WRE::Config->new;

if ($config->get("wreMonitor/items/mysql") && !$config->get("wreMonitor/mysqlAdministrativelyDown")) {
    my $mysql = WRE::Mysql->new(wreConfig=>$config);
    monitor($mysql);
}

if ($config->get("wreMonitor/items/modperl") && !$config->get("wreMonitor/modperlAdministrativelyDown")) {
    my $modperl = WRE::Modperl->new(wreConfig=>$config);
    monitor($modperl);
    if ($config->get("wreMonitor/items/runaway")) {
        my $killed = $modperl->killRunaways;
        logEntry("Killed $killed ".$modperl->getName." processes that were using too much memory.");
    }
}

if ($config->get("wreMonitor/items/modproxy") && !$config->get("wreMonitor/modproxyAdministrativelyDown")) {
    my $modproxy = WRE::Modproxy->new(wreConfig=>$config);
    monitor($modproxy);
}

if ($config->get("wreMonitor/items/spectre") && !$config->get("wreMonitor/spectreAdministrativelyDown")) {
    my $spectre = WRE::Spectre->new(wreConfig=>$config);
    monitor($spectre);
}
        
exit;

#-------------------------------------------------------------------
sub monitor {
    my $service = shift;
    if (eval{$service->ping} && !$@) {
        logEntry("All is well with ".$service->getName);
    }
    else {
        logEntry($service->getName." reported down. Starting critical monitor.");

        # wait an see if we had a false positive
        sleep 15;
        if (eval{$service->ping} && !$@) {
            logEntry($service->getName." has recovered.");
        }
        else {
            if (eval {$service->restart} && !$@) {
                my $message = $service->getName." on ".$config->get("apache/defaultHostname")." was down and has restarted.";
                logEntry($message);
                sendEmail($message);
            }
            else {
                my $message = $service->getName." on ".$config->get("apache/defaultHostname")." is down and could not be restarted.";
                logEntry($message." ".$@);
                sendEmail($message);
            }
        } 
    }
}

#-------------------------------------------------------------------
sub logEntry {
	my $message = shift;
    $message = localtime()." - ".$message."\n";
    WRE::File->new(wreConfig=>$config)->spit($config->getRoot("/var/logs/wremonitor.log"), \$message, { append => 1});
}

#-------------------------------------------------------------------
sub sendEmail {
	my $message = shift;
    my $smtp = Net::SMTP->new($config->get("smtp/hostname"));
    if (defined $smtp) {
        foreach my $notify (@{$config->get("wreMonitor/notify")}) {
            $smtp->mail($notify);
            $smtp->to($notify);
            $smtp->data();
            $smtp->datasend("To: ".$notify."\n");
            $smtp->datasend("From: WRE Monitor <".$notify.">\n");
            $smtp->datasend("Subject: ".$config->get("apache/defaultHostname")." WRE Service DOWN!\n");
            $smtp->datasend("\n");
            $smtp->datasend($message);
		    $smtp->datasend("\n");
		    $smtp->datasend($config->get("apache/defaultHostname"));
		    $smtp->datasend("\n");
            $smtp->dataend();
        }
        $smtp->quit;
    } 
    else {
        logEntry("Cannot connect to mail server.");
    }
}


