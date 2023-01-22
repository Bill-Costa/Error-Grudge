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

This document describes Error::Grudge version 0.0.0

=head1 SYNOPSIS

In your module:

    package Your::Cool::Module;
    use warnings;
    use strict;
    use Error::Grudge ":basic";

    # Your objects now have the hasErrorEvent() and setStatusEvent()
    # mix-in methods.

    sub readInputFile
    {
      my $self     = shift(@_);
      my $wantFile = shift(@_);

      # First make sure there are no previous, unexamined, errors.

      die($self->eventStackTrace()) if ($self->hasErrorEvent());

      # Now do stuff.  If we have a problem, report the error...

      if (not -e $wantFile)
        {
          $self->setStatusEvent
            (
              severity => 'ERROR',
               eventID => 'INPUT-FILE-LOOKUP',
               message => ['file lookup error', $wantFile, $!],
            );

         return();
        }

      # ... otherwise continue work with input file ...
    }

Meanwhile, in a program that does not check your return status...

   $myObj->readInputFile('no-such-file');     # Returns with error flag set.
   $myObj->readInputFile('this-one-exists');  # <-- BANG! Exception here,
                                              # but it is the location of
                                              # where the flag was set that
                                              # is reported.

Or in a program that does...

   $myObj->readInputFile('no-such-file');
   warn("skipping file: 'no-such-file'\n")    if ($myObj->hasErrorEvent());

   $myObj->readInputFile('this-one-exists');
   warn("skipping file: 'this-one-exists'\n") if ($myObj->hasErrorEvent());

=head1 OVERVIEW

This module provides a framework for returning out-of-band return
status information to your caller, but at the same time it will
automatically force an exception if a critical return status is being
ignored.

This module can add the following mix-in methods to your objects for
comprehensive status flagging, analysis, and reporting.  Note that
these verbose method names are designed to make it unlikely they will
collide with your own object method identifiers.

=begin text

Object Method           | Group   | Description
------------------------+---------+--------------------------------------------
setStatusEvent()        | :basic  | Die if pending error, else set new status
hasErrorEvent()         | :basic  | Test/clear last error status event
eventStackTrace()       | :basic  | Return stack dump for last event
getStatusEvent()        | :basic  | Return list of all status field values
eventSeverityIs()       | :basic  | Confirm last status event against a list
haltIfPendingError()    | :all    | Throw exception now if pending error
resetStatusEvent()      | :all    | Disarm pending and set new status event
forgiveErrorEvent()     | :all    | Disarm if pending error
holdGrudge()            | :all    | Reinstate if last event was an error
queryStatusEvent()      | :all    | Return status field values as hash
reportStatusEvent()     | :all    | Event status info suitable for printing
eventSeverityExceeds()  | :all    | Quantify a status event
eventSeverityLessThan() | :all    | Quantify a status event

=end text

=begin html

<P><CENTER>
<table>
<tr>
  <th>Object Method/th>
  <th>Group</th>
  <th>Description</th>
</tr>
<tr>
  <td><code>setStatusEvent()</dode></td>
  <td>:basic</td>
  <td>Die if pending error, else set new status</td>
</tr>
<tr>
  <td><code>hasErrorEvent()</dode></td>
  <td>:basic</td>
  <td>Test/clear last error status event</td>
</tr>
<tr>
  <td><code>eventStackTrace()</dode></td>
  <td>:basic</td>
  <td>Return stack dump for last event</td>
</tr>
<tr>
  <td><code>getStatusEvent()</dode></td>
  <td>:basic</td>
  <td>Return list of all status field values</td>
</tr>
<tr>
  <td><code>eventSeverityIs()</dode></td>
  <td>:basic</td>
  <td>Confirm last status event against a list</td>
</tr>
<tr>
  <td><code>haltIfPendingError()</dode></td>
  <td>:all  </td>
  <td>Throw exception now if pending error</td>
</tr>
<tr>
  <td><code>resetStatusEvent()</dode></td>
  <td>:all  </td>
  <td>Disarm pending and set new status event</td>
