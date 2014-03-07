package Test::Kantan::Message::Fail;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has description => ( is => 'ro', required => 1 );
has caller  => ( is => 'ro', required => 1 );

no Moo;

sub as_string {
    my ($self, %args) = @_;
    my $reporter = $args{reporter} or die;

    my @ret;
    push @ret, sprintf("%s\n", $reporter->colored(['red on_black'], $self->caller->code));
    if (defined $self->description) {
        push @ret, sprintf("%s\n", $reporter->colored(['red on_black'], $self->description));
    }
    push @ret, sprintf("   at %s line %s\n\n", $reporter->colored(['yellow'], $self->caller->filename), $reporter->colored(['yellow'], $self->caller->line));
    return join("", @ret);
}



1;

