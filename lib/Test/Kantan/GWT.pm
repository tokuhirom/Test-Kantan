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

sub _tag {
    my $tag = shift;
    if ($CURRENT->{last_state} && $CURRENT->{last_state} eq $tag) {
        return sprintf("%5s", 'And');
    } else {
        $CURRENT->{last_state} = $tag;
        return sprintf("%5s", $tag);
    }
}

sub setup(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('setup' => $code);
}

sub teardown(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('teardown' => $code);
}

sub Given {
    my ($title, $code) = @_;

    my $guard = $REPORTER->suite(_tag('Given') . ' ' . $title);
    $code->() if $code;
}

sub When {
    my ($title, $code) = @_;

    my $guard = $REPORTER->suite(_tag('When') . ' ' . $title);
    $code->() if $code;
}

sub Then($&) {
    my ($title, $code) = @_;

    my $guard = $REPORTER->suite(_tag('Then') . ' ' . $title);
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
        my $guard = $REPORTER->suite("Feature ${title}");
        $suite->parent->call_trigger('setup');
        $code->();
        $suite->parent->call_trigger('teardown');
    }
    $CURRENT->add_suite($suite);
}

sub Scenario {
    my ($title, $code) = @_;

    my $suite = Test::Kantan::Suite->new(
        title   => $title,
        parent  => $CURRENT,
    );
    {
        local $CURRENT = $suite;
        my $guard = $REPORTER->suite("Scenario ${title}");
        $suite->parent->call_trigger('setup');
        $code->();
        $suite->parent->call_trigger('teardown');
    }
    $CURRENT->add_suite($suite);
}

sub done_testing {
    $FINISHED++;

    return if $ROOT->is_empty;

    $REPORTER->finalize();

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

