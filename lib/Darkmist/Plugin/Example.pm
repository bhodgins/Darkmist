package Darkmist::Plugin::Example;

use Moose;
with 'Darkmist::Role::Plugin';
with 'Darkmist::Role::Initialization';


# Basic setup of the plugin, setting its name, etc:
sub darkmist_preinit {
    my $self = shift;

    $self->name('Example plugin');
}

# Post engine initialization hook:
sub darkmist_postinit {
    print "[Example Plugin]: All plugins should have loaded by now.\n";
}

__PACKAGE__->meta->make_immutable;
