use strict;
use warnings;
use utf8;
use Test::More;
use Test::Kantan::Expect;
use Test::Kantan::State;

{
    package Test::Kantan::Reporter::Null;
    use parent qw(Test::Kantan::Reporter::Base);
    use Class::Accessor::Lite 0.05 (
        rw => [qw(cutoff messages)],
    );
    sub new {
        bless {messages => [], cutoff => 80}, shift
    }
    sub message {
        my ($self, $message) = @_;
        push @{$self->{messages}}, $message;
    }
    sub colored { $_[2] }
    sub DESTROY { }
}

sub expect {
    my $v = shift;
    return Test::Kantan::Expect->new(
        source => $v,
        reporter => Test::Kantan::Reporter::Null->new(),
        state => Test::Kantan::State->new(),
    );
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

subtest 'is', sub {
    my $expect = Test::Kantan::Expect->new(
        source => 0,
        reporter => Test::Kantan::Reporter::Null->new(),
        state => Test::Kantan::State->new(),
    );
    ok !$expect->is(1);
    ok $expect->is(0);

    for (@{$expect->reporter->messages}) {
        note $_->as_string(reporter => $expect->reporter);
    }
};

subtest 'should_be_false', sub {
    ok !expect(1)->should_be_false;
    ok expect(0)->should_be_false;
};

subtest 'should_be_true', sub {
    ok expect(1)->should_be_true;
    ok !expect(0)->should_be_true;
};

done_testing;

