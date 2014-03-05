use strict;
use warnings;
use utf8;
use Test::More;

use Test::Kantan::Functions qw(spy);

sub X::y { die }

my $spy = spy('X', 'y')->returns(3);
is(X->y, 3);

done_testing;

