#!perl -I..

# Test Array vs Array1 functionality

use strict;
use Test::More tests => 13;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

use vars qw/@a1 @a2/;
my $m1 = 17;

my $err = qr/^Attempt to modify a readonly/;

# Create (2 tests)
eval 'Readonly::Array  @a1 => (\$m1, {x => 5, z => [1, 2, 3]})';
is $@ => '', 'Create a deep reference array';
eval 'Readonly::Array1 @a2 => (\$m1, {x => 5, z => [1, 2, 3]})';
is $@ => '', 'Create a shallow reference array';

# Modify (10 tests)
eval '$a1[0] = 7;';
like $@ => $err, 'Modify a1';
eval '$a2[0] = 7;';
like $@ => $err, 'Modify a2';

eval '${$a1[0]} = "the";';
like $@ => $err, 'Deep-modify a1';
is $m1 => 17, 'a1 unchanged';

eval '${$a2[0]} = "the";';
is $@ => '', 'Deep-modify a2';
is $m1 => 'the', 'a2 modification successful';

eval '$a1[1]{z}[1] = 42;';
like $@ => $err, 'Deep-deep modify a1';
is $a1[1]{z}[1] => 2, 'a1 unchanged';

eval '$a2[1]{z}[2] = 42;';
is $@ => '', 'Deep-deep modify a2';
is $a2[1]{z}[2], 42, 'a2 mod successful';
