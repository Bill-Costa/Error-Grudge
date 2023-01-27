#         File: Error::Grudge
#      Summary: Mixin to add error handling to your objects.
#       Author: Bill.Costa@alumni.unh.edu
#
#  Copyright (C) 2023 William F. Costa, All Rights Reserved.
#
#  NOTES: See https://perldoc.perl.org/perlsub#Signatures for info
#         on using subroutine signatures.

=pod

=head1 NAME

Error::Grudge - a mixin to add error handling methods to your objects

=head1 VERSION

This document describes Error::Grudge version 0.0.2

=head1 SYNOPSIS

In your module:

    package Your::Cool::Module;
    use warnings;
    use strict;
    use Error::Grudge ":basic";

    # Your objects now have the hasErrorReturn() and setReturnStatus()
    # mix-in methods.

    sub readInputFile
    {
      my $self     = shift(@_);
      my $wantFile = shift(@_);

      # First make sure there are no previous, unexamined, errors.

      die($self->getStackTrace()) if ($self->hasErrorReturn());

      # Now do stuff.  If we have a problem, report the error...

      if (not -e $wantFile)
        {
          $self->setReturnStatus
            (
               severity => 'ERROR',
               statusID => 'INPUT-FILE-LOOKUP',
                message => ['file lookup error', $wantFile, $!],
            );

         return();
        }

      # ... otherwise continue work with input file ...
    }

Meanwhile, in a program that does not check your return status...

   $myObj->readInputFile('no-such-file');   # Returns w/ a status set.
   $myObj->readInputFile('existing-file');  # <-- BANG! Exception here,
                                            # but it is the location
                                            # where the return status
                                            # was set that is reported.

Or in a program that does...

   $myObj->readInputFile('no-such-file');
   warn("skipping file: 'no-such-file'\n")  if ($myObj->hasErrorReturn());

   $myObj->readInputFile('existing-file');
   warn("skipping file: 'existing-file'\n") if ($myObj->hasErrorReturn());

=head1 OVERVIEW

This module provides a framework for returning out-of-band return
status information to your caller, but at the same time it will
automatically force an exception if a critical return status is being
ignored.

=head2 Return Status Object Methods

This module can add the following mix-in methods to your objects for
comprehensive status flagging, analysis, and reporting.  Note that
these verbose method names are designed to make it unlikely they will
collide with your own object method identifiers.

=begin text

Object Method            | Group   | Description
-------------------------+---------+-------------------------------------------
       setReturnStatus() | :basic  | Die if pending error, else set new status
        hasErrorReturn() | :basic  | Test/clear last error return status
         getStackTrace() | :basic  | Stack dump for last return status
       getReturnStatus() | :basic  | Return list of all status field values
      statusSeverityIs() | :basic  | Confirm last return status against a list
    haltIfPendingError() | :all    | Throw exception now if pending error
     resetReturnStatus() | :all    | Disarm pending and set new return status
    forgiveErrorReturn() | :all    | Disarm if pending error
            holdGrudge() | :all    | Reinstate if last return status was error
     queryReturnStatus() | :all    | Return status field values as hash
    reportReturnStatus() | :all    | Return status info suitable for printing
 statusSeverityExceeds() | :all    | Quantify a return status
statusSeverityLessThan() | :all    | Quantify a return status

=end text

=cut


=pod

=begin html

<P><CENTER>
<table>
<tr>
  <th>Object Method/th>
  <th>Group</th>
  <th>Description</th>
</tr>
<tr>
  <td><code>setReturnStatus()</dode></td>
  <td>:basic</td>
  <td>Die if pending error, else set new status</td>
</tr>
<tr>
  <td><code>hasErrorReturn()</dode></td>
  <td>:basic</td>
  <td>Test/clear last error return status</td>
</tr>
<tr>
  <td><code>getStackTrace()</dode></td>
  <td>:basic</td>
  <td>Return stack dump for last return status</td>
</tr>
<tr>
  <td><code>getReturnStatus()</dode></td>
  <td>:basic</td>
  <td>Return list of all status field values</td>
</tr>
<tr>
  <td><code>statusSeverityIs()</dode></td>
  <td>:basic</td>
  <td>Confirm last return status against a list</td>
</tr>
<tr>
  <td><code>haltIfPendingError()</dode></td>
  <td>:all  </td>
  <td>Throw exception now if pending error</td>
