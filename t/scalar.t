#!perl -I..

# Readonly scalar tests

use strict;
use Test::More tests => 12;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }


use vars qw/$s1 $s2/;
my ($ms1, $ms2);
my $err = qr/^Attempt to modify a readonly scalar/;

# creation (4 tests)
eval 'Readonly::Scalar $s1 => 13;';
is $@ => '', 'Create a global scalar';
eval 'Readonly::Scalar $ms1 => 31;';
is $@ => '', 'Create a lexical scalar';
eval 'Readonly::Scalar $s2 => undef;';
is $@ => '', 'Create an undef global scalar';
eval 'Readonly::Scalar $ms2;';
like $@ => qr/^Not enough arguments for Readonly::Scalar/, 'Try w/o args';

# fetching (4 tests)
is $s1  => 13, 'Fetch global';
is $ms1 => 31, 'Fetch lexical';
ok !defined $s2, 'Fetch undef global';
ok !defined $ms2, 'Fetch undef lexical';

# storing (2 tests)
eval {$s1 = 7;};
like $@  => $err, 'Error setting global';
is $s1 => 13, 'Readonly global value unchanged';

# untie (1 test)
SKIP:{
	skip "Can't catch 'untie' until perl 5.6", 1 if $] < 5.006;
	eval {untie $ms1;};
	like $@ => $err, 'Untie';
	}
