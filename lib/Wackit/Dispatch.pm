package APP::Web::Dispatch;
use strict;
use warnings;
use base 'CGI::Application::Dispatch';

use version; our $VERSION = qv('0.0.1');

use Readonly;
use Log::Log4perl;
use APP::Util;

sub dispatch_args
{
    my %config = get_config();

    # Initialize Logging system
    Log::Log4perl->init_once( $config{log_config} );

    return {
        args_to_new => { PARAMS => { config => \%config, }, },
        table       => [
            ''          => { app    => 'APP::Web::Home', rm => 'home', },
            '/:app'     => { prefix => 'APP::Web', rm => 'home', },
            '/:app/:rm' => { prefix => 'APP::Web', },
        ],
    };
} # end sub dispatch_args

1;

