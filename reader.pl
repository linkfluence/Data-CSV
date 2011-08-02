use strict;
use warnings;
use YAML::XS;
use lib 'lib';
use Data::CSV::Reader;

# read sequentially

my $reader = Data::CSV::Reader->new(
	check_type	=> 0,
);

$reader->def("a,b,c INTEGER,test:a,t,e");
print Dump $reader->def;
print Dump $reader->row("4,4,4,6,9,8");

# read all

print Dump $reader->all(
	"a,b,c INTEGER,test:a,t,e", # first line must be the definition
	"4,4,4,6,9,8"
);


# indirect constructor

use Data::CSV;
$reader = Data::CSV->reader;

# direct read all
#
# use Data::CSV;
# print Dump Data::CSV::read(...);

