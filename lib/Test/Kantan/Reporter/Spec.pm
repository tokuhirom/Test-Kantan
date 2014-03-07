package Test::Kantan::Reporter::Spec;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Term::ANSIColor ();

use parent qw(Test::Kantan::Reporter::Base);

use Class::Accessor::Lite 0.05 (
    rw => [qw(color level cutoff state)],
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

sub head_sp {
    my ($self) = @_;
    return ' ' x (2+$self->{level}*2);
}

sub step {
    my ($self, $title) = @_;
    printf "%s+ %s\n", $self->head_sp, $title;
}

sub tag_step {
    my ($self, $tag, $title) = @_;
    printf "%s%5s %s\n", $self->head_sp, $tag, $title;
}

sub suite {
    my ($self, $title) = @_;

    print "\n" if $self->{level} <= 1;
    printf "%s%s\n", $self->head_sp, $title;

    push @{$self->{message_stack}}, [];
    push @{$self->{fail_stack}}, $self->state->fail_cnt;
    push @{$self->{title}}, $title;
    $self->{level}++;
    return Scope::Guard->new(
        sub {
            my $orig_fail_cnt = pop @{$self->{fail_stack}};
            my $messages = pop @{$self->{message_stack}};
            my $titles = [@{$self->{title}}];
            if ($orig_fail_cnt != $self->state->fail_cnt && @$messages) {
                push @{$self->{message_groups}}, Test::Kantan::Reporter::Spec::MessageGroup->new(
                    titles => $titles,
                    messages => $messages,
                );
            }

            pop @{$self->{title}};

            --$self->{level};
        }
    );
}

sub fail {
    my ($self, $title) = @_;
    printf("%s%s  %s\n",
        $self->head_sp,
        $self->colored(['red'], "\x{2716}"),
        $title,
    );
}

sub pass {
    my ($self, $title) = @_;
    printf("%s%s  %s\n",
        $self->head_sp,
        $self->colored(['green'], "\x{2713}"),
        $title,
    );
}

sub message {
    my ($self, $message) = @_;
    push @{$self->{message_stack}->[-1]}, $message;
}

sub exception {
    my ($self, $exception) = @_;
    printf "Exception: %s\n", $self->truncstr($self->dump_data($exception));
}

sub diag {
    my ($self, %args) = @_;

    $self->message(Test::Kantan::Message::Diag->new(
        %args
    ));
}

sub finalize {
    my ($self, %args) = @_;

    if (!$self->state->is_passing || $ENV{TEST_KANTAN_VERBOSE}) {
        if (@{$self->{message_groups}}) {
            printf "\n\n\n  %s:\n", $self->colored(['red'], '(Diagnostic message)');
            for my $message_group (@{$self->{message_groups}}) {
                printf "\n    %s:\n", join(' → ', map { $self->colored(['green'], $_) } @{$message_group->titles});
                for my $message (@{$message_group->messages}) {
                    my $str = $message->as_string(reporter => $self);
                    $str =~ s/^/      /gm;
                    print "\n$str";
                }
            }
        }
    }

    # If Test::Builder was loaded...
    if (Test::Builder->can('new')) {
        if (!Test::Builder->new->is_passing) {
            # Fail if Test::Builder was failed.
            $self->state->failed;
        }
    }

    printf "\n\n%sok\n", $self->state->fail_cnt ? 'not ' : '';
}

package Test::Kantan::Reporter::Spec::MessageGroup;

use Class::Accessor::Lite 0.05 (
    rw => [qw(messages titles)],
    new => 1,
);

1;

