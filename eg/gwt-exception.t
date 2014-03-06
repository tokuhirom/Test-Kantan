use strict;
use warnings;
use utf8;
use Test::Kantan::GWT;

Feature 'Foo', sub {
    Scenario 'bar', sub {
         Then 'baz', sub { die };
    };
};

done_testing;

