use strict;
use warnings;
use utf8;
use Test::More;

use Test::Kantan::Functions qw(stub_guard);

sub X::y { die }

my $guard = stub_guard(
    'X', {
        y => sub { 3 }
    }
);
is(X->y, 3);

done_testing;

