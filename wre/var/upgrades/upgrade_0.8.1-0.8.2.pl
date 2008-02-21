#!/data/wre/prereqs/bin/perl

use strict;
use lib '/data/wre/lib';
use WRE::Config;
use WRE::File;

my $config = WRE::Config->new;


# changing version number
my $version = "0.8.2";
print "\tUpdating version number to $version.";
$config->set("version",$version);
print "\tOK\n";

enablingFilePrivilegeChecking($config);

sub enablingFilePrivilegeChecking {
    my $config = shift;
    print "\tEnabling file privilege checking...";
    my $file = WRE::File->new($config);
    my $dir = opendir("/data/wre/etc");
    foreach my $file (readdir($dir)) { 
        next unless ($file =~ m/.modproxy$/);
        my $contents = $file->slurp("/data/wre/etc/".$file);
        ${$contents} =~ s{
          RewriteRule ^/uploads/ - [L] 
        }{
            # For speed we only pass on uploads if there is a .wgaccess file
            RewriteCond %{REQUEST_FILENAME}             ^(.*/)     # Match up to the last /  - save the directory in %1
            RewriteCond ${DOCUMENT_ROOT}%1.wgaccess     !-f        # if (root + directory + .wgaccess) doesn't exist,
            RewriteRule ^/uploads/                      - [L]      # serve directly
        }xms;
        $file->spit("/data/wre/etc/".$file, $contents);
    }
    closedir($dir);
    print "\tOK\n";
}
