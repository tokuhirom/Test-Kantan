package Test::Kantan::Expect;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    rw => [qw(state reporter source)],
    new => 1,
);

use Test::Kantan::Caller;
use Test::Kantan::Message::Fail;
use Test::Deep::NoTest;

use overload (
    q{==} => 'is',
    q{eq} => 'is',
    fallback => 1,
);

sub stuff {
    my $self = shift;
    exists($self->{stuff}) ? $self->{stuff} : $self->{source};
}

sub ok {
    my $self = shift;
    if ($self->stuff) {
        1;
    } else {
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub like {
    my ($self, $regexp) = @_;
    if ($self->stuff =~ $regexp) {
        1;
    } else {
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub is {
    my ($self, $expected) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($self->stuff, $expected);
    if ($ok) {
        1;
    } else {
        $self->state->failed();
        my $diag = Test::Deep::deep_diag($stack);
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                description => $diag,
                caller      => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub isnt {
    my ($self, $expected) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($self->stuff, $expected);
    unless ($ok) {
        1;
    } else {
        # We can't call Test::Deep::deep_diag if cmp_details() was succeeded.
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                description => ('Got: ' . $self->reporter->truncstr($self->reporter->dump_data($self->source))),
                caller      => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub should_be_a {
    my ($self, $rhs) = @_;

    if (UNIVERSAL::isa($self->stuff, $rhs)) {
        1;
    } else {
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub _ok {
    my ($self, $v) = @_;

    if ($v) {
        1;
    } else {
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(1),
            )
        );
        0;
    }
}

sub should_be_true {
    my ($self) = @_;
    $self->_ok($self->stuff);
}

sub should_be_false {
    my ($self) = @_;
    $self->_ok(!$self->stuff);
}

1;

