# Package for defining constants of various types

require 5.005;
use strict;
$Readonly::VERSION = 0.05;    # Also change in the documentation!


# ----------------
# Read-only scalars
# ----------------
package Readonly::Scalar;
use Carp;

sub TIESCALAR
	{
	my $class = shift;
	unless (@_)
		{
		croak "No value specified for readonly scalar";
		}
	unless (@_ == 1)
		{
		croak "Too many values specified for readonly scalar";
		}
	my $value = shift;

	return bless \$value, $class;
	}

sub FETCH
	{
	my $self = shift;
	return $$self;
	}

sub STORE
	{
	croak "Attempt to modify a readonly scalar";
	}

sub UNTIE
	{
	croak "Attempt to modify a readonly scalar";
	}


# ----------------
# Read-only arrays
# ----------------
package Readonly::Array;
use Carp;

sub TIEARRAY
	{
	my $class = shift;
	my @self = @_;

	return bless \@self, $class;
	}

sub FETCH
	{
	my $self  = shift;
	my $index = shift;
	return $self->[$index];
	}

sub STORE
	{
	croak "Attempt to modify a readonly array";
	}

sub FETCHSIZE
	{
	my $self = shift;
	return scalar @$self;
	}

sub STORESIZE
	{
	croak "Attempt to modify a readonly array";
	}

sub EXTEND
	{
	croak "Attempt to modify a readonly array";
	}

eval q{
sub EXISTS
	{
	my $self  = shift;
	my $index = shift;
	return exists $self->[$index];
	}
} if $] >= 5.006;    # couldn't do "exists" on arrays before then

sub CLEAR
	{
	croak "Attempt to modify a readonly array";
	}

sub PUSH
	{
	croak "Attempt to modify a readonly array";
	}

sub UNSHIFT
	{
	croak "Attempt to modify a readonly array";
	}

sub POP
	{
	croak "Attempt to modify a readonly array";
	}

sub SHIFT
	{
	croak "Attempt to modify a readonly array";
	}

sub SPLICE
	{
	croak "Attempt to modify a readonly array";
	}

sub UNTIE
	{
	croak "Attempt to modify a readonly array";
	}


# ----------------
# Read-only hashes
# ----------------
package Readonly::Hash;
use Carp;

sub TIEHASH
	{
	my $class = shift;

	# must have an even number of values
	unless (@_ %2 == 0)
		{
		croak "May not store an odd number of values in a hash";
		}
	my %self = @_;
	return bless \%self, $class;
	}

sub FETCH
	{
	my $self = shift;
	my $key  = shift;

	return $self->{$key};
	}

sub STORE
	{
	croak "Attempt to modify a readonly hash";
	}

sub DELETE
	{
	croak "Attempt to modify a readonly hash";
	}

sub CLEAR
	{
	croak "Attempt to modify a readonly hash";
	}

sub EXISTS
	{
	my $self = shift;
	my $key  = shift;
	return exists $self->{$key};
	}

sub FIRSTKEY
	{
	my $self = shift;
	my $dummy = keys %$self;
	return scalar each %$self;
	}

sub NEXTKEY
	{
	my $self = shift;
	return scalar each %$self;
	}

sub UNTIE
	{
	croak "Attempt to modify a readonly hash";
	}


# ----------------------------------------------------------------
# Main package, containing convenience functions (so callers won't
# have to explicitly tie the variables themselves).
# ----------------------------------------------------------------
package Readonly;
use Carp;
use Exporter;
use vars qw/@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS/;
push @ISA, 'Exporter';
push @EXPORT_OK, qw/Scalar Array Hash/;

sub Scalar ($$)
	{
	return tie $_[0], 'Readonly::Scalar', $_[1];
	}

sub Array (\@;@)
	{
	my $aref = shift;
	return tie @$aref, 'Readonly::Array', @_;
	}

sub Hash (\%;@)
	{
	my $href = shift;

	# If only one value, and it's a hashref, expand it
	if (@_ == 1  &&  ref $_[0] eq 'HASH')
		{
		return tie %$href, 'Readonly::Hash', %{$_[0]};
		}

	# otherwise, must have an even number of values
	unless (@_ %2 == 0)
		{
		croak "May not store an odd number of values in a hash";
		}

	return tie %$href, 'Readonly::Hash', @_;
	}

1;
__END__

=head1 NAME

Readonly - Facility for creating read-only scalars, arrays, hashes.

=head1 VERSION

This documentation describes version 0.05 of Readonly.pm, March 15, 2002.

