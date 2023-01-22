use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Error::Grudge',
    license             => 'mit',
    dist_author         => 'Bill Costa <Bill.Costa@alumni.unh.edu>',
    dist_version_from   => 'lib/Error/Grudge.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Error-Grudge-*' ],
);

$builder->create_build_script();
