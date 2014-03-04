package Test::Kantan;
use 5.010_001;
use strict;
use warnings;

our $VERSION = "0.01";

use Test::Deep::NoTest qw(ignore);

use Test::Kantan::State;
use Test::Kantan::Caller;
use Test::Kantan::Test;
use Test::Kantan::Suite;
use Test::Kantan::Reporter::Spec;

use Test::Kantan::Message::Power;
use Test::Kantan::Message::Fail;
use Test::Kantan::Message::Diag;

# Alias.
sub import {
    my $class = shift;
    my %args = @_;

    require Test::Kantan::UI::Simple;
    Test::Kantan::UI::Simple->export_to_level(1);
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

