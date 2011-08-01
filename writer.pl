use ina;
use strict;
use warnings;
use Data::CSV::Writer;

my $writer = Data::CSV::Writer->new(
	check_type	=> 1,
);

$writer->def(
	a		=> 'INTEGER',
	b		=> undef,
	test	=> [
		# array => preserve order
		b	=> undef,
		a	=> 'VARCHAR',
	],
	test2	=> {
		# hash => order is lost
		a	=> undef,
		b	=> 'VARCHAR',
	},
);

print 'nodedef>', $writer->def;

print $writer->row({
	a		=> '0',
	test	=> {
		a => 6
	},
});

