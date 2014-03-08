package Test::Kantan::Message::Fail;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Moo;

has description => ( is => 'ro', required => 0 );
has caller  => ( is => 'ro', required => 1 );

no Moo;

1;
