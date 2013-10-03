#!/usr/bin/perl -w

sub var {
	my ($var) = @_;
	if ($var =~ /($|@|%)([a-zA-Z][a-zA-Z0-9]+)/) {
		return ($1, $2);
	} else {
		return $var;
	}
}

sub PerlToList {
	# converts a perl file, as an array of lines
	# into a list-based language-independant
	# recursive data structure.
	my (@perl) = @_;
	my @list;

	foreach $i (0..$#perl) {
		if ($perl[$i] =~ /^print\s*"([^"]*)"\s*;$/) { # print
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
			$list[$i] = ["print", {"string"=>$str, "newline"=>$newline}];
		} else {
			if ($perl[$i] =~ /^#!/) {

			} elsif ($perl[$i] =~ /^#/) {
				$list[$i] = $perl[$i];
			} else {
				$list[$i] = "# " . $perl[$i];
			}
		}
	}

	return @list;
}

sub ListToPython {
	# converts a list-based language-independant
	# recursive data structure into a python file,
	# as an array of lines
	my (@list) = @_;
	my @python = ();
	my %imports;

	foreach $i (0..$#list) {
		my @statement = @{$list[$i]} if defined $list[$i];
		if ((defined $statement[0]) and ($statement[0] eq "print")) {
			my %args = %{$statement[1]};
			if ($args{"newline"}) {
				push @python, ("print \"" . $args{"string"} ."\"");
			} else {
				$imports{"sys"}++;
				push @python, ("sys.stdout.write(\"" . $args{"string"} . "\")")
			}
		} else {
			push @python, $list[$i];
		}
	}

	unshift @python, "";

	foreach $import (keys %imports) {
		unshift @python, "import $import";
	}

	unshift @python, "#!/usr/bin/python2.7 -u";

	return @python;
}

@perl = ();

undef $/;

$string = <>;

# makes sure each statement and comment gets its own line
$string =~ s/#/\n#/g;
$string =~ s/;/;\n/g;
$string =~ s/{/{\n/g;
$string =~ s/}/\n}\n/g;
$string =~ s/(\s*\n+\s*)+/\n/g;

@perl = split "\n", $string;

print join("\n", &ListToPython(&PerlToList(@perl)));

print "\n";
