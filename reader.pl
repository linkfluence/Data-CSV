use strict;
use warnings;
use YAML::XS;
use lib 'lib';
use Data::CSV::Reader;

# read sequentially

my $reader = Data::CSV::Reader->new(
	check_type	=> 0,
);

$reader->def("nodedef> a;b;  c VARCHAR(44);test:a;t;test:e\n");
print Dump $reader->def;
print Dump $reader->row('4;"4""4";4;6;9;8\n');


print "\n\n";
# read all

print Dump $reader->all(
	"a;b;c INTEGER;test:a;t;test:e", # first line must be the definition
	'4;4;4;"6""6";9;8'
);

my $reader = Data::CSV::Reader->new(
	check_type	=> 0,
	text_csv => {
		sep_char	=> ";", 
		quote_char	=> "'",
		binary		=> 1,
		eol		=> "\n",
	}
);

$reader->def("nodedef> a;b;  c VARCHAR(44);test:a;t;test:e\n");
print Dump $reader->def;
eval {print Dump $reader->row("4;'4''4';4;6;9;8\n")};
warn "".$reader->text_csv->error_diag () if $@;


# indirect constructor

use Data::CSV;
my $reader = Data::CSV->reader(text_csv => {
	sep_char	=> ",", 
	quote_char	=> "'",
	binary		=> 1,
	eol		=> "\n",
	allow_loose_quotes  => 0,
	allow_loose_escapes => 0,
});

# direct read all
#
# use Data::CSV;
# print Dump Data::CSV::read(...);


$reader->def("nodedef> id VARCHAR,name VARCHAR,url VARCHAR,accept VARCHAR,refuse VARCHAR,seed_distance INTEGER,status VARCHAR,title VARCHAR,pages INTEGER,links INTEGER,score:text:verbes,score:text:stop words,score:text:ina,score:text:tf1\n");
print Dump $reader->def;
print Dump $reader->row("'g\"'roupe-tf1.fr-ae2d3dac5bee7e73',groupe-tf1.fr,http://www.groupe-tf1.fr/ressources-humaines/,,,1,valid,,1,,,,,\n");
eval {print Dump $reader->row("vie-publique.fr-d53067984bed2d61,vie-publique.fr,'https://mon.vie-publique.fr/?a=se&v=2&f=clip&tl=bk&u=http://service-public.fr/&t=service-public.fr,%20le%20site%20officiel%20de%20l''administration%20française&x=&tag=&sw=1',,,3,valid,,1,,,,,\n");};
die "".$reader->text_csv->error_diag () if $@;
#print Dump $reader->row("groupe-tf1.fr-ae2d3dac5bee7e73,groupe-tf1.fr,http://www.groupe-tf1.fr/ressources-humaines/,,,1,valid,,1,,,,,\n");
#print Dump $reader->row("lexpress.fr-1feb11e5765e1ed3,lexpress.fr,'http://l''express.fr/',,,3,valid,,10,151,880,87516,,220\n");


