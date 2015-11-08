#!/usr/bin/env perl

use Modern::Perl qw/2012/;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'ORC' ) || print "Bail out!\n";
}

diag( "Testing ORC $ORC::VERSION, Perl $], $^X" );
