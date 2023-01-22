#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a10.isAttr.t
#     Abstract:	Test object method: isAttr()
#        Usage:	prove a10.isAttr.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 20;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $nxtObj;
my $exists;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

throws_ok
  { Error::Grudge::isAttr('','foo') }
  qr/$Error::Grudge::DIAG{NOT_METHOD}/,
  'caught non-method call';

#---------------------------------------+
# Test normal usage.			|
#---------------------------------------+

$nxtObj = Error::Grudge->new('myfile');

$exists = $nxtObj->isAttr('attr1');
ok($exists, "confirmed existing attribute 'attr1'");
is(1, $exists, 'return value boolean (1)');
is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{ERROR_RESET},
    'diagnostic message is congruent'
  );


$exists = $nxtObj->isAttr(undef());
ok((not $exists), "confirm undef() is not an attribute");
is(undef(), $exists, 'return value is undefined');
is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{MISSING_ATTR},
    'diagnostic message is congruent'
  );

$exists = $nxtObj->isAttr('');
ok((not $exists), "confirm '' is not an attribute");
is(undef(), $exists, 'return value is undefined');
is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{MISSING_ATTR},
    'diagnostic message is congruent'
  );

$exists = $nxtObj->isAttr(\'bogus');
ok((not $exists), "confirm that a reference is not an attribute");
is(undef(), $exists, 'return value is undefined');
is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{NOT_ATTR_NAME},
    'diagnostic message is congruent'
  );

$exists = $nxtObj->isAttr('bogus');
ok((not $exists), "confirm 'bogus' is not an attribute");
is(0, $exists, 'return value boolean (0)');
is(
    $Error::Grudge::lastReportedError,
    "$Error::Grudge::DIAG{BOGUS_ATTR}: 'bogus'",
    'diagnostic message is congruent'
  );

$exists = $nxtObj->isAttr('_prv2');
ok((not $exists), "confirm private attribute is not confirmed");
is(0, $exists, 'return value boolean (0)');
is(
    $Error::Grudge::lastReportedError,
    $Error::Grudge::DIAG{IS_PRIVATE},
    'diagnostic message is congruent'
  );


#==[ EOF: a10.isAttr ]==
