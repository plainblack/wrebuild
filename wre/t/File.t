use lib '../lib';
use strict;
use Test::More tests => 28;
use WRE::Config;
use WRE::File;
use Path::Class;
use File::Temp qw(tempfile tempdir);
use File::Path;
use File::Slurp;
use File::Spec;

my $config = WRE::Config->new();
my $file = WRE::File->new(wreConfig=>$config);
isa_ok($file, "WRE::File");
isa_ok($file->wreConfig, "WRE::Config");

# test slurp
my $content = "This\nthat\nfoo\nbar";

my ($testFileHandle, $testFile) = tempfile();
$testFile = dir($testFile)->stringify;
open(my $f, ">", $testFile);
print {$f} $content;
close($f);
my $read = $file->slurp($testFile);
is(${$read}, $content, "slurp()");

# test spit
$content .= "XXXX";
$file->spit($testFile, \$content);
$read = $file->slurp($testFile);
is(${$read}, $content, "spit()");
my $append = "ZZZZ";
$file->spit($testFile, \$append, { append => 1 });
$read = $file->slurp($testFile);
is(${$read}, $content.$append, "spit() append");

# chown
$file->changeOwner($testFile);
my $user = $config->get("user");
if ($^O eq "MSWin32") {
    SKIP: {
        skip("skip change owner on windows", 2);
    }
}
else {
    if (my ($j, $j, $u, $g) = getpwnam $user) {
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($testFile);
        is($uid, $u, "changeOwner() user");
        is($gid, $u, "changeOwner() group");
    }
    else {
        SKIP: {
            skip("changeOwner() user because user $user isn't in password file", 2);
        }
    }
}


# md5
is($file->getMd5sum($testFile), "250be89ccf439ab7c048fcbc6a65bd58", "getMd5sum()");


# compare
$file->spit($testFile."2", \$content);
isnt($file->compare($testFile, $testFile."2"), 1, "compare() different");
$file->spit($testFile."2", \$append, { append => 1 });
is($file->compare($testFile, $testFile."2"), 1, "compare() same");


# copy
is($file->copy($testFile, $testFile."3"), "1", "copy() straight");
$file->spit($testFile, \$append, { append => 1 });
is($file->copy($testFile, $testFile."2"), "diff ".$testFile."2 ".$testFile, "copy() diff");
my $recursiveDir1 = tempdir( CLEANUP => 1 );
my $subDir = $recursiveDir1."/ab";
mkpath(dir($subDir)->stringify);
write_file(file($subDir."/a")->stringify, "AAAAAA");
write_file(file($subDir."/b")->stringify, "BBBBBB");
write_file(file($recursiveDir1."/x")->stringify, "XXXXXX");
write_file(file($recursiveDir1."/y")->stringify, "YYYYYY");
my $recursiveDir2 = tempdir( CLEANUP => 1 );
$file->copy($recursiveDir1, $recursiveDir2, {force=>1, recursive=>1});
is(-f file($recursiveDir2."/y")->stringify, 1, "recursive copy() main level file");
is(-d dir($recursiveDir2."/ab")->stringify, 1, "recursive copy() subdirectory");
is(-f file($recursiveDir2."/ab/a")->stringify, 1, "recursive copy() subdirectory file");


# processTemplate
my $content = "This is my starman port: [% config.get('starman/port') %].";
my $evaluatedContent = "This is my starman port: 8081.";
is(${$file->processTemplate(\$content)}, $evaluatedContent, "processTemplate() with scalarref");


# copy as template
$file->spit($testFile, \$content);
$file->copy($testFile, $testFile."2", {force=>1, processTemplate=>1});
my $contentRef = $file->slurp($testFile."2");
is($$contentRef, $evaluatedContent, "copy() as template");
$content = "A custom variable [% xy1 %].";
$file->spit($testFile, \$content);
$file->copy($testFile, $testFile."2", {force=>1, templateVars=>{xy1=>"YUMMY"}});
$contentRef = $file->slurp($testFile."2");
is($$contentRef, "A custom variable YUMMY.", "copy() as template with custom vars");


# path
$file->makePath("/tmp/foo/bar");
is(-d dir("/tmp/foo/bar")->stringify, 1, "makePath()");


# delete
$file->delete($testFile);
$file->delete($testFile."2");
$file->delete($testFile."3");
isnt(-f ($testFile."2"), 1, "delete() file");
$file->delete("/tmp/foo");
isnt(-d dir("/tmp/foo")->stringify, 1, "delete() folder");

## tar
my $backup_dir = File::Spec->catfile($config->getWebguiRoot(),'lib/Spectre');
my $tarFile = '/tmp/foo-tar.tar';
$file->tar(file=> $tarFile, stuff=>[$backup_dir], gzip=>0);
is(-e $tarFile, 1, 'tar() creates an archive file');
## untar
$file->untar(file=>$tarFile, path=> '/tmp', gunzip=>0);
is(-e "$backup_dir/Admin.pm", 1, 'untar() opens an archive file');
# cleanup
$file->delete($tarFile);
is(-f ($tarFile), undef, "delete() tar test file");
rmtree(['/tmp/data'],0,1);

## tar exclude test
my $exclude_file = '/tmp/tar-exclude';
open (OUT,">$exclude_file") or die "Count not open $exclude_file for writing: $!";
print OUT 'data/WebGUI/lib/Spectre/Cron.pm';
close OUT;
# run tar and untar
$file->tar(file=> $tarFile, stuff=>[$backup_dir], gzip=>0, exclude=>$exclude_file);
is(-e $tarFile, 1, 'tar() creates an archive file');
$file->untar(file=>$tarFile, path=> '/tmp', gunzip=>0);
is(-e "$backup_dir/Admin.pm", 1, 'untar() opens an archive file');
# check for excluded file
is(-f (substr("$backup_dir/Cron.pm", 1)), undef, "Check for excluded file");
# cleanup
$file->delete($exclude_file);
rmtree(['/tmp/data'],0,1);
$file->delete($tarFile);
is(-f ($tarFile), undef, "delete() tar test file");
