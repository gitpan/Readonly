#!perl -I..

# Examples from the docs -- make sure they work!

use strict;
use Test::More tests => 22;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

my ($a, @a, %a);
my $err = qr/^Attempt to modify a readonly/;

eval 'Readonly::Scalar $a => "A string value";';
is $@ => '', 'A string value';

my $computed_value = 5 + 5;
eval 'Readonly::Scalar $a => $computed_value;';
is $@ => '', 'Scalar computed value';

eval 'Readonly::Array @a => (1, 2, 3, 4);';
is $@ => '', 'Array, with parens';

eval 'Readonly::Array @a => 1, 2, 3, 4;';
is $@ => '', 'Array, without parens';

eval 'Readonly::Array @a => qw/1 2 3 4/;';
is $@ => '', 'Array, with qw';

my @computed_values = qw/a b c d e f/;
eval 'Readonly::Array @a => @computed_values;';
is $@ => '', 'Array, with computed values';

eval 'Readonly::Array @a => ();';
is $@ => '', 'Empty array 1';
eval 'Readonly::Array @a;';
is $@ => '', 'Empty array 2';

eval 'Readonly::Hash %a => (key1 => "value1", key2 => "value2");';
is $@ => '', 'Hash constant';

my %computed_values = qw/a A b B c C d D/;
eval 'Readonly::Hash %a => %computed_values;';
is $@ => '', 'Hash, computed values';

eval 'Readonly::Hash %a => ();';
is $@ => '', 'Empty hash 1';
eval 'Readonly::Hash %a;';
is $@ => '', 'Empty hash 2';

eval 'Readonly::Hash %a => (key1 => "value1", "value2");';
like $@, qr/odd number of values/, 'Odd number of values';

# Shallow vs deep (8 tests)
use vars qw/@shal @deep/;

eval 'Readonly::Array1 @shal => (1, 2, {perl=>"Rules", java=>"Bites"}, 4, 5)';
eval 'Readonly::Array  @deep => (1, 2, {perl=>"Rules", java=>"Bites"}, 4, 5)';

eval '$shal[1] = 7';
like $@ => $err, 'deep test 1';
is $shal[1] => 2, 'deep test 1 confirm';

eval '$shal[2]{APL}="Weird"';
is $@ => '', 'deep test 2';
is $shal[2]{APL} => "Weird", 'deep test 2 confirm';

eval '$deep[1] = 7';
like $@ => $err, 'deep test 3';
is $deep[1] => 2, 'deep test 3 confirm';

eval '$deep[2]{APL}="Weird"';
like $@ => $err, 'deep test 4';
ok !exists($deep[2]{APL}), 'deep test 4 confirm';
