#         File: Error::Grudge
#      Summary: Mixin to add error handling to your objects.
#       Author: Bill.Costa@alumni.unh.edu
#
#  Copyright (C) 2023 William F. Costa, All Rights Reserved.
#
#  NOTES: See https://perldoc.perl.org/perlsub#Signatures for info
#         on using subroutine signatures.
#

=pod

=head1 NAME

Error::Grudge - a mixin to add error handling methods to your objects

=head1 VERSION

This document describes B<Error::Grudge> version 0.0.2

=head1 SYNOPSIS

In your module:

    package Your::Cool::Module;
    use warnings;
    use strict;
    use Error::Grudge ":basic";

    # Your objects now have the hasErrorReturn() and setReturnStatus()
    # mixin methods.

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
               severity => 'FAIL',
               statusID => 'INPUT-FILE-LOOKUP',
                message => ['file lookup error', $wantFile, $!],
            );

         return();
        }

      # ... otherwise continue work with input file ...
    }

Meanwhile, in a program that does not check your return status...

   $myObj->readInputFile('no-such-file');   # Returns w/ an error status
   $myObj->readInputFile('existing-file');  # <-- BANG! Exception thrown,
                                            # but it is line above where
                                            # the error return status was
                                            # set that is reported.

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

This module can add the following mixin methods to your objects for
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
        DEBUG => 0,   # lowest severity
           OK => 1,   # successful completion
         INFO => 2,   # neutral diagnostic
         WARN => 3,   # warning or advisory
         FAIL => 4,   # recoverable error
         BOMB => 5,   # non-recoverable error
        LOGIC => 6,   # programmer logic error
      );

But as illustrated, a class method is provided allowing you to do a
wholesale replacement of this default table with your own preferred
status code names and hierarchy.

