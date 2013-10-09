#!/usr/bin/perl -w

# MISC FUNCTIONS

$a = "\nhello\n";
print chomp $a;

@arr = split //, $a;

print join " ", @arr;

print pop @arr;

print shift @arr;

shift @arr, "a";
push @arr, "z";
print @arr;

print join "", reverse @arr;