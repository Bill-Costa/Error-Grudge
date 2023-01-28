#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a03._extractRegistryEntry.t
#     Abstract:	Extract a copy of an object's current grudge registry entry.
#        Usage:	cd Error-Grudge
#		prove -lv a03._extractRegistryEntry.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 20;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $msg;

throws_ok
  { Error::Grudge::_extractRegistryEntry() }
  qr/Too few arguments for subroutine/,
  'caught missing required parameter value';

throws_ok
  { Error::Grudge::_extractRegistryEntry(123, 'extra-param') }
  qr/Too many arguments for subroutine/,
  'caught extraneous arguments in function call';

$msg = quotemeta("$Error::Grudge::DIAG{OUR_FAULT}: (missing param)");

throws_ok
  { Error::Grudge::_extractRegistryEntry('') }
  qr/^$msg/,
  'caught empty parameter value';

$msg = quotemeta("$Error::Grudge::DIAG{OUR_FAULT}: bad ID num:");

throws_ok
  { Error::Grudge::_extractRegistryEntry('dummyUbj') }
  qr/^$msg/,
  'caught being called as a class method w/ single arg';

throws_ok
  { Error::Grudge::->_extractRegistryEntry() }
  qr/^$msg/,
  'caught being called as object method';

#---------------------------------------+
# Test normal return.			|
#---------------------------------------+

Error::Grudge::_resetRegistryEntry(123);
my $e = Error::Grudge::_extractRegistryEntry(123);

ok(defined($e->{grudge}),               "      grudge: $e->{grudge}");
is($e->{grudge}, 0,                     "      grudge: is expected value");
ok(defined($e->{severity}),             "    severity: $e->{severity}");
is($e->{severity}, '*NONE*',            "    severity: is expected value");
ok(defined($e->{statusID}),             "    statusID: $e->{statusID}");
is($e->{statusID}, '(not set)',         "    statusID: is expected value");
ok((ref($e->{message}) eq 'ARRAY'),     "    message: $e->{message}[0]");
is($e->{message}[0], '(no msg)',        "    message: is expected value");
ok(defined($e->{fromFile}),             "   fromFile: $e->{fromFile}");
is($e->{fromFile}, 'unknown file',      "   fromFile: is expected value");
ok(defined($e->{fromLine}),             "   fromLine: $e->{fromLine}");
is($e->{fromLine}, 0,                   "   fromLine: is expected value");
ok(defined($e->{stackDump}),            "  stackDump: $e->{stackDump}");
is($e->{stackDump}, '(no stack trace)', "  stackDump: is expected value");

#==[ EOF: a03._extractRegistryEntry ]==
