
my $test = unit_test->new();
$test->main();

BEGIN {

    package testObj;

    use Moose -traits => ['Amazon::DynaMoose::Trait::HasTable'];
    __PACKAGE__->meta->tablename('Session');

    with 'Amazon::DynaMoose::Role::Item';

    has 'session_id' => (
        is     => 'rw',
        traits => [qw/IsPrimaryKey/]
    );
    has 'keyA' => ( is => 'rw' );
    has 'keyB' => ( is => 'rw' );

    package unit_test;

    use Moose;
    use Test::Most qw(no_plan -Test::Deep);
    use Try::Tiny;
    use FindBin qw($Bin);
    use lib "$Bin/lib";
    use Data::Dump qw/dump/;
    use Carp;

    with qw/TestDBRole/;

    sub do_db_tests {
        my ($self) = @_;

        # lives_ok {
        #     $self->db->insert(
        #         obj => testObj->new(
        #             keyA       => 'foob',
        #             keyB       => 'bar',
        #             session_id => 'bazz'
        #         )
        #     );
        # }
        # "inserts new object";

        # dies_ok {
        #     $self->db->insert(
        #         obj => testObj->new(
        #             keyA       => 'foob',
        #             keyB       => 'bar',
        #             session_id => 'bazz'
        #         )
        #     );
        # }
        # "prevents overwriting existing object on insert";

        # lives_ok {
        #     $self->db->put(
        #         obj => testObj->new(
        #             keyA       => 'foo',
        #             keyB       => 'bar',
        #             session_id => 'bazz'
        #         )
        #     );
        # }
        # "overwrites existing object on put";

        lives_ok {
            my $item = $self->db->get(
                {   TableName => 'Session',
                    Key       => { session_id => 'bazz' }
                }
            );
            $self->log->dump( 'resp', $item, 'info' );
        }
        "gets an item";

        lives_ok {
            my $item = $self->db->get(
                testObj->QueryPrimaryKey( { session_id => 'bazz' } ) );
            $self->log->dump( 'resp', $item, 'info' );
        }
        "gets an item using a query";

        #$self->log->dump( 'resp', $resp, 'info' );
    }

    1;
}
