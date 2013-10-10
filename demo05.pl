#!/usr/bin/perl -w

# Euler 1

$sum = 0;

foreach $i (0..1000) {
	if ($i % 3 == 0 or $i % 5 == 0) {
		$sum += $i
	}	
}

print $sum."\n";