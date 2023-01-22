#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a08.defaults.t
#     Abstract:	Test caller settable defaults service.
#        Usage:	prove a08.defaults.t

use warnings;
use strict;
use Scalar::Util;               # For variable groking services.
use Data::Dumper;
use Test::More tests => 10;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $nxtObj = Error::Grudge->new('sample-object');
my %ourDefs;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

throws_ok
  { Error::Grudge::defaults('') }
  qr/$Error::Grudge::DIAG{NOT_CLASS}/,
  'caught called as function, not class method call';

throws_ok
  { Error::Grudge::defaults('called-as-function-1-param') }
  qr/$Error::Grudge::DIAG{NOT_CLASS}/,
  'caught called as function, not class method call';

throws_ok
  { $nxtObj->defaults('call-as' => 'object-method') }
  qr/$Error::Grudge::DIAG{NOT_CLASS}/,
  'caught called as object method, not class method';

throws_ok
  { Error::Grudge->defaults('stray-value') }
  qr{Odd name/value argument for subroutine},
  'caught single scalar value where attr name/value pair(s) expected';

throws_ok
  { Error::Grudge->defaults(attr1 => 'ok', bogus => 'not ok') }
  qr/$Error::Grudge::DIAG{NOT_DEFAULT}/,
  'caught unrecognized object attribute name';

throws_ok
  { Error::Grudge->defaults(attr1 => 1, _prv2 => 2) }
  qr/$Error::Grudge::DIAG{NOT_DEFAULT}/,
  'caught attempt to set a private attribute';

throws_ok
  { Error::Grudge->defaults( uoID => 'sorry-old-son-cant-be-done' ) }
  qr/$Error::Grudge::DIAG{NOT_DEFAULT}/,
  'caught attempt to setup unsettable attribute';

#---------------------------------------+
# Test normal usage.			|
#---------------------------------------+

my $uniq = $$;
my %newDef = Error::Grudge->defaults( attr1 => $uniq );
is($newDef{attr1}, $uniq, "new default returned as function value");
my $newObj = Error::Grudge->new('foo');
is($newObj->{attr1}, $uniq, "new object assigned default");

#==[ EOF: a08.defaults.t ]==
