package Test::Kantan::Reporter::TAP;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Term::ANSIColor ();

use parent qw(Test::Kantan::Reporter::Base);

use Moo;

has color => (is => 'ro', required => 1);
has level => (is => 'ro', default => sub { 0 });
has cutoff => (is => 'ro', default => sub { $ENV{TEST_KANTAN_CUTOFF} || 80 });
has count => (is => 'ro', default => sub { 0 });
has state => (is => 'ro', required => 1);

no Moo;

use Scope::Guard;

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
    my ($self, %args) = @_;
    $args{caller} or die;

    my $title = $args{description} || $args{caller}->code || '-';
    $title =~ s/\n/\\n/g;
    $self->{count}++;
    printf("not ok %d - %s\n", $self->count, $title);
    if ($args{diag}) {
        $self->diag(message => $args{diag})
    }
}

sub pass {
    my ($self, %args) = @_;
    my $title = $args{description} || $args{caller}->code || '-';
    $title =~ s/\n/\\n/g;
    $self->{count}++; # TODO: use counter in the state object
    printf("ok %d - %s\n", $self->count, $title);
}

sub message {
    my ($self, $message) = @_;

    (my $moniker = ref($message)) =~ s/.*:://;
    my $method = "render_message_\L$moniker";
    my $str = $self->$method($message);
    $str =~ s/^/# /mg;
    print "$str\n";
}

sub render_message_power {
    my ($self, $message) = @_;
    $message->caller->code;
}

sub diag {
    my ($self, %args) = @_;
    my $message = $args{message} // die;
    my $cutoff = $args{cutoff} || $self->cutoff;
    $message = $self->dump_data($message);
    $message = $self->truncstr($message, $cutoff);
    for my $line (split /\n/, $message) {
        print "# $line\n";
    }
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

