package Amazon::DynaMoose::Exception::Validation;

use Moose;
use namespace::clean -except => 'meta';

with 'Amazon::DynaMoose::Exception::Interface';

__PACKAGE__->meta->make_immutable;

1;

__END__
