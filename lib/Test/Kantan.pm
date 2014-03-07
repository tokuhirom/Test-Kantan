package Test::Kantan;
use 5.010_001;
use strict;
use warnings;

our $VERSION = "0.18";

use parent qw(Exporter);

use Module::Load;

use Test::Kantan::State;
use Test::Kantan::Caller;
use Test::Kantan::Suite;
use Test::Kantan::Reporter::Spec;
use Test::Kantan::Functions;

use Test::Kantan::Message::Power;
use Test::Kantan::Message::Fail;
use Test::Kantan::Message::Diag;

if (Test::Builder->can('new')) {
    Test::Builder->new->no_diag(1);
}

our @EXPORT = (qw($COLOR $STATE $REPORTER Given When Then subtest done_testing Feature Scenario setup teardown), @Test::Kantan::Functions::EXPORT);

our $COLOR = $ENV{TEST_KANTAN_COLOR} || -t *STDOUT;
our $STATE = Test::Kantan::State->new();

my $reporter_class = do {
    my $s = $ENV{TEST_KANTAN_REPORTER} || 'Spec';
    my $klass = ($s =~ s/\A\+// ? $s : "Test::Kantan::Reporter::${s}");
    Module::Load::load $klass;
    $klass;
};
our $REPORTER = $reporter_class->new(
    color => $COLOR,
    state => $STATE,
);
$REPORTER->start;

use Test::Kantan::Functions;
use Test::Kantan;
use Try::Tiny;


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

    my $last_state = $CURRENT->{last_state};
    $CURRENT->{last_state} = $tag;
    if ($last_state && $last_state eq $tag) {
        $tag = 'And';
    }

    my $guard = $REPORTER->suite(sprintf("%5s %s", $tag, $title));
    if ($code) {
        try {
            $code->();
        } catch {
            $REPORTER->exception($_);
        };
    }
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
        my $guard = $REPORTER->suite(defined($tag) ? "${tag} ${title}" : $title);
        $suite->parent->call_trigger('setup');
        $code->();
        $suite->parent->call_trigger('teardown');
    }
    $CURRENT->add_suite($suite);
}

sub Feature  { _suite( 'Feature', @_) }
sub Scenario { _suite('Scenario', @_) }
sub subtest  { _suite(     undef, @_) }

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

