package Data::CSV::Reader;
use strict;
use warnings;
use Carp;
use base 'Data::CSV::base';
use enum::fields::extending 'Data::CSV::base';

sub liner {
	my ($self, $file) = @_;
	open(my $fh, '<', $file) or croak "failed to open file '$file' for reading: $!";
	binmode $fh;
	delete $self->[TYPE];
	delete $self->[DEF];
	sub {
		my $line = <$fh> || return;
		$self->row($line)
	}
}

sub row {
	my ($self, $line) = @_;
	
	#croak "no column definition" unless $self->[DEF];
	return $self->def($line) unless $self->[DEF];

	my @row = $self->[CSV]->parse($line) && $self->[CSV]->fields;

	my $hash = {};
	my $i = -1;
	for (@{$self->[DEF]}) {
		if (ref) {
			my $h = $row[++$i];
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{"@$_"}) {
				if ($type eq 'INTEGER') {
					$h =~ /\D/ && croak "'$h' is not of type INTEGER in column ", join(':', @$_);
				}
			}
			$h = {$_ => $h} for reverse @$_[1..$#$_];
			$hash->{$_->[0]} = $h
		} else {
			$hash->{$_} = $row[++$i];
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{$_}) {
				if ($type eq 'INTEGER') {
					$row[$i] =~ /\D/ && croak "'$row[$i]' is not of type INTEGER in column $_";
				}
			}
		}
	}
	
	return $hash;
}

sub get_def {
	my $self = shift;
	
	croak "no column definition" unless $self->[DEF];
	
	my $array;
	
	for (@{$self->[DEF]}) {
		if (ref) {
			my $h = $self->[DEF_TYPE]->{(ref) ? "@$_" : $_};
			$h = [$_ => $h] for reverse @$_[1..$#$_];
			push @$array, $_->[0], $h
		}
		else {
			push @$array, $_, $self->[DEF_TYPE]->{(ref) ? "@$_" : $_}
		}
	}
	
	$self->[TYPE] ? { $self->[TYPE] => $array } : $array
}

sub set_def {
	my $self = shift;
	my $line = shift || croak "missing definition";
	
	$line =~ s/^(\w+?)def>\s*//;
	$self->[TYPE] = $1;
	
	my @row = $self->[CSV]->parse($line) && $self->[CSV]->fields or croak "unable to parse column definition";
	$self->[DEF] = [ map { /:/ ? [split(':', $_)] : $_ } @row ];
	for (@{$self->[DEF]}) {
		if (((ref) ? $_->[-1] : $_) =~  s/\s+([A-Z]+)//) {
			$self->[DEF_TYPE]->{(ref) ? "@$_" : $_} = $1
		}
	}
	
	1
}

1
