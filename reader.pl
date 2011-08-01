use ina;
use strict;
use warnings;
use YAML::XS;
use Data::CSV::Reader;

my $reader = Data::CSV::Reader->new(
	check_type	=> 0,
);

$reader->def("a,b,c INTEGER,test:a,t,e");

print Dump($reader->row("4,4,4,6,9,8"));


use Time::This;
timed {
	for (1..100_000) {
		$reader->row("4,4,4,6,9,8");
	}
};
