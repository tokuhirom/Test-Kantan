package Test::Kantan::Reporter::Spec;
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
has state  => (is => 'ro', required => 1);
has messages => (is => 'ro', default => sub { +[] });
has message_stack => (is => 'ro', default => sub { +[[]] });

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
    $self->color ? Term::ANSIColor::colored($color, $msg) : $msg;
}

sub head_sp {
    my ($self) = @_;
    return ' ' x (2+$self->{level}*2);
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
    my ($self, %args) = @_;
    $self->message(Test::Kantan::Message::Fail->new(
        %args
    ));
}

sub pass {
    my ($self, %args) = @_;
    $self->message(Test::Kantan::Message::Pass->new(
        %args
    ));
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
                    (my $moniker = ref($message)) =~ s/.*:://;
                    my $method = "render_message_\L$moniker";
                    my $str = $self->$method($message);
                    $str =~ s/^/      /mg;
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

sub render_message_diag {
    my ($self, $message) = @_;

    my $msg = $self->dump_data($message->message);
    $msg =~ s/\n/\\n/g;
    return sprintf(
        "Diag: %s\n  at %s line %s.\n",
        $self->colored(['magenta on_black'], $self->truncstr($msg, $message->cutoff)),
        $message->caller->filename,
        $message->caller->line
    );
}

sub render_message_fail {
    my ($self, $message) = @_;

    my @ret;
    push @ret, sprintf("%s\n", $self->colored(['red on_black'], $message->caller->code));
    if (defined $message->description) {
        push @ret, sprintf("%s\n", $self->colored(['red on_black'], $message->description));
    }
    push @ret, sprintf("   at %s line %s\n\n", $self->colored(['yellow'], $message->caller->filename), $self->colored(['yellow'], $message->caller->line));
    return join('', @ret);
}

sub render_message_pass {
    my ($self, $message) = @_;
    "Passed: " . $message->caller->code;
}

sub render_message_power {
    my ($self, $message) = @_;

    my @ret;
    push @ret, sprintf("%s: %s\n", $self->colored(['red'], 'FAIL'), $self->colored(['magenta'], $message->caller->code));
    push @ret, sprintf("%s\n", $message->{err}) if $message->{err};
    push @ret, sprintf("  at %s line %s\n", $self->colored(['yellow'], $message->caller->filename), $self->colored(['yellow'], $message->caller->line));
    push @ret, "\n";
    for my $result (@{$message->{tap_results}}) {
        my $op = shift @$result;
        for my $value (@$result) {
            # take first argument if the value is scalar.
            my $deparse = B::Deparse->new();
            $deparse->{curcv} = B::svref_2object($message->{code});

            my $val = $self->truncstr($self->dump_data($value->[1]));
            $val =~ s/\n/\\n/g;
            push @ret, sprintf("%s => %s\n",
                $self->colored(['red on_black'], $deparse->deparse($op)),
                $self->colored(['red on_black'], $val),
            );
        }
    }
    join('', @ret);
}

package Test::Kantan::Reporter::Spec::MessageGroup;

use Moo;

has messages => (is => 'ro');
has titles   => (is => 'ro');

no Moo;

1;

