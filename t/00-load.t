#!perl -T
use 5.014;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'ORC' ) || print "Bail out!\n";
}

diag( "Testing ORC $ORC::VERSION, Perl $], $^X" );
