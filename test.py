#!/usr/bin/python2.7 -u
import sys

hello =  "greetings"

world =  "world"

print str(hello)

print "hello " + str(world) + "\n" + str(hello) + " world"

sys.stdout.write("hello... ")
print "hello"

i =  0
while  i  < 50:
    if  i  == 6:
        i = i + 1
        continue
    if  i  % 2  == 0  and i  > 4:
        i = i + 1
    print str(i)
    i = i + 1
    i = i - 1
    i = i + 1
    if  i  == 10:
        break

if  i  > 2:
    sys.stdout.write("sup ")
    print "sup"

# $i++ and i-- should not change in comments
a =  "or in strings! $i-- i++"
# or inline comments! $hello $i++ i--
sys.stdout.write(str(a))
i = i - 1

sys.stdout.write(str(i))

print ""

# @array = ()

for line in array
    line =  "hello"
    # stuff