</tr>
<tr>
  <td><code>resetReturnStatus()</dode></td>
  <td>:all  </td>
  <td>Disarm pending and set new return status</td>
</tr>
<tr>
  <td><code>forgiveErrorReturn()</dode></td>
  <td>:all  </td>
  <td>Disarm if pending error</td>
</tr>
<tr>
  <td><code>holdGrudge()</dode></td>
  <td>:all  </td>
  <td>Reinstate if last return status was an error</td>
</tr>
<tr>
  <td><code>queryReturnStatus()</dode></td>
  <td>:all  </td>
  <td>Return status field values as hash</td>
</tr>
<tr>
  <td><code>reportReturnStatus()</dode></td>
  <td>:all  </td>
  <td>Return status info suitable for printing</td>
</tr>
<tr>
  <td><code>statusSeverityExceeds()</dode></td>
  <td>:all  </td>
  <td>Quantify a return status</td>
</tr>
<tr>
  <td><code>statusSeverityLessThan()</dode></td>
  <td>:all  </td>
  <td>Quantify a return status</td>
</tr>
</table>
</CENTER></P>

=end html

E<10>

=head2 Framework Configuration Class Methods

The module comes out of the box with a predefined return status
serverity scale:

    Error::Grudge->configSeverityScale
      (
        DEBUG => { level => 0, log => 1 }, # lowest severity
           OK => { level => 1, log => 0 }, # successful completion
         INFO => { level => 2, log => 0 }, # neutral diagnostic
         WARN => { level => 3, log => 1 }, # warning or advisory
        ERROR => { level => 4, log => 1 }, # recoverable error
        FATAL => { level => 5, log => 1 }, # non-recoverable error
        LOGIC => { level => 6, log => 1 }, # programmer logic error
      );

But as illustrated, a class method is provided allowing you to do a
wholesale replacement of this default table with your own preferred
status code names and hierarchy.

Finally, a range of severity codes can be configured to determine which should
be flagged and returned as an error, and at what point setting the return status should
immediately cause an exception to be thrown.

    Error::Grudge->configThreshold
      (
             errorFloor => 'ERROR',  # ERROR and FATAL are flagged
         exceptionFloor => 'LOGIC',  # LOGIC halts immediately
      );

Again, these are the initial defaults, which can be changed to suit
your coding needs using the illustrated class method.

See the L<Class Methods|"Class Methods"> section of this document for
more details.

=head1 DESCRIPTION

Damian Conway in his book L<"Perl Best Practices"|http://www.oreilly.com/catalog/perlbp/>,
and in this L<Perl.com article|https://www.perl.com/pub/2005/07/14/bestpractices.html/>,
suggests that it is better to "throw exceptions instead of returning
special values or setting flags".  The reasoning is "developers can
silently ignore flags and return values, and ignoring them requires
absolutely no effort on the part of the programmer."  In particular
"Ignoring error indicators frequently causes programs to propagate
errors in entirely the wrong direction."  And finally "Constantly
checking return values for failure clutters your code with validation
statements, often greatly decreasing its readability."

While these are all valid points, the problem I have is that the
responsibility for error handling is shifted completely to the caller.
They now must decide which method calls need to be wrapped in either
an `eval` block, or using some "try-catch" block syntatic sugar
provided by some CPAN module (take your pick).

This module is yet another attempt to solve the problem by providing a
consistent framework to test for error conditions, allowing the caller
to have fine grained control over probing and handling such states.
But at the same time, it provides a safety feature where an ignored
error condition will cause an exception to be thrown.  Plus the
locus of the original error is reported accurately, even if the bug
is surfaced much later in execution.  We refer to this property as
your object being able to "hold a grudge", with each object holding
its own independent error grudge state.  A feature is also provided
that allows an object with a lingering unhandled error to be reported
when that object finally goes out of scope.

Finally, we provide a convenient mechanism to automatically log status
returns, of all types, to an open log stream handle.

The mix-in methods added by this module should work with any type of
blessed object.  However be aware that the services provided by this
module are B<not thread-safe>.  While a generous set of convenience
methods are provided for examining and manipulating your object's
return status, as few as three of these methods are needed to cover
most basic use cases.

