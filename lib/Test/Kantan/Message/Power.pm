package Test::Kantan::Message::Power;
use strict;
use warnings;
use utf8;
use 5.010_001;

use B::Deparse;
use B;

use Class::Accessor::Lite 0.05 (
    rw => [qw(code tap_results err caller)],
);

our $DUMP_CUTOFF=80;

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    for my $key (qw(code tap_results err caller)) {
        unless (exists $args{$key}) {
            Carp::confess("Missing mandatory parameter: ${key}");
        }
    }
    return bless {%args}, $class;
}


sub as_string {
    my ($self, %args) = @_;
    my $reporter = $args{reporter} or die;

    my @ret;
    push @ret, sprintf("%s: %s\n", $reporter->colored(['red'], 'FAIL'), $reporter->colored(['magenta'], $self->caller->code));
    push @ret, sprintf("%s\n", $self->{err}) if $self->{err};
    push @ret, sprintf("  at %s line %s\n", $reporter->colored(['yellow'], $self->caller->filename), $reporter->colored(['yellow'], $self->caller->line));
    push @ret, "\n";
    for my $result (@{$self->{tap_results}}) {
        my $op = shift @$result;
        for my $value (@$result) {
            # take first argument if the value is scalar.
            my $deparse = B::Deparse->new();
            $deparse->{curcv} = B::svref_2object($self->{code});

            my $val = $reporter->truncstr($reporter->dump_data($value->[1]));
            $val =~ s/\n/\\n/g;
            push @ret, sprintf("%s => %s\n",
                $reporter->colored(['red on_black'], $deparse->deparse($op)),
                $reporter->colored(['red on_black'], $val),
            );
        }
    }
    return join("", @ret);
}



1;

