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
}

sub setup(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('setup' => $code);
}

sub teardown(&) {
    my ($code) = @_;
    $CURRENT->add_trigger('teardown' => $code);
}

sub _step {
    my ($tag, $title, $code) = @_;

    if ($CURRENT->{last_state} && $CURRENT->{last_state} eq $tag) {
        $tag = 'And';
    }
    $CURRENT->{last_state} = $tag;

    my $guard = $REPORTER->suite(sprintf("%5s %s", $tag, $title));
    $code->() if $code;
}

sub Given { _step('Given', @_) }
sub When  { _step('When', @_) }
sub Then  { _step('Then', @_) }

sub _suite {
    my ($tag, $title, $code) = @_;

    my $suite = Test::Kantan::Suite->new(
        title   => $title,
        parent  => $CURRENT,
    );
    {
        local $CURRENT = $suite;
        my $guard = $REPORTER->suite("${tag} ${title}");
        $suite->parent->call_trigger('setup');
        $code->();
        $suite->parent->call_trigger('teardown');
    }
    $CURRENT->add_suite($suite);
}

sub Feature  { _suite('Feature',  @_) }
sub Scenario { _suite('Scenario', @_) }

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

