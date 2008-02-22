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
    my $file = WRE::File->new(wreConfig=>$config);
    opendir(my $dir, "/data/wre/etc");
    foreach my $filename (readdir($dir)) { 
        next unless ($filename =~ m/.modproxy$/);
        my $contents = $file->slurp("/data/wre/etc/".$filename);
        ${$contents} =~ s{RewriteRule\s+\^/uploads/\s+-\s+\[L\]}{
            # For speed we only pass on uploads if there is a .wgaccess file
            RewriteCond %\{REQUEST_FILENAME\}             ^(.*/)
            RewriteCond \$\{DOCUMENT_ROOT\}%1.wgaccess     !-f 
            RewriteRule ^/uploads/                      - [L]
        }xmsg;
        $file->spit("/data/wre/etc/".$filename, $contents);
    }
    closedir($dir);
    print "\tOK\n";
}
