package Test::Kantan::Builder;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Module::Load;
use Try::Tiny;

use Test::Kantan::State;

use Moo;

has color    => ( is => 'lazy' );
has state    => ( is => 'lazy' );
has reporter => ( is => 'lazy' );

no Moo;

sub _build_color {
    $ENV{TEST_KANTAN_COLOR} || -t *STDOUT;
}

sub _build_state {
    Test::Kantan::State->new();
}

sub _build_reporter {
    my $self = shift;

    my $reporter_class = do {
        my $s = $ENV{TEST_KANTAN_REPORTER} || 'Spec';
        my $klass = ($s =~ s/\A\+// ? $s : "Test::Kantan::Reporter::${s}");
        Module::Load::load $klass;
        $klass;
    };
    my $reporter = $reporter_class->new(
        color => $self->color,
        state => $self->state,
    );
    $reporter->start;
    return $reporter;
}

sub ok {
    my ($self, %args) = @_;
    my $caller      = param(\%args, 'caller');
    my $value       = param(\%args, 'value');
    my $description = param(\%args, 'description', {optional => 1});

    if ($value) {
        $self->state->passed();
        $self->reporter->pass(
            caller      => $caller,
            description => $description,
        );
        return 1;
    } else {
        $self->state->failed();
        $self->reporter->fail(
            caller      => $caller,
            description => $description,
        );
        return 0;
    }
}

sub exception {
    my ($self, %args) = @_;
    my $message = param(\%args, 'message');

    $self->state->failed();
    $self->reporter->exception(
        message => $message,
    );
}

sub param {
    my ($args, $key, $opts) = @_;

    if (exists $opts->{default} && not exists $args->{$key}) {
        $args->{$key} = $opts->{default};
    }

    if (exists $args->{$key}) {
        delete $args->{$key};
    } else {
        if ($opts->{optional}) {
            return undef;
        } else {
            Carp::confess "Missing mandatory parameter: ${key}";
        }
    }
}

sub diag {
    my ($self, %args) = @_;
    my $message = param(\%args, 'message');
    my $cutoff  = param(\%args, 'cutoff', { default => $self->reporter->cutoff });
    my $caller  = param(\%args, 'caller');

    $self->reporter->diag(
        message => $message,
        cutoff  => $cutoff,
        caller  => $caller,
    );
}

sub subtest {
    my ($self, %args) = @_;
    my $title = param(\%args, 'title');
    my $code  = param(\%args, 'code');
    my $suite = param(\%args, 'suite');

    my $guard = $self->reporter->suite($title);

    $suite->parent->call_trigger('setup');
    try {
        $code->();
    } catch {
        $self->exception(message => $_);
    };
    $suite->parent->call_trigger('teardown');
}

1;

