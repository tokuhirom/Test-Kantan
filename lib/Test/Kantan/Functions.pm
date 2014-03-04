package Test::Kantan::Functions;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

our @EXPORT = qw(expect ok diag ignore);

use Test::Power::Core;
use Test::Kantan::Expect;
use Test::Deep::NoTest qw(ignore);

sub expect {
    Test::Kantan::Expect->new(source => $_[0], reporter => $Test::Kantan::REPORTER, state => $Test::Kantan::STATE);
}

sub ok(&) {
    my $code = shift;

    local $@;
    my ($retval, $err, $tap_results, $op_stack)
        = Test::Power::Core->give_me_power($code);
    if ($retval) {
        return 1;
    } else {
        $Test::Kantan::STATE->failed();
        $Test::Kantan::REPORTER->message(
            Test::Kantan::Message::Power->new(
                code        => $code,
                err         => $err,
                tap_results => $tap_results,
                op_stack    => $op_stack,
                caller      => Test::Kantan::Caller->new(0),
                color       => $Test::Kantan::COLOR,
            )
        );
        return 0;
    }
}

sub diag {
    my $msg = shift;
    $Test::Kantan::REPORTER->message(
        Test::Kantan::Message::Diag->new(
            message => $msg,
            caller  => Test::Kantan::Caller->new(0),
        )
    );
}



1;

