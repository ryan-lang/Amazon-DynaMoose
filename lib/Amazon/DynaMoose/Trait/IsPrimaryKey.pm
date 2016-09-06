package Amazon::DynaMoose::Trait::IsPrimaryKey;

use Moose::Role;
use namespace::autoclean;

Moose::Util::meta_attribute_alias('IsPrimaryKey');

sub register_implementation {
    'Amazon::DynaMoose::Trait::IsPrimaryKey';
}

# TODO: trigger clearing the _primary_key attribute
# when any of these attributes change

no Moose::Role;

1;
__END__
