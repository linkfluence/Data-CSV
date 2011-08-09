use strict;
use warnings;
use lib 'lib';
use Data::CSV::Writer;

# write sequentially

my $writer = Data::CSV::Writer->new(
	check_type	=> 1,
);

$writer->def({
	node => [
		a		=> 'INTEGER',
		b		=> undef,
		test	=> [
			b	=> undef,
			a	=> 'VARCHAR',
		],
		test2	=> [
			a	=> undef,
			b	=> 'VARCHAR',
		],
	]
});

print $writer->def;
print $writer->row({
	a		=> '0',
	test	=> {
		a => '6 rf'
	},
});

print "\n\n";

# write all

print $writer->all(
	 # first entry must be the definition
	{node => [
		a		=> 'INTEGER',
		b		=> undef,
		test	=> [
			b	=> undef,
			a	=> 'VARCHAR',
		],
		test2	=> [
			a	=> undef,
			b	=> 'VARCHAR',
		],
	]},
	{
		a		=> '0',
		test	=> {
			a => 6
		},
	},
);

# indirect constructor

use Data::CSV;
$writer = Data::CSV->writer(
	check_type	=> 1,
);

# direct write all
#
# use Data::CSV;
# print Data::CSV::write(...);

