package WRE::Site;

#-------------------------------------------------------------------
# WRE is Copyright 2005-2011 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Carp qw(croak);
use Class::InsideOut qw(new public private id);
use Config::JSON;
use JSON;
use String::Random qw(random_string);
use WRE::File;
use WRE::Mysql;


private adminPassword => my %adminPassword;
public  databaseName => my %databaseName;

#-------------------------------------------------------------------

=head2 sitename ( )

Returns the sitename for the site we're working with.

=cut

public sitename => my %sitename, { set_hook => sub { $_ = lc $_ } };

#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE cconfig.

=cut

public wreConfig => my %config;


#-------------------------------------------------------------------

=head2 create ( params)

Creates a site given the creation information.

=head3 params

A hash reference containing a list of creation parameters.

=head4 databaseUser

The username that WebGUI will use to connect to the database for this site. If left blank this is auto generated.

=head4 databasePassword

The password that WebGUI will use to connect to the database for this site. If left blank this is auto generated.

=head4 var0 - var9

A series of variables that will be added to the list of template variables used in site creation.

=cut

sub create {
    my $self = shift;
    my $params = shift || {};
    my $wreConfig = $self->wreConfig;
    my $file = WRE::File->new(wreConfig=>$wreConfig);
    my $refId = id $self;
    my $sitename = $self->sitename;
    if (!defined $self->databaseName || length($self->databaseName) == 0) {
        $databaseName{$refId} = $self->makeDatabaseName;
    }
    # manufacture stuff
    $params->{databaseName} = $self->databaseName;
    $params->{databaseUser} ||= random_string("ccccccccccccccc");
    $params->{databasePassword} ||= random_string("cCncCncCncCncccnnnCCnc");
    $params->{sitename} = $sitename;
    my $domain = $sitename;
    $domain =~ s/[^.]+\.//;
    $params->{domain} = $domain;

    # create webgui config
    $file->copy($wreConfig->getWebguiRoot("/etc/WebGUI.conf.original"),
        $wreConfig->getWebguiRoot("/etc/".$sitename.".conf"),
        { force => 1 });
    my $webguiConfig = Config::JSON->new($wreConfig->getWebguiRoot("/etc/".$sitename.".conf"));
    my $overridesAsTemplate =  JSON::encode_json($wreConfig->get("webgui/configOverrides"));
    my $overridesAsJson = $file->processTemplate(\$overridesAsTemplate, $params);
    # webgui wants the paths a certain way regardless of windows
    ${$overridesAsJson} =~ s{\\data}{/data}xsg;
    ${$overridesAsJson} =~ s{\\wre}{/wre}xsg;
    ${$overridesAsJson} =~ s{\\domains}{/domains}xsg;
    my $overridesAsHashRef = JSON::decode_json(${$overridesAsJson});
    foreach my $key (keys %{$overridesAsHashRef}) {
        $webguiConfig->set($key, $overridesAsHashRef->{$key});
    }
    
    # create database
    my $mysql = WRE::Mysql->new(wreConfig=>$wreConfig);
    my $db = $mysql->getDatabaseHandle(password=>$adminPassword{$refId});
    $db->do("grant all privileges on ".$params->{databaseName}.".* to '".$params->{databaseUser}
        ."'\@'%' identified by '".$params->{databasePassword}."'");
    $db->do("flush privileges");
    $db->do("create database ".$params->{databaseName});
    $db->disconnect;
    $mysql->load(
        database    => $params->{databaseName},
        path        => $wreConfig->getWebguiRoot("/docs/create.sql"),
        username    => $params->{databaseUser},
        password    => $params->{databasePassword},
        );

    # create webroot
	$file->makePath($wreConfig->getDomainRoot('/'.$sitename.'/awstats'));
	$file->makePath($wreConfig->getDomainRoot('/'.$sitename.'/logs'));
	$file->makePath($wreConfig->getDomainRoot('/'.$sitename.'/public'));
    my $uploads = $wreConfig->getDomainRoot('/'.$sitename.'/public/uploads/');
    my $baseUploads = $wreConfig->getWebguiRoot('/www/uploads/');
    $file->copy($wreConfig->getWebguiRoot('/www/uploads/'), 
        $wreConfig->getDomainRoot('/'.$sitename.'/public/uploads/'),
        { recursive => 1, force=>1 });

    # create awstats config
    $file->copy($wreConfig->getRoot("/var/awstats.template"),
        $wreConfig->getRoot("/etc/awstats.".$sitename.".conf"),
        { templateVars => $params, force => 1 });

    # create modperl config
    $file->copy($wreConfig->getRoot("/var/modperl.template"), 
        $wreConfig->getRoot("/etc/".$sitename.".modperl"),
        { templateVars => $params, force => 1 });

    # create nginx config
    $file->copy($wreConfig->getRoot("/var/nginx.template"), 
        $wreConfig->getRoot("/etc/".$sitename.".nginx"),
        { templateVars => $params, force => 1 });
}

#-------------------------------------------------------------------

=head2 checkCreationSanity ( )

Returns a 1 if all the tests pass, and a 0 if they don't. Carps the error messages on failure so they can be
displayed to a user.

=cut

