package Test::Kantan::Functions;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

our @EXPORT = qw(expect ok diag ignore spy_on);

use Test::Kantan::Expect;
use Test::Deep::NoTest qw(ignore);
use Module::Spy qw(spy_on);

my $HAS_TEST_POWER = !$ENV{TEST_KANTAN_NOPOWER} && eval "use B; use B::Deparse; use Test::Power::Core; 1;";

sub expect {
    Test::Kantan::Expect->new(source => $_[0], builder => Test::Kantan->builder);
}

sub ok(&) {
    my $code = shift;

    if ($HAS_TEST_POWER) {
        local $@;
        my ($retval, $err, $tap_results, $op_stack)
            = Test::Power::Core->give_me_power($code);
        if ($retval) {
            return 1;
        } else {
            my $builder = Test::Kantan->builder;
            my $reporter = $builder->reporter;
            my @diag;
            for my $result (@{$tap_results}) {
                my $op = shift @$result;
                for my $value (@$result) {
                    # take first argument if the value is scalar.
                    my $deparse = B::Deparse->new();
                    $deparse->{curcv} = B::svref_2object($code);

                    my $val = $reporter->truncstr($reporter->dump_data($value->[1]));
                    $val =~ s/\n/\\n/g;
                    push @diag, sprintf("%s => %s\n",
                        $deparse->deparse($op),
                        $val,
                    );
                }
            }
            $builder->state->failed();
            if ($err) {
                $builder->reporter->diag(
                    message => $err,
                    caller  => Test::Kantan::Caller->new(0),
                    cutoff  => $reporter->cutoff,
                );
            }
            $builder->reporter->fail(
                diag => join('', @diag),
                caller      => Test::Kantan::Caller->new(0),
            );
            return 0;
        }
    } else {
        my $retval = $code->();
        my $builder = Test::Kantan->builder;
        $builder->ok(
            value       => $retval,
            caller      => Test::Kantan::Caller->new(0),
        );
    }
}

sub diag {
    my ($msg, $cutoff) = @_;

    Test::Kantan->builder->reporter->diag(
        message => $msg,
        cutoff  => $cutoff,
        caller  => Test::Kantan::Caller->new(0),
    );
}

1;

