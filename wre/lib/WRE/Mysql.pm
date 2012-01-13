package WRE::Mysql;

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
use base 'WRE::Service';
use Carp qw(croak);
use Class::InsideOut qw(new);
use DBI;
use Path::Class;
use WRE::Host;

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
    my $command = "mysqldump"
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
    my $self     = shift;
    my %options  = @_;
    my $password = $options{password};
    my $mysql    = $self->wreConfig->get("mysql");
    my $username = $options{username} || $mysql->{adminUser};
    my $test_db  = $mysql->{test}->{database} || 'test';
    my $dsn = $options{dsn} || 'DBI:mysql:'.$test_db.';host='.$mysql->{hostname}.';port='.$mysql->{port};
    my $db  = undef;
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
    my $command = "mysql"
        ." --batch" # disables interactive mode
        ." --user=".$options{username}
        ." --password=".$options{password}
        ." --host=".$config->get("mysql/hostname")
        ." --port=".$config->get("mysql/port")
        ." --execute=\"source ".$path->stringify."\""
        ." ".$options{database};
    system($command);
}

} # end inside out object

1;
