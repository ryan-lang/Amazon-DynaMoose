package Amazon::DynaMoose;
our $VERSION = '0.0.1001';

use Method::Signatures;
use Moose;
use Try::Tiny;

use Amazon::DynaMoose::Exception::Validation;
use Amazon::DynaMoose::Exception::ConditionalCheckFailed;
use Amazon::DynaMoose::Exception::InvalidArgs;

use Amazon::DynaMoose::Collapser;
use Amazon::DynaMoose::Expander;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

with qw/
    Amazon::DynaMoose::Role::DynamoAPI::LWP
    /;

has 'collapser' => (
    is      => 'rw',
    isa     => 'Amazon::DynaMoose::Collapser',
    default => sub { Amazon::DynaMoose::Collapser->new() }
);

has 'expander' => (
    is      => 'rw',
    isa     => 'Amazon::DynaMoose::Expander',
    default => sub { Amazon::DynaMoose::Expander->new() }
);

# does a PutItem; will not overwrite existing
method insert (:$obj!) {

    # build condition on primary key not existing
    my $conditions = [
        map { sprintf( 'attribute_not_exists(%s)', $_ ) }
            keys %{ $obj->_primary_key }
    ];
    $conditions = join( 'AND', @$conditions );

    my $resp = $self->api->put_item(
        TableName           => $obj->meta->tablename,
        Item                => $self->collapser->collapse($obj),
        ConditionExpression => $conditions
    );

    if ( $resp->failure ) {
        $self->_handleFailure( $resp->failure );
    }
    else {
        return $resp;
    }
}

# does a PutItem; may overwrite existing
method put (:$obj!) {
    my $resp = $self->api->put_item(
        TableName    => $obj->meta->tablename,
        Item         => $self->collapser->collapse($obj),
        ReturnValues => 'ALL_OLD'
    );

    if ( $resp->failure ) {
        $self->_handleFailure( $resp->failure );
    }
    else {
        return $resp;
    }
}

# method update (:$obj!) {
#     my $resp = $self->api->update_item(
#         TableName => $obj->meta->tablename,
#         Key       => $obj->_primary_key,
#         UpdateExpression =>
#             $self->collapser->collapse( $obj, exclude_primary_key => 1 ),
#         ReturnValues => 'UPDATED_NEW'
#     );

#     if ( $resp->failure ) {
#         $self->_handleFailure( $resp->failure );
#     }
#     else {
#         return $resp;
#     }
# }

method delete (:$obj, :$primary_key, :$tablename) {

    # either $obj, or $primary_key plus $tablename required
    my $resp;
    if ($obj) {
        $resp = $self->api->delete_item(
            TableName => $obj->meta->tablename,
            Key       => $obj->_primary_key
        );
    }
    else {
        $resp = $self->api->delete_item(
            TableName => $tablename,
            Key       => $primary_key
        );
    }

    return $resp;
}

# retrieve item by primary key
# query is either a Query object or a hashref
# that can be passed to get_item
method get ($query!) {
    my $args;
    if ( ref $query eq 'HASH' ) {
        $args = $query;
    }
    else {
        $args = {
            TableName => $query->class->meta->tablename,
            Key       => $query->filter
        };
    }

    my $item;
    my $resp = $self->api->get_item(
        sub {
            $item = shift;
        },
        %$args
    );

    my $obj = $self->expander->expand(
        data  => $item,
        class => ref $query eq 'HASH' ? undef : $query->class
    );

    return $obj;
}

method search (:$query!) {

}

method batch_get (:$query!) {

}

method _handleFailure ($failure) {
    for ( $failure->{__type} ) {
        when (/com.amazon.coral.validate/) {
            Amazon::DynaMoose::Exception::Validation->throw(
                $failure->{message} );
        }
        when (/ConditionalCheckFailedException/) {
            Amazon::DynaMoose::Exception::ConditionalCheckFailed->throw(
                $failure->{message} );
        }
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

1;
