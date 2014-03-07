package Test::Kantan::Message::Pass;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has caller => ( is => 'ro' );
has description => ( is => 'ro' );

no Moo;

sub as_string {
    my $self = shift;
    "Passed: " . $self->caller->code;
}

1;

