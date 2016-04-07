package Darkmist::Role::Plugin;

use Moose::Role;


has 'name' => (
    isa    => 'Str',
    is     => 'rw',
    );

has 'core'   => (
    isa      => 'Darkmist::Core',
    is       => 'ro',
    required => 1,
    );

sub dprint {
    my ($self, @args) = @_;
}

1;
