#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a11.get.t
#     Abstract:	Test public get() method.
#        Usage:	prove a11.get.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 6;      # Including no-warnings test.
use Test::Exception;
use Test::NoWarnings;
use Error::Grudge;		# What we are testing.

my $ourID = 'myFile.txt';
my $myObj = Error::Grudge->new($ourID);
my $result;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

throws_ok
  { $result = Error::Grudge::->get('attr1') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught being called as a class, not object, method';

throws_ok
  { $myObj->get('attr1') }
  qr/$Error::Grudge::DIAG{FUNC_IN_VOID}/,
  'caught function call in void context';

throws_ok
  { $result = $myObj->get('attrX') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught use of bogus attribute';

my $val = $myObj->get('uoID');
ok(defined($val), 'confirmed returned defined value for required attr');
like($val, qr/$ourID$/,  'confirmed expected value for required attr');

#==[ EOF: a11.get.t ]==
