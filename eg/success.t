use strict;
use warnings;
use utf8;
use Test::Kantan::Simple;

subtest 'Array', sub {
    subtest 'push', sub {
        subtest 'should push an element', sub {
            my @a = qw(a b c);
            push @a, 'd';
            ok { join( ' ', @a ) eq 'a b c d' };

            diag "HOGE";
        };
    };
};

subtest 'Hash', sub {
    subtest 'fetch', sub {
        subtest 'take the value', sub {
            expect(+{f => 1}->{f})->is(1);
            expect(+{f => 1}->{f}) == 1;
        };
    };
};

subtest 'Foo', sub {
    subtest 'bar', sub {
        ok { 1 };
    };
};

done_testing;

