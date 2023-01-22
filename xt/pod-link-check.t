#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	pod-link-check.t
#     Abstract:	Confirm proferred value is valid for a given attribute.
#        Usage:	prove pod-link-check.t

use warnings;
use strict;
use Test::More;
use Error::Grudge;		# What we are testing.

eval "use Test::Pod::LinkCheck";
if ( $@ )
  {
    plan skip_all => 'Test::Pod::LinkCheck required for testing POD';
  }
else
  {
    Test::Pod::LinkCheck->new->all_pod_ok;
  }

#==[ EOF: pod-link-check ]==

