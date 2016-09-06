package Amazon::DynaMoose::Expander;

use Method::Signatures;
use Moose;

method expand (:$data!,:$class?) {
    unless ($class) {
        $class = $$data{__CLASS__};
    }
    my $obj = $class->unpack($data);

    return $obj;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
