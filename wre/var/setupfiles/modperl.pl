use Apache2::SizeLimit;
$Apache2::SizeLimit::MAX_PROCESS_SIZE  = 250000;
$Apache2::SizeLimit::MAX_UNSHARED_SIZE = 175000;
$Apache2::SizeLimit::CHECK_EVERY_N_REQUESTS = 5;

1;

