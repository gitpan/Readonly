#!perl -I..

# Test Scalar vs Scalar1 functionality

use strict;
use Test::More tests => 21;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

use vars qw/$s1 $s2 $s3 $s4/;
my $m1 = 17;
my $m2 = \$m1;

my $err = qr/^Attempt to modify a readonly/;

# Create (4 tests)
eval 'Readonly::Scalar1 $s1 => ["this", "is", "a", "test", {x => 5}]';
is $@ => '', 'Create a shallow reference scalar';
eval 'Readonly::Scalar  $s2 => ["this", "is", "a", "test", {x => 5}]';
is $@ => '', 'Create a deep reference scalar';
eval 'Readonly::Scalar1 $s3 => $m2;';
is $@ => '', 'Create a shallow scalar ref';
eval 'Readonly::Scalar  $s4 => $m2;';
is $@ => '', 'Create a deep scalar ref';

# Modify (16 tests)
eval '$s1 = 7;';
like $@ => $err, 'Modify s1';
eval '$s2 = 7;';
like $@ => $err, 'Modify s2';
eval '$s3 = 7;';
like $@ => $err, 'Modify s3';
eval '$s4 = 7;';
like $@ => $err, 'Modify s4';

eval '$s1->[2] = "the";';
is $@ => '', 'Deep-modify s1';
is $s1->[2] => 'the', 's1 modification successful';

eval '$s2->[2] = "the";';
like $@ => $err, 'Deep-modify s2';
is $s2->[2] => 'a', 's2 modification supposed to fail';

eval '$s1->[4]{z} = 42;';
is $@ => '', 'Deep-deep modify s1';
is $s1->[4]{z} => 42, 's1 mod successful';

eval '$s2->[4]{z} = 42;';
like $@ => $err, 'Deep-deep modify s2';
ok !exists($s2->[4]{z}), 's2 mod supposed to fail';

eval '$$s4 = 21';
like $@ => $err, 'Deep-modify s4 should fail';
is $m1 => 17, 's4 mod should fail';

eval '$$s3 = "bah"';
is $@ => '', 'deep s3 mod';
is $m1 => 'bah', 'deep s3 mod';
