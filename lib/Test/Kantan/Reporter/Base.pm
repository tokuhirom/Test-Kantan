package Test::Kantan::Reporter::Base;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Data::Dumper ();

sub truncstr {
    my ($self, $message, $cutoff) = @_;

    unless (defined $cutoff) {
        $cutoff = $self->cutoff;
    }

    if (length($message) > $cutoff) {
        return substr($message, 0, $cutoff-3) . '...';
    } else {
        return $message;
    }
}

sub dump_data {
    my ($self, $value) = @_;

    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Sortkeys = 1;
    $value = Data::Dumper::Dumper($value);
    $value =~ s/\n/\\n/g;
    return $value;
}

1;

