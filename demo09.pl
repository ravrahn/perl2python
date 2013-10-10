#!/usr/bin/perl -w

# first n fib numbers

$end = $ARGV[0];

print "1";

$i = 1;
$j = 1;
$count = 0;
while ($count < $end) {
	print " $i";
	$temp = $i;
	$i = $i + $j;
	$j = $temp;
	$count++;
}

print "\n";