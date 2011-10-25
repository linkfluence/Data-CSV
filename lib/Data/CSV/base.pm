package Data::CSV::base;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(blessed);
use enum::fields qw(
	DEF
	DEF_TYPE
	CHECK_TYPE
	CSV
	TYPE
);

use constant DEFAULT_TEXT_CSV_ARGS	=> (
	sep_char	=> ";", 
	quote_char	=> '"',
	binary		=> 1,
	eol			=> "\n",
);

#use constant KNOWN_TYPES	=> qw(INTEGER FLOAT VARCHAR TEXT);

sub new {
	my $class = shift;
	my %args = (
		text_csv	=> undef,
		check_type	=> 0,
		def			=> undef,
		@_
	);
	
	my $text_csv = delete($args{text_csv});
	my $check_type = delete($args{check_type});
	my $def = delete($args{def});
	
	%args && croak "invalid arguments: '", join("', '", sort keys %args), "'";
	
	my $self = bless [], $class;
	
	$self->[CSV] = do {
		if (!$text_csv) {
			require Text::CSV_PP;
			Text::CSV_PP->new({$class->DEFAULT_TEXT_CSV_ARGS}) or die "invalid DEFAULT_TEXT_CSV_ARGS"
		}
		elsif (ref($text_csv) eq 'HASH') {
			require Text::CSV_PP;
			Text::CSV_PP->new({
				$class->DEFAULT_TEXT_CSV_ARGS,
				%$text_csv
			}) or croak "invalid arguments in 'text_csv'. Check your arguments: '", join("', '", sort keys %$text_csv), "'";
		}
		elsif (blessed($text_csv)) {
			$text_csv
		}
		else {
			croak "if defined, 'text_csv' must be either a hash reference of valid argument for Text::CSV or an instance of Text::CSV compatible class"
		}
	};
	
	$self->[CHECK_TYPE] = $check_type;

	$self->set_def($def) if $def;

	$self
}

sub def {
	my $self = shift;
	$self->set_def(@_) if @_;
	$self->get_def if defined wantarray;
}

sub all {
	my $self = shift;
	delete $self->[TYPE];
	delete $self->[DEF];
	map {$self->row($_)} @_
}

sub text_csv {
	$_[0]->[CSV]
}

sub type {
	$_[0]->[TYPE]
}

1
