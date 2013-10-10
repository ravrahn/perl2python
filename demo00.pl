#!/usr/bin/perl -w

# Prints an ascii mandelbrot set

$row = 0;
$col = 0;

$length = $ARGV[0]/3;
$width = $ARGV[0];

while ($row < $length) {
	while ($col < $width) {
		$xCoord = ($col - $width/2) / ($width/3.0);
		$yCoord = ($row - $length/2) / ($width/6.0);

		$y = 0;
	    $x = 0;
	    $steps = 0;
	    
	    while ( $x*$x + $y*$y < 2*2  &&  $steps < 256) {
	        $xtemp = ($x*$x) - ($y*$y) + $xCoord;
	        $y = (2*$x*$y) + $yCoord;
	        
	        $x = $xtemp;
	        
	        $steps++;
	    }

	    if ($steps == 256) {
	    	print "&";
	    } else {
	    	print " ";
	    }

			$col++;
		}
	print "\n";
	$row++;
	$col = 0;
}