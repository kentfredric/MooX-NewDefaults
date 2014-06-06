use strict;
use warnings;

use Test::More;

# define two classes, and make sure our sugar works with arrays.

{

  package TestClassA;
  use Moo;

  has one => ( is => 'ro', lazy => 1, default => sub { 'original default' } );
  has two => ( is => 'ro', lazy => 1, default => sub { 'original default(two)' } );
}
{

  package TestClassB;
  use Moo;

  use MooX::NewDefaults;

  extends @{ ['TestClassA'] };

  default_for [ 'one', 'two' ] => sub { 'new default!' };
}

# attribute defaults
subtest 'attr one' => sub {
  can_ok( $_->new, 'one' ) for 'TestClassA', 'TestClassB';

  is( TestClassA->new->one(), 'original default', 'A has correct default' );
  is( TestClassB->new->one(), 'new default!',     'B has correct default' );
};
subtest 'attr two' => sub {

  can_ok( $_->new, 'two' ) for 'TestClassA', 'TestClassB';

  is( TestClassA->new->two(), 'original default(two)', 'A has correct default' );
  is( TestClassB->new->two(), 'new default!',          'B has correct default' );
};

subtest 'delete accessor' => sub {
  my $stash = do {
    no strict;
    \%{'TestClassB::'};
  };

  delete $stash->{one};
  delete $stash->{two};

  subtest 'attr one' => sub {
    can_ok( $_->new, 'one' ) for 'TestClassA', 'TestClassB';

    is( TestClassA->new->one(), 'original default', 'A has correct default' );
    is( TestClassB->new->one(), 'original default', 'B has correct default' );
  };
  subtest 'attr two' => sub {

    can_ok( $_->new, 'two' ) for 'TestClassA', 'TestClassB';

    is( TestClassA->new->two(), 'original default(two)', 'A has correct default' );
    is( TestClassB->new->two(), 'original default(two)', 'B has correct default' );
  };
};

done_testing;
