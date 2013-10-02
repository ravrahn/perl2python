#!/usr/bin/perl -w

sub convertString {
	# given a perl string (like "lorem ipsum $sit amet" get it?)
	# converts it to a python string ("lorem ipsum " + $sit + "amet")
	# does not convert variables
	my ($string) = @_;
	my $newString = $string;

	$newString =~ s/"(.*)(\$[a-zA-Z0-9]+)(.*)"/"$1" + $2 + "$3"/g;

	$newString =~ s/\s*\+?\s*""\s*\+?\s*//g;

	return $newString;
}

@file = ();

while ($line = <>) {
	push @file, $line;
}

$indents = 0;

foreach $line (@file) {
	print "    " x $indents;
	$newLine = "";
	if ($line =~ /^\s*if\s*\((.*)\)\s*{\s*$/) {
		$newLine = "if $1:";
		$indents++;
	} elsif ($line =~ /^\s*while\s*\((.*)\)\s*{\s*$/) {
		$newLine = "while $1:";
		$indents++;
	} elsif ($line =~ /^\s*foreach\s*\$[a-zA-Z0-9]+\s*\((\@[a-zA-Z0-9]+)\)\s*{\s*$/){
		$newLine = "for $1 in 2:";
		$indents++;
	} elsif ($line =~ /^\s*}\s*$/) {
		$indents--;
	} else {
		$newLine = $line;
		chomp $newLine;
	}

	# replace the hashbang
	$newLine =~ s|^#!/usr/bin/perl( -w)?$|#!/usr/bin/python2.7 -u|;

	# remove existing indents
	$newLine =~ s/^\s*(.*)\s*$/$1/;

	if ($newLine =~ /^\s*[^#]/) { # line is not a comment

		# convert any strings in the line
		$newLine =~ s/("[^"]*")/&convertString($1)/eg;

		# remove sigils in variables
		$newLine =~ s/(\$|@|%)([a-zA-Z0-9]+)/$2/g;

		# change ++ to +=1
		# and -- to -=1
		$newLine =~ s/([a-zA-Z0-9]+)\+\+/$1 += 1/g;
		$newLine =~ s/([a-zA-Z0-9]+)\-\-/$1 -= 1/g;

		# remove trailing semicolons
		$newLine =~ s/;\s*$//;
	}

	

	print "$newLine\n";
}