#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	e02.new.t
#     Abstract:	Test example code in POD for object method: isAttr()
#        Usage:	prove e02.new.t

use warnings;
use strict;
use Scalar::Util;               # For variable groking services.
use Data::Dumper;
use Test::More tests => 8;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $nxtObj;
my $exists;

#---------------------------------------+
# POD examples for new()
#
#  my $obj1 = Error::Grudge->new('myfile.txt', attr1 => 'foo');
#
#  my %attrs = (
#                attr1 => 'foo',
#                attr2 => 'bar',
#                attr3 => 'bat',
#              );
#
#  my $obj2 = Error::Grudge->new('other-file.txt', %attrs);
#
#---------------------------------------+

my $obj1 = Error::Grudge->new('myfile.txt', attr1 => 'foo');
ok(defined($obj1), "created initial object");
like($obj1->{uoID}, qr/myfile.txt$/, 'required scalar was set');
is($obj1->{attr1}, 'foo',        'optional attribute was set');

my %attrs = (
              attr1 => 'foo',
              attr2 => 'bar',
              attr3 => 'bat',
            );

my $obj2 = Error::Grudge->new('other-file.txt', %attrs);
like($obj2->{uoID}, qr/other-file.txt/, 'required scalar was set');
is($obj2->{attr1}, 'foo',               'optional attribute 1 was set');
is($obj2->{attr2}, 'bar',               'optional attribute 2 was set');
is($obj2->{attr3}, 'bat',               'optional attribute 3 was set');

#==[ EOF: e02.new.t ]==
