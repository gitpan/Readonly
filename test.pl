# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use Test;
BEGIN {
my $num_tests = 66;
$num_tests -= 2  unless $] >= 5.006;
plan tests => $num_tests;
};
use Readonly;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.


#########################
# Read-only scalar tests
#########################
use vars qw/$s1 $s2/;
my ($ms1, $ms2);
my $err = qr/^Attempt to modify a readonly scalar/;

# creation
eval 'Readonly::Scalar $s1 => 13;';
ok($@,'');
eval 'Readonly::Scalar $ms1 => 31;';
ok($@,'');
eval 'Readonly::Scalar $s2 => undef;';
ok($@,'');
eval 'Readonly::Scalar $ms2;';
ok($@,qr/^Not enough arguments for Readonly::Scalar/);

# fetching
ok($s1,  13);
ok($ms1, 31);
ok(!defined $s2);
ok(!defined $ms2);

# storing
eval {$s1 = 7;};
ok($@, $err);
ok($s1, 13);

# untie
eval {untie $ms1;};
ok($@, ($]>5.006)? $err : '');


#########################
# Read-only array tests
#########################
use vars qw/@a1 @a2/;
my @ma1;
$err = qr/^Attempt to modify a readonly array/;

# creation
eval 'Readonly::Array @a1;';
ok($@,'');
eval 'Readonly::Array @ma1 => ();';
ok($@,'');
eval 'Readonly::Array @a2 => (1,2,3,4,5);';
ok($@,'');

# fetching
ok($a1[0],undef);
ok($a2[0],1);
ok($a2[-1],5);

# fetch size
ok(scalar(@a1),0);
ok(scalar(@ma1),0);
ok($#a2,4);

# store
eval {$ma1[0] = 5;};
ok($@, $err);
eval {$a2[3] = 4;};
ok($@, $err);

# storesize
eval {$#a1 = 15;};
ok($@, $err);

# extend
eval {$a1[77] = 88;};
ok($@, $err);

# exists
eval 'ok(exists $a2[4])'    if $] >= 5.006;
eval 'ok(!exists $ma1[4])'  if $] >= 5.006;

# clear
eval {@a1 = ();};
ok($@, $err);

# push
eval {push @ma1, -1;};
ok($@, $err);

# unshift
eval {unshift @a2, -1;};
ok($@, $err);

# pop
eval {pop (@a2);};
ok($@, $err);

# shift
eval {shift (@a2);};
ok($@, $err);

# splice
eval {splice @a2, 0, 1;};
ok($@, $err);

# untie
eval {untie @a2;};
ok($@, ($]>5.006)? $err : '');


#########################
# Read-only hash tests
#########################
use vars qw/%h1/;
my (%mh1, %mh2);
$err = qr/Attempt to modify a readonly hash/;

# creation
eval 'Readonly::Hash %h1 => (a=>"A", b=>"B", c=>"C", d=>"D");';
ok($@, '');
eval 'Readonly::Hash %mh1 => (one=>1, two=>2, three=>3, 4);';
ok($@, qr/odd number of values/);
eval 'Readonly::Hash %mh1 => {one=>1, two=>2, three=>3, four=>4};';
ok($@, '');

# fetch
ok($h1{a},'A');
ok(!defined $h1{q});
ok($mh1{two},2);

# store
eval {$h1{a} = 'Z';};
ok($@, $err);

# delete
eval {delete $h1{c};};
ok($@, $err);

# clear
eval {%h1 = ();};
ok($@, $err);

# exists
ok(exists $h1{a});
eval {ok(!exists $h1{x});};
ok($@,'');

# keys, values
my @a = sort keys %h1;
ok($a[0], 'a');
ok($a[1], 'b');
@a = sort values %h1;
ok($a[0], 'A');
ok($a[1], 'B');

# each
my ($k,$v);
while ( ($k,$v) = each %h1)
	{
	$mh2{$k} = $v;
	}
ok($mh2{c}, 'C');
ok($mh2{d}, 'D');

# untie
eval {untie %h1;};
ok($@, ($]>5.006)? $err : '');


#########################
# Examples from the docs
#########################
my ($a, @a, %a);

eval 'Readonly::Scalar $a => "A string value";';
ok($@, '');

my $computed_value = 5 + 5;
eval 'Readonly::Scalar $a => $computed_value;';
ok($@, '');

eval 'Readonly::Array @a => (1, 2, 3, 4);';
ok($@, '');

eval 'Readonly::Array @a => 1, 2, 3, 4;';
ok($@, '');

eval 'Readonly::Array @a => qw/1 2 3 4/;';
ok($@, '');

my @computed_values = qw/a b c d e f/;
eval 'Readonly::Array @a => @computed_values;';
ok($@, '');

eval 'Readonly::Array @a => ();';
ok($@, '');
eval 'Readonly::Array @a;';
ok($@, '');

eval 'Readonly::Hash %a => (key1 => "value1", key2 => "value2");';
ok($@, '');

my %computed_values = qw/a A b B c C d D/;
eval 'Readonly::Hash %a => %computed_values;';
ok($@, '');

eval 'Readonly::Hash %a => ();';
ok($@, '');
eval 'Readonly::Hash %a;';
ok($@, '');

eval 'Readonly::Hash %a => (key1 => "value1", "value2");';
ok($@, qr/odd number of values/);
