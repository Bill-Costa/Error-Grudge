use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Error::Grudge',
    AUTHOR              => 'Bill Costa <Bill.Costa@alumni.unh.edu>',
    VERSION_FROM        => 'lib/Error/Grudge.pm',
    ABSTRACT_FROM       => 'lib/Error/Grudge.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Error-Grudge-*' },
);