</tr>
<tr>
  <td><code>forgiveErrorEvent()</dode></td>
  <td>:all  </td>
  <td>Disarm if pending error</td>
</tr>
<tr>
  <td><code>holdGrudge()</dode></td>
  <td>:all  </td>
  <td>Reinstate if last event was an error</td>
</tr>
<tr>
  <td><code>queryStatusEvent()</dode></td>
  <td>:all  </td>
  <td>Return status field values as hash</td>
</tr>
<tr>
  <td><code>reportStatusEvent()</dode></td>
  <td>:all  </td>
  <td>Event status info suitable for printing</td>
</tr>
<tr>
  <td><code>eventSeverityExceeds()</dode></td>
  <td>:all  </td>
  <td>Quantify a status event</td>
</tr>
<tr>
  <td><code>eventSeverityLessThan()</dode></td>
  <td>:all  </td>
  <td>Quantify a status event</td>
</tr>
</table>
</CENTER></P>

=end html

E<10>

The module comes out of the box with a predefined status event
serverity scale:

    Error::Grudge->setSeverityScale
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
status names and hierarchy.

Finally, a range of events can be configured to determine which should
be flagged and returned as an error, and at what point should an event
immediately cause an exception to be thrown.

    Error::Grudge->configThreshold
      (
             errorFloor => 'ERROR',  # ERROR and FATAL are flagged
         exceptionFloor => 'LOGIC',  # LOGIC halts immediately
      );

Again, these are the initial defaults, which can be changed to suit
your coding needs using the illustrated class method.

=head1 DESCRIPTION

Damian Conway in his book L<"Perl Best Practices"|http://www.oreilly.com/catalog/perlbp/>,
and in this L<Perl.com article|https://www.perl.com/pub/2005/07/14/bestpractices.html/>,
suggests that it is better to "I<throw exceptions instead of returning
special values or setting flags>".  The reasoning is "I<developers can
silently ignore flags and return values, and ignoring them requires
absolutely no effort on the part of the programmer.>"  In particular
"I<Ignoring error indicators frequently causes programs to propagate
errors in entirely the wrong direction.>"  And finally "I<Constantly
checking return values for failure clutters your code with validation
statements, often greatly decreasing its readability.>"

While these are all valid points, the problem I have is that the
responsibility for error handling is shifted completely to the caller,
forcing them to wrap most if not all of your method calls in either an
`eval` block, or using the "try-catch" block syntatic sugar provided
by your choice of CPAN module.

This module is an attempt to solve the problem by providing a
consistent framework to test for error conditions, allowing the caller
to have fine grained control over probing and handling such states.
But at the same time, it provides a safety feature where an ignored
error condition will cause an exception to be thrown.  The original
locus of that error is reported accurately, even if the bug is surfaced
much later in execution.  We refer to this property as your object
being able to "hold a grudge", with each object holding its own
independent error grudge state.  A feature is also provided that
allows an object with a lingering unhandled error to be reported when
the object finally goes out of scope.

Finally, we provide a convenient mechanism to automatically log status
events, of all types, to an open log stream handle.

The mix-in methods added by this module should work with any type of
blessed object.  However be aware that the services provided by this
module are B<not thread-safe>.  While a generous set of convenience
methods are provided for examining and manipulating your object's
event status, as few as three of these methods are needed to cover
most basic use cases.

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
use v5.20;                              # 1st version with signatures
use warnings;                           # Save me from my own silly mistakes
use strict;                             # Keep things squeaky clean.
use Data::Dumper;			# A useful debugging aid.
use Carp;                               # Stack traces please.
use Hash::Util;                         # For restricted keys.
use Path::Tiny;				# Convenient file handling.
use Data::Vindication                   # Mostly for parameter validation.
  qw(isMissing isObject isString);      #
no warnings 'experimental::signatures'; # No longer experimental v5.36+
use feature 'signatures';               # For subroutine signatures
no warnings 'experimental::smartmatch'; # Switch is still experimental.
use feature 'switch';                   # For attribute validation.

