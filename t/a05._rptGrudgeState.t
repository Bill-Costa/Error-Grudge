#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a05._rptGrudgeState.t
#     Abstract:	Return object's ID; side effect: create profile if needed.
#        Usage:	cd Error-Grudge
#		prove -lv a05._rptGrudgeState.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 14;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;

{
  package Import::None;
  use warnings;
  use strict;
  use Error::Grudge;
  sub new { my $class = shift; bless(\$class => $class) }
}

my $obj_1 = Import::None->new();
my $obj_2 = Import::None->new();
my $obj_3 = Import::None->new();
my $id_1;
my $id_2;
my $id_3;

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $msg;

throws_ok
  { $id_1 = Error::Grudge::_rptGrudgeState() }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with no params';

$msg = quotemeta($Error::Grudge::DIAG{OUR_FAULT});

throws_ok
  { $id_1 = Error::Grudge::_rptGrudgeState('dummyUbj') }
  qr/^$msg/,
  'caught calling the method as a function with single arg';

throws_ok
  { $id_1 = Error::Grudge::->_rptGrudgeState() }
  qr/^$msg/,
  'caught being called as a class, not object, method';

throws_ok
  { Error::Grudge::_rptGrudgeState($obj_1) }
  qr/^$msg/,
  'caught function call in void context';

throws_ok
  { $id_1 = Error::Grudge::_rptGrudgeState($obj_1, 'extra-param') }
  qr/Too many arguments for subroutine/,
  'caught extraneous arguments in method call';

#---------------------------------------+
# Test normal returns.			|
#---------------------------------------+

my $rpt = Error::Grudge::_rptGrudgeState($obj_1);
ok((defined($rpt) and $rpt ne ''),             "is potato");
diag(' ');
diag($rpt);
like($rpt, qr/grudge = 0/,                     "   expected grudge value");
like($rpt, qr/severity = \*NONE\*/,            "   expected severity value");
like($rpt, qr/statusID = \(not set\)/,         "   expected statusID value");
like($rpt, qr/message = \(no msg\)/,           "  expected message value");
like($rpt, qr/fromFile = unknown file/,        "  expected fromFile value");
like($rpt, qr/fromLine = 0/,                   "  expected fromLine value");
like($rpt, qr/stackDump = \(no stack trace\)/, "  expected stackDump value");

#==[ EOF: a05._rptGrudgeState ]==
