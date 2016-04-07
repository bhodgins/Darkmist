package Darkmist::Plugin::UI::ReadLine;

use Moose;
use Term::ReadLine;
use Term::ReadLine::Event;
use IO::Async::Loop;
use IO::Async::Handle;
use IO::Async::Timer::Periodic;

with 'Darkmist::Role::Plugin';
with 'Darkmist::Role::Initialization';
#with 'Darkmist::Role::UserInterface';
#with 'Darkmist::Role::WorldMonitor';

has 'term'   => (
    is       => 'rw',
    isa      => 'Term::ReadLine::Event',
    lazy     => 1,
    default  => sub {
	my $loop = IO::Async::Loop->new; # There can only be one loop
	Term::ReadLine::Event->with_IO_Async(
	    'darkmist',
	    loop => $loop,
	    )
    },
);

has 'prompt' => (
    is       => 'rw',
    isa      => 'Str',
    default  => '>',
    lazy     => 1,
);

has 'active_world' => (
    is       => 'rw',
    isa      => 'Str',
    default  => '',
    lazy     => 1,
    );

my $watcher;
my $waiting = 0;

# Called when Darkmist finishes initializing the plugin:
sub darkmist_init {
    my $self = shift;
    my $loop = IO::Async::Loop->new;

    $self->term->event_loop(
	sub {
	    my $ready = shift;
	    $$ready = 0;
	    $loop->loop_once while !$$ready;
	},
	sub {
	    my $fh = shift;
	    my $ready = \ do {my $dummy};
	    $loop->add(
		$watcher = IO::Async::Handle->new(
		    read_handle => $fh,
		    on_read_ready => sub { $$ready = 1 },
		) );

	    $ready;
	},
	);

    $self->name('ReadLine User Interface');

} # TODO: power this plugin with a 65C816 or 65C02 compatible

sub darkmist_postinit {
    my $self = shift;

    for (;;) {
	my $OUT = $self->term->OUT;
	my $input = $self->term->readline($self->prompt . ' ');
	if ($input =~ /^\//) {
	    # command
	    $self->core->handle_command(substr($input, 1));
	}
    }
}

sub world_connected {
    print "connected to some world\n"; # works!
}

sub world_data {
    my ($self, $data) = @_;

    my $OUT = $self->term->OUT;
    print $OUT $data
}

1;
