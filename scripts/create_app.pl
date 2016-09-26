#!/usr/bin/perl
use strict; use warnings;

use FindBin qw/$Bin/;

use lib "$Bin/../lib";
use APP_VAL::Util;

my $app_name = shift;
my $cmd;

if (not $app_name) {
    die "Need app name";
}
        
# Read configuration file
my %config = get_config();

my $base_app_name = $config{app_name};

# Perl modules
my $pm_file = "lib/$base_app_name/Web/$app_name.pm";
if (-e $pm_file) {
    die "$pm_file already exists";
}
$cmd = qq{cp lib/$base_app_name/Web/SampleApp.pm $pm_file};
system $cmd;
$cmd = qq{perl -i -pe 's/BASE_APP_NAME/$base_app_name/g' $pm_file};
system $cmd;
$cmd = qq{perl -i -pe 's/APP_NAME/$app_name/g' $pm_file};
system $cmd;

# template
my $template_dir = "templates/$app_name";
if (-e $template_dir) {
    die "$template_dir already exists";
}
$cmd = qq{mkdir $template_dir};
system $cmd;

my $tmpl_str =<<EOD;

<p>This is the home runmode for app <b>$app_name</b></p>

EOD

if (-e "$template_dir/home.html") {
    die "$template_dir/home.html already exists";
}

open my $WFH, ">" , "$template_dir/home.html" 
    or die "Can't open $template_dir/home.html for writing: $!";
print $WFH $tmpl_str;
close $WFH;

print "\n";
print "Created $pm_file\n";
print "Created $template_dir\n";
print "Created $template_dir/home.html\n";

