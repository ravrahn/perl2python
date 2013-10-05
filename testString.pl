#!/usr/bin/perl -w


sub StringToStr {
	# converts a perl string, like "hello $world\n".$hello." world\n"
	# into an array of vars and strings

	my ($string) = @_;
	my $str = [];

	my $newString = $string;

	# remove variables from inside strings
	$newString =~ s/"([^"^\.]*)(\$[a-zA-Z][a-zA-Z0-9_]*)([^"^\.]*)"/"$1".$2."$3"/g;

	# replace "hello "."world" with "hello world"
	$newString =~ s/"\s*\.\s*"//g;

	# because there are no legal variable names inside strings,
	# and we need to split on dots,
	# we can replace dots inside strings with "$dot",
	# because it is guaranteed not to be in the strings anywhere else
	$newString =~ s/("[^"^\.]*?)\.([^"^\.]*")/$1\$dot$2/g;

	# now the string is in perl concat format
	# "string" . $var . "string" . $var, etc.
	# and dots inside strings have been replaced with $dot

	@strings = split(/\./, $newString);

	foreach my $item (@strings) {
		if ($item =~ /^\$[a-zA-Z][a-zA-Z0-9_]*$/) {
		} else {
			$item =~ s/\$dot/./g;
		}
		push @{$str}, $item;
	}

	return $str;
}

sub printStr {
	my ($str) = @_;
	my @string = @{$str};

	foreach $str (@string) {
		print "$str\n";
	}
}

while (<>) {
	&printStr(&StringToStr($_));
}