Be aware that this module goes against some well established Perl
conventions.  See the L<BUGS AND LIMITATIONS|"BUGS AND LIMITATIONS">
section below.

=head2 Our Error Handling Philosphy

=over

=item *

Any and all logic errors should be thrown immediately.  In practice
this primarily applies to API usage bugs that would have been caught
at compile time in a more strict language.  The reasoning is that if
the usage is incorrect, it is very unlikely that any resulting
data/actions will be rational.  With Perl, some logic errors may only
be caught at runtime.  It is expected that these will be surfaced by
unit testing.

=item *

Non-logic errors should be reported to the caller, giving it the
opportunity to handle the error gracefully.  We want to avoid having
diagnostic reporting that bypasses the caller.  There is no point
display warning or error messages that cannot be remedied or
understood by the end user.  The user interface of the application
should be responsible for all messaging to its world, be that GUI,
web browser, terminal, operator console, or batch log.

=back

=cut

package Error::Grudge;

no autovivification;                    # exists($self->{x}) doesn't add new x

my $NEW_PERL; # legacy
my $DEBUG;    # legacy

BEGIN
{
  $NEW_PERL = ($] >= 5.014) ? sub(){1} : sub(){0};
}

use v5.20;                              # 1st version with signatures
use warnings;                           # Save me from my own silly mistakes
use strict;                             # Keep things squeaky clean.
use Data::Dumper;			# A useful debugging aid.
use Carp;                               # Stack traces please.
use Scalar::Util;			# Get client's object ref as unique ID
use Hash::Util;                         # .... placeholder ...
use Data::Vindication                   # Mostly for parameter validation.
  qw(isMissing isObject isString);      #
no warnings 'experimental::signatures'; # No longer experimental v5.36+
use feature 'signatures';               # For subroutine signatures
no warnings 'experimental::smartmatch'; # Switch is still experimental.
use feature 'switch';                   # For attribute validation.

use version; our $VERSION = qv('0.00.02');


# Temp method defintions...

sub        setReturnStatus ( $self ) { }
sub         hasErrorReturn ( $self ) { }
sub       getStackTrace ( $self ) { }
sub        getReturnStatus ( $self ) { }
sub       statusSeverityIs ( $self ) { }
sub    haltIfPendingError ( $self ) { }
sub      resetReturnStatus ( $self ) { }
sub     forgiveErrorReturn ( $self ) { }
sub            holdGrudge ( $self ) { }
sub      queryReturnStatus ( $self ) { }
sub     reportReturnStatus ( $self ) { }
sub  statusSeverityExceeds ( $self ) { }
sub statusSeverityLessThan ( $self ) { }

use parent 'Exporter';

our @EXPORT_OK =
          qw(
              setReturnStatus        hasErrorReturn         getStackTrace
              getReturnStatus        statusSeverityIs

              haltIfPendingError    resetReturnStatus      forgiveErrorReturn
              holdGrudge            queryReturnStatus      reportReturnStatus
              statusSeverityExceeds  statusSeverityLessThan
            );

our %EXPORT_TAGS =
  (
    basic =>
      (
        [
          qw(
              setReturnStatus        hasErrorReturn         getStackTrace
              getReturnStatus        statusSeverityIs
            ),
        ],
      ),

    all =>
      (
        [
          qw(
              setReturnStatus        hasErrorReturn         getStackTrace
              getReturnStatus        statusSeverityIs

              haltIfPendingError    resetReturnStatus      forgiveErrorReturn
              holdGrudge            queryReturnStatus      reportReturnStatus
              statusSeverityExceeds  statusSeverityLessThan
            ),
        ],
      )
  );



our %DIAG =  # diagnostic message strings
(
  BOGUS_ATTR    => 'invalid '. __PACKAGE__.' object attribute name',
  ERROR_RESET   => '(no error reported)',
  FUNC_IN_VOID  => 'useless use of a pure function within void context',
  GEN_VAL_FAIL  => 'unexpected value for attribute',
  IS_PRIVATE    => 'please do not mess with private attribute',
  MISSING_ATTR  => 'missing required attribute name',
  MISSING_VALUE => 'missing required value',
  MOD_PRIVATE   => 'rejecting attempt to set private attribute',
  NOT_ATTR_NAME => 'attribute name is not a string',
  NOT_DEFAULT   => 'not a default-settable attribute',
  NOT_METHOD    => 'not called as an object method',
  NOT_CLASS     => 'not called as a class method',
  NOT_UNIQUE    => 'an object already exists for that identity',
  NOT_VOID      => 'expected to be called in VOID context',
  NO_CLASS      => 'missing object class name',
  NO_RULE       => 'no validation rule defined for attribute',
  OUR_FAULT     => 'internal confusion',
  READONLY      => 'cannot set read-only attribute',
  UNREACHABLE   => "unreachable code wasn't",
);

