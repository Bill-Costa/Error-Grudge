#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	e04.get.t
#     Abstract:	Test example code in POD for object method: get()
#        Usage:	prove e04.get.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 2;      # Including no-warnings test.
use Test::NoWarnings;
use Error::Grudge;		# What we are testing.

my $myObj = Error::Grudge->new('myFile.txt');

#---------------------------------------+
# Cut and past from the POD.		|
#---------------------------------------+

my $buf;
my $val1 = $myObj->get('attr1');
my $expect = quotemeta("attr1 = '$val1'");

if (defined($val1)) { $buf = "attr1 = '$val1'\n"   }
else                { $buf = "attr1 = (not set)\n" }

like($buf, qr/$expect/, "expected display info");

#==[ EOF: e04.get.t ]==
