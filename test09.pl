#!/usr/bin/perl -w

# REGEX

$a = "hello my name is owen";

if ($a =~ /owen/) {
	print "found you";
}

if ($a =~ /^owen$/) {
	print "you're all alone";
}

if ($a =~ /owen$/) {
	print "this is the end";
}

if ($a =~ /$a$/ && not ($a =~ /\$a$/)) {
	print "wow nice"
}