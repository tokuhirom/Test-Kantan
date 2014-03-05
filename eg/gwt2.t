use strict;
use warnings;
use utf8;
use Test::Kantan::GWT;

Feature 'Foo', sub {
    Scenario 'Normal', sub {
        Given 'First';
        Given 'Second';
        my @ary;

        When 'Push one item';
        push @ary, 'a';
        When 'Push next item';
        push @ary, 'b';

        Then 'the number of array is 2', sub {
            expect(0+@ary)->is(2);
        };
        Then 'first item is "a"', sub {
            expect($ary[0])->is('a');
        };
    };
};


done_testing;

