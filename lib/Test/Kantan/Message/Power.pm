package Test::Kantan::Message::Power;
use strict;
use warnings;
use utf8;
use 5.010_001;

use B::Deparse;
use B;

use Moo;

has code => ( is => 'ro', required => 1 );
has tap_results => ( is => 'ro', required => 1 );
has err  => ( is => 'ro', required => 1 );
has caller  => ( is => 'ro', required => 1 );

no Moo;



1;

