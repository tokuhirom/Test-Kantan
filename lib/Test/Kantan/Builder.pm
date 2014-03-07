package Test::Kantan::Builder;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Module::Load;

use Test::Kantan::State;
use Test::Kantan::Message::Pass;

use Class::Accessor::Lite 0.05 (
    rw => [qw(color state reporter)],
);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;

    my $self = bless { %args }, $class;
    $self->{color} = $ENV{TEST_KANTAN_COLOR} || -t *STDOUT;
    $self->{state} = Test::Kantan::State->new();
    $self->{reporter} ||= $self->_build_reporter;
    return $self;
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
        $self->reporter->message(
            Test::Kantan::Message::Pass->new(
                caller      => $caller,
                description => $args{description},
            ),
        );
        return 1;
    } else {
        $self->state->failed();
        $self->reporter->message(
            Test::Kantan::Message::Fail->new(
                caller      => $caller,
                description => $args{description},
            ),
        );
        return 0;
    }
}

1;

