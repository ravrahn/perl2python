#!/usr/bin/perl -w

# ASSIGNING
#    AND
# OPERATORS

$a = 1 + 2;
# variables on the right side
$hello = $a * 2 + (2**($a));

# invalid name - comment out
# $50 = 1 + 2;

# silly brackets
$foo = (1 + (2 ** (3 * (4 - 5)) + 6 + 7));

# all operators
$arith = (1 + 2 - 3 * 4 / 5 % 6 ** 7);

if ((1 || 2) && (3 and !4) or (not 5)) {
	print "boolean operators";
}
if ((1 < 2) && (2 <= 3) && (3 >= 4) && (4 != 5) && (5 == 6)) {
	print "comparison operators";
}

$bit = (1 | 2);
$bit = (2 ^ 3);
$bit = (3 & 4);
$bit = (4 << 5);
$bit = (5 >> 6);
$bit = (~7);

print $hello.$foo.$arith.$bit; # to stop it complaining