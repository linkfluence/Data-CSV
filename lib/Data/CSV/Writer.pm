package Data::CSV::Writer;
use strict;
use warnings;
use Carp;
use base 'Data::CSV::base';
use enum::fields::extending 'Data::CSV::base';
use List::Pairwise qw(mapp);

sub row {
	my ($self, $hash) = @_;
	
	#croak "no column definition" unless $self->[DEF];
	return $self->def($hash) unless $self->[DEF];
	
	$hash = {@$hash} if ref($hash) eq 'ARRAY';
	
	my $h;
	my @row = map {
		if (ref) {
			$h = $hash;
			$h = $h->{$_} for @$_;
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{"@$_"}) {
				if ($type eq 'INTEGER') {
					$h =~ /\D/ && croak "'$h' is not of type INTEGER in column ", join(':', $_);
				}
			}
		} else {
			$h = $hash->{$_};
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{$_}) {
				if ($type eq 'INTEGER') {
					$h =~ /\D/ && croak "'$h' is not of type INTEGER in column $_";
				}
			}
		}
		$h
	} @{$self->[DEF]};

	$self->[CSV]->combine(@row) && $self->[CSV]->string
}

sub get_def {
	my $self = shift;
	
	croak "no column definition" unless $self->[DEF];
	
	$self->[CSV]->combine(
		map {
			join(' ', ((ref) ? join(':', @$_) : $_), $self->[DEF_TYPE]->{(ref) ? "@$_" : $_} || ())
		} @{$self->[DEF]}
	) && $self->[CSV]->string
}

sub set_def {
	my $self = shift;
	croak "missing definition" unless @_;
	my $def = (@_==1 && ref $_[0]) ? $_[0] : \@_;
	
	$self->[DEF] = [];
	$self->[DEF_TYPE] = {};
	
	_traverse($def => $self->[DEF]);
	
	for (@{$self->[DEF]}) {
		$self->[DEF_TYPE]->{(ref) ? "@$_" : $_} = pop @$_;
		$_ = $_->[0] if @$_ == 1
	}
}

sub _traverse {
	my ($el, $store, @path) = @_;
	
	if (ref $el) {
		mapp {
			_traverse($b, $store, @path, $a);
		} ref($el) eq 'HASH' ? %$el : @$el;
	}
	else {
		push @$store, [@path, $el];
	}
}

1
