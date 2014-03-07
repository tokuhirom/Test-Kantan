use strict;
use warnings;
use utf8;
use Test::Kantan;

my @p;
setup { push @p, 'a' };

Feature 'foo', sub {
    Then 'pushed', sub {
        ok { expect(\@p)->to_be(['a']) };
    };
};

Feature 'bar', sub {
    Then 'pushed', sub {
        ok { expect(\@p)->to_be(['a', 'a']) };
    };
};

done_testing;

