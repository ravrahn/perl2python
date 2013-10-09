#!/usr/bin/perl -w

$hello = "greetings";

$world = "world";

print "$hello\n";

print "hello $world\n".$hello." world\n";

print "hello... ";
print "hello\n";

$i = 0;
while ($i < 50) {
	if ($i == 6) {
		$i++;
		next;
	}
	if ($i % 2 == 0 and $i > 4) {$i++}
	print "$i\n";
	$i++; $i--; $i++;
	if ($i == 10) {
		last;
	}
}

if ($i > 2) {
	print "sup ";
	print "sup\n";
}

# $i++ and i-- should not change in comments
$a = "or in strings! $i-- i++"; # or inline comments! $hello $i++ i--
print $a;
$i--;

print $i;

print "\n";

@array = ();

foreach $line (@array) {
	$line = "hello";
	# stuff;
}