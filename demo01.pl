#!/usr/bin/perl

# Doomsday for 2013 - a blast from the past

$THURSDAY = 0;
$FRIDAY = 1;
$SATURDAY = 2;
$SUNDAY = 3;
$MONDAY = 4;
$TUESDAY = 5;
$WEDNESDAY = 6;

$TRUE = 1;
$FALSE = 0;
$DAYS_PER_WEEK = 7;

$JANUARY = 1;
$FEBRUARY = 2;
$MARCH = 3;
$APRIL = 4;
$MAY = 5;
$JUNE = 6;
$JULY = 7;
$AUGUST = 8;
$SEPTEMBER = 9;
$OCTOBER = 10;
$NOVEMBER = 11;
$DECEMBER = 12;

$doomsday = $THURSDAY;
$leapYear = $FALSE;

$month = $ARGV[1];
$day = $ARGV[0];

$doomsdayDate = 0;

if ($month == $FEBRUARY && $leapYear == $TRUE) {
    $doomsdayDate = 1;
    
} elsif ($month % 2 == 0 && $month != $FEBRUARY) {
    $doomsdayDate = $month;
    
} elsif ($month == $JANUARY) {
    if ($leapYear == $TRUE) {
        $doomsdayDate = 4;
    } else {
        $doomsdayDate = 3;
    }
} elsif ($month == $MAY) {
    $doomsdayDate = 9;
    
} elsif ($month == $JULY) {
    $doomsdayDate = 11;
    
} elsif ($month == $SEPTEMBER) {
    $doomsdayDate = 5;
    
} else { # for Nov, March, non-leap Feb
    $doomsdayDate = 7;
}

$offset = ($day - $doomsdayDate) % $DAYS_PER_WEEK;

$dayOfWeek = $doomsday + $offset;


# // If something's gone wrong, correct it.
if ($dayOfWeek < 0) {
    $dayOfWeek = $dayOfWeek + $DAYS_PER_WEEK;
} elsif ($dayOfWeek >= $DAYS_PER_WEEK) {
    $dayOfWeek = $dayOfWeek - $DAYS_PER_WEEK;
}
    
if ($dayOfWeek % 7 == $MONDAY) {
	print "Monday\n";
} elsif ($dayOfWeek % 7 == $TUESDAY) {
	print "Tuesday\n";
} elsif ($dayOfWeek % 7 == $WEDNESDAY) {
	print "Wednesday\n";
} elsif ($dayOfWeek % 7 == $THURSDAY) {
	print "Thursday\n";
} elsif ($dayOfWeek % 7 == $FRIDAY) {
	print "Friday\n";
} elsif ($dayOfWeek % 7 == $SATURDAY) {
	print "Saturday\n";
} elsif ($dayOfWeek % 7 == $SUNDAY) {
	print "Sunday\n";
} else {
	print "Unknown\n";
}
