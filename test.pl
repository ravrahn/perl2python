#!/usr/bin/perl -w

$hello = "greetings!";

print "$hello\n";

print "hello!";
print "hello\n";

$i = 0;
while ($i < 10) {
	if ($i % 2 == 0) {print "hi";}
	$i++; $i--; $i++;
}

if ($i > 2) {
	print "sup\n";
	print "sup";
}

# $i++ and i-- should not change in comments
$a = "or in strings! $i-- i++"; # or inline comments! $hello $i++ i--
$i--;

print $i;

@array = ();

foreach $line (@array) {
	# stuff;
}