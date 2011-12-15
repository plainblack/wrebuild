package WRE::File;

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
use Carp qw(croak carp);
use Class::InsideOut qw(private public new id);
use Digest::MD5;
use File::Copy qw(cp);
use File::Find qw(find);
use File::Slurp qw(read_file write_file);
use File::Temp qw(tempfile tempdir);
use Path::Class;
use Template;
use WRE::Host;



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
    my $host = WRE::Host->new(wreConfig=>$self->wreConfig);
    if ($host->getOsName ne "windows") {
        my $refId = id $self;
        if ($groupId{$refId} eq "" || $userId{$refId} eq "") {
            my $user = $self->wreConfig->get("user");
            (undef, undef, $userId{$refId}, $groupId{$refId}) = getpwnam $user or carp $user." not in passwd file";
        }
        chown $userId{$refId}, $groupId{$refId}, $path;
    }
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
	my $from = dir(shift);
	my $to = dir(shift);
    my $options = shift;

    # handle recursion
    if ($options->{recursive}) {
        delete $options->{recursive};
        my @diff = ();
        $from->recurse(callback=> sub {
                my $foundPath = shift;
                my $newPath;
				if ($foundPath->stringify eq $from->stringify) {
					$newPath = $to;
				}
				else {
                    my $relativePath = $foundPath->relative($from);
                    my $volume = $relativePath->volume;
                    $relativePath =~ s/$volume(.*)/$1/; # remove the volume, fucking windows
					$newPath = $to->file($relativePath);
				}
                my $returnValue = $self->copy($foundPath->stringify, $newPath->stringify, $options);
                if ($returnValue ne "1") {
                    push(@diff, $returnValue);
                }
            });
        return (scalar(@diff) > 0) ? join("\n", @diff) : 1;
    }

    # no recursion
    else {
        my $out = 1;
        # copy a folder
        if (-d $from) {
            $self->makePath($to->stringify) unless (-d $to->stringify);
        }
        # copy a file
        else {
            # process a template
            if ($options->{processTemplate} || exists $options->{templateVars}) {
                my $temp = $to->stringify.".tmp";
                $self->spit($temp, $self->processTemplate($from->stringify, $options->{templateVars}));
                if ($options->{force} || !(-f $to->stringify) || $self->compare($temp, $to->stringify)) {
                    cp($temp, $to->stringify);
                }
                else {
                    $out = "diff ".$to->stringify." ".$from->stringify;
                }
                $self->delete($temp);
            }
            # not dealing with a template
            else {
                if ($options->{force} || !(-f $to->stringify) || $self->compare($from->stringify, $to->stringify)) {
                    cp($from->stringify, $to->stringify);
                }
                else {
                    $out = "diff ".$to->stringify." ".$from->stringify;
                }
	        }
            $self->changeOwner($to->stringify);
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
    my $path = file(shift)->stringify;
    if (-d $path) {
        dir($path)->rmtree;
    }
    elsif (-f $path) {
        file($path)->remove;
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
    if (open($fh, "<", $file)) {
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
    my $path = dir(shift);
    $path->mkpath;
    $self->changeOwner($path->stringify);
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
are automatically generated and added to the list: databaseHost, databasePort, nginxPort, starmanPort,
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
    $var->{databaseHost}  = $config->get("mysql/hostname");
    $var->{databasePort}  = $config->get("mysql/port");
    $var->{nginxPort}     = $config->get("nginx/port");
    $var->{starmanPort}   = $config->get("starman/port");
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

=head2 spit ( path, content, options )

Writes content into a file.

=head3 path

The path to the file you wish to write to.

=head3 content

A scalar reference containing what you want to put into the file.

=head3 options

A hash reference of additional options.

=head4 append

A boolean, that if turned on will append to the file rather than overwritting it.

=cut

sub spit {
    my $self        = shift;
    my $path        = shift;
    my $content     = shift;
    my $options     = shift;
    my %params      = ();
    $params{append} = $options->{append};
    unless (write_file($path, \%params, $content)) {
        croak "Couldn't write content to $path because $!";
    }
    $self->changeOwner($path);
}

#-------------------------------------------------------------------

=head2 tar ( file => $filename, stuff => @folders, [ gzip=>1, exclude=>$excludeFile ] ) 

Creates a tarball.

=head3 file

The path and filename of an archive to create.

=head3 stuff

An array reference of folder and file paths (stuff) to add to the archive. If there is only one path in this array,
and the array is a directory, tar will change to the folder before compressing.

=head3 gzip

Compress the file as it is created.

=head3 exclude

A path to an excludes file.

=cut

sub tar {
    my $self = shift;
    my %options = @_;
    my $args = "";
    if ($options{gzip}) {
        $args .= " --gzip";
    }
    if ($options{absPath}) {
        $args .= " -P";
    }
    if (exists $options{exclude}) {
        my $exFile = file($options{exclude});
        if (-e $exFile) {
            $args .= " --exclude-from=" . $exFile->stringify;
        }
    }
    my $firstThing = dir($options{stuff}->[0])->stringify;
    if (scalar(@{$options{stuff}}) == 1 && -d $firstThing) {
        chdir $firstThing;
        $options{stuff}->[0] = ".";
    }
    my $file = file($options{file})->stringify;
    my @stuff = ();
    foreach my $location (@{$options{stuff}}) {
        my $path = dir($location);
        push @stuff, $path->stringify;
    }
    # use real tar cuz Archive::Tar is sloooooowwwww
    my $tar = file($self->wreConfig->get("tar"))->stringify;
    if (system($tar." --create $args --file ".$file." ".join(" ", @stuff))) {
        croak "Couldn't create ".$file.".";
    }
}

#-------------------------------------------------------------------

=head2 untar ( file => $filename, path => $path, [ gunzip=>1 ] )

Extracts a tarball.

=head3 file

The path and filename of the tarball.

=head3 path

The location where you,'d like the tarball extracted.

=head3 gunzip

A boolean indicating whether to unzip the tarball while extracting it. 

=cut

sub untar {
    my $self = shift;
    my %options = @_;
    my $args = "";
    if ($options{gunzip}) {
        $args .= " --gunzip";
    }
    chdir dir($options{path})->stringify;
    my $file = file($options{file})->stringify;
    # use real tar cuz Archive::Tar is sloooooowwwww
    my $tar = file($self->wreConfig->get("tar"))->stringify;
    if (system($tar." --extract $args --file ".$file)) {
        croak "Couldn't extract ".$file.".";
    }
}

1;

