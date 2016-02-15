#!/usr/bin/env perl

# check all packages to ensure package names match the filename

use Modern::Perl qw/2012/;
use Test::More;
use Path::Tiny;
use Carp;

my $libdir=defined $ARGV[0] ? path(shift @ARGV) : path("./lib");
my $iter=$libdir->iterator({recurse => 1});
my $count=0;

sub module_name_for_file {
  my $filename=shift;
  my $modulename=$filename;
  $modulename =~ s{^(?:.*/)?lib/}{};
  $modulename =~ s{\.pm$}{};
  $modulename =~ s{/}{::}g;
  return $modulename;
}

while (defined(my $file=$iter->())) {
  next unless ($file =~ m{\.pm} and -f $file);
  my $module_name=module_name_for_file($file);
  my $perlcode=$file->openr_utf8;
  my $has_package=0;
  while(defined(my $line=<$perlcode>)) {
    if ($line =~ m{^\s*package (\S+);\s*$}) {
      my $package_name=$1;
      $has_package=1;
      is($module_name, $package_name, sprintf "%s: package name is %s, expected %s", $file, $package_name, $module_name);
    }
  }
  $count += $has_package;
  close $perlcode or die $!;
}

done_testing($count);
