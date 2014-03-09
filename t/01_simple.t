use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp;
use Test::Requires { 'Test::Power::Core' => '0.13' };
use t::Util;

for my $file (sort <eg/*.t>) {
    for my $reporter (qw(Spec TAP)) {
        for my $power (qw(0 1)) {
            note "$file $reporter";
            local $ENV{TEST_KANTAN_REPORTER} = $reporter;
            local $ENV{TEST_KANTAN_NOPOWER} = $power ? 0 : 1;
            (my $outfile = $file) =~ s/\.t\z/-${reporter}-${power}.out/;
            my $expected = slurp_utf8($outfile);

            my $out = run_test($file);
            $out =~ s/\A\n*//;
            $expected =~ s/\A\n*//;

            is($out, $expected, $outfile);
        }
    }
}

done_testing;
