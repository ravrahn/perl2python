#!/usr/bin/perl -w

# STRINGS

# so far so good...
$a = "hello";

# what
$a = $a."w"."o"."r"."l"."d";
# alrighty then
$a = $a." $a";

print $a." ";
print "$a\n";

# helloworld helloworld helloworld helloworld\n