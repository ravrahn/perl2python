#!/usr/bin/perl -w

# FOR

for $i (@arr) {
	print $i."\n";
}

foreach $i (@arr) {
	print $i;
}

# LAST AND NEXT

last;
next;