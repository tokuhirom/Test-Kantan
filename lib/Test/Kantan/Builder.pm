package Test::Kantan::Builder;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Module::Load;

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
    my $caller = $args{caller} or Carp::confess("Missing caller");
    exists($args{value}) or Carp::cofess("Missing value");
    my $value = $args{value};
       $value = !$value if $args{inverted};

    if ($value) {
        $self->reporter->pass(
            caller      => $caller,
            description => $args{description},
        );
        return 1;
    } else {
        $self->state->failed();
        $self->reporter->fail(
            caller      => $caller,
            description => $args{description},
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
    my ($args, $key) = @_;

    if (exists $args->{$key}) {
        delete $args->{$key};
    } else {
        Carp::confess "Missing mandatory parameter: message";
    }
}

1;

