#!/usr/bin/env perl
#
#     File: a00.load.t
#  Summary: Make sure we can at least load the module, or bailout.
#
#  Note that we do not ignore compile-time warnings.

use warnings;
use strict;
use Test::More tests => 2;
use Test::NoWarnings;

BEGIN
{
  use_ok( 'Error::Grudge' )
    or BAIL_OUT("Cannot even load the module under test!");
}

diag( "Testing Error::Grudge $Error::Grudge::VERSION");

#==[ a00.load.t ]==
