package WRE::WebguiDemo;

#-------------------------------------------------------------------
# WRE is Copyright 2005-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use lib ('/data/wre/lib','/data/WebGUI/lib');
use strict;
use Apache2::Const;
use DBI;
use String::Random qw(random_string);
use WebGUI;
use WebGUI::Config;
use WRE::Config;
use WRE::File;
use WRE::Mysql;

#-------------------------------------------------------------------
sub handler {   
    my $r = shift;
    my $config = WRE::Config->new("/data/wre/etc/wre.conf");
	$r->pnotes('wreConfig' => $config);
	my $id = $r->uri;
	$id =~ s/^\/(demo[0-9\_]+).*$/$1/;
	if (-e $config->getWebguiRoot("/etc/".$id.".conf")) {
		return WebGUI::handler($r,$id.".conf");
	} 
    elsif ($r->uri =~ /^\/extras/) {
		# just pass it on thru
	} 
    elsif ($r->uri eq "/create") {
        $r->set_handlers(PerlResponseHandler => \&createDemo);
        $r->set_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
	} 
    else {
        $r->set_handlers(PerlResponseHandler => \&promptDemo);
        $r->set_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
	}	
    return Apache2::Const::DECLINED;
}


#-------------------------------------------------------------------
sub promptDemo {
	my $r = shift;
	my $config = $r->pnotes('wreConfig');
	$r->content_type("text/html");
	$r->print(q|<html><head><title>WebGUI Demo</title></head><body>
        <div style="width: 300px; margin-top: 20%; text-align: left; margin-left: 35%; margin-bottom: 10px;
        background-color: #cccccc; border: 1px solid #800000; padding: 10px; color: #000080;">If you'd like your own
        personal demo of the <a style="color: #ff2200;" href="http://www.webgui.org/">WebGUI Content Engine&reg;</a> 
        click the button below. Your demo will last for |.$config->get("demo")->{duration}.q| day(s), then will be deleted.</div> 
        <div style="text-align: center; width: 300px; margin-left: 35%;"><form action="/create" method="post">
        <input onclick="this.value='Please wait while we create your demo!'" type="submit" 
        value="Create My Personal WebGUI Demo" /> </form></div> </body></html>|);
	return Apache2::Const::OK;
}

#-------------------------------------------------------------------
sub createDemo {
	my $r = shift;
	my $config = $r->pnotes('wreConfig');
	my $now = time();
    my $demo = $config->get("demo");
	srand;
	my $demoId = "demo".$now."_".int(rand(999));
    my $template = Template->new;
    my $params = {};
    my $file = WRE::File->new(wreConfig=>$config);

    # manufacture stuff
    $params->{databaseName} = $demoId;
    $params->{databaseUser} = random_string("ccccccccccccccc");
    $params->{databasePassword} = random_string("cCncCnCCncCncCnnnCcccnnCnc");
    $params->{databaseHost} = $config->get("mysql")->{hostname};
    $params->{databasePort} = $config->get("mysql")->{port};
    $params->{sitename} = $demo->{hostname};

    # create webgui config
    $file->copy($demo->{creation}{config}, $config->getWebguiRoot("/etc/".$demoId.".conf"), {force=>1});
    my $webguiConfig = Config::JSON->new($config->getWebguiRoot("/etc/".$demoId.".conf"));
    my $overridesAsTemplate = JSON::objToJson($config->get("webgui/configOverrides"));
    my $overridesAsJson = $file->processTemplate(\$overridesAsTemplate , $params);
    my $overridesAsHashRef = JSON::jsonToObj(${$overridesAsJson});
    foreach my $key (keys %{$overridesAsHashRef}) {
        $webguiConfig->set($key, $overridesAsHashRef->{$key});
    }
    $webguiConfig->set("uploadsPath",$config->getDomainRoot('/demo/'.$demoId.'/uploads'));
    $webguiConfig->set("uploadsURL", '/'.$demoId.'/uploads');
    $webguiConfig->set("demoCreated", time());
    $webguiConfig->set("gateway", "/".$demoId."/");

    # create database
    my $mysql = WRE::Mysql->new(wreConfig=>$config);
    my $db = $mysql->getDatabaseHandle(username=>$demo->{user}, password=>$demo->{password});
    $db->do("grant all privileges on ".$params->{databaseName}.".* to ".$params->{databaseUser}
        ."\@'%' identified by '".$params->{databasePassword}."'");
    $db->do("flush privileges");
    $db->do("create database ".$params->{databaseName});
    $db->disconnect;
    system $config->getRoot('/prereqs/bin/mysql -u'.$params->{databaseUser}.' -p'
        .$params->{databasePassword}.' --host='.$params->{databaseHost}.' --port='
        .$params->{databasePort}.' -e "source '.$demo->{creation}{database})
        .'" ' .$params->{databaseName};

    # create webroot
	$file->makePath($config->getDomainRoot('/demo/'.$demoId.'/uploads/'));
    $file->copy($demo->{creation}{uploads}.'/',
        $config->getDomainRoot('/demo/'.$demoId.'/uploads/'),
        { force=>1, recursive=>1}); 

    # send redirect
	$r->headers_out->set(Location => "/".$demoId."/");
    $r->status(301);
	return Apache2::Const::OK;
}


#-------------------------------------------------------------------
sub createDatabase {
	my $r = shift;
        my $demoId = shift;
	my $config = $r->pnotes('wreConfig');
	my $dsn = "DBI:mysql:test;host=".$config->get("mysqlhost");
	if ($config->get("db-port")) {
		$dsn .= ";port=".$config->get("db-port") ;
	}
        my $dbh = DBI->connect($dsn,$config->get("adminuser"),$config->get("adminpass"));
        $dbh->do("create database ".$demoId);
        $dbh->do("grant all privileges on ".$demoId.".* to demo\@localhost identified by 'demo'");
        $dbh->do("flush privileges");
        $dbh->disconnect;
	my $cmd = "/data/wre/prereqs/mysql/bin/mysql --host=".$config->get("mysqlhost");
	if ($config->get('db-port')) {
		$cmd .= ' --port='.$config->get('db-port');
	}
	$cmd .= " -udemo -pdemo ".$demoId." < ".$config->get("createScript");
	system($cmd);
}


1;
