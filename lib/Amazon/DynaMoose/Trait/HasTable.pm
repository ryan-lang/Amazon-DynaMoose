package Amazon::DynaMoose::Trait::HasTable;

use Moose::Role;
use namespace::clean -except => 'meta';

has tablename => (
    is  => 'rw',
    isa => 'Str'
);

no Moose::Role;

1;
__END__
