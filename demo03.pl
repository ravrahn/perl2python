#!/usr/bin/perl -w

# wonderous numbers

$x = $ARGV[0];

print "$x ";

$count = 0;
while ($x != 1) {
    if ($x % 2 == 0) {
        $x = $x / 2;
    } else {
        $x = 3 * $x;
        $x++;
    }
    print $x;
    $count++;
    
    if ($x == 1) {
        print "\n";
    } else {
        print " ";
    }
}

print "Printed ".$count." terms.\n";