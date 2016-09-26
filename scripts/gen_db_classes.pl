#!/usr/bin/perl
use strict; use warnings;

use Rose::DB::Object::Loader;

use lib 'lib';
use APP_VAL::DB;

my $loader = Rose::DB::Object::Loader->new(
    db  => APP_VAL::DB->new,
    class_prefix    => 'APP_VAL',
    module_dir  => 'lib',
    with_foreign_keys   => 1,
    with_relationships  => 1,
    #exclude_tables => qr/(raw_match_data|odi_series|odi_info)/,
);

$loader->make_modules;

