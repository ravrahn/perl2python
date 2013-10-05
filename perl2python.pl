#!/usr/bin/perl -w

#The List data structure:

# Basic Types:
	# string - a string
	# int - an integer
	# bool - a boolean

# Simple Types:
	# oper - A string containing an arithemetic, logical, comparison, or bitwise operator
	# expr - Array containing n instances of str, var, oper
	# str - Array containing n instances of string, var

# Strings and expressions are dynamic in length
# as such they are stored as n-length arrays
# with their first element being "str" or "expr"
# operators are stored as, for example: ["oper", ">"]

# Complex Types
	# var - string type, string name
	# range - int start, int end
	# assign - var left, expr right, bool local
	# print - str string, bool newline
	# if - expr statement, List commands
	# while - expr statement, List commands
	# for - i, set, List commands

# Each complex type is stored in this format:
# [name, {property=>value, property=>value}]
# A value can be another of these 'objects', or even an entire List



sub PerlToList {
	# converts a perl file, as an array of lines
	# into a list-based language-independant
	# recursive data structure.

	my (@perl) = @_;
	my @list;

	while (@perl) {
		my $item = shift @perl;
		if ($item =~ /^print\s*"([^"]*)"\s*$/) { # print
			my $newline;
			my $str = $1;
			if ($str =~ /\\n$/) {
				$newline = 1;
			} else {
				$newline = 0;
			}
			if ($newline) {
				$str =~ s/\\n$//;
			}
			push @list, ["print", {"string"=>$str, "newline"=>$newline}];
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
			push @list, ["assign", {"left"=>$1, "right"=>"$1 + 1"}];
		} elsif ($item =~ /^\$([a-zA-Z][a-zA-Z0-9_]*)\s*\-\-/) { # $i--
			push @list, ["assign", {"left"=>$1, "right"=>"$1 - 1"}];
		} else { # unknown (or comment)
			if ($item =~ /^#!/) {

			} elsif ($item =~ /^#/) {
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
				if ($args{"newline"}) {
					push @python, ("print \"" . $args{"string"} ."\"");
				} else {
					$imports{"sys"}++;
					push @python, ("sys.stdout.write(\"" . $args{"string"} . "\")")
				}
			} elsif ($statement[0] =~ /(if|while)/) {
				push @python, ("$1 " . $args{"statement"} . ":");
				foreach $line (&ListToPython(@{$args{"commands"}}, 1)) {
					push @python, ("    " . $line);

				}
			} elsif ($statement[0] eq "assign") {
				my $left = $args{"left"};
				my $right = $args{"right"};
				push @python, ("$left = $right");
			}
		} else {
			push @python, $item;
		}
	}

	if (!$noHeader) {
		unshift @python, "";

		foreach $import (keys %imports) {
			unshift @python, "import $import";
		}

		unshift @python, "#!/usr/bin/python2.7 -u";
	}

	return @python;
}

@perl = ();

undef $/;

$string = <>;

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

print join("\n", &ListToPython(&PerlToList(@perl), 0));

print "\n";
