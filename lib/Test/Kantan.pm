package Test::Kantan;
use 5.010_001;
use strict;
use warnings;

our $VERSION = "0.02";

use parent qw(Exporter);

use Test::Kantan::State;
use Test::Kantan::Caller;
use Test::Kantan::Test;
use Test::Kantan::Suite;
use Test::Kantan::Reporter::Spec;

use Test::Kantan::Message::Power;
use Test::Kantan::Message::Fail;
use Test::Kantan::Message::Diag;

use Test::Deep::NoTest qw(ignore);
use Test::Power::Core;
use Test::Kantan::Expect;

our @EXPORT = qw(describe it ok runtests diag expect ignore before_each);

our $COLOR = $ENV{TEST_KANTAN_COLOR} || -t *STDOUT;
our $CURRENT = our $ROOT = Test::Kantan::Suite->new(root => 1, title => 'Root');
our $STATE;
our $FINISHED;
our $REPORTER;

sub before_each(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('before_each' => $code);
}

sub after_each(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('after_each' => $code);
}

sub describe($&) {
    my ($title, $code) = @_;

    my $suite = Test::Kantan::Suite->new(
        title   => $title,
        parent  => $CURRENT,
    );
    {
        local $CURRENT = $suite;
        $code->();
    }
    $CURRENT->add_suite($suite);
}

sub it($&) {
    my ($title, $code) = @_;

    my $test = Test::Kantan::Test->new(
        title   => $title,
        code    => $code,
    );
    $CURRENT->add_test($test);
}

sub expect {
    Test::Kantan::Expect->new(source => $_[0], reporter => $REPORTER, state => $STATE);
}

sub ok(&) {
    my $code = shift;

    local $@;
    my ($retval, $err, $tap_results, $op_stack)
        = Test::Power::Core->give_me_power($code);
    if ($retval) {
        return 1;
    } else {
        $STATE->failed();
        $REPORTER->message(
            Test::Kantan::Message::Power->new(
                code        => $code,
                err         => $err,
                tap_results => $tap_results,
                op_stack    => $op_stack,
                caller      => Test::Kantan::Caller->new(0),
                color       => $COLOR,
            )
        );
        return 0;
    }
}

sub diag {
    my $msg = shift;
    $REPORTER->message(
        Test::Kantan::Message::Diag->new(
            message => $msg,
            caller  => Test::Kantan::Caller->new(0),
        )
    );
}

sub runtests {
    $FINISHED++;

    return if $ROOT->is_empty;

    local $STATE = Test::Kantan::State->new();
    local $REPORTER = Test::Kantan::Reporter::Spec->new(
        color => $COLOR,
    );
    $REPORTER->start;

    $ROOT->run(reporter => $REPORTER, state => $STATE);

    if (!$STATE->is_passing || $ENV{TEST_KANTAN_VERBOSE}) {
        $REPORTER->finalize(
            state => $STATE
        );
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
            $STATE->failed;
        }
    }
    printf "\n\n%sok\n", $STATE->fail_cnt ? 'not ' : '';
}

END {
    unless ($ROOT->is_empty) {
        unless ($FINISHED) {
            runtests()
        }
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::Kantan - It's new $module

=head1 SYNOPSIS

    use Test::Kantan;

=head1 DESCRIPTION

Test::Kantan is ...

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=cut

