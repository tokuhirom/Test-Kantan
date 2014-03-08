package Test::Kantan::Message::Diag;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has message => ( is => 'ro', required => 1 );
has caller  => ( is => 'ro', required => 1 );
has cutoff  => ( is => 'ro', required => 1 );

no Moo;

1;

