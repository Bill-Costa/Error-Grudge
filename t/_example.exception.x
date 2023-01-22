#!/usr/bin/env perl
# -*- cperl -*-
#
#        File:  Lib/t/TellUser/a04-assert.t
#    Abstract:  Unit test for ImgWorkFlow::assert() service.
#       Usage:  ./a04-exception.t
#               prove a04-assert.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 6;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
#use FindBin;
#use lib $FindBin::Bin . '/../../../../';
#use lib $FindBin::Bin . '/../../../';
use Error::Grudge;  # What we are testing.

#---------------------------------------+
# Test logic error exceptions.          |
#---------------------------------------+

throws_ok
  { my $obj = Error::Grudge::assert(undef()) }
  qr/\(no message\)/,
  'undef is a failed assertion';

throws_ok
  { my $obj = Error::Grudge::assert('') }
  qr/\(no message\)/,
  "an empty string ('') is a failed assertion";

throws_ok
  { my $obj = Error::Grudge::assert(0) }
  qr/\(no message\)/,
  'explicit false (0) is a failed assertion';

throws_ok
  { my $obj = Error::Grudge::assert(0, 'foo', 'bar', 'bat') }
  qr/bat/m,
  'last message lines was emitted';

ok(Error::Grudge::assert(1), "even if no message, assert(1) returns true");

#==[ EOF: a04-assert.t ]==
