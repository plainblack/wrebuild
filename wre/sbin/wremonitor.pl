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

if ($config->get("wreMonitor/items/mysql")) {
    my $mysql = WRE::Mysql->new(wreConfig=>$config);
    monitor($mysql);
}

if ($config->get("wreMonitor/items/modperl")) {
    my $modperl = WRE::Modperl->new(wreConfig=>$config);
    monitor($modperl);
    if ($config->get("wreMonitor/items/runaway")) {
        my $killed = $modperl->killRunaways;
        logEntry("Killed $killed ".$modperl->getName." processes that were using too much memory.");
    }
}

if ($config->get("wreMonitor/items/modproxy")) {
    my $modproxy = WRE::Modproxy->new(wreConfig=>$config);
    monitor($modproxy);
}

if ($config->get("wreMonitor/items/spectre")) {
    my $spectre = WRE::Spectre->new(wreConfig=>$config);
    monitor($spectre);
}
        
exit;

#-------------------------------------------------------------------
sub monitor {
    my $service = shift;
    if ($service->ping) {
        logEntry("All is well with ".$service->getName);
    }
    else {
        logEntry($service->getName." reported down. Starting critical monitor.");

        # wait an see if we had a false positive
        sleep 10;
        if ($service->ping) {
            logEntry($service->getName." has recovered.");
        }
        else {
            if ($service->restart) {
                sendEmail($service->getName." on ".$config->get("apache/defaultHostname")." was down and has restarted.");
            }
            else {
                sendEmail($service->getName." on ".$config->get("apache/defaultHostname")." is down and could not be restarted.");
            }
        } 
    }
}

#-------------------------------------------------------------------
sub logEntry {
	my $message = shift;
    $message = localtime()." - ".$message."\n";
    WRE::File->new(wreConfig=>$config)->spit($config->getRoot("/var/log/wremonitor.log"), \$message, { append => 1});
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
        logEntry("Error: Cannot connect to mail server.");
    }
}


