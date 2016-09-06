package Amazon::DynaMoose::Role::Item;

use Method::Signatures;
use Moose::Role;
use MooseX::Storage;

use Amazon::DynaMoose::Trait::IsPrimaryKey;
use Amazon::DynaMoose::Query;

with Storage( base => '=Amazon::DynaMoose::Storage' );

has '_primary_key' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $pk;

        for my $attr (
            grep { $_->does('Amazon::DynaMoose::Trait::IsPrimaryKey') }
            $self->meta->get_all_attributes )
        {
            my $accessor = $attr->accessor;
            $$pk{ $attr->name } = $self->$accessor;
        }

        return $pk;
    },
    traits => [qw/DoNotSerialize/]
);

method QueryPrimaryKey ($pk!) {
    return Amazon::DynaMoose::Query->new(
        class  => $self,
        filter => $pk
    );
}

no Moose::Role;

1;
__END__
