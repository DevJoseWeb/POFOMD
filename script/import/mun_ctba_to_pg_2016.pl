#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use POFOMD::Schema;
use utf8;
use Text::Unaccent;

use Text::CSV;
use Text2URI;

use String::Random qw(random_regex random_string);
my $t = new Text2URI();

my $schema     = POFOMD::Schema->connect( "dbi:Pg:host=localhost;dbname=pofomd", "postgres", "pofomd" );
my $rs         = $schema->resultset('Gasto');
my $rs_dataset = $schema->resultset('Dataset');

  
if ( scalar(@ARGV) != 2 ) {
    print "Use $0 [year] [dataset.csv]\n";
    exit;
}

my $year    = $ARGV[0];
my $ds_name = 'Municipio de Curitiba';

my $dataset = $rs_dataset->find_or_create(
    {
        nome    => $ds_name,
        periodo => $schema->resultset('Periodo')->find_or_create( { ano => $year } ),
        uri     => $t->translate( join( '-', 'ctba-curitiba', $year ) )
    }
);

=pod
my (
$CODIGO_ORGAO_SUPERIOR, $NOME_ORGAO_SUPERIOR,
$CODIGO_ORGAO_SUBORDINADO, $NOME_ORGAO_SUBORDINADO,
$CODIGO_UNIDADE_GESTORA, $NOME_UNIDADE_GESTORA,
$CODIGO_GRUPO_DESPESA, $NOME_GRUPO_DESPESA,
$CODIGO_FUNCAO, $NOME_FUNCAO,
$CODIGO_SUBFUNCAO, $NOME_SUBFUNCAO,
$CODIGO_PROGRAMA, $NOME_PROGRAMA,
$CODIGO_ACAO, $NOME_ACAO,
$LINGUAGEM_CIDADA, $VALOR
);
=cut
#Variaveis correspondentes as colunas do CSV sendo utilizado
my (

$ANO_EMPENHO,				$DATA_EMPENHO,			$CODIGO_FONTE,					$NOME_FONTE,
$CODIGO_FUNCAO,				$NOME_FUNCAO,			$CODIGO_PROGRAMA,				$NOME_PROGRAMA,
$CODIGO_ACAO,				$NOME_ACAO,			$CODIGO_SUBFUNCAO,				$NOME_SUBFUNCAO,
$CODIGO_UNIDADE_GESTORA,		$NOME_UNIDADE_GESTORA,		$CODIGO_DESPESA,				$NOME_DESPESA,
$CODIGO_GRUPO_DESPESA,			$NOME_GRUPO_DESPESA,		$CODIGO_DESPESA_MODALIDADE,			$NOME_MODALIDADE,
$CODIGO_DESPESA_ELEMENTO,		$NOME_ELEMENTO,			$CPF_CNPJ,					$CODIGO_EMPENHO,
$LICITACAO,				$VALOR,				$CODIGO_ITEM,					$NOME_ITEM,
$NOME_UNIDADE,				$QUANTIDADE,			$VL_PRECO_UNITARIO,				$VL_TOTAL,
$PROTOCOLOSUP,				$DT_TRANSACAO,			$VL_LIQUIDADO,					$VL_DEVOLVIDO,
$VL_ANULADO,				$VL_PAGO,			$VL_CONSIGNADO,



);


my $csv = Text::CSV->new(
    {
        sep_char           => ";",
        allow_loose_quotes => 1,
        binary             => 1,
        verbatim           => 0,
        auto_diag          => 2,
        escape_char        => undef,
    }
);

=pod
$csv->bind_columns(
    \$CODIGO_ORGAO_SUPERIOR, \$NOME_ORGAO_SUPERIOR,
    \$CODIGO_ORGAO_SUBORDINADO, \$NOME_ORGAO_SUBORDINADO,
    \$CODIGO_UNIDADE_GESTORA, \$NOME_UNIDADE_GESTORA,
    \$CODIGO_GRUPO_DESPESA, \$NOME_GRUPO_DESPESA,
    \$CODIGO_FUNCAO, \$NOME_FUNCAO,
    \$ODIGO_PROGRAMA, \$NOME_PROGRAMA,
    \$CODIGO_ACAO, \$NOME_ACAO,
    \$LINGUAGEM_CIDADA, \$VALOR
);
=cut

