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
	sub {{
		my $row = $self->[CSV]->getline($fh) || return;
		redo if @$row==1 && $row->[0] eq '';
		$self->row($row)
	}}
}

sub row {
	my ($self, $row) = @_;
	return $self->def($row) unless $self->[DEF];
	
	unless (ref $row) {
		$self->[CSV]->parse($row) or croak "unable to parse row";
		$row = [$self->[CSV]->fields];
	}

	my $hash = {};
	my $i = -1;
	for (@{$self->[DEF]}) {
		if (ref) {
			my $h = $row->[++$i];
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{"@$_"}) {
				if (
					($type eq 'INTEGER' && $h =~ /\D/)
					||
					($type eq 'FLOAT' && $h =~ /[^\d\.]/)
				) {
					croak "'$h' is not of type $type in column ", join(':', @$_);
				}
			}
			$h = {$_ => $h} for reverse @$_[1..$#$_];
			$hash->{$_->[0]} = $h
		} else {
			$hash->{$_} = $row->[++$i];
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{$_}) {
				if (
					($type eq 'INTEGER' && $row->[$i] =~ /\D/)
					||
					($type eq 'FLOAT' && $row->[$i] =~ /[^\d\.]/)
				) {
					croak "'$row->[$i]' is not of type $type in column $_";
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
	my $row = shift || croak "missing definition";
	
	unless (ref $row) {
		$self->[CSV]->parse($row) or croak "unable to parse column definition";
		$row = [$self->[CSV]->fields];
	}

	$row->[0] =~ s/^(\w+?)def>\s*//;
	$self->[TYPE] = $1;

	$self->[DEF] = [ map { /:/ ? [split(':', $_)] : $_ } @$row ];
	
	for (@{$self->[DEF]}) {
		s/^\s+|\s+$//g for (ref) ? @$_ : $_;
		if (((ref) ? $_->[-1] : $_) =~  s/\s+([A-Z]+(?:\(\d*\))?)$//) {
			$self->[DEF_TYPE]->{(ref) ? "@$_" : $_} = $1
		}
	}
	
	1
}

1
