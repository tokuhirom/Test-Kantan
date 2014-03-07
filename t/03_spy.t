use strict;
use warnings;
use utf8;
use Test::More;

use Test::Kantan::Functions qw(spy_on);

sub X::y { die }

my $spy = spy_on('X', 'y')->and_returns(3);
is(X->y, 3);

done_testing;

