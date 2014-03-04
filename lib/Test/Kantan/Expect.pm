package Test::Kantan::Expect;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    rw => [qw(state reporter source)],
    new => 1,
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
    }
}

sub is {
    my ($self, $rhs) = @_;

    if (Test::Deep::eq_deeply($self->stuff, $rhs)) {
        1;
    } else {
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(0),
            )
        );
    }
}

1;