my $foo;
my $fik;
$csv->bind_columns (

\$ANO_EMPENHO,				\$DATA_EMPENHO,			\$CODIGO_FONTE,					\$NOME_FONTE,
\$CODIGO_FUNCAO,			\$NOME_FUNCAO,			\$CODIGO_PROGRAMA,				\$NOME_PROGRAMA,
\$CODIGO_ACAO,				\$NOME_ACAO,			\$CODIGO_SUBFUNCAO,				\$NOME_SUBFUNCAO,
\$CODIGO_UNIDADE_GESTORA,		\$NOME_UNIDADE_GESTORA,		\$CODIGO_DESPESA,				\$NOME_DESPESA,
\$CODIGO_GRUPO_DESPESA,			\$NOME_GRUPO_DESPESA,		\$CODIGO_DESPESA_MODALIDADE,			\$NOME_MODALIDADE,
\$CODIGO_DESPESA_ELEMENTO,		\$NOME_ELEMENTO,		\$CPF_CNPJ,					\$CODIGO_EMPENHO,
\$LICITACAO,				\$VALOR,			\$CODIGO_ITEM,					\$NOME_ITEM,
\$NOME_UNIDADE,				\$QUANTIDADE,			\$VL_PRECO_UNITARIO,				\$VL_TOTAL,
\$PROTOCOLOSUP,				\$DT_TRANSACAO,			\$VL_LIQUIDADO,					\$VL_DEVOLVIDO,
\$VL_ANULADO,				\$VL_PAGO,			\$VL_CONSIGNADO,


	\$fik, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo, \$foo,
);


open my $fh, '<:encoding(utf8)', $ARGV[1] or die 'error';
#open my $fh, '<:encoding(iso-8859-1)', $ARGV[1] or die 'error';
#open my $fh, '<', $ARGV[1] or die "error: $!";

my $line = 0;

my $cache_inserting = {};
&load_from_database($_) for qw /Funcao Subfuncao Programa Acao Beneficiario Despesa Gestora Recurso/;

$rs->search( { dataset_id => $dataset->id } )->delete;


use Encode qw/encode decode/;
my $err = 0;


