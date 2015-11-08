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
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'ORC-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