# The registry holds all status info for an object, keyed by object's
# unique ID number, as returned by _getObjID() function.  See the
# _resetRegistryEntry() private function for the list of attributes
# maintained.

my %registry = ();

my @GRUDGE_ATTR_ORD =            # Keep in sync with _resetRegistryEntry()
  (
       'grudge',   # grudge in effect? always 1 or 0.
     'severity',   # one of DEBUG, OK, INFO, WARN, ERROR, FATAL, LOGIC, *NONE*
      'statusID',   # caller defined one 'word' identifier a particular status
      'message',   # diagnostic text provided by caller
     'fromFile',   # caller's source file where status was returned
     'fromLine',   # caller's line number in that file.
    'stackDump',   # stack trace returned provided by Carp module.
  );

#==============================================================================
#  Private Functions  =========================================================
#==============================================================================

sub _resetRegistryEntry ( $objID )

#      Abstract: Set object's registry entry to initial return status state.
#
#    Parameters: $objID -- unique value identifying a specific object
#
#       Returns: $isNewEntry -- true (1) if we had to create a new entry
#
#  Precondition: $objID is a unique ID number for a given object that
#		 never changes over the course of execution, and can
#		 always be recalled on demand.  (See _getObjID.)  The
#		 "no autovivification" pragma must be set to make sure
#		 that no new hash entry is created just because we
#		 looked to see if the key already exists.
#
# Postcondition: Creates or resets object's registry entry into a
#		 state that is used to indicate that no status
#		 information is available.
#
#     Dev Notes: The cavalcade of Error::Grudge attributes:
#
#          grudge -- grudge in effect? always 1 or 0.
#        severity -- one of DEBUG, OK, INFO, WARN, ERROR, FATAL, LOGIC, *NONE*
#         statusID -- caller defined one 'word' identifier for return status
#         message -- diagnostic text provided by caller
#        fromFile -- caller's source file where status was returned
#        fromLine -- caller's line number in that file.
#       stackDump -- stack trace returned provided by Carp module.

{
  confess($DIAG{OUR_FAULT} . ': (missing param)')      if (isMissing($objID));
  confess($DIAG{OUR_FAULT} . ": bad ID num: '$objID'") if ($objID !~ m/^\d+$/);

  my $isNewEntry = (not exists($registry{$objID}));

     $registry{$objID}{grudge} = 0;
   $registry{$objID}{severity} = '*NONE*';
    $registry{$objID}{statusID} = '(not set)';
    $registry{$objID}{message} = ['(no msg)'];
   $registry{$objID}{fromFile} = 'unknown file';
   $registry{$objID}{fromLine} = 0;
  $registry{$objID}{stackDump} = '(no stack trace)';

  return($isNewEntry);
}

#-----------------------------------------------------------------------------

sub _extractRegistryEntry ( $objID )

#      Abstract: Convert an inside-out object registry entry into a hash.
#
#    Parameters: $objID -- a (possibly long) integer
#
#       Returns: $hashRecRef -- reference to a populated hash, or undef().
#
#  Precondition: $objID is a unique ID number as returned by
#		 _getObjID().  The "no autovivification" pragma must
#		 be set to make sure that new hash entries are not
#		 created just because we looked to see if the key
#		 already exists.
#
# Postcondition: Returns a reference to a hash representation of the
#		 inside-out object, or undefined if the given ID does
#		 not currently exist within the registry.

{
  confess($DIAG{OUR_FAULT} . ': (missing param)')      if (isMissing($objID));
  confess($DIAG{OUR_FAULT} . ": bad ID num: '$objID'") if ($objID !~ m/^\d+$/);

  use Test::More;
  my $hashRecRef = {};
  return($hashRecRef) if (not exists($registry{$objID}));

  require Storable;
  $hashRecRef = Storable::dclone($registry{$objID});
  return($hashRecRef);
}

