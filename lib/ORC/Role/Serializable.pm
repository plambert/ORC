#!/usr/bin/perl -w

package ORC::Role::Serializable;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose::Role;

sub TO_JSON {
  my $self=shift;
  my @classes=grep { /^ORC::/ } ($self->meta->linearized_isa);
  my $data={};
  $data->{_class}=\@classes;
  for my $attr ($self->meta->get_all_attributes) {
    my $method=$attr->name;
    $data->{$method}=$self->$method;
  }
  return $data;
}

sub _quote_string {
  my $string=shift;
  $string=~s{\\}{\\\\}g;
  $string=~s{\n}{\\n}g;
  $string=~s{\t}{\\t}g;
  $string=~s{\r}{\\r}g;
  $string=~s{([^ -~])}{sprintf "0x%2x", $1}g;
  return sprintf "\"%s\"", $string;
}

sub _dump_scalar {
  my $ref = shift;
  my $indent_level = shift;
  my $indent = " " x $indent_level;
  my $result;
  if (!defined $ref) {
    $result = 'undef';
  }
  elsif (!ref $ref) {
    if (length($ref) == 0) {
      $result = "\"\"";
    }
    elsif ($ref =~ m{^[1-9]\d*$}) {
      $result = sprintf "%d", $ref;
    }
    elsif ($ref =~ m{^(\d+\.\d*|\.\d+)$}) {
      $result = sprintf "%f", $ref;
    }
    else {
      $result = _quote_string $ref;
    }
  }
  elsif ('ARRAY' eq ref $ref) {
    $result = "[\n";
    for my $entry (@$ref) {
      $result .= sprintf "%s,\n", _dump_scalar($entry, 1);
    }
    $result .= "]";
  }
  elsif ('HASH' eq ref $ref) {
    $result="{\n";
    for my $key (sort keys %$ref) {
      my $keystring=_dump_scalar($key, 1);
      my $value=_dump_scalar($ref->{$key},0);
      if ($value =~ m{\n}) {
        $value =~ s{^ +}{};
      }
      $result .= sprintf "%s => %s,\n", $keystring, $value;
    }
    #$result = sprintf "{%s}", join("; ", map { join("=>", _dump_scalar($_), _dump_scalar($ref->{$_}) ) } (sort keys %$ref) );
    $result .= "}";
  }
  elsif ('SCALAR' eq ref $ref) {
    $result = sprintf "\\%s", _quote_string $ref;
  }
  elsif ($ref->can('dump')) {
    my $dump=$ref->dump;
    my $value;
    if ($ref->can('do')) {
      $value=$ref->do;
    }
    elsif ($ref->can('value')) {
      $value=$ref->value;
    }
    if (defined $value) {
      $dump =~ s{\n+$}{};
      $result = sprintf "%s /* == %s */", $dump, $value;
    }
    else {
      $result = $dump;
    }
  }
  else {
    $result = "$ref";
  }
  $result =~ s{^}{$indent}gm;
  return $result;
}

sub dump {
  my $self=shift;
  my $indent_level=shift // 0;
  my $indent=(".." x $indent_level);
  my @classes=grep { /^ORC::/ } ($self->meta->linearized_isa);
  my $class=shift @classes;

  my %attr;

  for my $attr_ref ($self->meta->get_all_attributes) {
    my $attr_name=$attr_ref->name;
    my $value=$self->$attr_name;
    $attr{$attr_name}=$value;
  }

  return sprintf "%s%s[\n%s\n%s]\n", $indent, $class, _dump_scalar (\%attr, $indent_level + 1), $indent;
}

#__PACKAGE__->meta->make_immutable;

1;
