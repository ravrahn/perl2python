#!/usr/bin/perl -w

# 'make bricks'

$shortBricks = $ARGV[0];
$longBricks = $ARGV[1];
$equals = $ARGV[2];

if ($shortBricks + $longBricks*5 == $equals) {
	print "True\n";
} else {
	print "False\n";
}