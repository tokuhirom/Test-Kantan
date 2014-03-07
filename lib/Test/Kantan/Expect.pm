package Test::Kantan::Expect;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has builder  => ( is => 'rw',   required => 1 );
has source   => ( is => 'rw',   required => 1 );
has stuff    => ( is => 'lazy', required => 1 );
has inverted => ( is => 'rw',   default => sub { 0 } );

no Moo;

use Try::Tiny;

use Test::Kantan::Caller;
use Test::Kantan::Message::Fail;
use Test::Deep::NoTest;

sub reporter { shift->builder->reporter }
sub state    { shift->builder->state }

sub _build_stuff {
    my $self = shift;
    $self->source;
}

sub _ok {
    my ($self, %args) = @_;

    $self->builder->ok(
        inverted => $self->inverted,
        caller   => Test::Kantan::Caller->new(1),
        %args,
    );
}

sub not {
    my $self = shift;
    Test::Kantan::Expect->new(
        builder  => $self->builder,
        source   => $self->stuff,
        inverted => !$self->inverted,
    );
}

sub to_be_defined {
    my $self = shift;

    $self->_ok(
        value  => defined($self->stuff),
    );
}

sub to_be_truthy {
    my ($self) = @_;

    $self->_ok(
        value    => $self->stuff,
    );
}
sub to_be_true { goto \&to_be_truthy }

sub to_be_falsy {
    my ($self) = @_;

    $self->_ok(
        value    => !$self->stuff,
    );
}
sub to_be_false { goto \&to_be_falsy }

sub to_equal {
    my ($self, $expected) = @_;

    my ($ok, $stack) = Test::Deep::cmp_details($self->stuff, $expected);
    my $diag = $ok ? '-' : Test::Deep::deep_diag($stack);
    $self->_ok(
        value       => $ok,
        description => $diag,
    );
}

sub to_be { goto \&to_equal }

sub to_throw {
    my ($self, $expected) = @_;

    my $thrown;
    try { $self->stuff->() } catch { $thrown++ };
    $self->_ok(
        value       => $thrown,
    );
}

sub to_match {
    my ($self, $re) = @_;

    $self->_ok(
        value => scalar($self->stuff =~ $re),
    );
}

sub to_be_a {
    my ($self, $v) = @_;

    $self->_ok(
        value  => scalar(UNIVERSAL::isa($self->stuff, $v)),
    );
}

sub to_be_an { goto \&to_be_a }

1;
