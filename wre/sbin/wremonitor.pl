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

use List::Util qw/first sum max/;

my $config = WRE::Config->new;

if ($config->get("wreMonitor/items/mysql") && !$config->get("wreMonitor/mysqlAdministrativelyDown")) {
    my $mysql = WRE::Mysql->new(wreConfig=>$config);
    monitor($mysql);
    monitorMysql($mysql);
}

if ($config->get("wreMonitor/items/modperl") && !$config->get("wreMonitor/modperlAdministrativelyDown")) {
    my $modperl = WRE::Modperl->new(wreConfig=>$config);
    monitor($modperl);
    monitorModperl($modperl);
    if ($config->get("wreMonitor/items/runaway")) {
        my $killed = $modperl->killRunaways;
        logEntry("Killed $killed ".$modperl->getName." processes that were using too much memory.");
    }
}

if ($config->get("wreMonitor/items/modproxy") && !$config->get("wreMonitor/modproxyAdministrativelyDown")) {
    my $modproxy = WRE::Modproxy->new(wreConfig=>$config);
    monitor($modproxy);
    monitorModproxy($modproxy);
}

if ($config->get("wreMonitor/items/spectre") && !$config->get("wreMonitor/spectreAdministrativelyDown")) {
    my $spectre = WRE::Spectre->new(wreConfig=>$config);
    monitor($spectre);
    monitorSpectre($spectre);
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

        # wait and see if we had a false positive
        sleep 15;
        if (eval{$service->ping} && !$@) {
            logEntry($service->getName." has recovered.");
        }
        else {
            my $subject = "Subject: ".$config->get("apache/defaultHostname")." WRE Service DOWN!\n";
            my $message;
            if (eval {$service->restart} && !$@) {
                $message = $service->getName." on ".$config->get("apache/defaultHostname")." was down and has restarted.";
                logEntry($message);
            }
            else {
                $message = $service->getName." on ".$config->get("apache/defaultHostname")." is down and could not be restarted.";
                logEntry($message." ".$@);
            }
            sendEmail($subject, $message);
        } 
    }
}

#-------------------------------------------------------------------
sub monitorMysql {
    my $mysql = shift;
}

#-------------------------------------------------------------------
sub monitorModperl {
    my $modPerl = shift;
}

#-------------------------------------------------------------------
sub monitorModproxy {
    my $modProxy = shift;
}

#-------------------------------------------------------------------
sub monitorSpectre {
    my $spectre = shift;

    # Convenience variables for fields in the config files; everything but the email
    # address has a default.
    my ($maxTotalWorkflows, $maxWorkflowsPerSite, $maxPriority, $personToEmail);


    $maxTotalWorkflows      = $config->get('wremonitor/items/maxTotalWorkflows')                || 1000;
    $maxWorkflowsPerSite    = $config->get('wreMonitor/items/spectre/maxWorkflowsPerSite')      || 100;
    $maxPriority            = $config->get('wreMonitor/items/spectre/maxPriority')              || 100;

    # mapping of exceptional events to email bodies and subjects.
    my $emailParts = {
        bodies => {
            'workflowsPerSite' => <<EOTEXT,
    This is the $0 program, running as part of WebGUI. You are receiving this
    email because one of your sites has exceeded the maximum number of available
    workflows per site.
EOTEXT
            'totalWorkflows' => <<EOTEXT,
    This is the $0 program, running as part of WebGUI. You are receiving this
    email because the total number of workflows running for all of your sites
    has exceeded the maximum number of total available workflows.
EOTEXT
            'priority' => <<EOTEXT,
    This is the $0 program, running as part of WebGUI. You are receiving this
    email because the priority of one of your workflow activities has exceeded
    the maximum priority threshold.
EOTEXT
        },
        subjects => {
            'workflowsPerSite'  => 'Max workflows per site exceeded',
            'totalWorkflows'    => 'Max total workflows exceeded',
            'priority'          => 'Workflow priority threshold exceeded',
        }
    };

    # Get the data from Spectre.
    my $report              = $spectre->getStatusReport();

    # Process the report.
    my $workflowsPerSite    = $spectre->getWorkflowsPerSite($report);
    my $highestPriority     = $spectre->getPriorities($report);

    # Run our checks on the processed data.
    # If any sites have more workflows than they're allowed to have, send email.
    if(first { $_ >= $maxWorkflowsPerSite } values %$workflowsPerSite ) {
        sendEmail($emailParts->{subjects}{workflowsPerSite}, $emailParts->{bodies}{workflowsPerSite});
    }

    # Else, if the total number of workflows across all sites is higher than the
    # relevant threshold, send mail.
    elsif(sum values %{$workflowsPerSite} >= $maxTotalWorkflows) {
        sendEmail($emailParts->{subjects}{totalWorkflows}, $emailParts->{bodies}{totalWorkflows});
    }

    # Else, if the highest workflow priority across all sites is higher than the
    # relevant threshold, send mail.
    elsif($highestPriority >= $maxPriority) {
        sendEmail($emailParts->{subjects}{priority}, $emailParts->{bodies}{priority});
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
    my $subject = shift;
	my $message = shift;
    my $smtp = Net::SMTP->new($config->get("smtp/hostname"));
    if (defined $smtp) {
        foreach my $notify (@{$config->get("wreMonitor/notify")}) {
            $smtp->mail($notify);
            $smtp->to($notify);
            $smtp->data();
            $smtp->datasend("To: ".$notify."\n");
            $smtp->datasend("From: WRE Monitor <".$notify.">\n");
            $smtp->datasend("Subject: $subject");
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


