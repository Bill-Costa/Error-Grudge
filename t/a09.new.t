#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a01.new.t
#     Abstract:	Test example code in POD for object method: isAttr()
#        Usage:	prove a01.new.t

use warnings;
use strict;
use Scalar::Util;               # For variable groking services.
use Data::Dumper;
use Test::More tests => 18;     # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $nxtObj;
my $exists;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

throws_ok
  { $nxtObj = Error::Grudge::new('','foo') }
  qr/$Error::Grudge::DIAG{NO_CLASS}/,
  'caught non-method call';

ok((not defined($nxtObj)), 'confirmed object was not created');

throws_ok
  { $nxtObj = Error::Grudge::new('foo','') }
  qr/$Error::Grudge::DIAG{MISSING_VALUE}/,
  'caught non-method call';

ok((not defined($nxtObj)), 'confirmed object was not created');

throws_ok
  { $nxtObj = Error::Grudge->new('') }
  qr/$Error::Grudge::DIAG{MISSING_VALUE}/,
  'caught missing required parameter';

ok((not defined($nxtObj)), 'confirmed object was not created');

throws_ok
  { $nxtObj = Error::Grudge->new('myFile.txt', 'stray-value') }
  qr{Odd name/value argument for subroutine},
  'caught single scalar value where attr name/value pair(s) expected';

ok((not defined($nxtObj)), 'confirmed object was not created');

throws_ok
  { $nxtObj = Error::Grudge->new('myFile-01.txt', attr1 => 1, bogus => 2) }
  qr/invalid Error::Grudge object attribute name: 'bogus'/,
  'caught unrecognized object attribute name';

ok((not defined($nxtObj)), 'confirmed object was not created');

throws_ok
  { $nxtObj = Error::Grudge->new('myFile-02.txt', attr1 => 1, _prv2 => 2) }
  qr/$Error::Grudge::DIAG{IS_PRIVATE}: '_prv2'/,
  'caught attempt to set a private attribute';

ok((not defined($nxtObj)), 'confirmed object was not created');

$nxtObj = Error::Grudge->new('myFile-03.txt');

throws_ok
  { $nxtObj->{attr1} = 'naughty' }
  qr/Modification of a read-only value attempted/,
  'caught attempt to directly muck with attribute value';

isnt($nxtObj->{attr1}, 'naughty', 'confirmed attribute mucking failed');

my $obj1 = Error::Grudge->new('myFile-04.txt', attr1 => 'foo');
ok(defined($obj1), "created initial object");

my $packageName = Scalar::Util::blessed($obj1);
is(
    $packageName,
    "Error::Grudge",
    "object is of expected type: '$packageName'"
  );

is(
    $obj1->{attr1},
    'foo',
    'attribute assignment successful'
  );

#==[ EOF: a01.new.t ]==
