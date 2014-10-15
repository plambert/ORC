#!/usr/bin/perl -w

use strict;
use warnings;

package DSL;

use Moose;
use DSL::Parser;
use DSL::Variable;
use DSL::Assignment;
use DSL::Statement::Print;

1;
