#!perl -I..

# Test the Readonly function

use strict;
use Test::More tests => 10;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

eval 'Readonly \my $ros => 45;';
is $@ => '', 'Create scalar';

eval 'Readonly \my $ros2 => 45;  $ros2 = 45;';
like $@,qr/readonly scalar/, 'Modify scalar';

eval 'Readonly \my @roa => (1, 2, 3, 4);';
is $@ => '', 'Create array';

eval 'Readonly \my @roa2 => (1, 2, 3, 4); $roa2[2] = 3;';
like $@ => qr/readonly array/, 'Modify array';

eval 'Readonly \my %roh => (key1 => "value", key2 => "value2");';
is $@ => '', 'Create hash (list)';

eval 'Readonly \my %roh => (key1 => "value", "key2");';
like $@ => qr/odd number of values/, 'Odd number of values';

eval 'Readonly \my %roh2 => (key1 => "value", key2 => "value2"); $roh2{key1}="value";';
like $@ => qr/readonly hash/, 'Modify hash';

eval 'Readonly \my %roh => {key1 => "value", key2 => "value2"};';
is $@ => '', 'Create hash (hashref)';

eval 'Readonly \my %roh2 => {key1 => "value", key2 => "value2"}; $roh2{key1}="value";';
like $@ => qr/readonly hash/, 'Modify hash';
