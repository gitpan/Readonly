#!perl -I..

# Readonly reassignment-prevention tests

use strict;
use Test::More tests => 16;

# Find the module (1 test)
BEGIN {use_ok('Readonly'); }

sub expected
{
    my $line = shift;
    $@ =~ s/\.$//;   # difference between croak and die
    return "Modification of a read-only value attempted at " . __FILE__ . " line $line\n";
}

use vars qw($s1 @a1 %h1 $s2 @a2 %h2);

Readonly::Scalar $s1 => 'a scalar value';
Readonly::Array  @a1 => 'an', 'array', 'value';
Readonly::Hash   %h1 => {a => 'hash', of => 'things'};

my $err = qr/^Attempt to reassign/;

# Reassign scalar
eval {Readonly::Scalar $s1 => "a second scalar value"};
like $@ => $err, 'Readonly::Scalar reassign die';
is $s1 => 'a scalar value', 'Readonly::Scalar reassign no effect';

# Reassign array
eval {Readonly::Array @a1 => "another", "array"};
like $@ => $err, 'Readonly::Array reassign die';
ok eq_array(\@a1, [qw[an array value]]) => 'Readonly::Array reassign no effect';

# Reassign hash
eval {Readonly::Hash %h1 => "another", "hash"};
like $@ => $err, 'Readonly::Hash reassign die';
ok eq_hash(\%h1, {a => 'hash', of => 'things'}) => 'Readonly::Hash reassign no effect';


# Now use the naked Readonly function

Readonly \$s2 => 'another scalar value';
Readonly \@a2 => 'another', 'array', 'value';
Readonly \%h2 => {another => 'hash', of => 'things'};

# Reassign scalar
eval {Readonly \$s2 => "something bad!"};
like $@ => $err, 'Readonly Scalar reassign die';
is $s2 => 'another scalar value', 'Readonly Scalar reassign no effect';

# Reassign array
eval {Readonly \@a2 => "something", "bad", "!"};
like $@ => $err, 'Readonly Array reassign die';
ok eq_array(\@a2, [qw[another array value]]) => 'Readonly Array reassign no effect';

# Reassign hash
eval {Readonly \%h2 => {another => "bad", hash => "!"}};
like $@ => $err, 'Readonly Hash reassign die';
ok eq_hash(\%h2, {another => 'hash', of => 'things'}) => 'Readonly Hash reassign no effect';


# Reassign real constants
eval {Readonly::Scalar "hello" => "goodbye"};
like $@ => $err, 'Reassign real string';
eval {Readonly::Scalar1 6 => 13};
like $@ => $err, 'Reassign real number';
eval {Readonly \"scalar" => "vector"};
is $@ => expected(__LINE__-1),, 'Reassign indirect via ref';
