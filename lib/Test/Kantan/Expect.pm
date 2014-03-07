package Test::Kantan::Expect;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    rw => [qw(builder source)],
    new => 1,
);

use Try::Tiny;

use Test::Kantan::Caller;
use Test::Kantan::Message::Fail;
use Test::Deep::NoTest;

sub reporter { shift->builder->reporter }
sub state    { shift->builder->state }

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

    $self->builder->ok(
        value  => $self->stuff,
        caller => Test::Kantan::Caller->new(0),
    );
}

sub like {
    my ($self, $regexp) = @_;

    $self->builder->ok(
        value  => scalar($self->stuff =~ $regexp),
        caller => Test::Kantan::Caller->new(0),
    );
}

sub is {
    my ($self, $expected) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($self->stuff, $expected);
    my $diag = $ok ? '-' : Test::Deep::deep_diag($stack);
    $self->builder->ok(
        value  => $ok,
        caller => Test::Kantan::Caller->new(0),
        description => $diag,
    );
}

sub isnt {
    my ($self, $expected) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($self->stuff, $expected);
    # We can't call Test::Deep::deep_diag if cmp_details() was succeeded.
    $self->builder->ok(
        value  => !$ok,
        caller => Test::Kantan::Caller->new(0),
        description => ('Got: ' . $self->reporter->truncstr($self->reporter->dump_data($self->source))),
    );
}

sub should_be_a {
    my ($self, $rhs) = @_;

    $self->builder->ok(
        value  => scalar(UNIVERSAL::isa($self->stuff, $rhs)),
        caller => Test::Kantan::Caller->new(0),
    );
}

sub should_be_true {
    my ($self) = @_;

    $self->builder->ok(
        value  => scalar($self->stuff),
        caller => Test::Kantan::Caller->new(0),
    );
}

sub should_be_false {
    my ($self) = @_;

    $self->builder->ok(
        value  => scalar(!$self->stuff),
        caller => Test::Kantan::Caller->new(0),
    );
}

1;

