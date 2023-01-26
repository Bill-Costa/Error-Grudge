#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a02._resetRegistryEntry.t
#     Abstract:	Reset registry entries for a given object ID.
#        Usage:	cd Error-Grudge
#		prove -lv a02._resetRegistryEntry.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 22;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;

sub confirmReset ( $ )
{
  my $id = shift(@_);
  my $hRef = Error::Grudge::_extractRegistryEntry($id);

     is($hRef->{grudge}, 0,                  "   grudge: $hRef->{grudge}");
   is($hRef->{severity},           '*NONE*', " severity: $hRef->{severity}");
    is($hRef->{eventID},        '(not set)', "  eventID: $hRef->{eventID}");
    is(ref($hRef->{message}),       'ARRAY', "  message: $hRef->{message}");
   is($hRef->{fromFile},     'unknown file', " fromFile: $hRef->{fromFile}");
   is($hRef->{fromLine},                  0, " fromLine: $hRef->{fromLine}");
  is($hRef->{stackDump}, '(no stack trace)', "stackDump: $hRef->{stackDump}");
}

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $msg;

throws_ok
  { Error::Grudge::_resetRegistryEntry() }
  qr/Too few arguments for subroutine/,
  'caught missing required parameter value';

throws_ok
  { Error::Grudge::_resetRegistryEntry(123, 'extra-param') }
  qr/Too many arguments for subroutine/,
  'caught extraneous arguments in function call';

$msg = quotemeta("$Error::Grudge::DIAG{OUR_FAULT}: (missing param)");

throws_ok
  { Error::Grudge::_resetRegistryEntry('') }
  qr/^$msg/,
  'caught empty parameter value';

$msg = quotemeta("$Error::Grudge::DIAG{OUR_FAULT}: bad ID num:");

throws_ok
  { Error::Grudge::_resetRegistryEntry('dummyUbj') }
  qr/^$msg/,
  'caught being called as a class method w/ single arg';

throws_ok
  { Error::Grudge::->_resetRegistryEntry() }
  qr/^$msg/,
  'caught being called as object method';

#---------------------------------------+
# Test normal returns.			|
# "is potato" is Stephen Colbert's      |
# favorite Russian punch line. Sorry.	|
#---------------------------------------+

my $objReg;
my $isPotato = Error::Grudge::_resetRegistryEntry(123);
ok($isPotato, "created new object registry entry");
$objReg = Error::Grudge::_extractRegistryEntry(123);
confirmReset(123);

$isPotato = Error::Grudge::_resetRegistryEntry(123);
ok((not $isPotato), "reset existing entry");
confirmReset(123);

#==[ EOF: a02._resetRegistryEntry ]==
