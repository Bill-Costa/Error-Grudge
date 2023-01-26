#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	a01.exporter.t
#     Abstract:	Confirm non-export/export of method symbols.
#        Usage:	prove a01.exporter.t

use warnings;
use strict;
use Test::More tests => 7;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;

#---------------------------------------+
# Make sure methods are not being	|
# exported withing being asked.		|
#---------------------------------------+

{
  package Import::None;
  use warnings;
  use strict;
  require Error::Grudge;
  sub new { my $class = shift; bless(\$class => $class) }
}

my $objNone = Import::None->new();
ok((not $objNone->can("setStatusEvent")), "no  setStatusEvent() method");
ok((not $objNone->can("holdGrudge")),     "no      holdGrudge() method");

#---------------------------------------+
# Ask for just the top 5 methods.	|
#---------------------------------------+

{
  package Import::Basic;
  use warnings;
  use strict;
  use Error::Grudge qw(:basic);
  sub new { my $class = shift; bless(\$class => $class) }
}

my $objBasic = Import::Basic->new();
ok($objBasic->can("setStatusEvent"),       "has setStatusEvent() method");
ok((not $objBasic->can("holdGrudge")),     "no      holdGrudge() method");

#---------------------------------------+
# Ask for everything.			|
#---------------------------------------+

{
  package Import::All;
  use warnings;
  use strict;
  use Error::Grudge qw(:all);
  sub new { my $class = shift; bless(\$class => $class) }
}

my $objAll = Import::All->new();
ok($objAll->can("setStatusEvent"),       "has setStatusEvent() method");
ok($objAll->can("holdGrudge"),           "has     holdGrudge() method");

#---------------------------------------+
#---------------------------------------+

{
  package Import::Foo;
  use warnings;
  use strict;
  use Data::Dumper;
  use Error::Grudge;
  sub new { my $class = shift; bless(\$class => $class) }
}

#==[ EOF: a01.exporter ]==
