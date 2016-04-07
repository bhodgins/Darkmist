package Darkmist::WorldManager;

use Moose::Role;
use Darkmist::World;

has 'worlds' => (
    isa      => 'HashRef[Darkmist::World|Undef]',
    traits   => [ 'Hash' ],
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_worlds',
    );

sub add_world {

}

sub _build_worlds { {} } # For now

1;
