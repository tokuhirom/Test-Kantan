package Test::Kantan::Reporter::TAP;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Term::ANSIColor ();

use parent qw(Test::Kantan::Reporter::Base);

use Class::Accessor::Lite 0.05 (
    rw => [qw(color level cutoff count state)],
);
use Scope::Guard;

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    for my $key (qw(color state)) {
        unless (exists $args{$key}) {
            Carp::croak("Missing mandatory paramter: $key");
        }
    }
    my $self = bless {
        level => 0,
        cutoff => $ENV{KANTAN_CUTOFF} || 80,
        count => 0,
        %args
    }, $class;
    return $self;
}

sub start {
    my $encoding = do {
        require Term::Encoding;
        Term::Encoding::get_encoding();
    };

    binmode *STDOUT, ":encoding(${encoding})";
    STDOUT->autoflush(1);

    print "\n\n";
}

sub colored {
    my ($self, $color, $msg) = @_;
    $msg;
}

sub step {
    my ($self, $title) = @_;
    $title =~ s/\n/\\n/g;
    printf "# STEP %s\n", $title;
}

sub tag_step {
    my ($self, $tag, $title) = @_;
    $tag =~ s/\n/\\n/g;
    $title =~ s/\n/\\n/g;
    printf "# %5s %s\n", $tag, $title;
}

sub suite {
    my ($self, $title) = @_;
    push @{$self->{suite}}, $title;
    printf "# %s\n", join('/', @{$self->{suite}});
    return Scope::Guard->new(
        sub {
            pop @{$self->{suite}};
        }
    );
}

sub fail {
    my ($self, $test) = @_;
    my $title = $test->title;
    $title =~ s/\n/\\n/g;
    $self->{count}++;
    printf("not ok %d - %s\n", $self->count, $title);
}

sub pass {
    my ($self, $test) = @_;
    my $title = $test->title;
    $title =~ s/\n/\\n/g;
    $self->{count}++;
    printf("ok %d - %s\n", $self->count, $title);
}

sub message {
    my ($self, $message) = @_;
    my $str = $message->as_string(reporter => $self);
    $str =~ s/^/# /mg;
    print "$str\n";
}

sub exception {
    my ($self, $exception) = @_;
    printf "Exception: %s\n", $self->truncstr($self->dump_data($exception));
}

sub finalize {
    my ($self, %args) = @_;

    # If Test::Builder was loaded...
    if (Test::Builder->can('new')) {
        if (!Test::Builder->new->is_passing) {
            $self->state->failed;
            printf "not ok - %s\n", 'Test::Builder was failed';
        }
    }

    printf "1..%d\n", $self->count;
}

1;

