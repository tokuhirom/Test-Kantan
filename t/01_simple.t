use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp;
use t::Util;

for my $file (sort <eg/*.t>) {
    (my $outfile = $file) =~ s/\.t\z/.out/;
    print "perl -Ilib $file > $outfile\n";
}

for my $file (sort <eg/*.t>) {
    note $file;
    (my $outfile = $file) =~ s/\.t\z/.out/;
    my $expected = slurp_utf8($outfile);

    my $out = run_test($file);
    $out =~ s/\A\n*//;
    $expected =~ s/\A\n*//;

    is($out, $expected);
}

done_testing;
