package Data::CSV;
use strict;
use warnings;

sub reader {
	require Data::CSV::Reader;
	shift;
	Data::CSV::Reader->new(@_);
}

sub writer {
	require Data::CSV::Writer;
	shift;
	Data::CSV::Writer->new(@_);
}

1
