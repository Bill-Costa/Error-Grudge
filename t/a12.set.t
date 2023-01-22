#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a12.set.t
#     Abstract:	Test public object method: set()
#        Usage:	prove a12.set.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 14;     # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

#-------------------------------+
# Test usage errors.		|
#-------------------------------+

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

throws_ok
  { $nxtObj->set(uoID => 'value') }
  qr/$Error::Grudge::DIAG{READONLY}/,
  'caught trying to set unsettable attribute';

throws_ok
  { $nxtObj->set(attr1 => 'BOGUS-TEST-VALUE') }
  qr/$Error::Grudge::DIAG{GEN_VAL_FAIL}/,
  'caught trying to set disallowed value';

isnt($nxtObj->{attr1}, 'BOGUS-TEST-VALUE', 'confirmed disallowed not set');

#-------------------------------+
# Normal tests.			|
#-------------------------------+

my $uniq = $$;
my $self = $nxtObj->set( attr1 => $uniq );
is($nxtObj->{attr1}, $uniq, 'new value successfully set');
is($nxtObj, $self,          'return value is the object');

#==[ EOF: a12.set.t ]==
