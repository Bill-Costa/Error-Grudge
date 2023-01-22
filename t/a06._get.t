#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a06._get.t
#     Abstract:	Private attribute set method.
#        Usage:	prove a06._get.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 12;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $nxtObj = Error::Grudge->new('myfile.txt');
my $bogus = {};
my $result;

throws_ok
  { $result = Error::Grudge::_get() }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with no params';

throws_ok
  { $result = Error::Grudge::_get('attr1') }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with missing param';

throws_ok
  { $result = Error::Grudge::->_get('attr1') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught being called as a class, not object, method';

throws_ok
  { $result = $nxtObj->_get('') }
  qr/$Error::Grudge::DIAG{MISSING_ATTR}/,
  'caught missing required parameter $attr';

throws_ok
  { $result = $nxtObj->_get($bogus) }
  qr/$Error::Grudge::DIAG{NOT_ATTR_NAME}/,
  'caught non-string as $attr name';

throws_ok
  { $result = $nxtObj->_get('no_such_attr') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught invalid attribute name';

throws_ok
  { $result = $nxtObj->_get('Attr1') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught misspelled attribute name';

throws_ok
  { $nxtObj->_get('attr1') }
  qr/$Error::Grudge::DIAG{FUNC_IN_VOID}/,
  'caught function call in void context';

#---------------------------------------+
# Test normal returns.			|
#---------------------------------------+

is(
    $result = $nxtObj->_get('attr1'),
    'a1-default',
    "get public attribute value; confirmed return of current value"
  );

is(
    $nxtObj->_get('_prv2'),
    undef(),
    "get private attr value; confirmed return of current value (undef)"
  );

like(
    $nxtObj->_get('uoID'),
    qr/myfile.txt$/,
    "confirmed we could get an unsettable public attribute"
  );

#==[ EOF: a06._get ]==
