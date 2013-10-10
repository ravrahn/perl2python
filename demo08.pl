#!/usr/bin/perl -w

# Euler 48

$sum = 0;

foreach $i (0..1000) {
	$sum += $i ** $i
}

print $sum;