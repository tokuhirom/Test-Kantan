use strict;
use warnings;
use utf8;
use Test::Kantan::GWT;

my @p;
setup { push @p, 'a' };

Feature 'foo', sub {
    Then 'pushed', sub {
        ok { expect(\@p)->is(['a']) };
    };
};

Feature 'bar', sub {
    Then 'pushed', sub {
        ok { expect(\@p)->is(['a', 'a']) };
    };
};

done_testing;

