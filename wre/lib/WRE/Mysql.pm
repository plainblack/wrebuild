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
use Carp qw(carp);
use DBI;

{ # begin inside out object

my $wreConfig = {};

#-------------------------------------------------------------------

=head2 new ( wreConfig )

Constructor.

=head3 wreConfig

A WRE::Config object.

=cut

sub new {
    my $class = shift;
    $wreConfig = shift;
    bless \do{my $scalar}, $class;
}

#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if MySQL is running, or a 0 if it is not.

=cut

sub ping {
    my $self = shift;
    my $mysql = $wreConfig->get("mysql");
    my $db = undef;
    eval { 
        $db = DBI->connect(
            'DBI:mysql:'.$mysql->{test}->{database}.';host='.$mysql->{hostname}.';port='.$mysql->{port},
            $mysql->{test}->{user}, 
            $mysql->{test}->{password}
            ); 
    };
    if (defined $db) {
       $db->disconnect;
       return 1;
    }
    carp "Couldn't connect to database because: $@";
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
    system($wreConfig->getRoot("/prereqs/share/mysql/mysql.server")." start");
    while ($count < 10 && $success == 0) {
        sleep(1);
        $success = $self->ping;
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
    system($wreConfig->getRoot("/prereqs/share/mysql/mysql.server")." stop");
    while ($count < 10 && $success == 0) {
        $success = !$self->ping;
        unless ($success) {
            $count++;
        }
    }
    return $success;
}



} # end inside out object

1;
