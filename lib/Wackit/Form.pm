package APP::Web::Form;
use strict; use warnings;
use base qw/Class::Accessor/;

use version; our $VERSION = qv('0.2');

use Log::Log4perl;
use Data::FormValidator;
use HTML::FillInForm;
use Data::Dumper;


__PACKAGE__->mk_accessors(qw/
    query
    val_profile
    results
    success
/);

=head1 SYNOPSIS
 
    # in Web/User.pm

    sub register : runmode 
    {
        my $self = shift;

        my $logger = Log::Log4perl->get_logger(__PACKAGE__);

        # create validation profile for the form
        my $val_profile = {
            required => [qw/
                first_name password password_cnf email
            /],
            msgs => {
                any_errors  => 'some_errors',
                prefix      => undef,
                format      => '%s',
            },
        };
        my $user_form = Wackit::Form->new({
            query   => $self->query,
            val_profile => $val_profile,
        });

        # addditional constraints
        $user_form->add_to_val_profile({
            field   => 'password',
            min_length => 6,
            max_length => 10,
        });
        $user_form->add_to_val_profile({
            field   => 'password_cnf',
            same_as => 'password',
        });
        $user_form->add_to_val_profile({
            field   => 'email',
            custom_checks => [
                {
                    check => $self->check_email,
                    msg   => 'Invaid email',
                },  
            ],
        });

        $self->tt_params(form => $user_form);

        unless ($user_form->validate() eq 'ok') {
            return $user_form->fif($self->tt_process);
        }

        if ($user_form->success) {
            # form validated
            my $results = $user_form->results;
            $logger->debug("results " . Dumper($results));

            #$self->rs('User')->create();
            return "user registered!";
        }
        return $self->tt_process();
    }


=cut




##########################################################################
=pod

=head2 SUB/METHOD NAME GOES HERE

    Description of the sub here

=cut
#############################################################################
sub validate 
{
    my $self = shift;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);

    # is this a submit?
    if (not defined $self->query->param('submit')) {
        $logger->info('form not submitted yet');
        return 'ok';
    }

    $logger->info('form submitted');
    $logger->info('val_profile: ' . Dumper($self->val_profile));

    my $results = Data::FormValidator->check( $self->query, $self->val_profile );
    $self->results($results);

    unless ($results->has_invalid or $results->has_missing) {
        $logger->info('form validated successfully');
        $self->success(1);
        my $res_ref = $results->valid;
        $self->results($res_ref);

        return 'ok';
    }

    $logger->info('form is invalid');
    return 'not ok';
}

sub fif 
{
    my ($self, $html) = @_;

    return HTML::FillInForm->fill($html, $self->query);

}

##########################################################################
=pod

=head2 add_to_val_profile()

    This adds a constraint method to a field

=cut
#############################################################################
sub add_to_val_profile 
{
    my ($self, $args_ref) = @_;

    my $field       = $args_ref->{field};
    my $val_profile = $self->val_profile;
    $val_profile->{constraint_methods}{$field}
        = $self->_check_field($args_ref);
}



##########################################################################
=pod

=head2 _check_field()

    Description of the sub here

=cut
#############################################################################
sub _check_field 
{
    my ($self, $args_ref) = @_;

    my $field       = $args_ref->{field};
    my $val_profile = $self->val_profile;

    return sub {
        my $dfv = shift;

        $dfv->name_this($dfv->get_current_constraint_field);
        my $val = $dfv->get_current_constraint_value();

        if (exists $args_ref->{min_length}) {
            if (length $val < $args_ref->{min_length}) {
                $val_profile->{msgs}{constraints}{$field}
                    = 'Should contain a minimum of '
                    . $args_ref->{min_length}
                    . ' characters';
                return 0;
            }
        }

        if (exists $args_ref->{max_length}) {
            if (length $val > $args_ref->{max_length}) {
                $val_profile->{msgs}{constraints}{$field}
                    = 'Should contain not more than '
                    . $args_ref->{max_length}
                    . ' characters';
                return 0;
            }
        }

        if (exists $args_ref->{same_as}) {
            my $input = $dfv->get_input_data();

            if ($val ne $input->param($args_ref->{same_as})) {
                $val_profile->{msgs}{constraints}{$field}
                    = 'Should be same as ' . $args_ref->{same_as};
                return 0;
            }
        }

        if (exists $args_ref->{custom_checks}) {
            for my $c (@{ $args_ref->{custom_checks} }) {
                if (not $c->{check}($val)) {
                    $val_profile->{msgs}{constraints}{$field}
                        = $c->{msg};
                    return 0;
                }
            }
        }

        return 1;
    }
}

1;

