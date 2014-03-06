package Test::Kantan::Simple;
use strict;
use warnings;
use utf8;
use 5.010_001;

use parent qw(Exporter);

use Test::Kantan::Functions;
use Test::Kantan;

our @EXPORT = (qw(suite step test done_testing setup teardown), @Test::Kantan::Functions::EXPORT);

our $CURRENT = our $ROOT = Test::Kantan::Suite->new(root => 1, title => 'Root');
our $FINISHED;

sub setup(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('setup' => $code);
}

sub teardown(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('teardown' => $code);
}

sub step($) {
    my $message = shift;
    $REPORTER->step($message);
}

sub suite($&) {
    my ($title, $code) = @_;

    my $suite = Test::Kantan::Suite->new(
        title   => $title,
        parent  => $CURRENT,
    );
    {
        local $CURRENT = $suite;
        my $guard = $REPORTER->suite($suite);
        $suite->call_trigger('setup');
        $code->();
        $suite->call_trigger('teardown');
    }
    $CURRENT->add_suite($suite);
}

sub test($&) {
    my ($title, $code) = @_;

    my $test = Test::Kantan::Test->new(
        title   => $title,
        code    => $code,
    );
    $test->run(state => $STATE, reporter => $REPORTER);
    $CURRENT->add_test($test);
}

sub done_testing {
    $FINISHED++;

    return if $ROOT->is_empty;

    $REPORTER->finalize(
        state => $STATE
    );

    # Test::Pretty was loaded
    if (Test::Pretty->can('_subtest')) {
        # Do not run Test::Pretty's finalization
        $Test::Pretty::NO_ENDING=1;
    }
}

END {
    unless ($ROOT->is_empty) {
        unless ($FINISHED) {
            done_testing()
        }
    }
}

1;
