#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a01._assertIsAttrName.t
#     Abstract:	Test private Error::Grudge function _assertIsAttrName()
#        Usage:	prove a01._assertIsAttrName.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 7;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $nxtObj;
my $exists;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $bogus = {};
my $rtrn;

throws_ok
  { Error::Grudge::_assertIsAttrName('') }
  qr/$Error::Grudge::DIAG{MISSING_ATTR}/,
  'caught missing required parameter $attr';

throws_ok
  { Error::Grudge::_assertIsAttrName($bogus) }
  qr/$Error::Grudge::DIAG{NOT_ATTR_NAME}/,
  'caught non-string as $attr name';

throws_ok
  { Error::Grudge::_assertIsAttrName('no_such_attr') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught invalid attribute name';

throws_ok
  { Error::Grudge::_assertIsAttrName('Attr1') }
  qr/$Error::Grudge::DIAG{BOGUS_ATTR}/,
  'caught misspelled attribute name';

#---------------------------------------+
# Test normal returns.			|
#---------------------------------------+

is(
    Error::Grudge::_assertIsAttrName('attr1'),
    'attr1',
    'confirmed public attr name'
  );

is(
    Error::Grudge::_assertIsAttrName('_prv1'),
    '_prv1',
    'confirmed private attr name'
  );

#==[ EOF: a01._assertIsAttrName ]==
