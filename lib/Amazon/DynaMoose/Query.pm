package Amazon::DynaMoose::Query;

use Method::Signatures;
use Moose;

has 'class' => (
    is        => 'ro',
    isa       => 'ClassName',
    predicate => 'has_class'
);

# when a query is passed to get()
# the filter hashref will be used as the Key;
# when a query is passed to search()
# the filter will be used as ScanFilter
has 'filter' => (
    is  => 'rw',
    isa => 'HashRef'
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
