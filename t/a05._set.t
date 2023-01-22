#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a05._set.t
#     Abstract:	Private attribute set method.
#        Usage:	prove a05._set.t

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

throws_ok
  { Error::Grudge::_set() }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with no params';

throws_ok
  { Error::Grudge::_set('attr1') }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with missing param';

throws_ok
  { Error::Grudge::_set('attr','value') }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with required params';

throws_ok
  { Error::Grudge::->_set('attr','value') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught being called as a class, not object, method';

throws_ok
  { $nxtObj->_set('','value') }
  qr/$Error::Grudge::DIAG{MISSING_ATTR}/,
  'caught missing required parameter $attr';

throws_ok
  { $nxtObj->_set($bogus,'value') }
  qr/$Error::Grudge::DIAG{NOT_ATTR_NAME}/,
  'caught non-string as $attr name';

throws_ok
  { $nxtObj->_set('no_such_attr', 'value') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught invalid attribute name';

throws_ok
  { $nxtObj->_set('Attr1', 'value') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught misspelled attribute name';

#---------------------------------------+
# Test normal returns.			|
#---------------------------------------+

my $result;

is(
    $result = $nxtObj->_set('attr1','value'),
    'a1-default',
    "set public attribute value; confirmed return of previous value"
  );

is(
    $nxtObj->_set('_prv2','value'),
    undef(),
    "set private attr value; confirmed return of previous value (undef)"
  );

is(
    $nxtObj->_set('attr4','foobar'),
    undef(),
    "confirmed we could set an unsettable public attribute"
  );

#==[ EOF: a05._set ]==
