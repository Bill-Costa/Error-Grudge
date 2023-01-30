#!/usr/bin/env perl
# -*- cperl -*-
#
#         File:	Lib/t/TellUser/e01.defaults.t
#     Abstract:	Test example code in POD for class method: defaults()
#        Usage:	prove e01.defaults.t

use warnings;
use strict;
no autovivification;            # exists($self->{x}) doesn't add new x
use Data::Dumper;
use Test::More tests => 8;      # Including no-warnings test.
use Test::NoWarnings;
use Test::Exception;
use Error::Grudge;  # What we are testing.

#---------------------------------------+
# Example #1				|
#---------------------------------------+

Error::Grudge->configSeverityScale( DEBUG => { log => 1 } );

	#-------------------------------+
	# Did we get what we expect?	|
	#-------------------------------+

my %table = Grudge->configSeverityScale();
is($table{DEBUG}{log}, 1,                           'turned on DEBUG logging');

#---------------------------------------+
# Example #2				|
#---------------------------------------+

my %newTable = Error::Grudge->configSeverityScale();
delete($newTable{FATAL});
$newTable{ABEND} = { level => 5, log => 1 };
Error::Grudge->configSeverityScale(%newTable);

	#-------------------------------+
	# Did we get what we expect?	|
	#-------------------------------+

my %table = Grudge->configSeverityScale();
ok((not exists($table{FATAL})),                    'ERROR status was removed');
ok(exists($table{ABEND}),                                'ABEND status added');
is($table{ABEND}{level}, 5,                                 'ABEND level = 5');
is($table{ABEND}{log}, 1,                                 'ABEND has logging');

#---------------------------------------+
# Example #3				|
#---------------------------------------+

Error::Grudge->configSeverityScale
  (
    undef() => undef(),
         OK => { level => 1, log => 0 }, # successful completion
       WARN => { level => 2, log => 0 }, # warning or advisory
      FAULT => { level => 3, log => 1 }, # an error
  );

	#-------------------------------+
	# Did we get what we expect?	|
	#-------------------------------+

my %table = Grudge->configSeverityScale();


#==[ EOF: e01.defaults.t ]==