use version; our $VERSION = qv('0.00.00');

#-------------------------------+
# This feature is not needed if |
# you are doing an OO module.   |
#-------------------------------+
#
# use Exporter::Easy
#   (
#     EXPORT => [ qw(mustHave) ],                      # Foist our garbage
#         OK => [ qw($thisVar fun1 fun2 fun3 fun4) ],  # Export on request
#       TAGS => [                                      # Export groups...
#                 base => [ qw( fun1 ) ],
#                 more => [ qw( fun2 fun3 fun4 ) ],
#                  all => [ qw( $thisVar :base :more ) ],
#               ],
#   );
#
#-------------------------------+

#   We have three types of object related structures for managing
#   defaults during object creation.
#
#   %objectTemplate          $clientDefaults          new( params... )
#   -----------------------  -----------------------  -----------------------
#   - This is copied for     - Only created if your   - After the defaults
#     all new object           client calls class       (on left) are applied
#     instances.               defaults() method.       to new object, the
#                                                       new() arg values, if
#   - Use for any initial    - These defaults are       any, are applied.
#     default values set       layered over your
#     by you, the module       initial values.
#     author.
#
#   IMPORTANT: %objectTemplate needs to contain all attributes,
#   private and public.  We will not work with attributes added on the
#   fly.  If that is needed, create a new method that does that to
#   keep %objectTemplate, %callerAttrIs, and @toStringOrd up to date.

our $lastReportedError = 'BAD LOGIC';   # Internal out-of-band message passing
my $clientDefaults = undef();           # Populated by defaults() class method.
my %objectRegistry = ();		# Keep track of all objects.
my %objectTemplate =                    # Template/defaults for our object.
  (
    uoID  => undef(),			# Unique Object ID set only by new()
    attr1 => 'a1-default',		# These values for unit testing.
    attr2 => 'a2-default',
    attr3 => undef(),
    attr4 => undef(),
    _prv1 => '_p1-default',
    _prv2 => undef(),
  );

my @toStringOrd  = qw( uoID attr1 attr2 attr3 attr4 _prv1 _prv2 );
my %callerAttrIs =
  (
    uoID  => { settable => 0, required => 1, },   # Set with new() only.
    attr1 => { settable => 1, required => 1, },
    attr2 => { settable => 1, required => 0, },
    attr3 => { settable => 1, required => 0, },
    attr4 => { settable => 0, required => 0, },
  );

Hash::Util::lock_keys(%objectTemplate);
Hash::Util::lock_hash(%objectTemplate);

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
  READONLY      => 'cannot set read-only attribute',
  UNREACHABLE   => "unreachable code wasn't",
);

#==============================================================================
#  Private Class Functions  ===================================================
#==============================================================================

sub _assertIsAttrName ($attr)

#      Abstract: Validate attribute spelling or confess.
#
#    Parameters: $attr -- claimed to be an attribute name
#
#       Returns: $attr -- the confirmed attribute name
#
#  Precondition: $attr is defined and has a non-blank string value.
#
# Postcondition: Throws exception if $attr is an unknown attribute or
#		 is otherwise invalid, otherwise we return the name,
#		 not that anyone should care.
#
#     Dev Notes: The "no autovivification" pragma must be set to make
#                sure we don't accidentally try to create a new hash
#                key just by trying to look for it.
#
#                It seems silly to return a value since our purpose is
#                to stop te bus if the attribute name is invalid.  But
#                I guess you could do something like:
#
#                  my $attrName = _assertIsAttrName('attr1');  # or die

{
  confess($DIAG{MISSING_ATTR} . "\n_")           if (isMissing($attr));
  confess($DIAG{NOT_ATTR_NAME} . ": '$attr'\n_") if (not isString($attr));

  no autovivification;
  if (not exists($objectTemplate{$attr}))
    {
      my $pkgName = __PACKAGE__;
      confess($DIAG{BOGUS_ATTR} . ": '$attr'\n_");
    }

  return($attr);
}

