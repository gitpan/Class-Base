#!/usr/bin/perl -w                                         # -*- perl -*-
#========================================================================
#
# test.pl
#
# Test the Class::Base.pm module.
#
# Written by Andy Wardley <abw@kfs.org>, based on the version lifted from
# the Template Toolkit.
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $Id$
#
#========================================================================

use strict;
use warnings;
use lib qw( ./lib );
use Class::Base;


#------------------------------------------------------------------------
# mini test harness
#------------------------------------------------------------------------

print "1..15\n";
my $n = 0;

sub ok {
    shift or print "not ";
    print "ok ", ++$n, "\n";
}

sub is {
    ok( $_[0] eq $_[1] );
}


#------------------------------------------------------------------------
# Class::Test::Fail always fails, but we check it reports errors OK
#------------------------------------------------------------------------

package Class::Test::Fail;
use base qw( Class::Base );
use vars qw( $ERROR );

sub init {
    my $self = shift;
    return $self->error('expected failure');
}


package main;

my ($pkg, $mod);

# instantiate a base class object and test error reporting/returning
$mod = Class::Base->new();
ok( $mod );
ok( ! defined $mod->error('barf') );
ok( $mod->error() eq 'barf' );

# Class::Test::Fail should never work, but we check it reports errors OK
$pkg = 'Class::Test::Fail';
ok( ! $pkg->new() );
is( $pkg->error, 'expected failure' );
is( $Class::Test::Fail::ERROR, 'expected failure' );


#------------------------------------------------------------------------
# Class::Test::Name should only work with a 'name'parameters
#------------------------------------------------------------------------

package Class::Test::Name;
use base qw( Class::Base );
use vars qw( $ERROR );

sub init {
    my ($self, $params) = @_;
    $self->{ NAME } = $params->{ name } 
	|| return $self->error("No name!");
    return $self;
}

sub name {
    $_[0]->{ NAME };
}

package main;

$mod = Class::Test::Name->new();
ok( ! $mod );
is( $Class::Test::Name::ERROR, 'No name!' );
is( Class::Test::Name->error(), 'No name!' );

# give it what it wants...
$mod = Class::Test::Name->new({ name => 'foo' });
ok( $mod );
ok( ! $mod->error() );
is( $mod->name(), 'foo' );

# ... in 2 different flavours
$mod = Class::Test::Name->new(name => 'foo');
ok( $mod );
ok( ! $mod->error() );
is( $mod->name(), 'foo' );


