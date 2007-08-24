package WRE::Mysql;

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
use base 'WRE::Service';
use Carp qw(croak);
use Class::InsideOut qw(new);
use DBI;
use Path::Class;

=head1 ISA

WRE::Service

=cut

{ # begin inside out object


#-------------------------------------------------------------------

=head2 dump ( database => $database, path => $path )

Dumps a database to a specified file path.

=head3 database

The name of the database you want to dump.

=head3 path

The path to the file where you want the dump to be created.

=cut

sub dump {
    my $self    = shift;
    my %options = @_;    
    my $config  = $self->wreConfig;
    my $path = file($options{path});
    my $command = $config->get("/prereqs/bin/mysqldump")
        ." --user=".$config->get("backup/mysql/user")
        ." --password=".$config->get("backup/mysql/password")
        ." --host=".$config->get("mysql/hostname")
        ." --port=".$config->get("mysql/port")
        ." --result-file=".$path->stringify
        ." --opt" # increased dump and load performance
        ." ".$options{database};
    system($command);
}


#-------------------------------------------------------------------

=head2 getDatabaseHandle ( password => $password, [ username=>$user, dsn=>$dsn ] )

Returns an administrator's database handle.

=head3 password

The password you want to connect with.

=head3 username

The username you want to connect with. This defaults to the "adminUser" specified in the config file, which is
usually "root".

=head3 dsn

A dsn to connect with. By default uses the DSN for the test database.

=cut

sub getDatabaseHandle {
    my $self = shift;
    my %options = @_;
    my $password = $options{password};
    my $mysql = $self->wreConfig->get("mysql");
    my $username = $options{username} || $mysql->{adminUser};
    my $dsn = $options{dsn} || 'DBI:mysql:'.$mysql->{test}->{database}.';host='.$mysql->{hostname}.';port='.$mysql->{port};
    my $db = undef;
    eval { 
        $db = DBI->connect($dsn, $username, $password, {RaiseError=>1});
    };
    if ($@) {
        croak "Couldn't connect to MySQL because ".$@;
    }
    return $db;
}

#-------------------------------------------------------------------

=head getName () 

Returns human readable name.

=cut

sub getName {
    return "MySQL";
}


#-------------------------------------------------------------------

=head2 isAdmin ( password => $password )

Checks to see if the specified password will work to log in as mysql admin.

=head3 password

The password to check.

=cut

sub isAdmin {
    my $self = shift;
    my $db = $self->getDatabaseHandle(@_);
    if (defined $db) {
        $db->disconnect;
        return 1;
    }
    return 0;
}

#-------------------------------------------------------------------

=head2 load ( database => $database, path => $path, username=> $user,  password=> $password )

Loads a dump file into a database.

=head3 database

The name of the database you want to load the file into.

=head3 path

The path to the dump file you want loaded.

=head3 username

A username that has the privileges to import a dump.

=head3 password

The password that goes with username.

=cut

sub load {
    my $self    = shift;
    my %options = @_;    
    my $config  = $self->wreConfig;
    my $path = file($options{path});
    my $command = $config->get("/prereqs/bin/mysql")
        ." --batch" # disables interactive mode
        ." --user=".$options{username}
        ." --password=".$options{password}
        ." --host=".$config->get("mysql/hostname")
        ." --port=".$config->get("mysql/port")
        ." --execute='source ".$path->stringify."'"
        ." ".$options{database};
    system($command);
}


#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if MySQL is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $config = $self->wreConfig;
    my $db;
    eval {$db = $self->getDatabaseHandle(password=>$config->get("mysql/test/password"), username=>$config->get("mysql/test/user"))};
    if (defined $db) {
       $db->disconnect;
       return 1;
    }
    return 0;
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not.

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub start {
    my $self = shift;
    my $count = 0;
    my $success = 0;
    my $config = $self->wreConfig;
    my $cmd = $config->getRoot("/prereqs/share/mysql/mysql.server")." start --user=".$config->get("user");
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 0) {
        sleep(1);
        eval {$success = $self->ping };
        $count++;
    }
    return $success;
}

#-------------------------------------------------------------------

=head2 stop ( )

Returns a 1 if the stop was successful, or a 0 if it was not.

Note: The process that runs this command must be either root or the user specified in the WRE config file.

=cut

sub stop {
    my $self = shift;
    my $count = 0;
    my $success = 1;
    my $cmd = $self->wreConfig->getRoot("/prereqs/share/mysql/mysql.server")." stop";
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 1) {
        sleep(1);
        eval {$success = $self->ping };
        $count++;
    }
    return !$success;
}




} # end inside out object

1;
