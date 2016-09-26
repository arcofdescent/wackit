package APP::DB;
use base qw(Rose::DB);

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db(
    driver   => 'mysql',
    database => 'impact_index',
    host     => 'localhost',
    username => 'ii',
    password => 'ii7890',
);

1;

