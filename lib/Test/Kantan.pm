package Test::Kantan;
use 5.010_001;
use strict;
use warnings;

our $VERSION = "0.08";

use parent qw(Exporter);

use Test::Kantan::State;
use Test::Kantan::Caller;
use Test::Kantan::Test;
use Test::Kantan::Suite;
use Test::Kantan::Reporter::Spec;
use Test::Kantan::Functions;

use Test::Kantan::Message::Power;
use Test::Kantan::Message::Fail;
use Test::Kantan::Message::Diag;

if (Test::Builder->can('new')) {
    Test::Builder->new->no_diag(1);
}

our @EXPORT = qw($COLOR $STATE $REPORTER);

our $COLOR = $ENV{TEST_KANTAN_COLOR} || -t *STDOUT;
our $CURRENT = our $ROOT = Test::Kantan::Suite->new(root => 1, title => 'Root');
our $FINISHED;
our $STATE = Test::Kantan::State->new();
our $REPORTER = Test::Kantan::Reporter::Spec->new(
    color => $COLOR,
);
$REPORTER->start;

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

