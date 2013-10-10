#!/usr/bin/perl -w

# Waffle Iron
# prints a waffle of size specified in arguments

$waffleSize = $ARGV[0];

$j = 0;
while ($j < $waffleSize+1) {
    if ($j == 0) {
    	$i = 0;
        while ($i <= $waffleSize*2) {
            print "_";
            $i++;
        }
    } else {
    	$i = 0;
        while ($i <= $waffleSize) {
            if ($i == 0) {
                print "|";
            } else {
                print "_|";
            }
            $i++;
        }
    }
    print "\n";
    $j++;
}

return 0;