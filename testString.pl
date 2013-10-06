#!/usr/bin/perl -w

sub StringToStr {
	# converts a perl string, like "hello $world\n".$hello." world\n"
	# into an array of vars and strings

	my ($string) = @_;
	my $str = [];

	my @string = ();

	my @newString = split //, $string;

	my @currentVar = ();
	my $inString = "";
	my $prevChar = "";
	my $char = "";

	while (@newString) {
		$char = shift @newString;
		if ($inString eq "") {
			if ($char =~ /("|')/ && !($prevChar eq "\\")) {
				$inString = $1;
				push @currentVar, $char;
			} elsif ($char eq ".") {
				push @string, (join "", @currentVar);
				@currentVar = ();
			} else {
				push @currentVar, $char;
			}
		} else {
			if ($char eq $inString) {
				$inString = "";
			}
			push @currentVar, $char;
		}
		$prevChar = $char;
	}
	push @string, (join "", @currentVar);

	foreach (@string) {
		if ($_ =~ /^("|')/) {
			my $tempString = $_;
			$tempString =~ s/(\$[a-zA-Z][a-zA-Z0-9_]*)/".$1."/g;
			if ($tempString eq $_) {
				push @{$str}, $_;
			} else {
				push @{$str}, @{&StringToStr($tempString)};
			}
		} else {
			push @{$str}, $_;
		}
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