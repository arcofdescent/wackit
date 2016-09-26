#!/usr/bin/perl
use strict; use warnings;

use Cwd;

my $app_name = shift;
if (!defined $app_name) {
    die "need app name";
}
        
my $base_dir = getcwd;
my $cmd;
my $lc_app_name = lc $app_name;

# app and web directories
$cmd = qq{mkdir lib/$app_name};
system $cmd;
$cmd = qq{mkdir lib/$app_name/Web};
system $cmd;

# lib/Wackit
$cmd = qq{cp lib/Wackit/Wackit.pm lib/$app_name/Web.pm};
system $cmd;
$cmd = qq{perl -i -pe 's/APP/$app_name/g' lib/$app_name/Web.pm};
system $cmd;
$cmd = qq{cp lib/Wackit/Form.pm lib/$app_name/Web/};
system $cmd;
$cmd = qq{cp lib/Wackit/SampleApp.pm lib/$app_name/Web/};
system $cmd;

# home web class for the app
$cmd = qq{cp lib/Wackit/MyApp.pm lib/$app_name/Web/Home.pm};
system $cmd;
$cmd = qq{perl -i -pe 's/APP/$app_name/g' lib/$app_name/Web/Home.pm};
system $cmd;
$cmd = qq{mkdir templates/Home};
system $cmd;
$cmd = qq{cp templates/home.html templates/Home/};
system $cmd;

# web dispatch class for the app
$cmd = qq{cp lib/Wackit/Dispatch.pm lib/$app_name/Web/Dispatch.pm};
system $cmd;
$cmd = qq{perl -i -pe 's/APP/$app_name/g' lib/$app_name/Web/Dispatch.pm};
system $cmd;

# DB
$cmd = qq{cp lib/Wackit/DB.pm lib/$app_name/DB.pm};
system $cmd;
$cmd = qq{perl -i -pe 's/APP/$app_name/g' lib/$app_name/DB.pm};
system $cmd;

# Util.pm
$cmd = qq{cp lib/Wackit/Util.pm lib/$app_name/Util.pm};
system $cmd;
$cmd = qq{perl -i -pe 's/LC_APP/$lc_app_name/g' lib/$app_name/Util.pm};
system $cmd;
$cmd = qq{perl -i -pe 's/APP/$app_name/g' lib/$app_name/Util.pm};
system $cmd;
$cmd = qq{perl -i -pe 's{BASE_DIR_VAL}{$base_dir}g' lib/$app_name/Util.pm};
system $cmd;

# app.conf
$cmd = qq{cp lib/Wackit/wackit.conf conf/$lc_app_name.conf};
system $cmd;
$cmd = qq{perl -i -pe 's{BASE_DIR_VAL}{$base_dir}g' conf/$lc_app_name.conf};
system $cmd;
$cmd = qq{perl -i -pe 's/APP_VAL/$app_name/g' conf/$lc_app_name.conf};
system $cmd;

# logger.conf
$cmd = qq{perl -i -pe 's/APP/$app_name/g' conf/logger.conf};
system $cmd;
$cmd = qq{perl -i -pe 's{BASE_DIR_VAL}{$base_dir}g' conf/logger.conf};
system $cmd;

# create_app.pl
$cmd = qq{perl -i -pe 's/APP_VAL/$app_name/g' scripts/create_app.pl};
system $cmd;

# gen_db_classes.pl
$cmd = qq{perl -i -pe 's/APP_VAL/$app_name/g' scripts/gen_db_classes.pl};
system $cmd;

# mod_perl_startup.pl
$cmd = qq{perl -i -pe 's{BASE_DIR_VAL}{$base_dir}g' scripts/mod_perl_startup.pl};
system $cmd;

# app.css
$cmd = qq{touch www/stylesheets/$lc_app_name.css};
system $cmd;
$cmd = qq{perl -i -pe 's/APP/$lc_app_name/g' templates/site.html};
system $cmd;



$cmd = qq{rm -rf lib/Wackit};
system $cmd;

$cmd = q{./scripts/setup.sh};
system $cmd;