#-----------------------------------------------------------------------------

sub _getObjID ( $objRef )

#      Abstract: Generate unique object ID; create registry entry as needed
#
#    Parameters: $objRef -- reference to a blessed thingy
#
#       Returns: $gID -- a unique object identification number
#
#  Precondition: $objRef is defined and blessed
#
# Postcondition: Returns the unique ID.  Adds an entry in the object
#		 registry and sets it to a standard initial state if
#		 it is not already recorded.
#
#     Dev Notes: The unique identification number is actually the
#                object's address in memory.  For this reason, this
#                module is not thread safe.
#
#                Also note:
#
#                   my $gID = _getObjID($self);   # Do it this way...
#		    my $gID = $self->_getObjID(); #  because this don't work!
#
#                Because our private methods are not exported to the
#                caller, the caller's objects cannot reference them
#                using the standard object notation.  So we really
#                have to be call as a function, not a method.

{
  confess($DIAG{OUR_FAULT} . ': (missing param)')      if (isMissing($objRef));
  confess($DIAG{OUR_FAULT} . ': (not object)')      if (not isObject($objRef));
  confess($DIAG{OUR_FAULT} . ': (void context)') if (not defined(wantarray()));

  my $gID = Scalar::Util::refaddr($objRef);
  confess($DIAG{OUR_FAULT} . ': object ID extraction failed')
    if (isMissing($gID));

  confess($DIAG{OUR_FAULT} . ": unexpected object ID format '$gID'")
    if ($gID !~ m/^\d+$/);

  _resetRegistryEntry($gID) if (not exists($registry{$gID}));

  return($gID);
}

#------------------------------------------------------------------------------

sub _rptGrudgeState ( $objRef )

#      Abstract: Debugging tool; the object's grudge state in printable form.
#
#    Parameters: $objRef -- a blessed thingy
#
#       Returns: $report -- the report with carriage control chars
#
#  Precondition: $objRef is defined an is an object.
#
# Postcondition: Returns the client object's grudge state as printable
#		 string, with no side effects.  If object is not in
#		 registry as of yet, that fact is reported instead.
#
#     Dev Notes: See global @GRUDGE_ATTR_ORD comments for info about
#		 the attributes.

{
  confess($DIAG{OUR_FAULT} . ': (missing param)')      if (isMissing($objRef));
  confess($DIAG{OUR_FAULT} . ': (not object)')      if (not isObject($objRef));
  confess($DIAG{OUR_FAULT} . ': (void context)') if (not defined(wantarray()));

  my $gID  = _getObjID($objRef);
  my $FMT  = "%12s = %s\n";
  my $PAD  = ' ' x 12;
  my $buf  = '';
  my $hRef = $registry{$gID};

  return("(no registry entry for $gID)") if (not defined($hRef));

  foreach my $attr (@GRUDGE_ATTR_ORD)
    {
      if (not ref($registry{$gID}{$attr}))
        {
          $buf .= sprintf($FMT, $attr, $registry{$gID}{$attr});
        }
      elsif (ref($registry{$gID}{$attr}) eq 'ARRAY')
        {
          my $lines = join("\n$PAD  ", @{$registry{$gID}{$attr}});
          $buf .= sprintf($FMT, $attr, $lines);
        }
    }

  return($buf);
}

#==============================================================================
#  Private Object Methods  ====================================================
#==============================================================================

#==============================================================================
#  Object Constructors  =======================================================
#==============================================================================

=pod

=head1 Object Constructor

=for author to fill in:
    Description of the objects constructed.

=cut

#------------------------------------------------------------------------------

=head2 new( $uoID, [ attr => 'value', ... ] )

Constructor for Error::Grudge objects.

=over

S<C<$uoID> -- some unique object identifier, like filename, etc.>

B<Returns:> $obj -- an instantiated Error::Grudge object

B<Precondition:> $uoID must be a defined, non-blank string value.  No
other objects may have the same exact value for this attribute.  It
must be unique.

B<Postcondition:> Returns the object, or throws an exception if there
where any errors in the provided parameters.

B<Example:>

  my $obj1 = Error::Grudge->new('myfile.txt', attr1 => 'foo');

  my %attrs = (
                attr1 => 'foo',
                attr2 => 'bar',
                attr3 => 'bat',
              );

  my $obj2 = Error::Grudge->new('other-file.txt', %attrs);

