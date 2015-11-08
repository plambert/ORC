use 5.014;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
  module_name         => 'ORC',
  license             => 'apache_2_0',
  dist_author         => q{Paul M. Lambert <plambert@plambert.net>},
  dist_abstract       => q{A simple domain-specific language for role-playing game tools},
  dist_version_from   => 'lib/ORC.pm',
  release_status      => 'stable',
  requires => {
    'Carp::Always' => 0,
    'namespace::sweep' => 0,
    'Moose' => 0,
    'Parse::RecDescent' => 0,
    'Modern::Perl' => 0,
  },
  configure_requires => {
    'Module::Build' => 0,
  },
  build_requires => {
    'Test::More' => 0,
    'Test::Continuous' => 0,
    'Test::LongString' => 0,
  },
  add_to_cleanup     => [ 'ORC-*' ],
  create_makefile_pl => 'traditional',
);

$builder->create_build_script();

