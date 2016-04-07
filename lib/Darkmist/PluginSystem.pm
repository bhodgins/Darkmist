package Darkmist::PluginSystem;

use Moose::Role;
use Moose::Autobox;

use Module::Runtime qw(require_module);


sub _build_plugins {
    my $self = shift;
    my @autoloaded = ();
    
    if (exists ($self->config->{'plugins'})) {
	print "loading plugins...\n";
	my $plugins = $self->config->{'plugins'};
	
        foreach my $plugin ($self->config->{'plugins'}->flatten) {
	    
            print "Loading plugin: '$plugin'\n";
            my $plugin = $self->_load_plugin($plugin);
	    push @autoloaded, $plugin;
        }
    }

    \@autoloaded;
}

# All of the heavy lifting is done for us by the following role:
with 'Darkmist::Role::PluginManagement' => {
    autoloader          => '_build_plugins',
    role_restriction    => 'Darkmist::Role::Plugin',
    with_prefix         => 'Darkmist::Role',
};

# override for load_plugin to pass core instance to constructor:
# TODO: Fix PluginManagement so that it will accept arguments to plugins
sub _load_plugin {
    my ($self, $plugin_name) = @_;
    # We ignore orig here, because we are replacing it.
    
    require_module($plugin_name);
    my $plugin_obj = $plugin_name->new( core => $self );
    $plugin_obj;
}

# Load autoloadable plugins and pre_init() them:
after 'darkmist_preinit' => sub {
    my $self = shift;
   
    $self->_plugins;
    $self->dispatch('Initialization' => 'darkmist_preinit');
};

after 'darkmist_init' => sub {
    shift->dispatch('Initialization' => 'darkmist_init');
};

after 'darkmist_postinit' => sub {
    shift->dispatch('Initialization' => 'darkmist_postinit');
};

# TODO: Clean this up:
after 'dispatch' => sub {
    $_[0]->plugin_dispatch(@_[1 .. $#_]);
};

1;
