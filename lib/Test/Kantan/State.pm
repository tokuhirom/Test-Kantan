package Test::Kantan::State;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Class::Accessor::Lite 0.05 (
    ro => [qw(fail_cnt messages)],
);

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    bless {
        fail_cnt => 0,
        %args
    }, $class;
}

sub is_passing {
    my $self = shift;
    return $self->fail_cnt == 0;
}

sub failed {
    my ($self) = @_;
    $self->{fail_cnt}++;
}

1;
__END__

package Test::Kantan::Builder;

sub step {
    my $self = shift;
    print "    + STEP $_[0]\n", shift;
}

sub runtests {
    my $self = shift;

    for my $test (@{$self->{tests}}) {
    # local @TEST_NAMES=@TEST_NAMES;
    # push @TEST_NAMES, $test->[0];
        print "  + $test->[0]\n";
        $test->[1]->();
    }

    if (!$self->is_passing) {
        if ($self->messages) {
            printf "\n\n\n  %s:\n\n", colored(['red'], '(Diagnostic message)');
            for my $message ($self->messages) {
                print $message->as_string;
            }
        }
    }

    # Test::Pretty was loaded
    if (Test::Pretty->can('_subtest')) {
        # Do not run Test::Pretty's finalization
        $Test::Pretty::NO_ENDING=1;
    }

    # If Test::Builder was loaded...
    if (Test::Builder->can('new')) {
        if (!Test::Builder->new->is_passing) {
            # Fail if Test::Builder was failed.
            $self->{fail_cnt}++;
        }
    }
    printf "\n\n%sok\n", $self->{fail_cnt} ? 'not ' : '';

    $self->{finished}++;
}

sub messages {
    my $self = shift;
    return @{$self->{messages}};
}

sub finished {
    my $self = shift;
    $self->{finished};
}

1;

