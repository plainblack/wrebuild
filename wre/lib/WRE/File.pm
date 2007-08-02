package WRE::File;

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
use Carp qw(carp);
use Class::InsideOut qw(private public new id);
use Digest::MD5;
use File::Copy qw(cp);
use File::Find qw(find);
use File::Path qw(mkpath rmtree);
use File::Slurp qw(read_file write_file);
use File::Temp qw(tempfile tempdir);
use Template;

{ # begin inside out object


=head1 METHODS

The following methods are available from this package.

=cut


# cache these things
private groupId => my %groupId;
private userId => my %userId;
private template => my %template;

#-------------------------------------------------------------------

=head2 wreConfig ( )

Returns a reference to the WRE cconfig.

=cut

public wreConfig => my %wreConfig;



#-------------------------------------------------------------------

=head2 changeOwner ( path )

Change the path's privileges to be owned by the WRE user.

=head3 path

=cut

sub changeOwner {
    my $self = shift;
    my $path = shift;
    my $refId = id $self;
    unless ($groupId{$refId} eq "" || $userId{$refId} eq "") {
        my $crap = "";
        my $user = $self->wreConfig->get("user");
        ($crap, $crap, $userId{$refId}, $groupId{$refId}) = getpwnam $user or carp $user." not in passwd file";
    }
    chown $userId{$refId}, $groupId{$refId}, $path;
}


#-------------------------------------------------------------------

=head2 compare ( path1, path2 ) 

Returns 1 if the files at the paths are the same or a 0 if they are not;

=cut

sub compare {
    my $self = shift;
    my $path1 = shift;
    my $path2 = shift;
    return ($self->getMd5sum($path1) eq $self->getMd5sum($path2)) ? 1 : 0;
}


#-------------------------------------------------------------------

=head2 copy (from, to, options)

Copy's a file from one place to another. Returns a diff command if there is already a file in the "to" location.
Returns a 1 if successful.

=head3 from

The path to copy the file from.

=head3 to

The path to copy the file to.

=head3 options

A hash reference of options that you can pass into the copy process.

=head4 force

A boolean that overwrites the file if it already exists. The diff is still returned though.

=head4 processTemplate

A boolean indicating whether to process the from file as a template. If this is specified then the resulting 
file is compared to the to file (if it exists) for diffing purposes. A default set of template variables will
be used from the config file. 

=head4 recursive

A boolean recursively copies the from if it is a directory.

=head4 templateVars

A hash reference containing template variables. No need to specify "processTemplate" if you have specified
a list of template variables to process.

=cut

sub copy {
    my $self = shift;
	my $from = shift;
	my $to = shift;
    my $options = shift;

    # handle recursion
    if ($options->{recursive}) {
        $from.'/' unless ($from =~ m{/$});
        $to.'/' unless ($to =~ m{/$});
        delete $options->{recursive};
        my @diff = ();
        find({ 
            no_chdir=>1, 
            wanted=> sub { 
                    my $newPath = $File::Find::name;
                    $newPath =~ s/$from(.*)/$1/;
                    $newPath = $to.$newPath;
                    my $returnValue = $self->copy($File::Find::name, $newPath, $options);
                    if ($returnValue ne "1") {
                        push(@diff, $returnValue);
                    }
                } 
            }, $from);
        return (scalar(@diff) > 0) ? join("\n", @diff) : 1;
    }

    # no recursion
    else {
        my $out = 1;
        # copy a folder
        if (-d $from) {
            $self->makePath($to) unless (-d $to);
        }
        # copy a file
        else {
            # process a template
            if ($options->{processTemplate} || exists $options->{templateVars}) {
                my $temp = $to.".tmp";
                $self->spit($temp, $self->processTemplate($from, $options->{templateVars}));
                if ($options->{force} || !(-f $to) || $self->compare($temp, $to)) {
                    cp($temp, $to);
                }
                else {
                    $out = "diff $to $from";
                }
                $self->delete($temp);
            }
            # not dealing with a template
            else {
                if ($options->{force} || !(-f $to) || $self->compare($from, $to)) {
                    cp($from, $to);
                }
                else {
                    $out = "diff $to $from";
                }
	        }
            $self->changeOwner($to);
        }
        return $out;
    }
}


#-------------------------------------------------------------------

=head2 delete ( path )

Delete's a file or folder.

=head3 path

The path to a file or folder to delete.

=cut

sub delete {
    my $self = shift;
    my $path = shift;
    if (-d $path) {
        rmtree($path);
    }
    elsif (-f $path) {
        unlink $path
    }
}


#-------------------------------------------------------------------

=head2 getMd5sum ( path )

Returns an MD5 checksum. 

=head3 path

The path to the file to check.

=cut

sub getMd5sum {
    my $self = shift;
    my $file = shift;
    ## create Digest::MD5 object to be reused throughout.
    my $md5 = Digest::MD5->new;
    ## i am the filehandle.
    my $fh;
    if (open($fh, "< $file")) {
        ## load the file.
        $md5->addfile($fh);
        my $digest = $md5->hexdigest;
        close($fh);
        return $digest;
    }
    else {
        carp "Couldn't open to create MD5 sum:". $file. ": $!";
    }
}        


#-------------------------------------------------------------------

=head2 makePath ( path )

Creates a folder, or series of folders all along the path.

=head3 path

THe path of the folder to create.

=cut

sub makePath {
    my $self = shift;
    my $path = shift;
    mkpath($path);
}


#-------------------------------------------------------------------

=head2 makeTempPath () 

Creates a temporary path and returns the path as a string. Will automatically delete the temporary path at program
exit if you forget to clean it up.

=cut

sub makeTempPath {
    return tempdir( CLEANUP => 1 );    
}


#-------------------------------------------------------------------

=head2 new ( wreConfig => $config )

Constructor.

=head3 wreConfig

A reference to a WRE Configuration object.

=cut

# auto created by Class::InsideOut



#-------------------------------------------------------------------

=head2 processTemplate ( { input }, vars )

Returns a scalar reference of the processed template.

=head3 input

Either a path to a template file as a scalar or a scalar reference to a template string.

=head3 vars

A hash reference containing the template variables to process on the template. The following template variables
are automatically generated and added to the list: databaseHost, databasePort, modproxyPort, modperlPort,
domainRoot, wreRoot, webguiRoot

=cut

sub processTemplate {
    my $self    = shift;
    my $input   = shift;
    my $var     = shift;
    my $config = $self->wreConfig;

    # check to see if a path was passed in
    unless (ref $input eq "SCALAR") {
        $input = $self->slurp($input);
    }

    # add in some template template variables
    $var->{databaseHost}  = $config->get("mysql")->{hostname};
    $var->{databasePort}  = $config->get("mysql")->{port};
    $var->{modproxyPort}  = $config->get("apache")->{modproxyPort};
    $var->{modperlPort}   = $config->get("apache")->{modperlPort};
    $var->{domainRoot}    = $config->getDomainRoot;
    $var->{wreRoot}       = $config->getRoot;
    $var->{wreUser}       = $config->get("user");
    $var->{webguiRoot}    = $config->getWebguiRoot;

    # cache template
    my $refId = id $self; # inside out reference id
    if ($template{$refId} eq "") {
        $template{$refId} = Template->new(INCLUDE_PATH=>'/');
    }

    # process the template
    my $output = undef;
    $template{$refId}->process($input, $var, \$output);
    return \$output;
}

#-------------------------------------------------------------------

=head2 slurp ( path )

Reads a file into a scalar and returns a reference to the scalar.

=cut

sub slurp {
    my $self = shift;
    my $path = shift;
    return read_file($path, scalar_ref=>1); 
}


#-------------------------------------------------------------------

=head2 spit ( path, content )

Writes content into a file.

=head3 path

The path to the file you wish to write to.

=head3 content

A scalar reference containing what you want to put into the file.

=cut

sub spit {
    my $self = shift;
    my $path = shift;
    my $content = shift;
    unless (write_file($path, $content)) {
        carp "Couldn't write content to $path because $!";
    }
    $self->changeOwner($path);
}




} # end inside out object
1;
