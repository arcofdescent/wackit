package APP::Web::Home;
use strict; use warnings;
use base 'APP::Web';

use version; our $VERSION = qv('0.0.1');

use Log::Log4perl;
use Data::Dumper;

##########################################################################
=pod

=head2 RUN MODE - home()

    Description of the sub here

=cut
#############################################################################
sub home : runmode
{
    my $self = shift;

    return $self->tt_process();
}


1;

