package TestDBRole;

use Moose::Role;
our $VERSION = '0.01';
use v5.14;
use TestDB;

use Log::Log4perl qw(:easy);
use Try::Tiny;
use Env qw/LOADTABLE TESTTABLE LOG_TRACE /;
use Env qw/DYNAMO_HOST DYNAMO_SCOPE DYNAMO_ACCESS_KEY DYNAMO_SECRET_KEY/;
use Data::Dump qw/dump/;
use Test::Most qw(-Test::Deep);
use Types::Standard -all;
use Getopt::Std;
no if $] >= 5.018, warnings => "experimental";
use Method::Signatures;
use IPC::Cmd qw/can_run run/;

with 'Amazon::DynaMoose::Role::Logger';

has 'testclass' => ( is => 'ro', isa => 'Str' );
has 'verbose'   => ( is => 'rw', isa => 'Bool' );

has db => (
    is         => 'ro',
    isa        => 'TestDB',
    lazy_build => 1,
);

has 'db_host' => (
    is      => 'ro',
    isa     => Str,
    default => sub {$DYNAMO_HOST}
);

has 'db_scope' => (
    is      => 'ro',
    isa     => Str,
    default => sub {$DYNAMO_SCOPE}
);

has 'db_access_key' => (
    is      => 'ro',
    isa     => Str,
    default => sub {$DYNAMO_ACCESS_KEY}
);

has 'db_secret_key' => (
    is      => 'ro',
    isa     => Str,
    default => sub {$DYNAMO_SECRET_KEY}
);

# command line args/options
has 'opts' => (
    is      => 'rw',
    isa     => HashRef,
    default => sub { {} },
    traits  => ['Hash'],
    handles => {
        get_opt => 'get',
        set_opt => 'set'
    },
);

sub _build_db {
    my $self           = shift;
    my $connectionArgs = {
        host       => $self->db_host,
        scope      => $self->db_scope,
        access_key => $self->db_access_key,
        secret_key => $self->db_secret_key,
        #debug      => 1
    };

    warn 'building db connection with args: ' . dump $connectionArgs;
    return TestDB->new(%$connectionArgs);
} ## end sub _build_db

# d = run db tests
# t = track writes in journal
# c = clean up records after done
#   if combined with 'd' cleanup is done with begin/rollback
#   if combined with 't' cleanup loads the journal and deletes in reverse
# n = chainable request. used for downstream tests to ask  for row(s)
#   to be inserted in the db that can be used in subsequent tests.
#   shields downstream tests from deep knowledge about dependent data
sub BUILD {
    my $self = shift;

    my %opts;
    getopts( 'l:dctn', \%opts );
    $self->opts( \%opts );

    say "opts: " . dump \%opts;
}

sub main {
    my $self = shift;

    # log level
    my $LOG_LEVEL = $ERROR;
    if ( defined $self->get_opt('l') ) {
        for ( lc( $self->get_opt('l') ) ) {
            when ('debug') {
                $LOG_LEVEL = $DEBUG;
                $self->verbose(1);
            }
            when ('info') {
                $LOG_LEVEL = $INFO;
            }
            when ('warn') {
                $LOG_LEVEL = $WARN;
            }
            when ('error') {
                $LOG_LEVEL = $ERROR;
            }
        }
    } ## end if ( defined $opt->{l})
    $LOG_LEVEL = $TRACE if ($LOG_TRACE);

    Log::Log4perl->easy_init($LOG_LEVEL);

    use_ok( $self->testclass )
        if ( $self->testclass );

    $self->do_db_tests();
}

1;

__END__

