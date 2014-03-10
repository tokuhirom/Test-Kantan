package Test::Kantan::Functions;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

our @EXPORT = qw(expect ok diag ignore spy_on);

use Test::Kantan::Expect;
use Test::Deep::NoTest qw(ignore);
use Module::Spy 0.03 qw(spy_on);

my $HAS_TEST_POWER = !$ENV{TEST_KANTAN_NOOBSERVER} && eval "use B; use B::Deparse; use Devel::CodeObserver 0.10; 1;";

sub expect {
    my $stuff = shift;
    Test::Kantan::Expect->new(
        stuff   => $stuff,
        builder => Test::Kantan->builder
    );
}

sub ok(&) {
    my $code = shift;

    if ($HAS_TEST_POWER) {
        state $observer = Devel::CodeObserver->new();
        my ($retval, $pairs) = $observer->call($code);

        my $builder = Test::Kantan->builder;
        $builder->ok(
            value       => $retval,
            caller      => Test::Kantan::Caller->new(0),
        );
        while (@$pairs) {
            my $code = shift @$pairs;
            my $dump = shift @$pairs;

            $builder->diag(
                message => sprintf("%s => %s", $code, $dump),
                caller  => Test::Kantan::Caller->new(0),
                cutoff  => $builder->reporter->cutoff,
            );
        }
        return !!$retval;
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

    Test::Kantan->builder->diag(
        message => $msg,
        cutoff  => $cutoff,
        caller  => Test::Kantan::Caller->new(0),
    );
}

1;

