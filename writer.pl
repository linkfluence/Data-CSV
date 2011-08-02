use strict;
use warnings;
use lib 'lib';
use Data::CSV::Writer;

# write sequentially

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

# write all

print $writer->all(
	 # first entry must be the definition
	[
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
	],
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

# direct call
#
# use Data::CSV;
# print Data::CSV->write(...);

