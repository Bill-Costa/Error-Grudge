#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a02._validateAttrValue.t
#     Abstract:	Confirm proferred value is valid for a given attribute.
#        Usage:	prove a02._validateAttrValue.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 14;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $nxtObj;
my $exists;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $bogus = {};
my $result;

throws_ok
  { $result = Error::Grudge::_validateAttrValue() }
  qr/Too few arguments for subroutine/,
  'caught missing required parameter $attr';

throws_ok
  { $result = Error::Grudge::_validateAttrValue('attr1') }
  qr/Too few arguments for subroutine/,
  'caught missing required parameter $value';

throws_ok
  { $result = Error::Grudge::_validateAttrValue('','value') }
  qr/$Error::Grudge::DIAG{MISSING_ATTR}/,
  'caught empty value for required parameter $attr';

throws_ok
  { $result = Error::Grudge::_validateAttrValue($bogus,'value') }
  qr/$Error::Grudge::DIAG{NOT_ATTR_NAME}/,
  'caught non-string as $attr name';

throws_ok
  { $result = Error::Grudge::_validateAttrValue('no_such_attr', 'value') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught invalid attribute name';

throws_ok
  { $result = Error::Grudge::_validateAttrValue('Attr1', 'value') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught misspelled attribute name';

throws_ok
  { Error::Grudge::_validateAttrValue('attr1', 'value') }
  qr/$Error::Grudge::DIAG{FUNC_IN_VOID}/,
  'caught use of function in a void context';

#---------------------------------------+
# Test normal returns.			|
#---------------------------------------+

is(
    Error::Grudge::_validateAttrValue('attr1','value'),
    '1',
    "confirmed proposed value is OK for public attribute 'attr1'"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{ERROR_RESET},
    "confirmed correct out-of-band return value for successful validation"
  );

#---------------------------------------+

is(
    Error::Grudge::_validateAttrValue('_prv2','value'),
    '1',
    "confirmed proposed value is OK for all private attrs"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{ERROR_RESET},
    "confirmed correct out-of-band return value for successful validation"
  );

#---------------------------------------+

is(
    Error::Grudge::_validateAttrValue('uoID',''),
    '0',
    "confirmed bad proposed value is not OK for public attribute"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{MISSING_VALUE} . ": 'uoID'",
    "confirmed out-of-band return value for unsuccessful validation"
  );

#==[ EOF: a02._validateAttrValue ]==