#-----------------------------------------------------------------------------

sub _validateAttrValue ($attr, $val)

#      Abstract: Validate attribute assignment value.
#
#    Parameters: $attr -- attribute receiving value
#                $val  -- candiate value to assign (may be undefined)
#
#       Returns: $bool -- 1 if valid, 0 if not.
#
#  Precondition: $attr is an expected attribute name
#
# Postcondition: Returns test result.  If the result is 0 (failed),
#		 check the package global $lastReportedError for the
#		 reason.  An exception is thrown if the attribute name
#		 is invalid in any way.  We also thrown an exception
#		 if called within a void context.

{
  confess($DIAG{FUNC_IN_VOID}) if (not defined(wantarray()));
  _assertIsAttrName($attr);

  $lastReportedError = $DIAG{ERROR_RESET};

  for ($attr)
    {
      when (/^uoID$/)
        {
          return(1) if (not isMissing($val));
          $lastReportedError = $DIAG{MISSING_VALUE} . ": '$attr'";
          return(0);
        }

      when (/^attr1$/)
        {
          return(1) if (defined($val) and $val ne 'BOGUS-TEST-VALUE');
          $lastReportedError = $DIAG{GEN_VAL_FAIL} . ": '$attr'";
          return(0);
        }

      when (/^attr2$/)
        {
          return(1);
        }

      when (/^attr3$/)
        {
          return(1);
        }

      when (/^attr4$/)
        {
          return(1);
        }

      when (/^_prv/)
        {
          return(1);
        }

      default
        {
          confess($DIAG{NO_RULE}, ": '$attr'\n_");
        }
    }

  confess($DIAG{UNREACHABLE});
}

#==============================================================================
#  Private Object Methods  ====================================================
#==============================================================================

sub _isAttr ($self, $attr)

#      Abstract: Confirm attribute spelling and existance.
#
#    Parameters: $self -- reference to a Error::Grudge object
#                $attr -- claimed to be an attribute name
#
#       Returns: $result -- 0, 1, or undefined.
#
#  Precondition: Called as an object method.
#
# Postcondition: Return 1 if attribute exists, 0 if unknown attribute,
#                undefined if this could not possibly be an attribute.
#                Sets private global $lastReportedError.

{
  confess($DIAG{NOT_METHOD})   if (not isObject($self));
  confess($DIAG{FUNC_IN_VOID}) if (not defined(wantarray()));

  if (isMissing($attr))
    {
      $lastReportedError = $DIAG{MISSING_ATTR};
      return(undef);
    }

  if (not isString($attr))
    {
      $lastReportedError = $DIAG{NOT_ATTR_NAME};
      return(undef);
    }

  if (not exists($self->{$attr}))
    {
      $lastReportedError = "$DIAG{BOGUS_ATTR}: '$attr'";
      return(0);
    }

  $lastReportedError = $DIAG{ERROR_RESET};
  return(1);
}

#-----------------------------------------------------------------------------

sub _validateAttrNameFromCaller ($self, $attr)

#      Abstract: Validate attribute spelling from this module's clients.
#
#    Parameters: $self -- an Error::Grudge object
#                $attr -- claimed to be an attribute name
#
#  Precondition: $self is a defined blessed reference.
#
# Postcondition: If $attr is an known attribute, we return true (1).
#                Otherwise we thrown an exception with an attempt to
#                show where the caller made their mistake, without
#                stack tracing our own module's code.
#
#     Dev Notes: Not being called as object method is *our* fault.
{
  confess($DIAG{NOT_METHOD} . "\n_") if (not isObject($self));

  no autovivification;             # So exists() test will not create new key.
  my $pkgName = __PACKAGE__;
  local %Carp::Internal;
  $Carp::Internal{ (__PACKAGE__) }++;

  confess($DIAG{MISSING_ATTR}  . "\n_ ")   if (isMissing($attr));
  confess($DIAG{NOT_ATTR_NAME} . "\n_ ")   if (not isString($attr));
  confess($DIAG{BOGUS_ATTR} . ": '$attr'") if (not exists($self->{$attr}));
  confess($DIAG{IS_PRIVATE} . ": '$attr'") if ($attr =~ m/^_/);
  return(1);
}

