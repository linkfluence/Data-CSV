package Data::CSV;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT_OK = qw(flatten);

sub reader {
	require Data::CSV::Reader;
	shift;
	Data::CSV::Reader->new(@_)
}

sub writer {
	require Data::CSV::Writer;
	shift;
	Data::CSV::Writer->new(@_)
}

sub read {
	reader->all(@_)
}

sub write {
	writer->all(@_)
}

# utility function, quick (15 times as fast) and dirty (only works for hashes and without circular ref detection) version of Hash::Flatten::flatten()
{
	my $res;
	sub flatten {
		my $hash = shift;
		$res = {};
		_flatten($hash, '');
		return $res;
	}
	sub _flatten {
		my ($hash, $path) = @_;
		while (my ($k, $v) = each %$hash) {
			if (ref $v) {
				_flatten($v, "$path$k:")
			} else {
				$res->{$path.$k} = $v
			}
		}
	}
}

#my $test = {
#	a	=> 1,
#	b	=> {
#		c	=> 2,
#		d	=> {
#			e	=> 3,
#			f	=> 4,
#		}
#	}
#};
#
#use YAML;
#use Time::This;
#use Hash::Flatten ();
#timed {
#	for (1..100_000) {
#		my $hash = Hash::Flatten::flatten($test);
#	}
#} "Hash::Flatten";
#
#timed {
#	for (1..100_000) {
#		my $hash = flatten($test);
#	}
#} __PACKAGE__;
#
#print Dump flatten($test);
#exit;

1
