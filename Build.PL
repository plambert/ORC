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
    'namespace::sweep' => '0.006',
    'Moose' => '2.1604',
    'Parse::RecDescent' => 0,
    'Modern::Perl' => '1.20150127',
  },
  configure_requires => {
    'Module::Build' => 0,
  },
  build_requires => {
    'Test::More' => 0,
    'Test::Continuous' => '0.76',
    'Test::LongString' => 0,
    'YAML' => '1.15',
    'Test::YAML' => '1.06',
    'Test::Base' => '0.88',
    'Spiffy' => '0.46',
    'Text::Diff' => '1.43',
    'File::ChangeNotify' => '0.24',
    'MooseX::SemiAffordanceAccessor' => '0.10',
    'JSON' => '2.90',
  },
  add_to_cleanup     => [ 'ORC-*' ],
  create_makefile_pl => 'traditional',
);

$builder->create_build_script();