#-----------------------------------------------------------------------------

sub _set ($self, $attr, $value)

#      Abstract: Return value of given object's attribute.
#
#    Parameters: $self  -- reference to a Error::Grudge object
#                $attr  -- claimed to be an attribute name
#                $value -- a value to store or undefined
#
#       Returns: $value - the previous value or undefined
#
#  Precondition: $self is a defined blessed reference, $attr is
#                a valid attribute name.
#
# Postcondition: If the named attribute exists within the object, the
#                value is stored and we return any previous value.
#                Otherwise we throw an exception.
#
#         Notes: We see and modify all available attributes, including
#                private ones.  We also do not do any value
#                validation, excepting the value provided as gospel.
#                Contrast this with the public set() method.
#
#                Returning the previous value is offered as a
#                convenience for the caller and as such calling within
#                a void context is allowed.
#
#        BEWARE: Any sort of reference, such as a hadh or a code ref,
#                can be stored using this mechanism.  But it is up to
#                caller to determine if any 'old' value returned in
#                such circumstances is actually useful.

{
  confess($DIAG{NOT_METHOD} . "\n_") if (not isObject($self));

  _assertIsAttrName($attr);
  my $oldVal = $self->{$attr};
  Hash::Util::unlock_hashref($self);
  $self->{$attr} = $value;
  Hash::Util::lock_hashref($self);
  return($oldVal);
}

#-----------------------------------------------------------------------------

sub _get ($self, $attr)

#      Abstract: Set new value for attribute while returning previous value.
#
#    Parameters: $self -- reference to a Error::Grudge object
#                $attr -- claimed to be an attribute name
#
#       Returns: $oldVal - the current value assigned to the attribute
#
#  Precondition: $self is a defined blessed reference, $attr is
#                a valid public attribute name.
#
# Postcondition: If the named attribute exists within the object,
#                returns the value without side effects.  Otherwise we
#                throw an exception.  Since this is a pure function,
#                we also throw an exception if called within a void
#                context.
#
#         Notes: We see and return all available attributes, including
#                private ones, in contrast to the public get() method.

{
  confess($DIAG{NOT_METHOD}   . "\n_")  if (not isObject($self));
  confess($DIAG{FUNC_IN_VOID} . "\n_ ") if (not defined(wantarray()));

  _assertIsAttrName($attr);
  return($self->{$attr});
}

#-----------------------------------------------------------------------------

sub _init ($self, %attrs)

#      Abstract: Initialize or reset zero or more public attribute values.
#
#    Parameters: %attrs -- hash containing zero or more expected attr names
#
#       Returns: $self -- with any changes applied.
#
#  Precondition: $self is defined and blessed hash ref.  %attrs is a
#                hash containing zero or more key/value pairs where
#                each key is an expected public attribute name for
#                this type of object.  Private attributes are allowed.
#
# Postcondition: The supplied attribute values are validated and
#                applied to the object.  An exception is thrown if any
#                of the attribute names is misspelled, unexpected, or
#                private.
#
#     DEV NOTES: The idea is to allow caller to set values only for
#                known attributes.  This cannot be used to add new
#                attributes.  We also will refuse to set private
#                attributes; use _set() method for that.


{
  use Test::More;
  confess($DIAG{NOT_METHOD}) if (not isObject($self));

  foreach my $attr (keys(%attrs))
    {
      $self->set($attr, $attrs{$attr});
    }

  return($self);
}

#==============================================================================
#  Class Methods  =============================================================
#==============================================================================

=pod

=head1 Class Methods

=for author to fill in:
    The following class methods are provided:

=cut

#------------------------------------------------------------------------------

=head2 defaults( [ attr => 'value', ... ] )

Set default attribute values for all subsequent new objects.

=over

S<C<%attrs> -- zero or more attribute name/value pairs>

