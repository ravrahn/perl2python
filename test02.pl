#!/usr/bin/perl -w

# WHILE AND IF

$i = 0;
while ($i < 50) {
	if ($i == 6) {
		$i++;
		next;
	}
	if ($i % 2 == 0 and $i > 4) {
		$i++
	}
	$i++;
	if ($i == 10) {
		last;
	}
}