#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a03._getObjID.t
#     Abstract:	Return object's ID; side effect: create profile if needed.
#        Usage:	cd Error-Grudge
#		prove -lv a03._getObjID.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 12;      # Including no-warnings test.
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
# Test normal returns.			|
#---------------------------------------+

my $prevID;

ok(($id_1 = Error::Grudge::_getObjID($obj_1)), "(1) object ID: $id_1");
$prevID = $id_1;
ok(($id_1 = Error::Grudge::_getObjID($obj_1)), "(1) object ID again");
is($id_1, $prevID,                                "(1) object ID is the same");

ok(($id_2 = Error::Grudge::_getObjID($obj_2)), "(2) object ID: $id_2");
$prevID = $id_2;
is($id_2, $prevID,                                "(2) object ID is the same");

isnt($id_1, $id_2, "id (1) and id (2) are different");

#---------------------------------------+
# Test usage errors.			|
#---------------------------------------+

my $msg;

throws_ok
  { $id_1 = Error::Grudge::_getObjID() }
  qr/Too few arguments for subroutine/,
  'caught calling the method as a function with no params';

$msg = quotemeta($Error::Grudge::DIAG{OUR_FAULT});

throws_ok
  { $id_1 = Error::Grudge::_getObjID('dummyUbj') }
  qr/^$msg/,
  'caught calling the method as a function with single arg';

throws_ok
  { $id_1 = Error::Grudge::->_getObjID() }
  qr/^$msg/,
  'caught being called as a class, not object, method';

throws_ok
  { Error::Grudge::_getObjID($obj_1) }
  qr/^$msg/,
  'caught function call in void context';

throws_ok
  { $id_1 = Error::Grudge::_getObjID($obj_1, 'extra-param') }
  qr/Too many arguments for subroutine/,
  'caught extraneous arguments in method call';

#==[ EOF: a03._getObjID ]==
