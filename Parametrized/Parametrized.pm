package Parametrized;

sub new($) {
	my $type = shift;
	my $this = {
		'Params' => {}
	};
	bless $this,$type;
}
sub reset {}
sub get_paramlist {
	my $self = shift;
	return $self->{'Params'};
}
sub set_param($$$) {
	my $self = shift;
	$self->{'Params'}{$_[0]}[0] = $_[1];
}

1;

