#!/usr/bin/perl -w

use strict;
use warnings;

#The List data structure:

# Basic Types:
	# string - a string
	# oper - A string containing an arithemetic, logical, comparison, or bitwise operator

# Simple Types:
	# expr - Array containing n instances of str, var, oper
	# str - Array containing n instances of string, var

# Str and expr are dynamic in length
# as such they are stored as n-length arrays
# with their first element being "str" or "expr"
# operators are stored as, for example: ["oper", ">"]

# Complex Types
	# var - string type, string name
	# range - string start, string end
	# assign - var left, expr|str right
	# print - str string
	# if - expr statement, List commands
	# while - expr statement, List commands
	# for - var, set, List commands

# Each complex type is stored in this format:
# [name, {property=>value, property=>value}]
# A value can be another of these 'objects', or even an entire List


sub StringToVar {
	# converts a string containing a perl variable
	# to a 'var' - ["var", {"type"=>type, "name"=>name}]

	my ($string) = @_;

	my $type;
	my $name;

	if ($string =~ /^(\$|@|%)([a-zA-Z][a-zA-Z0-9_]*)/) {
		if ($1 eq "\$") {
			$type = "var";
		} elsif ($1 eq "@") {
			$type = "list";
		} elsif ($1 eq "%") {
			$type = "dict";
		}

		$name = $2;
	} else {
		return $string;
	}

	return ["var", {"type"=>$type, "name"=>$name}];

}

sub StringToStr {
	# converts a perl string, like "hello $world\n".$hello." world\n"
	# into an array of vars and strings

	my ($string) = @_;
	my $str = ["str"];

	my @string = ();

	$string =~ s/^\s*//;

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
			push @{$str}, &StringToVar($_);
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
				&operSplit($expr, $char."=", \@chars);
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
		} elsif ($char =~ /a/) {
			if ($string[0] =~ /n/ and $string[1] =~ /d/) {
				shift @string;
				shift @string;
				&operSplit($expr, $char."nd", \@chars);
				@chars = ();
			} else {
				push @chars, $char;
			}
		} elsif ($char =~ /n/) {
			if ($string[0] =~ /o/ and $string[1] =~ /t/) {
				shift @string;
				shift @string;
				&operSplit($expr, $char."ot", \@chars);
				@chars = ();
			} else {
				push @chars, $char;
			}
		} elsif ($char =~ /o/) {
			if ($string[0] =~ /r/) {
				shift @string;
				&operSplit($expr, $char."r", \@chars);
				@chars = ();
			} else {
				push @chars, $char;
			}
		} elsif ($char =~ /e/) {
			if ($string[0] =~ /q/) {
				shift @string;
				&operSplit($expr, $char."q", \@chars);
				@chars = ();
			} else {
				push @chars, $char;
			}
		} elsif ($char =~ /(\$|@|%)/) {
			if ((defined $string[0]) and $string[0] =~ /[a-zA-Z]/) {
				# grab the rest of the variable
				# turn it into a var
				# and add that to the expr array
				my $varend = 0;
				my $i = 0;
				while ($i <= $#string) {
					if ($string[$i] =~ /[a-zA-Z0-9_]/) {
						$varend = $i+1;
					} else {
						last;
					}
					$i++;
				}
				my @arr = ($char);
				foreach my $i (0..$varend-1) {
					push @arr, shift @string;
				}
				push @{$expr}, &StringToVar((join("", @arr)));
			} else {
				# it's not of interest
				push @chars, $char;
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
				if ($string[$i] =~ /\\/) { # this line obliterates syntax highlighting due to a sublime text bug, I think
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
			# just add it to the array
			push @chars, $char;
		}
	}

	my $str = join "", @chars;
	$str =~ s/^\s*(.*)\s*$/$1/;

	push @{$expr}, $str;

	return $expr;
}

