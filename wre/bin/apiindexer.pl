#!/data/wre/prereqs/bin/perl
use lib '/data/WebGUI/lib';
use lib '/data/wre/lib';
use strict;
use Pod::POM::Web::Indexer;
print "Indexing POD content...\n";
Pod::POM::Web::Indexer->new->index(-from_scratch => 1);
print "\nIndexing complete.\n";



