package Test::Kantan;
use 5.010_001;
use strict;
use warnings;

our $VERSION = "0.23";

use parent qw(Exporter);

use Try::Tiny;

use Test::Kantan::State;
use Test::Kantan::Builder;
use Test::Kantan::Caller;
use Test::Kantan::Suite;
use Test::Kantan::Functions;

our @EXPORT = (
    qw(Feature Scenario Given When Then),
    qw(subtest done_testing setup teardown),
    @Test::Kantan::Functions::EXPORT
);

# If users loaded Test::Builder, suppress it's outputs.
if (Test::Builder->can('new')) {
    Test::Builder->new->no_diag(1);
}

our $BUILDER;
sub builder {
    if (not defined $BUILDER) {
        $BUILDER = Test::Kantan::Builder->new();
    }
    return $BUILDER;
}

# -------------------------------------------------------------------------
# DSL functions

our $CURRENT = our $ROOT = Test::Kantan::Suite->new(root => 1, title => 'Root');
our $FINISHED;
our $RAN_TEST;

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

    my $guard = builder->reporter->suite(sprintf("%5s %s", $tag, $title));
    if ($code) {
        try {
            $code->();
        } catch {
            builder->exception(message => $_);
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
        my $guard = builder->reporter->suite(defined($tag) ? "${tag} ${title}" : $title);
        $suite->parent->call_trigger('setup');
        $code->();
        $suite->parent->call_trigger('teardown');
    }
    $RAN_TEST++;
}

sub Feature  { _suite( 'Feature', @_) }
sub Scenario { _suite('Scenario', @_) }

# Test::More compat
sub subtest  { _suite(     undef, @_) }

# BDD compat
sub describe { _suite(     undef, @_) }
sub context  { _suite(     undef, @_) }
sub it       { _suite(     undef, @_) }

sub done_testing {
    $FINISHED++;

    builder->reporter->finalize();

    # Test::Pretty was loaded
    if (Test::Pretty->can('_subtest')) {
        # Do not run Test::Pretty's finalization
        $Test::Pretty::NO_ENDING=1;
    }
}

END {
    if ($RAN_TEST) {
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