B<Returns:> Hash containing all settable attributes with their default
values.

B<Precondition:> Must be called as class method.

B<Postcondition:> New default settings are applied or an exception is
thrown if there are any errors.

B<Example:>

  my %defs = Error::Grudge->defaults(attr1 => 5, attr2 => undef());
  my $nxtObj = Error::Grudge->new('myfile', attr3 => 'new-val');

=back

This method may be called without any arguments as a way of examining
all of the caller-settable attributes and their current default
values.  Call this method before setting your own defaults to see what
built-in defaults may already exist.

For convenience when creating new objects, modify the returned hash to
override defaults as needed and fill-in missing values, and then use
that hash as the argument value for the new() object constructor.

=cut

sub defaults ($className, %attrs)
{
  confess($DIAG{NOT_CLASS}) if (isMissing($className));
  confess($DIAG{NOT_CLASS}) if (isObject($className));
  confess($DIAG{NOT_CLASS}) if ($className ne __PACKAGE__);

  #-------------------------------------+
  # If first time we are being called,  |
  # then create initial class owned     |
  # global object.                      |
  #-------------------------------------+

  if (not defined($clientDefaults))
    {
      foreach my $attr (keys(%objectTemplate))
        {
          _assertIsAttrName($attr);
          next if (not $callerAttrIs{$attr}{settable});
          $clientDefaults->{$attr} = $objectTemplate{$attr};
        }
    }

  Hash::Util::lock_ref_keys($clientDefaults);

  #-------------------------------------+
  # Now apply what the caller wants.    |
  #-------------------------------------+

  no autovivification;
  foreach my $attr (keys(%attrs))
    {
      croak("ERROR: " . $DIAG{NOT_DEFAULT} . ": '$attr'\n_")
        if (not exists($clientDefaults->{$attr}));

      my $nxtVal = $attrs{$attr};
      my $valueAllowed = _validateAttrValue($attr => $nxtVal);
      if ($valueAllowed)
        {
          $clientDefaults->{$attr} = $nxtVal;
        }
      else
        {
          if (not defined($nxtVal)) { $nxtVal = 'NULL'      }
          else                      { $nxtVal = "'$nxtVal'" }

          croak("ERROR: " . $DIAG{GEN_VAL_FAIL} . ": $attr => $nxtVal\n_");
        }
    }

  return(%{$clientDefaults});
}

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
  no autovivification;  # exists($self->{x}) doesn't create a new x

  croak("ERROR: ".$DIAG{NO_CLASS})                if (isMissing($className));
  croak("ERROR: ".$DIAG{MISSING_VALUE}.': $uoID') if (isMissing($uoID));

  #-----------------------------+
  # Handle our unique required	|
  # attribute first.		|
  #-----------------------------+

  my $absID = path($uoID)->realpath();
  confess("unable to resolve as a filename\n_ '$uoID'\n_ $!\n_")
    if (isMissing($absID));

  if (exists($objectRegistry{$absID}))
    {
      my $msg = "ERROR: " . $DIAG{NOT_UNIQUE} . ": '$uoID'\n_";

      if ($uoID eq $absID) { croak($msg)                               }
      else                 { croak($msg . " resolved to: '$absID'\n_") }
    }

  my $self = {};
  $self->{uoID} = $absID;
  $objectRegistry{$absID} = $self;

  #-----------------------------+
  # Copy attributes from object |
  # template for our defaults.  |
  #-----------------------------+

  foreach my $attr (keys(%objectTemplate))
    {
      next if ($attr eq 'uoID');
      $self->{$attr} = $objectTemplate{$attr};
    };

  bless($self, $className);             # You are now an object.  Hooray!
  Hash::Util::lock_ref_keys($self);     # Keys are now immutable.

  #-----------------------------+
  # Npw apply client defaults,  |
  # if any, and then finally    |
  # arg values from call.       |
  #-----------------------------+

  $self->_init(%{$clientDefaults}) if (defined($clientDefaults));
  $self->_init(%attrs);

  #-----------------------------+
  # Check for missing required  |
  # params/attributes.          |
  #-----------------------------+

  foreach my $attr (keys(%callerAttrIs))
    {
      next if ($attr eq 'uoID');			# Already handled.
      confess("logic error; no such attr: '$attr'\n_")
        if (not exists($callerAttrIs{$attr}));

      if ($callerAttrIs{$attr}{required})
        {
          croak("ERROR: ".$DIAG{MISSING_VALUE}, " for attribute: '$attr'\n_")
            if (isMissing($self->{$attr}));
        }
    }

  Hash::Util::lock_hashref($self);	# From here on out, set() or _set().
  return($self);
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
  croak("ERROR: " . $DIAG{NOT_METHOD}) if (not isObject($self));

  #-------------------------------------+
  # Private _isAttr() will catch all	|
  # errors except private attr case.	|
  #-------------------------------------+

  my $status = $self->_isAttr($attrName);
  return($status) if (not $status);

  #-------------------------------------+
  # Hide private from client.		|
  #-------------------------------------+

  if ($attrName =~ m/^_/)
    {
      $lastReportedError = $DIAG{IS_PRIVATE};
      return(0);
    }

  $lastReportedError = $DIAG{ERROR_RESET};
  return(1);
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
  croak("ERROR: " . $DIAG{NOT_METHOD})   if (not isObject($self));
  croak("ERROR: " . $DIAG{FUNC_IN_VOID}) if (not defined(wantarray()));

  $self->_validateAttrNameFromCaller($attr);

  return($self->{$attr});
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
  croak("ERROR: " . $DIAG{NOT_METHOD}) if (not isObject($self));

  $self->_validateAttrNameFromCaller($attr);

  croak("ERROR: " . $DIAG{READONLY} . ": '$attr'\n_")
    if (not $callerAttrIs{$attr}{settable});

  my $valAllowed = _validateAttrValue($attr, $value);
  if (not $valAllowed)
    {
      if (not defined($value)) { $value = 'NULL'     }
      else                     { $value = "'$value'" }

      croak("ERROR: " . $DIAG{GEN_VAL_FAIL} . ": $attr => $value\n_");
    }

  Hash::Util::unlock_hashref($self);
  $self->{$attr} = $value;
  Hash::Util::lock_hashref($self);
  return($self);
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
  croak("ERROR: " . $DIAG{NOT_METHOD}) if (not isObject($self));

  #-------------------------------------+
  # Prescan object attrs to determine	|
  # annotations and format widths.	|
  #-------------------------------------+

  my $maxLabelWidth = 0;
  my %annotation    = ();
  my %alreadySeen   = ();
  foreach my $name (keys(%{$self}))
    {
      $maxLabelWidth = length($name) if (length($name) > $maxLabelWidth);

      my $prefix = '';
      if    (not exists($callerAttrIs{$name})) { $prefix .= '   ' }
      elsif ($callerAttrIs{$name}{settable})   { $prefix .= 'RW ' }
      else                                     { $prefix .= 'RO ' }

      if    (not exists($callerAttrIs{$name})) { $prefix .= '     ' }
      elsif ($callerAttrIs{$name}{required})   { $prefix .= '     ' }
      else                                     { $prefix .= '(opt)' }

      $annotation{$name} = $prefix;
    }

  #-------------------------------------+
  # Build the display text block.	|
  #-------------------------------------+

  my $buffer = '';
  foreach my $name (@toStringOrd)
    {
      #next if ($name =~ m/^_/);
      my $showVal = Data::Vindication::showValue($self->{$name});
      $buffer .= sprintf
                   (
                     "%3s %${maxLabelWidth}s: %s\n",
                     $annotation{$name}, $name, $showVal
                   );
    }

  return($buffer);
}

#==============================================================================
#  Module Runtime Initializations  ============================================
#==============================================================================

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
L<https://github.com/[% github.name %]/[% github.project %]/issues>.

=head1 REPOSITORY

L<https://github.com/[% github.name %]/[% github.project %]>

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
