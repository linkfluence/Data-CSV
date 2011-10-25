use strict;
use warnings;
use lib 'lib';
use Data::CSV::Writer;

# write sequentially

my $writer = Data::CSV::Writer->new(
	check_type	=> 1,
	text_csv => {
		sep_char	=> ",", 
		quote_char	=> "'",
		binary		=> 1,
		eol		=> "\n",
	}
);

#$writer->def({
#	node => [
#		a		=> 'INTEGER',
#		b		=> undef,
#		test	=> [
#			b	=> undef,
#			a	=> 'VARCHAR',
#		],
#		test2	=> [
#			a	=> undef,
#			b	=> 'VARCHAR',
#		],
#	]
#}#);

$writer->def({
	node	=> [
		a		=> 'INTEGER',
		b		=> undef,
		'test:b'	=> undef,
		'test:a'	=> 'VARCHAE',
		'test2:a'	=> undef,
		'test2:b'	=> 'VARCHAR',
	]
});
		
print $writer->def;
print $writer->row({
	a		=> '0',
	test	=> {
		a => "http://l'express.fr/"
	},
});

print "\n\n";

# write all

print $writer->all(
	 # first entry must be the definition
	#{node => [
	#	a		=> 'INTEGER',
	#	b		=> undef,
	#	test	=> [
	#		b	=> undef,
	#		a	=> 'VARCHAR',
	#	],
	#	test2	=> [
	#		a	=> undef,
	#		b	=> 'VARCHAR',
	#	],
	#]},
	{node	=> [
		a		=> 'INTEGER',
		b		=> undef,
		'test:b'	=> undef,
		'test:a'	=> 'VARCHAE',
		'test2:a'	=> undef,
		'test2:b'	=> 'VARCHAR',
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

