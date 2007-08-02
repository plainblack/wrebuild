use lib '../lib';
use strict;
use Test::More tests => 16;
use WRE::Config;
use WRE::File;

my $config = WRE::Config->new();
my $file = WRE::File->new(wreConfig=>$config);
isa_ok($file, "WRE::File");
isa_ok($file->wreConfig, "WRE::Config");

# test slurp
my $content = "This\nthat\nfoo\nbar";
my $testFile = "/tmp/wrefiletest";
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

# chown
$file->changeOwner($testFile);
my $user = $config->get("user");
if (my ($j, $j, $u, $g) = getpwnam $user) {
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($testFile);
    is($uid, $u, "changeOwner() user");
    is($gid, $u, "changeOwner() group");
}
else {
    SKIP: {
        skip("changeOwner() because user $user isn't in password file", 2);
    }
}

# md5
is($file->getMd5sum($testFile), "f34ff5bf9ad371dfca49dc97218cace5", "getMd5sum()");

# compare
$file->spit($testFile."2", \$content);
is($file->compare($testFile, $testFile."2"), 1, "compare() same");
$content .= "YYY";
$file->spit($testFile."2", \$content);
isnt($file->compare($testFile, $testFile."2"), 1, "compare() different");

# copy
is($file->copy($testFile, $testFile."3"), "1", "copy() straight");
is($file->copy($testFile, $testFile."2"), "diff /tmp/wrefiletest2 /tmp/wrefiletest", "copy() diff");

# processTemplate
my $content = "This is my modperl port: [% modperlPort %].";
my $evaluatedContent = "This is my modperl port: 81.";
is(${$file->processTemplate(\$content)}, $evaluatedContent, "processTemplate() with scalarref");


# copy as template
$file->spit($testFile, \$content);
$file->copy($testFile, $testFile."2", {force=>1, processTemplate=>1});
my $contentRef = $file->slurp($testFile."2");
is($$contentRef, $evaluatedContent, "copy() as template");

# path
$file->makePath("/tmp/foo/bar");
is(-d "/tmp/foo/bar", 1, "makePath()");

# delete
$file->delete($testFile);
$file->delete($testFile."2");
$file->delete($testFile."3");
isnt(-f $testFile, 1, "delete() file");
$file->delete("/tmp/foo");
isnt(-d "/tmp/foo", 1, "delete() folder");

