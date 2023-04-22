#!/usr/bin/perl
#
# Copyright 2014 Pierre Mavro <deimos@deimos.fr>
# Copyright 2014 Vivien Didelot <vivien@didelot.org>
#
# Licensed under the terms of the GNU GPL v3, or any later version.
#
# This script is meant to use with i3blocks. It parses the output of the "acpi"
# command (often provided by a package of the same name) to read the status of
# the battery, and eventually its remaining time (to full charge or discharge).
#
# The color will gradually change for a percentage below 85%, and the urgency
# (exit code 33) is set if there is less that 5% remaining.

# Edited by Andreas Lindlbauer <endeavouros.mousily@aleeas.com>

use strict;
use warnings;
use utf8;

# otherwise we get in console "Wide character in print at"
binmode(STDOUT, ':utf8');

# my $acpi;
my $upower;
my $percent;
my $bat_state;
my $status;
my $ac_adapt;
my $full_text;
my $short_text;
my $label = '😅';
my $bat_number = $ENV{BLOCK_INSTANCE} || 0;

open (UPOWER, "upower -i /org/freedesktop/UPower/devices/battery_BAT$bat_number | grep 'percentage' |") or die;
$upower = <UPOWER>;
close(UPOWER);

# fail on unexpected output
if ($upower !~ /:          (\d+)%/) {
	die "$upower\n";
}

$percent = $1;
$full_text = "$percent%";

open (BAT_STATE, "upower -i /org/freedesktop/UPower/devices/battery_BAT$bat_number | grep 'state' |") or die;
$bat_state = <BAT_STATE>;
close(BAT_STATE);

if ($bat_state !~ /:               (\w+)/) {
	die "$bat_state\n";
}
$status = $1;

if ($status eq 'discharging') {
	$full_text .= ' ';
} elsif ($status eq 'charging') {
	$full_text .= ' ';
} elsif ($status eq 'Unknown') {
	open (AC_ADAPTER, "acpi -a |") or die;
	$ac_adapt = <AC_ADAPTER>;
	close(AC_ADAPTER);

	if ($ac_adapt =~ /: ([\w-]+)/) {
		$ac_adapt = $1;

		if ($ac_adapt eq 'on-line') {
			$full_text .= ' CHR';
		} elsif ($ac_adapt eq 'off-line') {
			$full_text .= ' DIS';
		}
	}
}

$short_text = $full_text;

if ($percent < 20) {
  $label = '';
} elsif ($percent < 45) {
  $label = '';
} elsif ($percent < 70) {
  $label = '';
} elsif ($percent < 95) {
  $label = '';
} else {
  $label = '';
}

# print text
print " ${label}";
print " $full_text\n";
print " ${label}";
print " $short_text\n";

# consider color and urgent flag only on discharge
if ($status eq 'discharging') {

	if ($percent < 20) {
		print "#FF0000\n";
	} elsif ($percent < 40) {
		print "#FFAE00\n";
	} elsif ($percent < 60) {
		print "#FFF600\n";
	} elsif ($percent < 85) {
		print "#A8FF00\n";
	}

	if ($percent < 5) {
		exit(33);
	}
}

exit(0);
