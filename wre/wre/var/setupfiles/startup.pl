#!/data/wre/prereqs/perl/bin/perl

use Apache2::SizeLimit;
$Apache2::SizeLimit::MAX_PROCESS_SIZE = 100000;
$Apache2::SizeLimit::MAX_UNSHARED_SIZE = 25000;
$Apache2::SizeLimit::CHECK_EVERY_N_REQUESTS = 5;


