package MooX::NewDefaults;

# ABSTRACT: Alter attribute defaults with less pain

use parent 'Moo';

sub import {
  my $target = caller;
  my $class  = shift;
  Moo::_install_tracked $target => default_for => sub {
    my $name_proto = shift;
    my @name_proto = ref $name_proto eq 'ARRAY' ? @$name_proto : $name_proto;
    if ( @_ != 1 ) {
      require Carp;
      Carp::croak(
        sprintf q[Invalid options for %s default: Single argument expected, got %s],
        join( ', ', map "'$_'", @name_proto ),
        scalar @_
      );
    }
    my %spec = ( default => ( shift @_ ) );
    foreach my $name ( map { '+' . $_ } @name_proto ) {

      # Note that when multiple attributes specified, each attribute
      # needs a separate \%specs hashref
      my $spec_ref = @name_proto > 1 ? +{%spec} : \%spec;
      $class->_constructor_maker_for($target)->register_attribute_specs( $name, $spec_ref );
      $class->_accessor_maker_for($target)->generate_method( $target, $name, $spec_ref );
      $class->_maybe_reset_handlemoose($target);
    }
  };
}

1;

__END__

=head1 SYNOPSIS

Concept and documentation liberally stolen from L<< C<MooseX::NewDefaults>|MooseX::NewDefaults >>

    package One;
    use Moo;

    has A => (is => 'ro', default => sub { 'say ahhh' });
    has B => (is => 'ro', default => sub { 'say whoo' });

    package Two;
    use Moo;
    use MooX::NewDefaults;

    extends 'One';

    # sugar for defining a new default
    default_for A => sub { 'say oooh' };

    # this is also legal
    default_for B => 'say oooh';

=head1 DESCRIPTION

Ever start using a package from the CPAN, only to discover that it requires
lots of subclassing and "has '+foo' => (default => ...)"?  It's not
recommended Moose best practice, and it's certainly not the prettiest thing
ever, either.

That's where we come in.

This package introduces new sugar that you can use in your class,
default_for (as seen above).

e.g.

    has '+foo' => (default => sub { 'a b c' });

...is the same as:

    default_for foo => sub { 'a b c' };

=head1 NEW SUGAR

=head2 default_for

default_for() is a shortcut to extend an attribute to give it a new default;
this default value may be any legal value for default options.

    # attribute bar defined elsewhere (e.g. superclass)
    default_for bar => 'new default';

... is the same as:

    has '+bar' => (default => 'new default');

=cut
