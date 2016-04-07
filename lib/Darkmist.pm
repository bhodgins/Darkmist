package Darkmist;

use warnings;
use strict;


sub import {
    my ($class, @modules) = @_;

    foreach my $module (@modules) {
	eval "package $class; use Darkmist::$module";
	warn $@ if $@;
    }
}

1;