sub PerlToList {
	# converts a perl file, as an array of lines
	# into a list-based language-independant
	# recursive data structure.

	my (@perl) = @_;
	my @list;

	while (@perl) {
		my $item = shift @perl;
		if ($item =~ /^print\s*\(?\s*(.*)\s*\)?\s*$/) { # print
			my $str = $1;
			push @list, ["print", {"string"=>&StringToStr($str)}];

		} elsif ($item =~ /^(if|while|elsif)\s*\((.*?)\)\s*{/) {
			my $ifwhile = $1;
			my $statement = $2;
			my @sublist = ();
			my $endsToIgnore = 0;
			while (1) {
				my $subitem = shift @perl;
				if ($subitem =~ /{$/) {
					$endsToIgnore++;
				}
				if ($subitem =~ /^}$/ and $endsToIgnore == 0) {
					last;
				} elsif ($subitem =~ /^}$/) {
					$endsToIgnore--;
				}
				push @sublist, $subitem;
			}
			my @subcommands = &PerlToList(@sublist);
			push @list, ["$ifwhile", {"statement"=>&StringToExpr($statement), "commands"=>\@subcommands}];
		
		} elsif ($item =~ /^(for|foreach)\s*(\$[a-zA-Z][a-zA-Z0-9_]*)\s*\((.*)\)/) {
			my $var = &StringToVar($2);
			my $set = $3;
			my @sublist = ();
			my $endsToIgnore = 0;
			while (1) {
				my $subitem = shift @perl;
				if ($subitem =~ /{$/) {
					$endsToIgnore++;
				}
				if ($subitem =~ /^}$/ and $endsToIgnore == 0) {
					last;
				} elsif ($subitem =~ /^}$/) {
					$endsToIgnore--;
				}
				push @sublist, $subitem;
			}

			if ($set =~ /(.*)\.\.(.*)/) {
				$set = ["range", {"left"=>$1, "right"=>$2}];
			} else {
				$set = &StringToVar($set);
			}

			my @subcommands = &PerlToList(@sublist);
			push @list, ["for", {"var"=>$var, "set"=>$set, "commands"=>\@subcommands}];

		} elsif ($item =~ /^\$([a-zA-Z][a-zA-Z0-9_]*)\s*\+\+/) { # $i++
			push @list, ["assign", {"left"=>&StringToVar("$1"), "right"=>"$1 + 1"}];
		
		} elsif ($item =~ /^\$([a-zA-Z][a-zA-Z0-9_]*)\s*\-\-/) { # $i--
			push @list, ["assign", {"left"=>&StringToVar("\$$1"), "right"=>"$1 - 1"}];
		
		} elsif ($item =~ /^(\$[a-zA-Z][a-zA-Z0-9_]*)\s*=(.*)/) {
			my $left = $1;
			my $right = $2;
			if ($right =~ /"|'/) { # right side is a string
				push @list, ["assign", {"left"=>&StringToVar("$left"), "right"=>&StringToStr($right)}];
			} else { # right side in an expr
				push @list, ["assign", {"left"=>&StringToVar("$left"), "right"=>&StringToExpr($right)}];
			}

		}else { # unknown (or comment)
			if ($item =~ /^#!/) {
				# completely ignore hashbangs
			} elsif ($item =~ /^$/) {
				push @list, $item;
			} elsif ($item =~ /^#/) {
				push @list, $item;
			} elsif ($item =~ /^last$/) {
				push @list, "break";
			} elsif ($item =~ /^next$/) {
				push @list, "continue";
			} else {
				push @list, "# " . $item;
			}
		}
	}

	return @list;
}

sub ExprToPython {

	my (@expr) = @_;
	my $python = "";

	if (!($expr[0] eq "expr")) {
		return @expr;
	}

	shift @expr;

	foreach (@expr) {
		if ($_ =~ /^ARRAY/) {
			if (@{$_}[0] eq "str") {
				$python = $python." (".&StrToPython(@{$_}).")";
			} elsif (@{$_}[0] eq "var") {
				$python = $python." ".&VarToPython(@{$_});
			} elsif (@{$_}[0] eq "expr") {
				$python= $python."(".&ExprToPython(@{$_}).")";
			}
		} else {
			if ($_ =~ /^\s*!\s*$/) {
				$python = $python." not";
			} elsif ($_ =~ /^\s*\|\|\s*$/) {
				$python = $python." or";
			} elsif ($_ =~ /^\s*&&\s*$/) {
				$python = $python." and";
			} else {
				$python = $python." ".$_;
			}
		}
	}

	return $python;
}

sub VarToPython {
	my (@var) = @_;
	my $python = "";

	if (!($var[0] eq "var")) {
		return @var;
	}

	my %args = %{$var[1]};

	return $args{"name"};
}

sub StrToPython {

	my (@str) = @_;

	my @string = ();


	foreach my $str (@str) {
		if ($str =~ /^str$/) {
			next;
		}
		if ($str =~ /^ARRAY/) {
			my %var = %{@{$str}[1]};
			$str = "str(".$var{"name"}.")";

		}
		push @string, $str;
	}

	my $python = join " + ", @string;

	return $python;
}

