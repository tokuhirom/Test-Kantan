package Test::Kantan::UI::Simple;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Exporter);

our @EXPORT = qw(suite step test ok done_testing diag expect cmp_deeply ignore);

our $COLOR = $ENV{TEST_KANTAN_COLOR} || -t *STDOUT;
our $CURRENT = our $ROOT = Test::Kantan::Suite->new(root => 1, title => 'Root');
our $STATE = Test::Kantan::State->new();
our $FINISHED;
our $REPORTER = Test::Kantan::Reporter::Spec->new(
    color => $COLOR,
);
$REPORTER->start;

sub suite($&) {
    my ($title, $code) = @_;

    my $suite = Test::Kantan::Suite->new(
        title   => $title,
        parent  => $CURRENT,
    );
    {
        local $CURRENT = $suite;
        my $guard = $REPORTER->suite($suite);
        $code->();
    }
    $CURRENT->add_suite($suite);
}

sub step($) {
    my ($title) = @_;

    my $test = Test::Kantan::Test->new(
        title   => $title,
        code    => sub { },
    );
}

sub test($&) {
    my ($title, $code) = @_;

    my $test = Test::Kantan::Test->new(
        title   => $title,
        code    => $code,
    );
    $CURRENT->call_before_each_trigger();
    $test->run(
        state => $STATE,
        reporter => $REPORTER,
    );
    $CURRENT->call_after_each_trigger();
    $CURRENT->add_test($test);
}

sub ok {
    if ($_[0]) {
        1;
    } else {
        $STATE->failed();
        $REPORTER->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub expect(&) {
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

sub cmp_deeply {
    if (Test::Deep::eq_deeply(@_)) {
        1;
    } else {
        $STATE->failed();
        $REPORTER->message(
            Test::Kantan::Message::Fail->new(
                caller => Test::Kantan::Caller->new(0),
            )
        );
        0;
    }
}

sub done_testing {
    $FINISHED++;

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

