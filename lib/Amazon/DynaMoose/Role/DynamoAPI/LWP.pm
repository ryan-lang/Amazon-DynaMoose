package Amazon::DynaMoose::Role::DynamoAPI::LWP;

use Moose::Role;
use Amazon::DynamoDB;

with 'Amazon::DynaMoose::Role::Logger';

has 'implementation' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Amazon::DynamoDB::LWP'
);

has 'dynamo_version' => (
    is      => 'ro',
    isa     => 'Str',
    default => '20120810'
);

has [qw/access_key secret_key/] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has 'host' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has 'scope' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has 'ssl' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1
);

has 'debug' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0
);

has 'api' => (
    is         => 'ro',
    lazy_build => 1
);

sub _build_api {
    my $self = shift;

    my $args = {
        implementation => $self->implementation,
        dynamo_version => $self->dynamo_version,
        access_key     => $self->access_key,
        secret_key     => $self->secret_key,
        host           => $self->host,
        scope          => $self->scope,
        ssl            => $self->ssl,
        debug          => $self->debug
    };

    $self->log->dump( 'connecting to db: ', $args );

    my $dbh = Amazon::DynamoDB->new(%$args);

    return $dbh;
}

no Moose::Role;

1;
__END__
