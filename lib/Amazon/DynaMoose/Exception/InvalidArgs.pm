package Amazon::DynaMoose::Exception::InvalidArgs;

use Moose;
use namespace::clean -except => 'meta';

with 'Amazon::DynaMoose::Exception::Interface';

has '+message' => (
    default => "invalid args",
);

__PACKAGE__->meta->make_immutable;

1;

__END__
