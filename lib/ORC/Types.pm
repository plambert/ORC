package ORC::Types;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose::Util::TypeConstraints;
use ORC::Number;

subtype 'ORC::Type::Number',
  as 'ORC::Number';

coerce 'ORC::Type::Number',
  from 'Int',
  via { ORC::Number->new($_) };

coerce 'Int',
  from 'ORC::Type::Number',
  via { $_->value };

1;