sub ListToPython {
	# converts a list-based language-independant
	# recursive data structure into a python file,
	# as an array of lines
	my $noHeader = pop @_;
	my (@list) = @_;
	my @python = ();
	my %imports;

	while (@list) {
		my $item = shift @list;
		my @statement = @{$item} if defined $item and $item =~ /^ARRAY/;

		if (defined $statement[0]) {
			my %args = %{$statement[1]};

			if ($statement[0] eq "print") {
				my $newline;
				my @str;

				my $string = &StrToPython(@{$args{"string"}});

				if ($string =~ /\\n"\s*$/) {
					$newline = 1;
					$string =~ s/\\n"\s*$/"/g;
				} else {
					$newline = 0;
				}

				$string =~ s/\s*\+\s*""//g;
				$string =~ s/""\s*\+\s*//g;

				if ($newline) {
					push @python, ("print " . $string);
				} else {
					$imports{"sys"}++;
					push @python, ("sys.stdout.write(" . $string . ")");
				}
			} elsif ($statement[0] =~ /(if|while|elsif)/) {
				my $type = $1;
				$type =~ s/elsif/elif/;
				my @statementArg = @{$args{"statement"}};
				if ($statementArg[0] eq "expr") {
					push @python, ("$type " . &ExprToPython(@statementArg) . ":");
					foreach my $line (&ListToPython(@{$args{"commands"}}, 1)) {
						push @python, ("    " . $line);

					}
				}
			} elsif ($statement[0] =~ /for/) { # c-style is impossible with the parsing so I've just done the "for $x (@a)" style
				my $var = $args{"var"};
				my $set = $args{"set"};

				if (@{$var}[0] eq "var") {
					$var = &VarToPython(@{$var});
				}

				if (@{$set}[0] eq "var") {
					$set = &VarToPython(@{$set});
				} elsif (@{$set}[0] eq "range") {
					my %rangeArgs = @{$set}[1];
					my $left = $rangeArgs{"left"};
					my $right = $rangeArgs{"right"};
					$set = "range(".$left.", ".$right.")";
				}

				push @python, ("for ".$var." in ".$set.":");
				foreach my $line (&ListToPython(@{$args{"commands"}}, 1)) {
					push @python, ("    " . $line);
				}
			} elsif ($statement[0] eq "assign") {
				my $left = $args{"left"};
				my @leftArray = @{$left} if defined $left and $left =~ /^ARRAY/;
				if (@leftArray and ($leftArray[0] eq "var")) {
					$left = &VarToPython(@{$left});
				}
				my $right = $args{"right"};
				my @rightArray = @{$right} if defined $right and $right =~ /^ARRAY/;
				if (@rightArray and ($rightArray[0] eq "expr")) {
					$right = &ExprToPython(@rightArray);
				} elsif (@rightArray and ($rightArray[0] eq "str")) {
					$right = &StrToPython(@rightArray);
				}
				push @python, ("$left = $right");
			}
		} else {
			push @python, $item;
		}
	}

	if (!$noHeader) {
		if (!($python[0] =~ /^$/)) {

		unshift @python, "";
		}

		foreach my $import (keys %imports) {
			unshift @python, "import $import";
		}

		unshift @python, "#!/usr/bin/python2.7 -u";
	}

	return @python;
}

my @perl = ();

undef $/;

my $string = <>;

$string =~ s/\n\n/\nBLANKLINE\n/g;

# makes sure each statement and comment gets its own line
$string =~ s/#/\n#/g;
$string =~ s/;/\n/g; # this makes c-stype for loops really hard
$string =~ s/{/{\n/g;
$string =~ s/}/\n}\n/g;
$string =~ s/(\s*\n+\s*)+/\n/g;
$string =~ s/(\$[a-zA-Z][a-zA-Z0-9_]*)\s*(\.|\+|\-|\*)=/$1 = $1 $2/g;

my @perlTemp = split "\n", $string;

foreach (@perlTemp) {
	if ((defined $_) and !($_ =~ /^$/)) {
		push @perl, $_;
	}
}

foreach (@perl) {
	$_ =~ s/^BLANKLINE$//g;
}

print join("\n", &ListToPython(&PerlToList(@perl), 0));

print "\n";
