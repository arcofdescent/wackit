package APP::Util;
use strict;
use warnings;

use version; our $VERSION = qv('0.8');

use MIME::Lite;
use Date::Manip;
use Data::Dumper;
use File::Slurp;
use Readonly;
use Config::General;

use Exporter();
our @ISA = qw(Exporter);

# export these symbols by default
our @EXPORT = (
    qw/
        get_config
        get_random_int
        get_datetime
        strip_html
        gen_random_password
        send_email
        /
);

# only export if asked for
our @EXPORT_OK = (
    qw/

        /
);

Readonly my $BASE_DIR => 'BASE_DIR_VAL';
Readonly my $CONFIG_FILE => "$BASE_DIR/conf/LC_APP.conf";

### INSTANCE METHOD ###########################################
# Usage      : %config = get_config();
# Purpose    : Return config hash
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub get_config 
{
    my $tmp = $/;
    $/ = "\n";
    my $c = Config::General->new(
        -ConfigFile      => $CONFIG_FILE,
        -LowerCaseNames  => 1,
        -AutoTrue        => 1,
        -StrictVars      => 1,
        -InterPolateVars => 1,
    );

    my %config = $c->getall();
    $/ = $tmp;
    return %config;
}


### CLASS METHOD/INSTANCE METHOD/INTERFACE SUB/INTERNAL UTILITY ###
# Usage      : ????
# Purpose    : ????
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub get_random_int
{
    my ( $min, $max ) = @_;

    return $min if $min == $max;
    ( $min, $max ) = ( $max, $min ) if $min > $max;
    return $min + int rand( 1 + $max - $min );
}


### INTERFACE SUB #################################################
# Usage      : get_datetime();
# Purpose    : ????
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub get_datetime
{
    return UnixDate( ParseDate('now'), "%Y-%m-%d %H:%M:%S" );
}

### INTERFACE SUB ####################################################
# Usage      : strip_html($html_str);
# Purpose    : ????
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub strip_html
{
    my $text = shift;

    $text =~ s{<(.*) .*>(.*)</\1>}{$2};

    return $text;
}


### INTERFACE SUB #################################################
# Usage      : my $passwd = gen_random_password();
# Purpose    : Generate a random password
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub gen_random_password
{
    my @chars = qw/a b c d e f g h i j k l m n p
        q r s t u v w x y z A B C D E F G H I J K L
        M N P Q R S T U V W X Y Z
        1 2 3 4 5 6 7 8 9
        /;

    my $password;

    for ( 0 .. 7 )
    {
        my $random_int = get_random_int( 1, 55 );
        $password .= $chars[$random_int];
    }

    return $password;
} # end sub gen_random_password

### INTERFACE SUB ###################################################
# Usage      :
#
#   send_email(
#       smtp_server => '127.0.0.1',
#       from => $from,
#       to => $to,
#       cc => $cc, (optional)
#       bcc => $bcc, (optional)
#       subject => $subject,
#       html_part = $html,
#       text_part => $text,
#   );
#
# Purpose    : Send email with HTML
# Returns    : 1 on success
# Parameters :
#
#   to => Comma separated list of email addresses
#   cc => Comma separated list of email addresses
#   bcc => Comma separated list of email addresses
#
# Throws     : dies on SMTP error
# Comments   :
# See Also   : n/a
####################################################################
sub send_email
{
    my %args = @_;

    my @mime_lite_args = (
        From    => $args{'from'},
        To      => $args{'to'},
        Subject => $args{'subject'},
        Type    => 'multipart/related',
    );

    if ( exists $args{'cc'} )
    {
        push @mime_lite_args, Cc => $args{'cc'};
    }
    if ( exists $args{'bcc'} )
    {
        push @mime_lite_args, Bcc => $args{'bcc'};
    }

    # Create a multipart message
    my $msg = MIME::Lite->new(@mime_lite_args);

    # Add HTML part
    if ( exists $args{html_part} )
    {
        $msg->attach(
            Type => 'text/html',
            Data => $args{'html_part'},
        );
    }

    # Add text part
    $msg->attach(
        Type => 'TEXT',
        Data => $args{'text_part'},
    );

    # Send the message
    $msg->send_by_smtp( $args{'smtp_server'} );

    return 1;
} # end sub send_email


1;

=pod

=head1 NAME
 
<Module::Name> - <One line description of module's purpose>
 
 
=head1 VERSION
 
This documentation refers to <Module::Name> version 0.0.1
 
 
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
 
=head2 B<method_name()>

=head3 Description

=over 4

Brief description of the method.

=back

=head3 Usage

=over 4

my $ret = $obj->method_name(
    @params,
);

=back

=head3 Parameters

=over 4

1) param1 - param 1

=back

=head3 Returns
 
=over 4

$ret

=back


 
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

Rohan Almeida <almeida@aarohan.biz>

 
=head1 LICENCE AND COPYRIGHT
 
Copyright (c) 2008 Aarohan Technologies <services@aarohan.biz> 
All rights reserved.

