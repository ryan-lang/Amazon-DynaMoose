package Amazon::DynaMoose::Collapser;

use Method::Signatures;
use Moose;

method collapse ($obj!, :$exclude_primary_key = 0) {
    my $packed = $obj->pack();

    # remove the keys that make up the primary key
    if ($exclude_primary_key) {
        foreach my $k ( keys %{ $obj->_primary_key } ) {
            delete $$packed{$k};
        }
    }

    return $packed;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
