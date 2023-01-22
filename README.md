# Error-Grudge #

Perl mix-in for adding new methods for out-of-band error returns for your Perl OO module.

Right now, very much a work in progress.  (Lots of code but it is from
a generic template for a Perl OO module.)  So nothing close to working
yet.  In the meantime, here is a bit of documentation from the
module's POD for a little light reading.

## SYNOPSIS ##

In your module:

```perl

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
```

Meanwhile, in a program that does not check your return status...

```perl

   $myObj->readInputFile('no-such-file');     # Returns with error flag set.
   $myObj->readInputFile('this-one-exists');  # <-- BANG! Exception here,
                                              # but it is the location of
                                              # where the flag was set that
                                              # is reported.

```

Or in a program that does...

```perl

   $myObj->readInputFile('no-such-file');
   warn("skipping file: 'no-such-file'\n")    if ($myObj->hasErrorEvent());

   $myObj->readInputFile('this-one-exists');
   warn("skipping file: 'this-one-exists'\n") if ($myObj->hasErrorEvent());

```

## OVERVIEW ##

This module provides a framework for returning out-of-band return
status information to your caller, but at the same time it will
automatically force an exception if a critical return status is being
ignored.

This module can add the following mix-in methods to your objects for
comprehensive status flagging, analysis, and reporting.  Note that
these verbose method names are designed to make it unlikely they will
collide with your own object method identifiers.

<P><CENTER>
<table>
<tr>
  <th>Object Method</th>
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

The module comes out of the box with a predefined status event
serverity scale:

```perl

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

```

But as illustrated, a class method is provided allowing you to do a
wholesale replacement of this default table with your own preferred
status names and hierarchy.

Finally, a range of events can be configured to determine which should
be flagged and returned as an error, and at what point should an event
immediately cause an exception to be thrown.

```perl

    Error::Grudge->configThreshold
      (
             errorFloor => 'ERROR',  # ERROR and FATAL are flagged
         exceptionFloor => 'LOGIC',  # LOGIC halts immediately
      );

```

Again, these are the initial defaults, which can be changed to suit
your coding needs using the illustrated class method.

## DESCRIPTION ##

Damian Conway, in his book ["Perl Best Practices"](http://www.oreilly.com/catalog/perlbp/),
and in this [Perl.com article](https://www.perl.com/pub/2005/07/14/bestpractices.html),
suggests that it is better to "_throw exceptions instead of returning
special values or setting flags_".  The reasoning is "_developers can
silently ignore flags and return values, and ignoring them requires
absolutely no effort on the part of the programmer._"  In particular
"_Ignoring error indicators frequently causes programs to propagate
errors in entirely the wrong direction._"  And finally "_Constantly
checking return values for failure clutters your code with validation
statements, often greatly decreasing its readability._"

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
module are **NOT THREAD-SAFE**.  While a generous set of convenience
methods are provided for examining and manipulating your object's
event status, as few as three of these methods are needed to cover
most basic use cases.

## Our Error Handling Philosphy ##

- Any and all logic errors should be thrown immediately.  In practice
  this primarily applies to API usage bugs that would have been caught
  at compile time in a more strict language.  The reasoning is that if
  the usage is incorrect, it is very unlikely that any resulting
  data/actions will be rational.  With Perl, some logic errors may
  only be caught at runtime.  It is expected that these will be
  surfaced by unit testing.

- Non-logic errors should be reported to the caller, giving it the
  opportunity to handle the error gracefully.  We want to avoid having
  diagnostic reporting that bypasses the caller.  There is no point
  display warning or error messages that cannot be remedied or
  understood by the end user.  The user interface of the application
  should be responsible for all messaging to its world, be that GUI,
  web browser, terminal, operator console, or batch log.


## AUTHOR ##

Bill Costa  `Bill.Costa@alumni.unh.edu`

## LICENCE AND COPYRIGHT ##

Copyright (c) 2023, Bill Costa `Bill.Costa@alumni.unh.edu`. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

## DISCLAIMER OF WARRANTY ##

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

<!-- EOF: 22-JAN-2023 -->
