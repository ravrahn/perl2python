#!/usr/bin/perl -w

#The List data structure:

# Basic Types:
	# string - a string

# Simple Types:
	# oper - A string containing an arithemetic, logical, comparison, or bitwise operator
	# expr - Array containing n instances of str, var, oper
	# str - Array containing n instances of string, var

# Str and expr are dynamic in length
# as such they are stored as n-length arrays
# with their first element being "str" or "expr"
# operators are stored as, for example: ["oper", ">"]

# Complex Types
	# var - string type, string name
	# comment - string text
	# range - string start, string end
	# assign - var left, expr|str right
	# print - str string
	# if - expr statement, List commands
	# while - expr statement, List commands
	# for - i, set, List commands

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

		} elsif ($item =~ /^(if|while)\s*\((.*?)\)\s*{/) {
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
			push @list, ["$ifwhile", {"statement"=>$statement, "commands"=>\@subcommands}];
		
		} elsif ($item =~ /^\$([a-zA-Z][a-zA-Z0-9_]*)\s*\+\+/) { # $i++
			push @list, ["assign", {"left"=>&StringToVar("$1"), "right"=>"$1 + 1"}];
		
		} elsif ($item =~ /^\$([a-zA-Z][a-zA-Z0-9_]*)\s*\-\-/) { # $i--
			push @list, ["assign", {"left"=>&StringToVar("\$$1"), "right"=>"$1 - 1"}];
		
		} elsif ($item =~ /^\$([a-zA-Z][a-zA-Z0-9_]*)\s*=(.*)/) {
			my $left = $1;
			my $right = $2;
			if ($right =~ /"|'/) { # right side is a string
				push @list, ["assign", {"left"=>&StringToVar("\$$left"), "right"=>&StringToStr($right)}];
			}

		}else { # unknown (or comment)
			if ($item =~ /^#!/) {
				# completely ignore hashbangs
			} elsif ($item =~ /^$/) {
				push @list, $item;
			}elsif ($item =~ /^#/) {
				push @list, $item;
			} else {
				push @list, "# " . $item;
			}
		}
	}

	return @list;
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
		my @statement = @{$item} if defined $item;

		if (defined $statement[0]) {
			my %args = %{$statement[1]};

			if ($statement[0] eq "print") {
				my $newline;
				my @str;

				foreach my $str (@{$args{"string"}}) {
					if ($str =~ /^str$/) {
						next;
					}
					if ($str =~ /^ARRAY/) {
						%var = %{@{$str}[1]};
						$str = $var{"name"};
					}
					push @str, $str;
				}

				my $string = join " + ", @str;

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
			} elsif ($statement[0] =~ /(if|while)/) {
				push @python, ("$1 " . $args{"statement"} . ":");
				foreach $line (&ListToPython(@{$args{"commands"}}, 1)) {
					push @python, ("    " . $line);

				}
			} elsif ($statement[0] eq "assign") {
				my $left = $args{"left"};
				my @leftArray = @{$left};
				if (@leftArray and ($leftArray[0] eq "var")) {
					my %leftArgs = %{$leftArray[1]};
					$left = $leftArgs{"name"};
				}
				my $right = $args{"right"};
				my @rightArray = @{$right};
				if (@rightArray and ($rightArray[0] eq "str")) {
					shift @{$right};
					$right = join " + ", @{$right};
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

@perl = ();

undef $/;

$string = <>;

$string =~ s/\n\n/\nBLANKLINE\n/g;

# makes sure each statement and comment gets its own line
$string =~ s/#/\n#/g;
$string =~ s/;/\n/g;
$string =~ s/{/{\n/g;
$string =~ s/}/\n}\n/g;
$string =~ s/(\s*\n+\s*)+/\n/g;

@perlTemp = split "\n", $string;

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
