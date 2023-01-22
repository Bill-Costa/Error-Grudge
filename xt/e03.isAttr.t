#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	e03.isAttr.t
#     Abstract:	Test example code in POD for object method: isAttr()
#        Usage:	prove e03.isAttr.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 5;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

#---------------------------------------+
# POD example for isAttr()
#
#  my $exists = $myObj->isAttr($aName);
#  die("invalid attr: '$aName'\n_ $Error::Grudge::lastReportedError\n_")
#    if (not $exists);
#
#---------------------------------------+

my $aName  = 'attr1';
my $myObj  = Error::Grudge->new('myfile');
my $exists = $myObj->isAttr($aName);

is($exists, 1, "confirmed existing attribute");
is($Error::Grudge::lastReportedError, '(no error reported)', 'confirmed msg');

$aName  = 'attr99';
$exists = $myObj->isAttr($aName);
is($exists, 0, "confirmed non-existing attribute");
like($Error::Grudge::lastReportedError, qr/invalid/, 'confirmed msg');

#==[ EOF: e03.isAttr ]==
