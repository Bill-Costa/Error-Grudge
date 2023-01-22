#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	e02.toString.t
#     Abstract:	Test example code in POD for object method: toString()
#        Usage:	prove e02.toString.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 2;      # Including no-warnings test.
use Test::NoWarnings;
use Error::Grudge;		# What we are testing.

#---------------------------------------+
# Cut and past from the POD.		|
#---------------------------------------+

my $nxtObj = Error::Grudge->new('myfile');
my $expect = <<BLOCK;
RO        uoID: ('Path::Tiny' object)
RW       attr1: 'a1-default'
RW (opt) attr2: 'a2-default'
RW (opt) attr3: NULL
RO (opt) attr4: NULL
         _prv1: '_p1-default'
         _prv2: NULL
BLOCK

#---------------------------------------+
# Did we get what we expect?		|
#---------------------------------------+

is($nxtObj->toString(), $expect, "report object template defaults");

#==[ EOF: e02.toString.t ]==
