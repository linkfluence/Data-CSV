package Data::CSV::Writer;
use strict;
use warnings;
use Carp;
use base 'Data::CSV::base';
use enum::fields::extending 'Data::CSV::base';
use List::Pairwise qw(mapp);

sub liner {
	my ($self, $file) = @_;
	open(my $fh, '>', $file) or croak "failed to open file '$file' for writing: $!";
	binmode $fh;
	delete $self->[TYPE];
	delete $self->[DEF];
	sub {
		print $fh $self->row(@_)
	}
}

sub row {
	my ($self, $hash) = @_;
	return $self->def($hash) unless $self->[DEF];
	
	my $h;
	my @row = map {
		if (ref) {
			$h = $hash;
			$h = $h->{$_} for @$_;
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{"@$_"}) {
				if (
					($type eq 'INTEGER' && $h =~ /\D/)
					||
					($type eq 'FLOAT' && $h =~ /[^\d\.]/)
				) {
					croak "'$h' is not of type $type in column ", join(':', @$_);
				}
			}
		} else {
			$h = $hash->{$_};
			if (my $type = $self->[CHECK_TYPE] && $self->[DEF_TYPE]->{$_}) {
				if (
					($type eq 'INTEGER' && $h =~ /\D/)
					||
					($type eq 'FLOAT' && $h =~ /[^\d\.]/)
				) {
					croak "'$h' is not of type $type in column $_";
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

	my $quote = $self->[TYPE] && $self->[CSV]->quote_char();
	$self->[CSV]->quote_char('') if $quote;

	$self->[CSV]->combine(
		map {
			join(' ',
				((ref) ? join(':', @$_) : $_),
				$self->[DEF_TYPE]->{(ref) ? "@$_" : $_} || ()
			)
		} @{$self->[DEF]}
	);
	$self->[CSV]->quote_char($quote) if $quote;

	$self->[TYPE] ? "$self->[TYPE]def> ". $self->[CSV]->string : $self->[CSV]->string
}

sub set_def {
	my $self = shift;
	croak "missing definition" unless @_;
	my ($type, $def) = (ref($_[0]) eq 'HASH') ? %{$_[0]} : (undef, $_[0]);

	croak "if type is present it must be a string" if defined($type) && $type =~ /\W/;
	croak "definition must be an array reference" unless (ref($def)||'') eq 'ARRAY';
	
	$self->[TYPE] = $type;
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
