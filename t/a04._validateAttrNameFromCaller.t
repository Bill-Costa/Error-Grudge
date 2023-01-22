#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a04._validateAttrNameFromCaller.t
#     Abstract:	Confirm attribute's spelling and existance.
#        Usage:	prove a04._validateAttrNameFromCaller.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 9;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $nxtObj = Error::Grudge->new('myfile.txt');

throws_ok
  { $nxtObj->_validateAttrNameFromCaller() }
  qr/Too few arguments for subroutine/,
  'method call, but caught missing required parameter $attr';

throws_ok
  { Error::Grudge::_validateAttrNameFromCaller('attr1') }
  qr/Too few arguments for subroutine/,
  'invalid function call caught as missing required parameter $attr';

throws_ok
  { Error::Grudge::_validateAttrNameFromCaller('attr1','value') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'invalid function call caught despite correct parameter count';

throws_ok
  { $nxtObj->_validateAttrNameFromCaller('') }
  qr/$Error::Grudge::DIAG{MISSING_ATTR}/,
  'caught empty string as attribute name';

throws_ok
  { $nxtObj->_validateAttrNameFromCaller(\'attr1') }
  qr/$Error::Grudge::DIAG{NOT_ATTR_NAME}/,
  'caught passing a non-string as attribute name';

throws_ok
  { $nxtObj->_validateAttrNameFromCaller('fred') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught passing an unrecognized attribute name';

throws_ok
  { $nxtObj->_validateAttrNameFromCaller('_prv2') }
  qr/$Error::Grudge::DIAG{IS_PRIVATE}/,
  'caught asking for private attribute';

#---------------------------------------+
# Finally, one that works.		|
#---------------------------------------+

is(
    $nxtObj->_validateAttrNameFromCaller('attr1'),
    '1',
    "confirmed use of public attribute name 'attr1'"
  );

#==[ EOF: a04._validateAttrNameFromCaller ]==
