#============================================================= -*-perl-*-
#
# Class::Base
#
# DESCRIPTION
#   Module implementing a common base class from which other modules
#   can be derived.
#
# AUTHOR
#   Andy Wardley    <abw@kfs.org>
#
# COPYRIGHT
#   Copyright (C) 1996-2002 Andy Wardley.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id$
#
#========================================================================

package Class::Base;

use strict;

our $VERSION  = '0.01';
our $REVISION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);


#------------------------------------------------------------------------
# new(@config)
# new(\%config)
#
# General purpose constructor method which expects a hash reference of 
# configuration parameters, or a list of name => value pairs which are 
# folded into a hash.  Blesses a hash into an object and calls its 
# init() method, passing the parameter hash reference.  Returns a new
# object derived from Class::Base, or undef on error.
#------------------------------------------------------------------------

sub new {
    my $class  = shift;

    # allow hash ref as first argument, otherwise fold args into hash
    my $config = defined $_[0] && UNIVERSAL::isa($_[0], 'HASH') 
	? shift : { @_ };

    my $self = bless {
	_ERROR   => '',
	_FACTORY => $config->{ factory },
    }, $class;

    return $self->init($config)
	|| $class->error($self->error());
}


#------------------------------------------------------------------------
# init()
#
# Initialisation method called by the new() constructor and passing a 
# reference to a hash array containing any configuration items specified
# as constructor arguments.  Should return $self on success or undef on 
# error, via a call to the error() method to set the error message.
#------------------------------------------------------------------------

sub init {
    my ($self, $config) = @_;
    return $self;
}


#------------------------------------------------------------------------
# error()
# error($msg, ...)
# 
# May be called as a class or object method to set or retrieve the 
# package variable $ERROR (class method) or internal member 
# $self->{ _ERROR } (object method).  The presence of parameters indicates
# that the error value should be set.  Undef is then returned.  In the
# abscence of parameters, the current error value is returned.
#------------------------------------------------------------------------

sub error {
    my $self = shift;
    my $errvar;

    { 
	no strict qw( refs );
	$errvar = ref $self ? \$self->{ _ERROR } : \${"$self\::ERROR"};
    }
    if (@_) {
	# don't join if first arg is an object (may force stringification)
	$$errvar = ref($_[0]) ? shift : join('', @_);
	return undef;
    }
    else {
	return $$errvar;
    }
}

1;


=head1 NAME

Class::Base - useful base class for deriving other modules 

=head1 SYNOPSIS

    package My::Funky::Module;
    use base qw( Class::Base );

    sub init {
	my ($self, $config) = @_;

	# to indicate a failure
	return $self->error('bad constructor!');

	# or to indicate general happiness and well-being
	return $self;
    }

    package main;

    my $object = My::Funky::Module->new( foo => 'bar', ... )
	  || die My::Funky::Module->error();

=head1 DESCRIPTION

This module implements a simple base class from which other modules
can be derived, thereby inheriting a number of useful methods.

For a number of years, I found myself re-writing this module for
practically every Perl project of any significant size.  Or rather, I
would copy the module from the last project and perform a global
search and replace to change the names.  Eventually, I decided to Do
The Right Thing and release it as a module in it's own right.

It defines a base class which implements a number of useful methods
like new(), init() and error().  Eventually, you will be able to 
mix-in other base class module to provide additional functionality
to your objects in an easy and consistent manner.  I just haven't
got around to releasing those modules... yet.

This module is what object-oriented afficionados would describe as an
"abstract base class".  That means that it's not designed to be used
as a stand-alone module, rather as something from which you derive
your own modules.  Like this:

    package My::Funky::Module
    use base qw( Class::Base );

You can then use it like this:

    use My::Funky::Module;

    my $module = My::Funky::Module->new();

If you want to apply any per-object initialisation, then simply write
an init() method.  This gets called by the new() method which passes a
reference to a hash reference of configuration options.

    sub init {
	my ($self, $config) = @_;

	...

	return $self;
    }

When you create new objects using the new() method you can either pass
a hash reference or list of named arguments.  The new() method does
the right thing to fold named arguments into a hash reference for
passing to the init() method.  Thus, the following are equivalent:

    # hash reference
    my $module = My::Funky::Module->new({ 
	foo => 'bar', 
	wiz => 'waz',
    });

    # list of named arguments (no enclosing '{' ... '}')
    my $module = My::Funky::Module->new(
	foo => 'bar', 
	wiz => 'waz'
    );

The init() method should return $self to indicate success or undef to
indicate a failure.  You can use the error() method to report an error
within the init() method.  The error() method returns undef, so you can
use it like this:

    sub init {
	my ($self, $config) = @_;

	# let's make 'foobar' a mandatory argument
	$self->{ foobar } = $config->{ foobar }
	    || return $self->error("no foobar argument");

	return $self;
    }

When you create objects of this class via new(), you should now check
the return value.  If undef is returned then the error message can be
retrieved by calling error() as a class method.

    my $module = My::Funky::Module->new()
  	  || die My::Funky::Module->error();

Alternately, you can inspect the $ERROR package variable which will
contain the same error message.

    my $module = My::Funky::Module->new()
  	 || die $My::Funky::Module::ERROR;

Of course, being a conscientious Perl programmer, you will want to be
sure that the $ERROR package variable is correctly defined.

    package My::Funky::Module
    use base qw( Class::Base );
    use vars qw( $ERROR );

You can also call error() as an object method.  If you pass an argument
then it will be used to set the internal error message for the object
and return undef.  Typically this is used within the module methods
to report errors.

    sub another_method {
	my $self = shift;

	...

	# set the object error
	return $self->error('something bad happened');
    }

If you don't pass an argument then the error() method returns the
current error value.  Typically this is called from outside the object
to determine its status.  For example:

    my $object = My::Funky::Module->new()
        || die My::Funky::Module->error();

    $object->another_method()
	|| die $object->error();

=head1 AUTHOR

Andy Wardley E<lt>abw@kfs.orgE<gt>

=head1 HISTORY

This module began life as the Template::Base module distributed as 
part of the Template Toolkit. 

=head1 COPYRIGHT

Copyright (C) 1996-2002 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
