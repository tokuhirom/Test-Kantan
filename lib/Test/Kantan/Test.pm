package Test::Kantan::Test;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    rw => [qw(title code)],
);
use Scalar::Util ();

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    for my $key (qw(title code)) {
        unless (exists $args{$key}) {
            Carp::croak("Missing mandatory paramter: $key");
        }
    }
    my $self = bless {%args}, $class;
    return $self;
}

sub run {
    my ($self, %args) = @_;
    my $state = $args{state} or Carp::croak("Missing mandatory parameter: state");
    my $reporter = $args{reporter} or die;

    my $orig_fail_cnt = $state->fail_cnt;
    my $ok = $self->code->();
    my $new_fail_cnt = $state->fail_cnt();

    if ($orig_fail_cnt == $new_fail_cnt) {
        $reporter->pass($self->title);
    } else {
        $reporter->fail($self->title);
    }
}

1;