=back

After the object has been created, attribute values can be viewed
using the L<get()> method and changed using the L<set()> method.
However once set, the object's Unique Object ID (uoID) value can be
examined but not changes.

=cut

  # DEV NOTES: The _init() service sets the attribute values for us
  #            while doing attribute name validation.  But the first
  #            parameter is special -- only we can set it.
  #
  #            By locking the object's attribute hash, we prevent the
  #            caller from mucking with our attributes, but it means
  #            our own attribute setters need to remember to unlock
  #            and lock the object.
  #
  #            By locking the keys, we prevent our own misspelling of
  #            an attribute name and any error will point directly to
  #            our code.  There should be no reason to unlock the keys
  #            for the rest of the object's life, unless of course
  #            there is a need to add a new key on the fly.

sub new ($className, $uoID, %attrs)
{
}

#==============================================================================
#  Object Methods  ============================================================
#==============================================================================

=pod

=head1 Object Methods

This module provides the following object methods.

=cut

#-----------------------------------------------------------------------------

# DEV NOTES: isAttr() is for client visible attributes, _isAttr() is for
#            all attributes.

=pod

=head2 isAttr ( $attrName )

Returns true if the named public attribute exists within object.

=over

S<C<$attrName> -- name of an existing non-private attribute>

B<Returns:> $bool -- 0, 1, or undefined

B<Precondition:> Called as object method.

B<Postcondition:> Returns confirmation.  Returns true (1) if the
attribute exists.  Returns false (0) if the name could be an
attribute, but does not exist or is private.  Returns undefined if
C<$attrName> is undefined, an empty string, or is not a string.

If we return false or undefined, the class global
C<$Error::Grudge::lastReportedError> contains a diagnostic message.

B<Example:>

  my $exists = $myObj->isAttr($aName);
  die("invalid attr: '$aName'\n_ $Error::Grudge::lastReportedError\n_")
    if (not $exists);

=back

Methods like C<get()> and C<set()> require the caller to provide
an attribute name.  Misspelling that name, or other unexpected name
related usage error, will cause an exception to be thrown.  This
method can be used proactively to avoid such issues.

Also note that an existing attribute is always gettable, but may not
be settable.  Use the C<defaults()> class method for a list of all
settable object attributes.

=cut

sub isAttr ($self, $attrName)
{
}

#-----------------------------------------------------------------------------

=pod

=head2 get( $attrName )

Returns the value of the named attribute.

=over

S<C<$attrName> -- name of an existing non-private attribute>

B<Returns:> The value currently held or undefined.

B<Precondition:> $attrName is required; attribute name must exist.

B<Postcondition:> Returns value or throws exception if name is not
recognized.

B<Example:>

  # The following assumes attr1 stores a scalar value.

  my $val1 = $myObj->get('attr1');
  if (defined($val1)) { print("attr1 = '$val1'\n")   }
  else                { print("attr1 = (not set)\n") }

=back


=cut

sub get ($self, $attr)
{
}

#-----------------------------------------------------------------------------

=pod

=head2 set( $attrName, $value )

Set named attribute to new value.

=over

S<C<$attrName> -- name of an existing non-private attribute>

S<C<$value> -- value to assign; required but may be undefined>

B<Returns:> $self -- for possible object method chaining

B<Precondition:> Attribute name must be recognized.

B<Postcondition:> The value is set or an exception is thrown if there
are any errors.

B<Examples:>

  $myObj->set('attr1', $value);       # OK
  $myObj->set(attr1 => $value);       # OK
  $myObj->{attr1} = $value;           # Naughty; exception thrown.

  # Old school catch/rethrow on assignment error

  eval
    {
      $myObj->set(attr1 => $value);   # $value may be invalid
      1;                              # made it to here so success
    }
  or do
    {
      my $error = $@ || 'unknown failure';  # catch diagnostic message
      if ($error !~ m/'invalid|out of range'/)
        {
          confess($error);  # not an error we expected
        }
      else
        {
          # handle error
        }
    };

=back

The last example illustrates how an attribute assignment error could
be caught and handled.

=cut

sub set ($self, $attr, $value )
{
}

#-----------------------------------------------------------------------------

