#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

for my $file (sort <eg/*.t>) {
    (my $outfile = $file) =~ s/\.t\z/.out/;
    my $cmd = "perl -Ilib $file > $outfile";
    system($cmd)==0 or die "ABORT\n";
}

