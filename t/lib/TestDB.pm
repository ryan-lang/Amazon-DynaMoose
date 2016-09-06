package TestDB;

use Moose;

extends 'Amazon::DynaMoose';

no Moose;
__PACKAGE__->meta->make_immutable;

1;