while ( my $row = $csv->getline($fh) ) {
    $line++;

#$_ = encode('iso-8859-1', $_);
#    my $var = uc   unac_string('UTF-8', $_);
#$var =~ s/ /_/g;
#    print STDERR '\$' . $var . ', '
#}
#    exit;

    next if $line == 1 or !$VALOR;

#   $CODIGO_ACAO=$PA;
#   $NOME_ACAO=$PAPA;

#$NOME_FUNCAO = decode('iso-8859-1', $NOME_FUNCAO);
#$NOME_FUNCAO = encode('utf-8', $NOME_FUNCAO);

#$NOME_SUBFUNCAO = decode('iso-8859-1', $NOME_SUBFUNCAO);
#$NOME_SUBFUNCAO = encode('utf-8', $NOME_SUBFUNCAO);

#$NOME_PROGRAMA = decode('iso-8859-1', $NOME_PROGRAMA);
#$NOME_PROGRAMA = encode('utf-8', $NOME_PROGRAMA);

    print "
    CODIGO_FUNCAO: $CODIGO_FUNCAO
    NOME_FUNCAO: $NOME_FUNCAO
    CODIGO_SUBFUNCAO: $CODIGO_SUBFUNCAO
    NOME_SUBFUNCAO: $NOME_SUBFUNCAO
    CODIGO_PROGRAMA: $CODIGO_PROGRAMA
    NOME_PROGRAMA: $NOME_PROGRAMA
    CODIGO_ACAO: $CODIGO_ACAO
    NOME_ACAO: $NOME_ACAO
    VALOR: $VALOR
    " if 1;

#    $VALOR = normalize_value($VALOR);
    my $str = random_regex('\d\d\d\d\d\d\d\d\d\d\d\d');
    eval {
        my $obj = $rs->create(
            {
                dataset_id => $dataset->id,

                &cache_or_create( 'funcao', 'Funcao', { codigo => $CODIGO_FUNCAO, nome => $NOME_FUNCAO } ),

                &cache_or_create( 'subfuncao', 'Subfuncao', { codigo => $CODIGO_SUBFUNCAO, nome => $NOME_SUBFUNCAO } ),

                &cache_or_create(
                    'programa',
                    'Programa',
                    {
                        codigo => $CODIGO_PROGRAMA,
                        nome   => &remover_acentos($NOME_PROGRAMA)
                    }
                ),

                &cache_or_create(
                    'acao', 'Acao',
                    {
                        codigo => $CODIGO_ACAO,
                        nome   => &remover_acentos($NOME_ACAO)
                    }
                ),

                &cache_or_create(
                    'beneficiario',
                    'Beneficiario',
                    {
                        codigo    => 'NAO-INFORMADO',
                        nome      => &remover_acentos('NAO-INFORMADO'),
                        documento => '0',
                        uri       => $t->translate( &remover_acentos('NAO-INFORMADO') )
                    }
                ),

                &cache_or_create(
                    'despesa',
                    'Despesa',
                    {
                        codigo => $CODIGO_GRUPO_DESPESA,
                        nome   => &remover_acentos($NOME_GRUPO_DESPESA)
                    }
                ),

                &cache_or_create(
                    'gestora',
                    'Gestora',
                    {
                        codigo => $CODIGO_UNIDADE_GESTORA,
                        nome   => $NOME_UNIDADE_GESTORA
                    }
                ),

                pagamento => $schema->resultset('Pagamento')->create(
                    {
                        numero_processo            => "NAO-INFORMADO-$CODIGO_ACAO-$str",
                        numero_nota_empenho        => 'NAO-INFORMADO',
                        tipo_licitacao             => 'NAO-INFORMADO',
                        valor_empenhado            => 0,
                        valor_liquidado            => $VALOR,
                        valor_pago_anos_anteriores => 0,
                    }
                ),

                &cache_or_create(
                    'recurso',
                    'Recurso',
                    {
                        codigo => 'NAO-INFORMADO',
                        nome   => 'NAO-INFORMADO'
                    }
                ),
                valor => $VALOR
            }
        );
    };

    print "$@\n" if $@;
    $err++ if $@;

    #    print "funcao, $NOME_FUNCAO\n";
    #    print "subfuncao, $NOME_SUBFUNCAO\n";
    #    print "programa, $NOME_PROGRAMA\n";
    #    print "acao, $NOME_ACAO\n";

}

print $csv->error_diag();
print "\n\n";
print "done #err $err total $line \n";
close $fh;

sub load_from_database {
    my ($campo) = @_;

    my $campo_lc = lc $campo;
    my $rs       = $schema->resultset($campo);
    my $r;
    $cache_inserting->{$campo_lc}{ $r->codigo } = $r->id while ( $r = $rs->next );
}

sub cache_or_create {
    my ( $campo, $set, $info ) = @_;

    my $codigo = $info->{codigo};
    my $id;

    if ( exists $cache_inserting->{$campo}{$codigo} ) {

        $id = $cache_inserting->{$campo}{$codigo};

    }
    else {
        my $obj = $schema->resultset($set)->create($info);

        $cache_inserting->{$campo}{$codigo} = $id = $obj->id;
    }

    return ( $campo . '_id' => $id );
}

sub remover_acentos {
    my $var = shift;
   # $var = unac_string( 'UTF-8', $var );
    return $var;
}

sub normalize_value {
	my $valor = shift;

	$valor    =~ s/,/./g;
	my @valor = split /\./, $valor;
	my $cents = pop @valor;
	$valor    = join "", @valor;
	$valor    = $valor . "." . $cents;

	return $valor;
}
