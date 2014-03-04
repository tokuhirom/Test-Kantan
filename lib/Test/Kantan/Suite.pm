package Test::Kantan::Suite;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    rw => [qw(title root)],
);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    for my $key (qw(title)) {
        unless (exists $args{$key}) {
            Carp::croak("Missing mandatory paramter: $key");
        }
    }
    my $self = bless {
        suites => [],
        tests  => [],
        triggers => +{},
        %args,
    }, $class;
    return $self;
}

sub add_test {
    my ($self, $test) = @_;
    push @{$self->{tests}}, $test;
}

sub add_suite {
    my ($self, $suite) = @_;
    push @{$self->{suites}}, $suite;
}

sub is_empty {
    my $self = shift;
    return @{$self->{tests}} + @{$self->{suites}} == 0;
}

sub call_trigger {
    my ($self, $trigger_name) = @_;
    for my $trigger (@{$self->{triggers}->{$trigger_name}}) {
        $trigger->();
    }
}

sub call_before_each_trigger {
    my ($self) = @_;
    $self->{parent}->call_before_each_trigger() if $self->{parent};
    for my $trigger (@{$self->{triggers}->{'before_each'}}) {
        $trigger->();
    }
}

sub call_after_each_trigger {
    my ($self) = @_;
    for my $trigger (@{$self->{triggers}->{'after_each'}}) {
        $trigger->();
    }
    $self->{parent}->call_after_each_trigger() if $self->{parent};
}

sub add_trigger {
    my ($self, $trigger_name, $code) = @_;
    push @{$self->{triggers}->{$trigger_name}}, $code;
}

sub run {
    my ($self, %args) = @_;
    my $reporter = $args{reporter} or die;

    my $guard = $self->root ? undef : $reporter->suite($self);

    $self->call_trigger('before_all');
    for my $test (@{$self->{tests}}) {
        $self->call_before_each_trigger();
        $test->run(%args);
        $self->call_after_each_trigger();
    }
    for my $suite (@{$self->{suites}}) {
        $suite->run(%args);
    }
    $self->call_trigger('after_all');
}

1;

