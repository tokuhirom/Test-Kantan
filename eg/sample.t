use strict;
use warnings;
use utf8;
use Test::Kantan::Simple;

subtest 'Array', sub {
    subtest 'push', sub {
        subtest 'should push an element', sub {
            my @a=qw(a b c);
            push @a, 'd';
            ok { join(' ', @a) eq 'a b c d e' };

            diag "HOGE";
        };
    };
};

subtest 'Hash', sub {
    subtest 'fetch', sub {
        subtest 'take the value', sub {
            expect(+{f => 1}->{g})->ok;
        };
    };
};

done_testing;
