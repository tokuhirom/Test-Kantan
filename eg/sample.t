use strict;
use warnings;
use utf8;
use Test::Kantan;

suite 'Array', sub {
    suite 'push', sub {
        test 'it should push an element', sub {
            my @a=qw(a b c);
            push @a, 'd';
            expect { join(' ', @a) eq 'a b c d e' };

            diag "HOGE";
        };
    };
};

suite 'Hash', sub {
    suite 'fetch', sub {
        step 'foo';
        step 'bar';

        test 'take the value', sub {
            ok +{f => 1}->{g};
        };
    };
};

done_testing;
