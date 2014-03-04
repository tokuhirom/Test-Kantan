use strict;
use warnings;
use utf8;
use Test::Kantan;

suite 'Array', sub {
    suite 'push', sub {
        test 'should push an element', sub {
            my @a=qw(a b c);
            push @a, 'd';
            ok { join(' ', @a) eq 'a b c d e' };

            diag "HOGE";
        };
    };
};

suite 'Hash', sub {
    suite 'fetch', sub {
        test 'take the value', sub {
            expect(+{f => 1}->{g})->ok;
        };
    };
};

done_testing;
