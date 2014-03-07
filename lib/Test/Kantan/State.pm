package Test::Kantan::State;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has fail_cnt => (is => 'ro', default => sub { 0 });
has messages => (is => 'ro');

no Moo;

sub is_passing {
    my $self = shift;
    return $self->fail_cnt == 0;
}

sub failed {
    my ($self) = @_;
    $self->{fail_cnt}++;
}

1;
