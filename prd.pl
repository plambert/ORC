#!/usr/bin/perl -w

use strict;
use warnings;
use Parse::RecDescent;
use Data::Dumper;
use lib '.';
use PRD;

# Enable warnings within the Parse::RecDescent module.
$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
# $::RD_HINT   = 1; # Give out hints to help fix problems.
# $::RD_TRACE  = 90; # Trace behaviour to help fix problems.

my $dsl=DSL->new;

my $text="a = 7;\n";

my $result=$dsl->parse($text);
die "Cannot parse\n" unless (defined($result));

# print $result;
print Dumper($result);

