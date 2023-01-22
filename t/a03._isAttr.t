#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a03._isAttr.t
#     Abstract:	Confirm attribute's spelling and existance.
#        Usage:	prove a03._isAttr.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 15;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $nxtObj = Error::Grudge->new('myfile.txt');
my $result;

throws_ok
  { $result = $nxtObj->_isAttr() }
  qr/Too few arguments for subroutine/,
  'method call, but caught missing required parameter $attr';

throws_ok
  { $result = Error::Grudge::_isAttr('attr1') }
  qr/Too few arguments for subroutine/,
  'invalid function call caught as missing required parameter $attr';

throws_ok
  { $result = Error::Grudge::_isAttr('attr1','value') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'invalid function call caught despite correct parameter count';

throws_ok
  { $nxtObj->_isAttr('attr1') }
  qr/$Error::Grudge::DIAG{FUNC_IN_VOID}/,
  'caught use of function in a void context';

#---------------------------------------+
# Test normal returns.			|
#---------------------------------------+

is(
    $nxtObj->_isAttr('attr1'),
    '1',
    "confirmed public attribute 'attr1'"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{ERROR_RESET},
    "confirmed correct out-of-band return value for successful validation"
  );

#---------------------------------------+

is(
    $nxtObj->_isAttr('_prv2'),
    '1',
    "confirmed private attribute '_prv2'"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{ERROR_RESET},
    "confirmed correct out-of-band return value for successful validation"
  );

#---------------------------------------+

is(
    $nxtObj->_isAttr(''),
    undef(),
    "confirmed '' could not possibly be a valid attribute name"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{MISSING_ATTR},
    "confirmed correct out-of-band return value for missing attribute"
  );

#---------------------------------------+

is(
    $nxtObj->_isAttr(\'foo'),
    undef(),
    "confirmed a referenceis not a valid attribute name"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{NOT_ATTR_NAME},
    "confirmed correct out-of-band return value for bogus attr name"
  );

#---------------------------------------+

is(
    $nxtObj->_isAttr('foo'),
    '0',
    "confirmed 'foo' is not a valid attribute name"
  );

is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{BOGUS_ATTR} . ": 'foo'",
    "confirmed correct out-of-band return value for bogus attr name"
  );

#==[ EOF: a03._isAttr ]==