sub checkCreationSanity {
    my $self = shift;
    my $wreConfig = $self->wreConfig;
    my $mysql = WRE::Mysql->new(wreConfig=>$wreConfig);
    my $sitename = $self->sitename;
    my $password = $adminPassword{id $self};

    # check that mysql is alive
    unless (eval {$mysql->ping}) {
        croak "MySQL appears to be down. ".$@;
        return 0;
    }

    # check that this user has admin rights
    unless (eval {$mysql->isAdmin(password=>$password)}) {
        croak "Invalid admin password. ". $@;
        return 0;
    }

    # check that the config file isn't already there
    if (-e $wreConfig->getWebguiRoot("/etc/".$sitename.".conf")) {
        croak "WebGUI config file for $sitename already exists.";
        return 0;
    }

    # check that the sitename does not contain spaces
    croak "The sitename ($sitename) must not contain spaces." if($sitename =~ /\s+/);

    # check for the existence of a database with this name
    my $db = $mysql->getDatabaseHandle(password=>$password);
    my $sth = $db->prepare("show databases like ?");
    my $databaseName = $self->databaseName || $self->makeDatabaseName;
    $sth->execute($databaseName);
    my ($databaseExists) = $sth->fetchrow_array;
    $sth->finish;
    if ($databaseExists) {
        croak "A database called $databaseName already exists.";
        $db->disconnect;
        return 0;
    }
    $db->disconnect;

    # all tests were successful
    return 1;
}

#-------------------------------------------------------------------

=head2 checkDeletionSanity ( )

Returns a 1 if all the tests pass, and a 0 if they don't. Carps the error messages on failure so they can be
displayed to a user.

=cut

sub checkDeletionSanity {
    my $self = shift;
    my $wreConfig = $self->wreConfig;
    my $mysql = WRE::Mysql->new(wreConfig=>$wreConfig);
    my $sitename = $self->sitename;
    my $filename = $sitename.".conf";

    # check that mysql is alive
    unless (eval {$mysql->ping}) {
        croak "MySQL appears to be down. ".$@;
        return 0;
    }

    # check that this user has admin rights
    unless (eval {$mysql->isAdmin(password=>$adminPassword{id $self})} ) {
        croak "Invalid admin password.";
        return 0;
    }

    # check that the config file isn't already there
    unless (-e $wreConfig->getWebguiRoot("/etc/".$filename)) {
        croak "WebGUI config file for $sitename doesn't exist.";
        return 0;
    }

    # check if they're trying to delete WebGUI system configs
    if ($filename eq "spectre.conf" || $filename eq "log.conf") {
        croak "Not a WebGUI site config.";
        return 0;
    }

    # all tests were successful
    return 1;
}


#-------------------------------------------------------------------

=head2 delete ( )

Delete's a site and everything related to it.

=cut

sub delete {
    my $self = shift;
    my $wreConfig = $self->wreConfig;
    my $file = WRE::File->new(wreConfig=>$wreConfig);
    my $refId = id $self;
    my $sitename = $self->sitename;

    # database
    my $webguiConfig = Config::JSON->new($wreConfig->getWebguiRoot("/etc/".$sitename.".conf"));
    my $databaseName = $webguiConfig->get("dsn");
    $databaseName =~ s/^DBI\:mysql\:(\w+).*$/$1/i; 
    my $databaseUser = $webguiConfig->get("dbuser");
    my $mysql = WRE::Mysql->new(wreConfig=>$wreConfig);
    my $db = $mysql->getDatabaseHandle(password=>$adminPassword{$refId});
    $db->do("drop database $databaseName");

    my $sth = $db->prepare("select Host from `mysql`.`db` where User=? and Db=?");
    $sth->execute($databaseUser, $databaseName);
    while (my $row = $sth->fetchrow_arrayref ){
        my $host = $row->[0];
        $db->do("revoke all privileges on ".$databaseName.".* from '".$databaseUser."'\@'" . $host . "'");
        $db->do("delete from mysql.user where user='".$databaseUser."'");
    }

    # web root
    $file->delete($wreConfig->getDomainRoot("/".$sitename));

    # awstats
    $file->delete($wreConfig->getRoot("/etc/awstats.".$sitename.".conf"));

    # modperl
    $file->delete($wreConfig->getRoot("/etc/".$sitename.".modperl"));

    # nginx
    $file->delete($wreConfig->getRoot("/etc/".$sitename.".nginx"));

    # webgui
    $file->delete($wreConfig->getWebguiRoot("/etc/".$sitename.".conf"));
}

#-------------------------------------------------------------------

=head2 makeDatabaseName ( )

Returns a database friendly name generated from the sitename.

=cut

sub makeDatabaseName {
    my $self = shift;
    my $databaseName = $self->sitename;
    $databaseName =~ s/\W/_/g;
    return $databaseName;
}


#-------------------------------------------------------------------

=head2 new ( wreConfig => $config, sitename => $sitename, adminPassword => $pass)

Constructor.

=head3 wreConfig

A reference to a WRE Configuration object.

=head3 sitename

The full name of a site, like "www.example.com".

=head3 adminPassword

The password for the WRE database "root" user.

=cut

# auto generated



1;
