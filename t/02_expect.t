use strict;
use warnings;
use utf8;
use Test::More;
use Test::Kantan::Expect;
use Test::Kantan::State;

{
    package Test::Kantan::Reporter::Null;
    sub new { bless {}, shift }
    sub DESTROY { }
    sub AUTOLOAD { }
}

subtest 'should_be_a', sub {
    {
        package A;
        our @ISA=qw(B);
    }

    {
        package B;
        sub new { bless {}, shift }
    }

    my $expect = Test::Kantan::Expect->new(
        source => A->new,
        reporter => Test::Kantan::Reporter::Null->new(),
        state => Test::Kantan::State->new(),
    );
    ok $expect->should_be_a('A');
    ok $expect->should_be_a('B');
    ok !$expect->should_be_a('C');
};

subtest 'isnt', sub {
    my $expect = Test::Kantan::Expect->new(
        source => 0,
        reporter => Test::Kantan::Reporter::Null->new(),
        state => Test::Kantan::State->new(),
    );
    ok !$expect->isnt(0);
    ok $expect->isnt(1);
};

done_testing;

