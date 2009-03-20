#!/data/wre/prereqs/bin/perl

print <<STOP;

A serious flaw was discovered in MySQL 5.1 which shipped with WRE 0.9.0. This flaw
will cause database corruption. Therefore in WRE 0.9.0 we've gone back to MySQL 5.0.
Read the wre/gotcha.txt about how to downgrade. 

Unfortunately if you're reading this message you're going to have to start by
restoring from backup.

STOP


