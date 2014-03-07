package Test::Kantan::Functions;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

our @EXPORT = qw(expect ok diag ignore spy_on);

use Test::Power::Core;
use Test::Kantan::Expect;
use Test::Deep::NoTest qw(ignore);
use Module::Spy qw(spy_on);

sub expect {
    Test::Kantan::Expect->new(source => $_[0], builder => Test::Kantan->builder);
}

sub ok(&) {
    my $code = shift;

    local $@;
    my ($retval, $err, $tap_results, $op_stack)
        = Test::Power::Core->give_me_power($code);
    if ($retval) {
        return 1;
    } else {
        my $builder = Test::Kantan->builder;
        $builder->state->failed();
        $builder->reporter->message(
            Test::Kantan::Message::Power->new(
                code        => $code,
                err         => $err,
                tap_results => $tap_results,
                op_stack    => $op_stack,
                caller      => Test::Kantan::Caller->new(0),
            )
        );
        return 0;
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

