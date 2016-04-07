package Darkmist::Core;

use Moose;
use Moose::Util qw(apply_all_roles);
use Moose::Autobox;

use Darkmist::Config;
use Devel::Confess;
use IO::Async::Loop;

with 'Darkmist::Role::Configuration' => {
    configfile => 'darkmist.yml',
    class      => 'Darkmist::Config',
};


# Apply method modifiers to these in your subsystems:
sub darkmist_preinit  {}
sub darkmist_postinit {}
sub darkmist_init     {}
sub dispatch          {} # ($role, $call, @args)

sub start {
    my $self = shift;
    
    #print "\nWe're going to attempt to prefork, hold on tight...\n";
    #my $pid = fork;
    #die "Can't fork: $!\n" unless defined($pid);

    #if ($pid == 0) {
    #print "... We're in the fork!\n\n";
	
    # Subsystems:
    with 'Darkmist::PluginSystem' => {
	with_prefix => 'Darkmist::Role',
    };

    with 'Darkmist::CommandHandler';
    with 'Darkmist::WorldManager';
    
    my @init_levels = qw(
        darkmist_preinit
        darkmist_init
        darkmist_postinit
    );
    
    $self->$_() foreach (@init_levels);
    print "ready.\n";
    IO::Async::Loop->new->run;
}

#__PACKAGE__->meta->make_immutable;
1;
