#!perl -I..

# Readonly array tests

use strict;
use Test::More tests => 23;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

use vars qw/@a1 @a2/;
my @ma1;
my $err = qr/^Attempt to modify a readonly array/;

# creation (3 tests)
eval 'Readonly::Array @a1;';
is $@ =>'', 'Create empty global array';
eval 'Readonly::Array @ma1 => ();';
is $@ => '', 'Create empty lexical array';
eval 'Readonly::Array @a2 => (1,2,3,4,5);';
is $@ => '', 'Create global array';

# fetching (3 tests)
ok !defined($a1[0]), 'Fetch global';
is $a2[0]  => 1, 'Fetch global';
is $a2[-1] => 5, 'Fetch global';

# fetch size (3 tests)
is scalar(@a1)  => 0, 'Global size (zero)';
is scalar(@ma1) => 0, 'Lexical size (zero)';
is $#a2 => 4, 'Global last element (nonzero)';

# store (2 tests)
eval {$ma1[0] = 5;};
like $@ => $err, 'Lexical store';
eval {$a2[3] = 4;};
like $@ => $err, 'Global store';

# storesize (1 test)
eval {$#a1 = 15;};
like $@ => $err, 'Change size';

# extend (1 test)
eval {$a1[77] = 88;};
like $@ => $err, 'Extend';

# exists (2 tests)
SKIP: {
	skip "Can't do exists on array until Perl 5.6", 2  if $] < 5.006;

	eval 'ok(exists $a2[4], "Global exists")';
	eval 'ok(!exists $ma1[4], "Lexical exists")';
	}

# clear (1 test)
eval {@a1 = ();};
like $@ =>  $err, 'Clear';

# push (1 test)
eval {push @ma1, -1;};
like $@ =>  $err, 'Push';

# unshift (1 test)
eval {unshift @a2, -1;};
like $@ =>  $err, 'Unshift';

# pop (1 test)
eval {pop (@a2);};
like $@ =>  $err, 'Pop';

# shift (1 test)
eval {shift (@a2);};
like $@ =>  $err, 'shift';

# splice (1 test)
eval {splice @a2, 0, 1;};
like $@ =>  $err, 'Splice';

# untie (1 test)
SKIP: {
	skip "Can't catch untie until Perl 5.6", 1  if $] <= 5.006;
	eval {untie @a2;};
	like $@ => $err, 'Untie';
	}
