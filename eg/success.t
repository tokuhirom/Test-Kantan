use strict;
use warnings;
use utf8;
use Test::Kantan::Simple;

suite 'Array', sub {
    suite 'push', sub {
        test 'should push an element', sub {
            step 'do something';

            my @a = qw(a b c);
            push @a, 'd';
            ok { join( ' ', @a ) eq 'a b c d' };

            diag "HOGE";
        };
    };
};

suite 'Hash', sub {
    suite 'fetch', sub {
        test 'take the value', sub {
            expect(+{f => 1}->{f})->is(1);
            expect(+{f => 1}->{f}) == 1;
        };
    };
};

suite 'Foo', sub {
    step 'A';
    step 'B';
    step 'C';

    test 'bar', sub {
        ok { 1 };
    };
};

done_testing;

