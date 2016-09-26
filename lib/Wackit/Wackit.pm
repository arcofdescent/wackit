package APP::Web;
use strict; use warnings;
use base 'CGI::Application';

###########################################################
# Base Class
###########################################################

use version; our $VERSION = qv('0.1');

use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::AutoRunmode;

use APP::Web::Form;
use Log::Log4perl;
use Data::Dumper;
use APP::Util;

### INSTANCE METHOD #####################################################
# Usage      : $self->cgiapp_init();
# Purpose    : Initialization is done here
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub cgiapp_init
{
    my ($self) = @_;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);
    $logger->info('----------- START REQUEST ---------');
    $logger->info('PATH INFO: ' . $self->query->path_info());

    # Set config
    $self->{'_config'} = $self->param('config');

    # configure Template module
    $self->tt_config(
        TEMPLATE_OPTIONS => {
            INCLUDE_PATH    => $self->config->{'template_dir'},
            PRE_CHOMP       => 1,
        },
        TEMPLATE_NAME_GENERATOR => \&wackit_tt_name,
    );

    # Configure session
    $self->session_config(
        CGI_SESSION_OPTIONS => [
            "driver:File",
            $self->query,
            { Directory => $self->config->{'session_dir'}, }
        ],
        COOKIE_PARAMS => {
           -expires     => '+5d', # expires in 5 days
        },
        SEND_COOKIE         => 1,
    );
}

### INSTANCE METHOD ##################################################
# Usage      : $obj->setup()
# Purpose    : Setup the Application run modes
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
######################################################################
sub setup
{
    my ($self) = @_;

    $self->mode_param('mode');
    $self->error_mode('handle_error');

    # Configure the authentication module
    $self->authen->config(
        DRIVER  => [ 'Generic', { user => 'pass' } ],
        STORE   => 'Session',
        #LOGIN_RUNMODE => 'login_form',
        #POST_LOGIN_RUNMODE => 'home',
        CREDENTIALS => [ 'authen_username', 'authen_password' ],
    );
    
}   



### INSTANCE METHOD ################################################
# Usage      : $self->cgiapp_prerun();
# Purpose    : This method is called just before the run mode executes
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub cgiapp_prerun
{
    my ($self) = @_;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);

    # Log current run mode
    my $rm = $self->get_current_runmode();
    $logger->info("Run mode: $rm");
}


### INSTANCE METHOD #####################################################
# Usage      : $self->cgiapp_postrun()
# Purpose    : Called just after each run mode method completes but
#            : before the HTTP headers and content are sent
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub cgiapp_postrun
{
    my ($self, $output_ref) = @_;
    
    my $site_output = $self->tt_process( 'site.html', { content => $$output_ref} );

    $$output_ref = $$site_output;
}

### INSTANCE METHOD ###################################################
# Usage      : $self->teardown();
# Purpose    : This is the last method called. Do cleanup stuff here.
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub teardown
{
    my ($self) = @_;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);

    $logger->info("----------- END REQUEST --------------");
}


### INSTANCE METHOD #################################################
# Usage      : my $config_ref = $self->config();
# Purpose    : Returns config hash (Config::General)
# Returns    : $config_ref => hashref of config values
# Parameters : None
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub config
{
    my $self = shift;

    if (not defined $self->{'_config'}) {
        die "config not set";
    }

    return $self->{'_config'}
}


### INSTANCE METHOD ##################################################
# Usage      : $self->handle_error();
# Purpose    : Show CGI::Application errors
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub handle_error
{
    my ($self, $err_str) = @_;

    return "ERROR: $err_str";
}


### INSTANCE METHOD ################################################
# Usage      : my $tt_name = wackit_tt_name();
# Purpose    : Generate template file name
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub wackit_tt_name
{
    my $self = shift;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);

    # Get the calling app
    my $app = caller 2;

    # Remove base app name
    $app =~ s/^APP::Web(::)?//;

    # get the directory
    $app =~ s/:/\//;

    # if not base app then add a trailing slash
    if ($app ne q{}) {
        $app .= '/';
    }
    $logger->debug("calling app is $app");


    my $current_run_mode = $self->get_current_runmode();
    return $app . $current_run_mode . ".html";
}

1;

=pod

=head1 NAME
 
Wackit - Base class for Wackit
 
 
=head1 VERSION
 
This documentation refers to Wackit version 0.8
 
 
=head1 SYNOPSIS
 
    use <Module::Name>;
    # Brief but working code example(s) here showing the most common usage(s)
  
  
=head1 DESCRIPTION
 
A full description of the module and its features.
 
 
=head1 SUBROUTINES/METHODS 
 
A separate section listing the public components of the module's interface. 
These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module provides.
Name the section accordingly.
 
In an object-oriented module, this section should begin with a sentence of the 
form "An object of this class represents...", to give the reader a high-level
context to help them understand the methods that are subsequently described.
 
 
=head1 DIAGNOSTICS
 
A list of every error and warning message that the module can generate
(even the ones that will "never happen"), with a full explanation of each 
problem, one or more likely causes, and any suggested remedies.
 
 
=head1 CONFIGURATION AND ENVIRONMENT
 
A full explanation of any configuration system(s) used by the module,
including the names and locations of any configuration files, and the
meaning of any environment variables or properties that can be set. These
descriptions must also include details of any configuration language used.
 
 
=head1 DEPENDENCIES
 
A list of all the other modules that this module relies upon, including any
restrictions on versions, and an indication whether these required modules are
part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.
 
 
=head1 INCOMPATIBILITIES
 
A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for 
system or program resources, or due to internal limitations of Perl 
(for example, many modules that use source code filters are mutually 
incompatible).
 
 
=head1 BUGS AND LIMITATIONS
 
There are no known bugs in this module. 
 
=head1 AUTHOR
 
Rohan Almeida  <rohan@almeida.in>
 
 
=head1 LICENCE AND COPYRIGHT
 
Copyright (C) 2006 by Rohan Almeida <rohan@almeida.in>

This module is free software; you can redistribute it and/or modify it under
the terms of either:

a) the GNU General Public License

or

b) the "Artistic License"

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See either the GNU General Public License or the
Artistic License for more details.


