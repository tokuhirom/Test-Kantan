use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp;
use t::Util;

for my $file (sort <eg/*.t>) {
    for my $reporter (qw(Spec TAP)) {
        note "$file $reporter";
        local $ENV{TEST_KANTAN_REPORTER} = $reporter;
        (my $outfile = $file) =~ s/\.t\z/-${reporter}.out/;
        my $expected = slurp_utf8($outfile);

        my $out = run_test($file);
        $out =~ s/\A\n*//;
        $expected =~ s/\A\n*//;

        is($out, $expected, $outfile);
    }
}

done_testing;
