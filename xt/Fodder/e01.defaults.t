#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	Lib/t/TellUser/e01.defaults.t
#     Abstract:	Test example code in POD for class method: defaults()
#        Usage:	prove e01.defaults.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 8;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;  # What we are testing.

#---------------------------------------+
# Cut and past from the POD.		|
#---------------------------------------+

my %defaultPlus = Error::Grudge->defaults(attr1 => 5, attr2 => undef());
my $nxtObj = Error::Grudge->new('myfile', attr3 => 'new-val');

#---------------------------------------+
# Did we get what we expect?		|
#---------------------------------------+

like($nxtObj->{uoID},   qr/myfile/, 'uoID set with new()');
is($nxtObj->{attr1},           '5', 'attr1 set from defaults()');
is($nxtObj->{attr2},       undef(), 'attr2 object template default');
is($nxtObj->{attr3},     'new-val', 'attr3 set from new()');
is($nxtObj->{attr4},       undef(), 'attr4 object template default');
is($nxtObj->{_prv1}, '_p1-default', '_prv1 object template default');
is($nxtObj->{_prv2},       undef(), '_prv2 object template default');

#==[ EOF: e01.defaults.t ]==
