#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a07._init.t
#     Abstract:	Test example code in POD for object method: isAttr()
#        Usage:	prove a07._init.t

use warnings;
use strict;
use Scalar::Util;               # For variable groking services.
use Data::Dumper;
use Test::More tests => 12;     # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

throws_ok
  { Error::Grudge::_init('') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught called as function, not object method call';

throws_ok
  { Error::Grudge::_init('called-as-function-1-param') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught called as function, not object method call';

throws_ok
  { Error::Grudge->_init('call-as' => 'class-method') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught called as class method, not object method';

my $nxtObj = Error::Grudge->new('sample-object');
my $rtrnObj;

throws_ok
  { $nxtObj = $nxtObj->_init('stray-value') }
  qr{Odd name/value argument for subroutine},
  'caught single scalar value where attr name/value pair(s) expected';

is(Scalar::Util::blessed($rtrnObj), undef(), "no object returned (1)");

throws_ok
  { $rtrnObj = $nxtObj->_init(attr1 => 'ok', bogus => 'not ok') }
  qr/invalid Error::Grudge object attribute name: 'bogus'/,
  'caught unrecognized object attribute name';

is(Scalar::Util::blessed($rtrnObj), undef(), "no object returned (2)");

throws_ok
  { $rtrnObj = $nxtObj->_init(attr1 => 1, _prv2 => 2) }
  qr/$Error::Grudge::DIAG{IS_PRIVATE}/,
  'caught attempt to set a private attribute';

is(Scalar::Util::blessed($rtrnObj), undef(), "no object returned (3)");

throws_ok
  { $rtrnObj = $nxtObj->_init( uoID => 'sorry-old-son-cant-be-done' ) }
  qr/$Error::Grudge::DIAG{READONLY}/,
  'caught attempt to directly muck with attribute value';

is(Scalar::Util::blessed($rtrnObj), undef(), "no object returned (4)");

#==[ EOF: a07._init.t ]==
