#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	e05.set.t
#     Abstract:	Test example code in POD for object method: set()
#        Usage:	prove e05.set.t

use warnings;
use strict;
use Data::Dumper;
use Test::More tests => 2;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;		# What we are testing.

my $myObj = Error::Grudge->new('myFile.txt');

#---------------------------------------+
# Cut and past from the POD.		|
#
#  $myObj->set('attr1', $value);       # OK
#  $myObj->set(attr1 => $value);       # OK
#  $myObj->{attr1} = $value;           # Naughty; exception thrown.
#  $myObj->set(%newVals);              # OK for valid set of attr/vals.
#
#  # Old school catch/rethrow on assignment error
#
#  eval
#    {
#      $myObj->set(attr1 => $value);   # $value may be invalid
#      1;                              # made it to here so indicate success
#    }
#  or do
#    {
#      my $error = $@ || 'unknown failure';  # catch diagnostic message
#      if ($error !~ m/'invalid|out of range'/)
#        {
#          confess($error);  # not an error we expected
#        }
#      else
#        {
#          # handle error
#        }
#    };

#---------------------------------------+

my $value = 'bar';

$myObj->set('attr1', $value);       # OK
$myObj->set(attr1 => $value);       # OK

throws_ok
  { $myObj->{attr1} = $value }               # Naughty; exception thrown.
  qr/Modification of a read-only value/,
  'caught attempt to muck with object';

# Old school catch/rethrow on assignment error

eval
  {
    $myObj->set(attr1 => $value);   # $value may be invalid
    1;                              # made it to here so indicate success
  }
or do
  {
    my $error = $@ || 'unknown failure';  # catch diagnostic message
    if ($error !~ m/'invalid|out of range'/)
      {
        diag("Uh-oh: $error");  # not an error we expected
      }
    else
      {
        diag("error handled...\n");
      }
  };

#==[ EOF: e05.set.t ]==
