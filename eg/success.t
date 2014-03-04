use strict;
use warnings;
use utf8;
use Test::Kantan;

describe 'Array', sub {
    describe 'push', sub {
        it 'should push an element', sub {
            my @a=qw(a b c);
            push @a, 'd';
            ok { join(' ', @a) eq 'a b c d' };

            diag "HOGE";
        };
    };
};

describe 'Hash', sub {
    describe 'fetch', sub {
        it 'take the value', sub {
            expect(+{f => 1}->{f})->is(1);
        };
    };
};

runtests;

