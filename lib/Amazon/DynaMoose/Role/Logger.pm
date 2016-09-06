package Amazon::DynaMoose::Role::Logger;

use Moose::Role;
use Data::Dump 1.16;
use Data::Dump::Filtered qw/dump_filtered/;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

with 'MooseX::Log::Log4perl';

my $dumpFilterCallback = sub {
    my ( $ctx, $oref ) = @_;

    return unless $ctx->class;

    for ( $ctx->class ) {
        when ("DateTime") {
            return { dump => qq($oref) };
        }
        when ("Data::Money") {
            return { dump => qq($oref) };
        }
        when ("DL::DB::Money") {
            return { dump => qq($oref) };
        }
        when ("DateTime::Duration") {
            return { dump => encode_json( { $oref->deltas() } ) };
        }
        when ('DL::Log4perl') {
            return { dump => 'hidden' };
        }
    } ## end for ( $ctx->class )
};

sub Log::Log4perl::Logger::dump {
    my ( $self, $message, $argsref, $loglevel ) = @_;

    $Log::Log4perl::caller_depth += 1;

    local $Data::Dumper::Terse = 1;

    my $coderef = sub {
        return $message . dump_filtered( $argsref, $dumpFilterCallback );
    };
    for ($loglevel) {
        when (undef)      { $self->trace($coderef); }
        when (/^debug$/i) { $self->debug($coderef); }
        when (/^info$/i)  { $self->info($coderef); }
        when (/^warn$/i)  { $self->warn($coderef); }
        when (/^error$/i) { $self->error($coderef); }
        when (/^fatal$/i) { $self->fatal($coderef); }
        default           { $self->trace($coderef); }
    }

    $Log::Log4perl::caller_depth -= 1;
}

no Moose::Role;

1;
__END__