=pod

=head2 toString()

Returns, as a formatted space padded string block, a textual
representation of the object with annotations.  This can be a useful
debugging-aid.

=over

B<Returns:> Formatted, multi-line, human-readable string.

B<Precondition:> Called as an object method.

B<Postcondition:> Returns value; pure function; no side effects.

B<Example:>

  my $nxtObj = Error::Grudge->new('myfile');
  print("Initial object state:\n", $myObj->toString(), "\n");

  # Returns something like:

  Initial object state:
  RO        uoID: 'myfile'
  RW (opt) attr1: 'a1-default'
  RW (opt) attr2: 'a2-default'
  RW (opt) attr3: NULL
  RW (opt) attr4: NULL
           _prv1: '_p1-default'
           _prv2: NULL

=back

Where:

  RW = read/write -- the caller can set this attribute value
  RO = readonly -- the caller cannot change this value

If "(opt)" is not shown, the given attribute must be defined and
have non-blank value.

=for hiddenPrivate
Note that private attributes are not shown.  If you really must reveal
all of the object's guts, see the L<Data::Dumper> documentation for
how to dump a hash reference.

=for visiblePrivate
Note that private attributes are shown as a debugging aid.  Do not
code against these values since these variables and their semantics
may change or disappear.

Revealing the object attribute values is not an invitation for
bypassing the C<get()> and C<set()> methods.  Be aware that an attempt
to modify the object directly will be met with open hostility (fatal
runtime error).

=cut

sub toString ($self)
{
}

#------------------------------------------------------------------------------

sub DESTROY
{
  my $self = shift(@_);
  local($., $@, $!, $^E, $?);	# Eliminate all free radicals!

  return if ($NEW_PERL and (${^GLOBAL_PHASE} eq 'DESTRUCT'));

  if (not defined($self) or not Scalar::Util::blessed($self))
    {
      warn("DESTROY not called as object method?\n");
      return();
    }

  # my $oIndex = Scalar::Util::refaddr($self);
  # delete($confirmed{$oIndex});
  # delete($status{$oIndex});
  # delete($message{$oIndex});
  # delete($fromLine{$oIndex});
  warn("retired sidecar status data") if ($DEBUG);
}

#------------------------------------------------------------------------------

sub CLONE
{
  my $self = shift(@_);
  confess("threads not supported by this module");
}

#==============================================================================
#  Class Methods  =============================================================
#==============================================================================

=pod

=head1 Class Methods

The provided class methods are optional services for replacing or
tweeking the default return status codes defined by this module's
framework.  The trigger points for automatic exception activation may
also be adjusted.  Refer to the L<OVERVIEW|"OVERVIEW"> section above
for the out-of-the-box defaults.

=cut

#------------------------------------------------------------------------------

=head2 configSeverityScale ( %table )

Defines the return status code keywords in terms of their level of
severity, and automatic logging status.

=head3 Example #1

Turn logging on for debugging.

=over

  Error::Grudge->configSeverityScale( DEBUG => { log => 1 } );

=back

=head3 Example #2

Replace 'FATAL' keyword with the old IBM term 'ABEND' for 'ABnormal
END'.

=over

  my %newTable = Error::Grudge->configSeverityScale();
  delete($newTable{FATAL});
  $newTable{ABEND} = { level => 5, log => 1 };
  Error::Grudge->configSeverityScale(%newTable);

=back

=head3 Example #3

Replace entire default table with a terse, custom set of severity levels.

=over

  Error::Grudge->configSeverityScale
    (
          OK => { level => 1, log => 0 }, # successful completion
        WARN => { level => 2, log => 0 }, # warning or advisory
       FAULT => { level => 3, log => 1 }, # an error
    );

=back

The B<Error::Grudge> severity scale is used to define the return
status keywords that will be recognized, and their relative order of
severity.  The default table, illustrated in
L<Framework Configation Class Methods|"Framework Configuration Class Methods>
section above, is what will be defined the first time this module is
loaded.

=over

=item *

At least one return status keyword definition is required in C<%table>.

=item *

The recommeded format for a return status keyword is to use a single
uppercase word, but this is not a requirement.

=item *

The C<level> attribute is required and must be a positive integer.
The C<log> attribute is optional and defaults to false (0).

=item *

