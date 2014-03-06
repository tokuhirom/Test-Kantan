#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

for my $file (sort <eg/*.t>) {
    for my $reporter (qw(Spec TAP)) {
        (my $outfile = $file) =~ s/\.t\z/-${reporter}.out/;
        my $cmd = "perl -Ilib $file > $outfile";
        local $ENV{TEST_KANTAN_REPORTER}=$reporter;
        system($cmd)==0 or die "ABORT\n";
    }
}