Finally, a range of severity codes can be configured to determine which should
be flagged and returned as an error, and at what point setting the return status should
immediately cause an exception to be thrown.

    Error::Grudge->configThreshold
      (
             errorFloor => 'FAIL',   # FAIL and BOMB are flagged
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
an C<eval> block, or using a "try-catch" block provided as syntatic
sugar by some CPAN module (take your pick).

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

The mixin methods added by this module should work with any type of
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

Any and all I<logic> errors should be thrown immediately.  In practice
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

# sub        setReturnStatus ( $self ) { }
# sub         hasErrorReturn ( $self ) { }
# sub       getStackTrace ( $self ) { }
# sub        getReturnStatus ( $self ) { }
# sub       statusSeverityIs ( $self ) { }
# sub    haltIfPendingError ( $self ) { }
# sub      resetReturnStatus ( $self ) { }
# sub     forgiveErrorReturn ( $self ) { }
# sub            holdGrudge ( $self ) { }
# sub      queryReturnStatus ( $self ) { }
# sub     reportReturnStatus ( $self ) { }
# sub  statusSeverityExceeds ( $self ) { }
# sub statusSeverityLessThan ( $self ) { }

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
     'severity',   # one of DEBUG, OK, INFO, WARN, FAIL, BOMB, LOGIC, *NONE*
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
#           grudge -- grudge in effect? always 1 or 0.
#         severity -- one of DEBUG, OK, INFO, WARN, FAIL, BOMB, LOGIC, *NONE*
#         statusID -- caller defined one 'word' identifier for return status
#          message -- diagnostic text provided by caller
#         fromFile -- caller's source file where status was returned
#         fromLine -- caller's line number in that file.
#        stackDump -- stack trace returned provided by Carp module.

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

A class getter/setter method that can redefine the return status code
keywords with their relative level of severity.

=head3 Example #1

Replace 'BOMB' keyword with the old IBM term 'ABEND' for 'ABnormal
END' while retaining its relative severity value.

=over

  my %newTable = Error::Grudge->configSeverityScale();
  $newTable{ABEND} => $newTable{BOMB};
  delete($newTable{BOMB});
  Error::Grudge->configSeverityScale(%newTable);

=back

=head3 Example #2

Replace entire default table with a custom set of severity levels.

=over

  BEGIN
  {
    Error::Grudge->configSeverityScale
      (
           FAULT => 500,  # a server error
           ERROR => 400,  # a client error
            WARN => 300,  # warning or resource error
         SUCCESS => 200,  # successful completion
              OK => 200,  # synonym for SUCCESS
            INFO => 100,  # informational response
      );
  }

=back

The B<Error::Grudge> severity scale can be used to redefine the return
status keywords that will be recognized, and their relative order of
severity.  The default table, illustrated in
L<Framework Configation Class Methods|"Framework Configuration Class Methods">
section above, is what will be defined the first time this module is
loaded.

Notes:

=over

=item *

At least one return status keyword definition and integer value is
required in C<%table>.

=item *

The recommeded format for a return status keyword is to use a single
uppercase word, but this is not a requirement.

=item *

The C<level> value is required and is expected to be a positive
integer.

=item *

This method may be called with an empty parameter list, but not within
a VOID context.  It may also be called within a VOID context, but only
with a non-empty parmeter list.  (Both situations are shown in exemple
#1.)

=item *

When called within a list context, returns the current settings as a
hash table B<before> applying any changes.  Within a scalar context,
returns a hash reference which is a B<copy> of those settings.

=back

Example #2 illustrates that the order of the table defintions is not
important, nor do the values need to be contigous, nor start with any
particular value.  It is only the relativity of the values that is
important.

Example #2 also illustrates that a severity level may be assigned to
more than one keyword.  While the severity may be identical, your code
could assign different symantics to each keyword, or treat them
equivalently.

It should be obvious that any changes are best made when your own
module is first loaded, perhaps within a C<BEGIN> block.  Modifications
made later, during the program's execution, may confuse your caller, or
yourself!

=cut

sub configSeverityScale ( $class, %table )
{
}


#------------------------------------------------------------------------------

=pod

=head2 configThreshold ( %table )

A class getter/setter method that can redefine the severity levels for
automatic exception reporting.

=head3 Example #1

Modify the default trip-wires to be even more pendantic.

=over

  Error::Grudge->configThrehold
    (
          errorFloor => 'WARN',  # WARN|FAIL may not be ignored
      exceptionFloor => 'BOMB',  # BOMB|LOGIC throw exception immediately
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

The B<Error::Grudge> severity threholds define the point where your
object should start holding a grudge, and at what point an exception
should be thrown immediately.

=over

=item *

The same return status keyword cannot be used for both thresholds.

=item *

This method may be called with an empty parameter list, but not within
a VOID context.  It may also be called within a VOID context but only
with a non-empty parmeter list.

=item *

When called within a list context, returns the current settings as a
hash table B<before> applying any changes.  Within a scalar context,
returns a hash reference which is a B<copy> of those settings.

=back

Normally any changes should be made when your own module is first
loaded.  However changes made on the fly may make sense for debugging
purposes, as illustrated in example #2.

=cut


sub configThreshold ( $class, %table )
{
}

#==============================================================================
#  Module Runtime Initializations  ============================================
#==============================================================================

Error::Grudge->configSeverityScale
  (
    DEBUG => 0,  # lowest severity
       OK => 1,  # successful completion
     INFO => 2,  # neutral diagnostic
     WARN => 3,  # warning or advisory
     FAIL => 4,  # recoverable error
     BOMB => 5,  # non-recoverable error
    LOGIC => 6,  # programmer logic error
  );


Error::Grudge->configThreshold
  (
         errorFloor => 'FAIL',   # FAIL and BOMB are flagged
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

B<Error::Grudge> requires no configuration files nor environment
variables.

=head1 DEPENDENCIES

C<Carp.pm> -- part of core

C<Exporter::Easy> -- I'm lazy.  You should be too.

C<Data::Vindication> -- Data validation by another name.

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

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

=over

=item *

Since private functions are not in EXPORT_OK, they cannot be called as
object or class methods.  But they can be called as functions if fully
qualified with the module name.

=item *

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris
malesuada dictum eleifend. Integer ultricies dolor dui, hendrerit
fringilla magna mattis et. Vivamus convallis imperdiet commodo.

=back

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

=over

=item *

See "roles" in L<Moose>.

=back

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
