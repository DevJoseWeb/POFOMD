
package POFOMD::Schema::Result::Programa;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('programa');
__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'integer',
        'is_auto_increment' => 1,
        is_nullable         => 0,
        sequence            => "programa_id_seq",
    },
    'codigo' => { 'data_type' => 'varchar' },
    'nome'   => { 'data_type' => 'varchar' }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint( [ qw/codigo/ ] );

__PACKAGE__->has_many(
    'gastos',
    'POFOMD::Schema::Result::Gasto',
    { "foreign.programa_id" => "self.id" },
    { cascade_copy          => 0, cascade_delete => 1 },
);

1;

