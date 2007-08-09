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

=head1 ISA

WRE::Service

=cut

{ # begin inside out object


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

=head2 ping ( )

Returns a 1 if MySQL is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $mysql = $self->wreConfig->get("mysql");
    my $db;
    eval {$db = $self->getDatabaseHandle(password=>$mysql->{test}->{password}, username=>$mysql->{test}->{user})};
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
    my $cmd = $self->wreConfig->getRoot("/prereqs/share/mysql/mysql.server")." start";
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
    my $success = 0;
    my $cmd = $self->wreConfig->getRoot("/prereqs/share/mysql/mysql.server")." stop";
    `$cmd`; # catch command line output
    while ($count < 10 && $success == 0) {
        sleep(1);
        eval {$success = !$self->ping };
        $count++;
    }
    return $success;
}




} # end inside out object

1;
