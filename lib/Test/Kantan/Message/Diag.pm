package Test::Kantan::Message::Diag;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has message => ( is => 'ro', required => 1 );
has caller  => ( is => 'ro', required => 1 );
has cutoff  => ( is => 'ro', required => 1 );

no Moo;

sub as_string {
    my ($self, %args) = @_;
    my $reporter = $args{reporter} or die;

    my $msg = do {
        if (not defined $self->message) {
            '(undef)';
        } elsif (ref $self->message) {
            $reporter->dump_data($self->message);
        } else {
            $self->message;
        }
    };
    $msg =~ s/\n/\\n/g;
    return sprintf("Diag: %s\n  at %s line %s.\n", $reporter->colored(['magenta on_black'], $reporter->truncstr($msg, $self->cutoff)), $self->caller->filename, $self->caller->line);
}



1;

