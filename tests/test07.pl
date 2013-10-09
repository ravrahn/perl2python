#!/usr/bin/perl -w

# STDIN AND ARGV
# mine can't do these

while ($line = <>) {
	print $line;
}

for $arg (@ARGV) {
	print $ARGV[0];
}