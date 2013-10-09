#!/usr/bin/perl -w

use strict;
use warnings;

sub StringToStr {
	# converts a perl string, like "hello $world\n".$hello." world\n"
	# into an array of vars and strings

	my ($string) = @_;
	my $str = ["str"];

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

sub operSplit {
	# so I didn't need to have
	# these lines
	# 10 times over and over
	# in the multi-char bit
	my ($expr, $char, $chars) = @_;
	my @chars = @{$chars};

	my $str = join "", @chars;
	$str =~ s/^\s*(.*)\s*$/$1/;
	push @{$expr}, $str;
	push @{$expr}, $char;
}

sub StringToExpr {
	# converts a string containing a perl expression
	# like "1 + $i" or "1 == $i"
	# into an array of ints, opers, and vars.

	my ($string) = @_;
	my $expr = ["expr"];

	# /and|or|not|<=|>=|<>|!=|==|eq|<<|>>|&|~|\||\^|\+|\-|\*\*|\*|\/|%|\|\||&&|!|<|>/, $string;
	
	my @string = split //, $string;

	my @chars = ();
	while (@string) { # go through char-by-char
		my $char = shift @string;
		if ($char =~ /\+|\^|\-|~|%|\.|\//) { # operators that cannot be the start of a multi-char operator
			&operSplit($expr, $char, \@chars);
			@chars = ();
		# operators that can be the start of a multi-char operator
		} elsif ($char =~ /</) {
			if ($string[0] =~ /(>|<|=)/) {
				shift @string;
				&operSplit($expr, $char.$1, \@chars);
				@chars = ();
			} else {
				&operSplit($expr, $char, \@chars);
				@chars = ();
			}
		} elsif ($char =~ />/) {
			if ($string[0] =~ /(=|>)/) {
				shift @string;
				&operSplit($expr, $char.$1, \@chars);
				@chars = ();
			} else {
				&operSplit($expr, $char, \@chars);
				@chars = ();
			}
		} elsif ($char =~ /=/) {
			if ($string[0] =~ /=/) {
				shift @string;
				&operShift($expr, $char."=", \@chars);
				@chars = ();
			} else {
				# = is not a normal operator so it's just pushed on
				# if it's not ==
				push @chars, $char;
			}
		} elsif ($char =~ /!/) {
			if ($string[0] =~ /=/) {
				shift @string;
				&operSplit($expr, $char."=", \@chars);
				@chars = ();
			} else {
				&operSplit($expr, $char, \@chars);
				@chars = ();
			}
		} elsif ($char =~ /&/) {
			if ($string[0] =~ /&/) {
				shift @string;
				&operSplit($expr, $char."&", \@chars);
				@chars = ();
			} else {
				&operSplit($expr, $char, \@chars);
				@chars = ();
			}
		} elsif ($char =~ /\*/) {
			if ($string[0] =~ /\*/) {
				shift @string;
				&operSplit($expr, $char."*", \@chars);
				@chars = ();
			} else {
				&operSplit($expr, $char, \@chars);
				@chars = ();
			}
		} elsif ($char =~ /\|/) {
			if ($string[0] =~ /\|/) {
				shift @string;
				&operSplit($expr, $char."|", \@chars);
				@chars = ();
			} else {
				&operSplit($expr, $char, \@chars);
				@chars = ();
			}
		} elsif ($char =~ /\(/) {
			# grab everything inside the brackets
			# and call &StringToExpr on it
			# and add that to the expr array
			my $close = 0;
			my $opens = 1;
			my $i = 0;
			while ($i <= $#string and $opens != 0) {
				if ($string[$i] =~ /\)/) {
					$close = $i;
					$opens--;
				} elsif ($string[$i] =~ /\(/) {
					$opens++;
				}
				$i++;
			}
			my @arr = ();
			foreach my $i (0..$close-1) {
				push @arr, shift @string;
			}
			shift @string;
			push @{$expr}, &StringToExpr((join "", @arr));
		} elsif ($char =~ /"|'/) {
			# grab the whole string
			# and calls &StringToStr on it
			# and add that to the expr array
			my $strend = 0;
			my $i = 0;
			while ($i <= $#string) {
				if ($string[$i] =~ /\\/) {
					$i++;
				} elsif ($string[$i] =~ /$char/) {
					$strend = $i;
				}
				$i++;
			}
			my @arr = ();
			foreach my $i (0..$strend-1) {
				push @arr, shift @string;
			}
			shift @string;
			push @{$expr}, &StringToStr("\"".(join "", @arr)."\"");
		} else {
			push @chars, $char;
		}
	}

	my $str = join "", @chars;
	$str =~ s/^\s*(.*)\s*$/$1/;

	push @{$expr}, (join "", @chars);

	return $expr;
}

sub printStr {
	my (@str) = @_;

	shift @str;

	my $string = "";

	foreach my $line (@str) {
		$string = $string.$line;
	}

	return $string;
}

sub printExpr {
	my (@expr) = @_;

	shift @expr;

	my $string = "";

	foreach my $line (@expr) {
		if ($line =~ /^ARRAY/) {
			if (@{$line}[0] eq "expr") {
				$string = $string."(".&printExpr(@{$line}).")";
			} elsif (@{$line}[0] eq "str") {
				$string = $string."\"".&printStr(@{$line})."\"";
			}
		} else {
			$string = $string.$line." ";
		}
	}

	return $string;
}

while (<>) {
	print &printExpr(@{&StringToExpr($_)});
	print "\n";
}