This method may be called with an empty parameter list, but not inside
a VOID context.  It may also be called in VOID context but only with a
non-empty parmeter list.  (Both situations are shown in exemple #2.)

=item *

When called in a list context, returns the current/new C<%table>.  In
scalar context, returns a reference to a copy of the current/new
table.

=back

Any changes you make should be made when your own module is first
loaded.  Changes made on the fly are probably not a good idea.

=cut

sub configSeverityScale ( %table )
{
}


#------------------------------------------------------------------------------

=pod

=head2 configThreshold ( %table )

Defines the severity levels for automatic exception reporting.

=head3 Example #1

Modify the default trip-wires to be even more pendantic.

=over

  Error::Grudge->configThrehold
    (
          errorFloor => 'WARN',  # WARN|ERROR may not be ignored
      exceptionFloor => 'FATAL', # FATAL|LOGIC throw exception immediately
    );

=back

=head3 Example #2

For debugging, temporarily make C<WARN> return status (or worse)
immediately throw an exception, but only for this section of code.

=over

  my %std = Error::Grudge->configThreshold( exceptionFloor => 'WARN' );

 ... one or more calls made to your methods that set a return status ...

  Error::Grudge->configThreshold(%std);  # restore original thresholds

=back

Any changes you make should be made when your own module is first
loaded.  Changes made on the fly may make sense for debugging
purposes, as illustrated in example #2.

=cut


sub setSeverityScape ( %table )
{
}

#==============================================================================
#  Module Runtime Initializations  ============================================
#==============================================================================

Error::Grudge->configSeverityScale
  (
    DEBUG => { level => 0, log => 1 }, # lowest severity
       OK => { level => 1, log => 0 }, # successful completion
     INFO => { level => 2, log => 0 }, # neutral diagnostic
     WARN => { level => 3, log => 1 }, # warning or advisory
    ERROR => { level => 4, log => 1 }, # recoverable error
    FATAL => { level => 5, log => 1 }, # non-recoverable error
    LOGIC => { level => 6, log => 1 }, # programmer logic error
  );

Error::Grudge->configThreshold
  (
         errorFloor => 'ERROR',  # ERROR and FATAL are flagged
     exceptionFloor => 'LOGIC',  # LOGIC halts immediately
  );


1; # All Perl modules must end on a positive note.

__END__

=pod

=head1 DIAGNOSTICS

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris
malesuada dictum eleifend. Integer ultricies dolor dui, hendrerit
fringilla magna mattis et. Vivamus convallis imperdiet commodo.

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<Odd name/value argument for subroutine %s>

The C<new()> method, and others, expect name/value pairs for setting
object attribute values.  In particular, while a hash may be used to
provide thse values, as in:

    my $obj = Error::Grudge->new('myfile.txt', %attrSet);

a reference to a hash will not work and will be seen as a single
value.  Try instead:

    my $obj = Error::Grudge->new('myfile.txt', %{$hashRef});

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris
malesuada dictum eleifend. Integer ultricies dolor dui, hendrerit
fringilla magna mattis et. Vivamus convallis imperdiet commodo.

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

Error::Grudge requires no configuration files or environment variables.

=head1 DEPENDENCIES

C<Carp.pm> -- part of core

C<Exporter::Easy> -- I'm lazy.  You should be too.

C<Data::Vindication> -- Data validation by another name.

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.

=head1 INCOMPATIBILITIES

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris
malesuada dictum eleifend. Integer ultricies dolor dui, hendrerit
fringilla magna mattis et. Vivamus convallis imperdiet commodo.

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.

=head1 BUGS AND LIMITATIONS

- Since private functions are not in EXPORT_OK, they can not be called
  as object or class methods.  But they can be called as functions if
  fully qualified with the module name.


Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris
malesuada dictum eleifend. Integer ultricies dolor dui, hendrerit
fringilla magna mattis et. Vivamus convallis imperdiet commodo.

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
L<https://github.com/Bill-Costa/Error-Grudge/issues>.

=head1 REPOSITORY

L<https://github.com/Bill-Costa/Error-Grudge>

=head1 AUTHOR

Bill Costa  C<< <Bill.Costa@alumni.unh.edu> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2023, Bill Costa C<< <Bill.Costa@alumni.unh.edu> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 SEE ALSO

[list other modules that provide similar services]

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
