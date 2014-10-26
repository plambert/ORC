#!/usr/bin/perl -w

use lib '.';
use strict;
use warnings;
use DSL;

my $file;
my $dsl=DSL->new;
my $debug;

while(@ARGV and $ARGV[0] =~ /^-/) {
  my $opt=shift;
  if ($opt eq '-h') {
    usage();
  }
  elsif ($opt eq '-d') {
    $debug=1;
  }
  else {
    die "$0: ${opt}: unknown option\n";
  }
}

usage("no files to run") unless (@ARGV);

for $file (@ARGV) {
  print "=== $file\n" if (@ARGV>1);
  open(FILE, '<', $file) or die "$0: ${file}: unable to open file for reading\n";
  my $script=do { local $/; <FILE> };
  close(FILE);
  my $parsed_script=$dsl->parse($script);
  die "$0: ${file}: parsing failed\n" unless (defined($parsed_script));
  print $parsed_script->do;
}

sub usage {
  print STDERR "$0: usage: $0 [files...]\n";
  if (@_) {
    print STDERR map { "$_\n" } (@_);
    exit 1;
  }
  exit 0;
}
