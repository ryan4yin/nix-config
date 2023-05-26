#!/usr/bin/env perl
# Copyright 2014 Pierre Mavro <deimos@deimos.fr>
# Copyright 2014 Vivien Didelot <vivien@didelot.org>
# Copyright 2014 Andreas Guldstrand <andreas.guldstrand@gmail.com>
# Copyright 2014 Benjamin Chretien <chretien at lirmm dot fr>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Edited by Andreas Lindlbauer <endeavouros.mousily@aleeas.com>

use strict;
use warnings;
use utf8;
use Getopt::Long;

binmode(STDOUT, ":utf8");

# default values
my $t_warn = $ENV{T_WARN} || 70;
my $t_crit = $ENV{T_CRIT} || 90;
my $chip = $ENV{SENSOR_CHIP} || "";
my $temperature = -9999;
my $label = "😀 ";

sub help {
    print "Usage: temperature [-w <warning>] [-c <critical>] [--chip <chip>]\n";
    print "-w <percent>: warning threshold to become yellow\n";
    print "-c <percent>: critical threshold to become red\n";
    print "--chip <chip>: sensor chip\n";
    exit 0;
}

GetOptions("help|h" => \&help,
           "w=i"    => \$t_warn,
           "c=i"    => \$t_crit,
           "chip=s" => \$chip);

# Get chip temperature
open (SENSORS, "sensors -u $chip |") or die;
while (<SENSORS>) {
    if (/^\s+temp1_input:\s+[\+]*([\-]*\d+\.\d)/) {
        $temperature = $1;
        last;
    }
}
close(SENSORS);

$temperature eq -9999 and die 'Cannot find temperature';

if ($temperature < 45) {
  $label = '';
} elsif ($temperature < 55) {
  $label = '';
} elsif ($temperature < 65) {
  $label = '';
} elsif ($temperature < 75) {
  $label = '';
} else {
  $label = '';
}
# Print short_text, full_text
print "${label}";
print " $temperature°C\n";
print "${label}";
print " $temperature°C\n";

# Print color, if needed
if ($temperature >= $t_crit) {
    print "#FF0000\n";
    exit 33;
} elsif ($temperature >= $t_warn) {
    print "#FFFC00\n";
}

exit 0;
