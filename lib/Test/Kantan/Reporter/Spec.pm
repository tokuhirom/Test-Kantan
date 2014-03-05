package Test::Kantan::Reporter::Spec;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Term::ANSIColor ();

use parent qw(Test::Kantan::Reporter::Base);

use Class::Accessor::Lite 0.05 (
    rw => [qw(color level cutoff)],
);
use Scope::Guard;

sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    for my $key (qw(color)) {
        unless (exists $args{$key}) {
            Carp::croak("Missing mandatory paramter: $key");
        }
    }
    my $self = bless {
        level => 0,
        cutoff => $ENV{KANTAN_CUTOFF} || 80,
        messages => [],
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
    $self->color ? Term::ANSIColor::colored($color, $msg) : $msg;
}

sub indent {
    my $self = shift;
    $self->{level}++;
    return Scope::Guard->new(
        sub {
            --$self->{level};
        }
    );
}

sub head_sp {
    my ($self) = @_;
    return ' ' x (3+$self->{level}*2);
}

sub step {
    my ($self, $title) = @_;
    printf "%s  + %s\n", $self->head_sp, $title;
}

sub tag_step {
    my ($self, $tag, $title) = @_;
    printf "%s  %5s %s\n", $self->head_sp, $tag, $title;
}

sub suite {
    my ($self, $suite) = @_;

    ++$self->{level};
    print "\n";
    printf "%s%s\n", $self->head_sp, $suite->title;

    return Scope::Guard->new(
        sub {
            --$self->{level};
        }
    );
}

sub fail {
    my ($self, $test) = @_;
    printf("%s  %s  %s\n",
        $self->head_sp,
        $self->colored(['red'], "\x{2716}"),
        $test->title,
    );
}

sub pass {
    my ($self, $test) = @_;
    printf("%s  %s  %s\n",
        $self->head_sp,
        $self->colored(['green'], "\x{2713}"),
        $test->title,
    );
}

sub message {
    my ($self, $message) = @_;
    push @{$self->{messages}}, $message;
}

sub finalize {
    my ($self, %args) = @_;
    my $state = $args{state} or die;

    if (!$state->is_passing || $ENV{TEST_KANTAN_VERBOSE}) {
        if (@{$self->{messages}}) {
            printf "\n\n\n  %s:\n\n", $self->colored(['red'], '(Diagnostic message)');
            for my $message (@{$self->{messages}}) {
                my $str = $message->as_string(reporter => $self);
                $str =~ s/^/      /gm;
                print "\n$str";
            }
        }
    }
}

1;

