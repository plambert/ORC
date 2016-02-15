#!/usr/bin/env perl

use Modern::Perl qw/2012/;
use Test::More tests => 1;

use ok 'ORC';

diag "Testing ORC $ORC::VERSION, Perl $], $^X";


# BEGIN {
#   plan tests => 1;
#   use_ok( 'ORC' ) || print "Bail out!\n";
#   diag( "Testing ORC $ORC::VERSION, Perl $], $^X" );
# }