=head1 SYNOPSIS

 use Readonly;

 # Read-only scalar
 Readonly::Scalar     $sca => $initial_value;
 Readonly::Scalar  my $sca => $initial_value;

 # Read-only array
 Readonly::Array      @arr => @values;
 Readonly::Array   my @arr => @values;

 # Read-only hash
 Readonly::Hash       %has => (key => value, key => value, ...);
 Readonly::Hash    my %has => (key => value, key => value, ...);
 # or:
 Readonly::Hash       %has => {key => value, key => value, ...};

 # You can use the read-only variables like any regular variables:
 print $sca;
 $something = $sca + $arr[2];
 next if $has{$some_key};

 # But if you try to modify a value, your program will die:
 $sca = 7;            # "Attempt to modify readonly scalar"
 push @arr, 'seven';  # "Attempt to modify readonly array"
 delete $has{key};    # "Attempt to modify readonly hash"


=head1 DESCRIPTION

This is a facility for creating non-modifiable variables.
This is useful for configuration files, headers, etc.


=head1 COMPARISON WITH "use constant" OR TYPEGLOB CONSTANTS

=over 1

=item *

Perl provides a facility for creating constant scalars, via the "use
constant" pragma.  That built-in pragma creates only scalars and
lists; it creates variables that have no leading $ character and which
cannot be interpolated into strings.  It works only at compile
time. You cannot take references to these constants.

=item *

Another popular way to create read-only scalars is to modify the symbol
table entry for the variable by using a typeglob:

 *a = \"value";

This works fine, but it only works for global variables ("my"
variables have no symbol table entry).  Also, the following similar
constructs do B<not> work:

 *a = [1, 2, 3];      # Does NOT create a read-only array
 *a = { a => 'A'};    # Does NOT create a read-only hash

=item *

Readonly.pm, on the other hand, will work with global variables and
with lexical ("my") variables.  It will create scalars, arrays, or
hashes, all of which look and work like normal, read-write Perl
variables.  You can use them in scalar context, in list context; you
can take references to them, pass them to functions, anything.

However, Readonly.pm does impose a performance penalty.  This is
probably not an issue for most configuration variables.  But benchmark
your program if it might be.

=back 1

=head1 FUNCTIONS

=over 4

=item Readonly::Scalar $var => $value;

Creates a nonmodifiable scalar, C<$var>, and assigns a value of
C<$value> to it.  Thereafter, its value may not be changed.  Any
attempt to modify the value will cause your program to die.

A value I<must> be supplied.  If you want the variable to have
C<undef> as its value, you must specify C<undef>.

=item Readonly::Array @arr => (value, value, ...);

Creates a nonmodifiable array, C<@arr>, and assigns the specified list
of values to it.  Thereafter, none of its values may be changed; the
array may not be lengthened or shortened or spliced.  Any attempt to
do so will cause your program to die.

=item Readonly::Hash %h => (key => value, key => value, ...);

=item Readonly::Hash %h => {key => value, key => value, ...};

Creates a nonmodifiable hash, C<%h>, and assigns the specified keys
and values to it.  Thereafter, its keys or values may not be changed.
Any attempt to do so will cause your program to die.

A list of keys and values may be specified (with parentheses in the
synopsis above), or a hash reference may be specified (curly braces in
the synopsis above).  If a list is specified, it must have an even
number of elements, or the function will die.

=back

=head1 EXAMPLES

 # SCALARS: 

 # A plain old read-only value
 Readonly::Scalar $a => "A string value";

 # The value need not be a compile-time constant:
 Readonly::Scalar $a => $computed_value;


 # ARRAYS:

 # A read-only array:
 Readonly::Array @a => (1, 2, 3, 4);

 # The parentheses are optional:
 Readonly::Array @a => 1, 2, 3, 4;

 # You can use Perl's built-in array quoting syntax:
 Readonly::Array @a => qw/1 2 3 4/;

 # You can initialize a read-only array from a variable one:
 Readonly::Array @a => @computed_values;

 # A read-only array can be empty, too:
 Readonly::Array @a => ();
 Readonly::Array @a;        # equivalent


 # HASHES

 # Typical usage:
 Readonly::Hash %a => (key1 => 'value1', key2 => 'value2');

 # A read-only hash can be initialized from a variable one:
 Readonly::Hash %a => %computed_values;

 # A read-only hash can be empty:
 Readonly::Hash %a => ();
 Readonly::Hash %a;        # equivalent

 # If you pass an odd number of values, the program will die:
 Readonly::Hash %a => (key1 => 'value1', "value2");
     --> dies with "May not store an odd number of values in a hash"


=head1 EXPORTS

By default, this module exports no symbols into the calling program's
namespace.  The following symbols are available for import into your
program, if you like:

 Scalar
 Array
 Hash

=head1 REQUIREMENTS

 Perl 5.005
 Carp.pm (included with Perl)
 Exporter.pm (included with Perl)

=head1 AUTHOR / COPYRIGHT

Eric J. Roode, eric@myxa.com

Copyright (c) 2001-2002 by Eric J. Roode. All Rights Reserved.  This module
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

If you have suggestions for improvement, please drop me a line.  If
you make improvements to this software, I ask that you please send me
a copy of your changes. Thanks.


=cut
