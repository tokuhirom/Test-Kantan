package Test::Kantan::GWT;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Exporter);

use Test::Kantan::Functions;
use Test::Kantan;

our @EXPORT = (qw(Given When Then done_testing Feature Scenario setup teardown), @Test::Kantan::Functions::EXPORT);

our $CURRENT = our $ROOT = Test::Kantan::Suite->new(root => 1, title => 'Root');
our $FINISHED;

$STATE = Test::Kantan::State->new();

$REPORTER = Test::Kantan::Reporter::Spec->new(
    color => $COLOR,
);
$REPORTER->start;

sub setup(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('setup' => $code);
}

sub teardown(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('teardown' => $code);
}

sub Given {
    my ($message, $code) = @_;
    $REPORTER->Given($message);
    $code->() if $code;
}

sub When($) {
    my ($message, $code) = @_;
    $REPORTER->When($message);
    $code->() if $code;
}

sub Feature($&) {
    my ($title, $code) = @_;

    my $suite = Test::Kantan::Suite->new(
        title   => $title,
        parent  => $CURRENT,
    );
    {
        local $CURRENT = $suite;
        my $guard = $REPORTER->suite($suite);
        $suite->parent->call_trigger('setup');
        $code->();
        $suite->parent->call_trigger('teardown');
    }
    $CURRENT->add_suite($suite);
}

sub Scenario { goto \&Feature }

sub Then($&) {
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
            done_testing()
        }
    }
}

1;

