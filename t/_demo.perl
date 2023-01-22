#!/usr/bin/env perl
#
#     File: demo.t
#  Summary: Optional demonstration file that is not a formal regression test.

use warnings;
use strict;
use Test::More tests => 1;
use Test::NoWarnings;
use Error::Grudge;

my $obj = Error::Grudge->new('some-required-value');
diag("\nInitial object state:\n", $obj->toString(), "\n");

#==[ demo.t ]==
