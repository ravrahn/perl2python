#!/usr/bin/perl -w

# Euler 6
# difference of sum of squares and squares of sums

$squareOfSum = 0;
$sumOfSquare = 0;

foreach $i (0..100) {
	$squareOfSum += $i;
	$sumOfSquare += $i ** 2;
}

$squareOfSum = $squareOfSum ** 2;

$result = $squareOfSum - $sumOfSquare;

print "$result\n";