package Neural::Basic;
use Math::DVector;
use Parametrized;

$Neural::VERSION = '0.01';

require DynaLoader;
@ISA = (DynaLoader);
use strict;
use Neural::BasicGroups;

=head1 NAME

Neural::Basic - Copylefted artificial neural networks extension

=head1 DESCRIPTION

The Neural module enables access to the GANN artificial neural
network library designed especially to work with Perl.
This makes it possible to do high-level neural network operations
from inside Perl. The interface consists of several classes
of Perl objects, described below.

For information about the design, see L<Math::Gann>

=head1 CLASSES

=cut
######################################################################
package Neural::Pars;

sub new ($$) {
	my $type = shift;
	my $net = shift;
	my $this = {
		'Net' => $net,
		'UIn' => new Math::DVector($net->nunits),
		'UOut' => new Math::DVector($net->nunits),
		'Wei' => new Math::DVector($net->nweights),
		'DUOut' => new Math::DVector($net->nunits),
		'DWei' => new Math::DVector($net->nweights)
	};
	bless $this,$type;
}

sub rand_weights ($$) {
	my $this = shift;
	my ($min,$max);
	if($#_ == 1) {
		$min = $_[0]; $max = $_[1];
	} else {
		$min = -0.3; $max = 0.3;
	}
	print "RW: $min,$max\n";
	$this->{Wei}-> setlist( map {$min + rand($max-$min)} 
	 	(0..$this->{Net}->nweights-1) );
}

sub asstr {
	my $this = shift;
	my $str = "";
	for ("UIn","UOut","Wei","DUOut","DWei") {
		$str .= $_ . " = " . $this->{$_}->asstr . "\n";
	}
	return $str;
}

=head2 Neural::Pars

Neural::Pars is a convenience class that holds suitably
sized vectors for a given network. The most important user-accessible
members are 'Wei' and 'DWei', which give the weights and the
gradient of the error w.r.t. the weights (when doing
backprop), respectively. The other members are usually not important
for the user.

Methods:

=over 8

=item new(I<net>)

Net must be a reference to a valid Neural::Net.

=item rand_weights(I<min>,I<max>)

Randomize all the weights in the network.
Min and max are optional arguments, defaulting to -0.8 and 0.8.

=item asstr

Return a string representation of this structure. Useful for debugging.

=back

=cut

##########################################################################
package Neural::Net;
use Carp;
#use Neural::BasicGroup;
#use Neural::BiasGroup;

=head2 Neural::Net

Neural::Net is the class that does most of the actual work:
it contains the network topology and is used to do forward and
backpropagation.

Before using, the network topology has to be constructed by
creating all the groups of neurons one by one, specifying the connections
of each to each other. 

Methods:

=over 8

=item new(ninputs)

Creates a new, empty net

=item new_load(file,args)

Loads a network from a file. The file is actually perl code to
create the network and I<args> are given verbatim to the 
function C<define_network> in the file, which should return one 
reference to the network.

=item activate(in,unitin,unitout,out,wei)
=item activate_p(in,out,pars)

Does forward propagation through the network. I<in> is the inputs
vector, and I<out> gives the result

=item backactivate(in,unitin,unitout,out,wei,dwei,dunitout,target)

Does back-propagation through the network. I<target> is the output
we would have liked to have and I<dwei> gives the gradient
on the error surface w.r.t. the weights.

=item backprop(in,unitin,unitout,out,wei,dwei,dunitout,target)

Just a wrapper that calls both of the preceding functions
and does some error checking on the sizes of the vectors.

=item inputsize(), outputsize(), nunits(), nweights(), ngroups()

Return numbers of some entities in the network.

=item print_perl

Returns a string describing the network's structure in plain text.
Useful for debugging, mostly.

=back

The current implementation is still a little rough, requiring the
call to finalize() in order to get a work. 

=cut


sub new {
	my ($type,$ninputs)=@_;
	my $this = {
		groups => [new Neural::InputGroup($ninputs)],
		wstart => 0,
		ostart => $ninputs,
		ninputs => $ninputs,
		outstart => 0,
		noutputs => $ninputs,
	};
	bless $this,$type;
}

sub new_load {
	my ($type,$fn,@args) = @_;
	my $net;
	@!=0;
	eval `cat $fn` or die "Couldn't load network $fn: ($!) ($@)\n";
	$net = &defnets(@args);
	return $net;
}

sub add_group {
	my ($this,$type,%pars) = @_;
	print "BEFORE: Nwei:",$this->nweights(),"\n";
	$_=$type;
	my $grp;
#	print %Neural::; print "\nAND BIAS\n";
	my @a=%Neural::BiasGroup::; print "\n";
	@a=%Neural::BasicGroup::; print "\n";

	if (defined $pars{Input_Groups}) {
		my $igs = delete $pars{Input_Groups};
		my (@avino,@avio);
		@avio = map { $this->{groups}[$_]->get_ostart() }
				@$igs;
		@avino = map { $this->{groups}[$_]->get_noutputs() }
				@$igs;
		print "AVIO: ",(join ' ',@avio)," AVINO: ",
			(join ' ',@avino),"\n";
		my ($ravino,$ravio) = (\@avino,\@avio);
		print "TYP: ",ref($ravino),", ",ref($ravio),"\n";
		$pars{N_InputGroups} = $#avio+1;
		$pars{N_InputGNeurons} = $ravino;
		$pars{InputGOutStarts} = $ravio;
	}

	print "Neural::${type}Group->New(".'$this->{wstart},$this->{ostart},%pars)';
	$grp = eval "Neural::${type}Group->New(".'$this->{wstart},$this->{ostart},%pars)';

	push @{$this->{groups}},$grp;
	$this->{outstart} = $grp->get_ostart;
	$this->{noutputs} = $grp->get_noutputs;
	print "AFTER: Nwei:",$this->nweights()," os:",$this->{outstart},
		" nout:",$this->{noutputs},"\n";
	return $#{$this->{groups}};
}

sub inputsize { my ($this)=@_; return $this->{ninputs}; }
sub nunits { my ($this)=@_; return $this->{ostart}; }
sub nweights { my ($this)=@_; return $this->{wstart}; }
sub ngroups { my ($this)=@_; return $#{$this->{groups}}+1; }
sub outputsize { my ($this)=@_; return $this->{noutputs}; }

sub activate {
	my ($this,$input,$unitinputs,$unitoutputs,$output,$weights) =
		@_;
	$unitoutputs->zero();
	$unitinputs->zero();
	$unitoutputs->set_range(0,$this->{ninputs},
		$input,0);
	for (@{$this->{groups}}[1..($#{$this->{groups}})]) {
		$_->activate($unitinputs,$unitoutputs,$weights);
	}
	$output->set_range(0,$this->{noutputs},$unitoutputs,
		$this->{outstart});
}

sub backactivate {
	my ($this,$input,$unitinputs,$unitoutputs,$dunitoutputs,
		$output,$weights,$dweights,$target)=@_;
	$dunitoutputs->zero();
	my $targ = 
	  $this->set_target($this->{outstart},
		$this->{noutputs},$dunitoutputs,$output,$target);
	for(@{$this->{groups}}[reverse (1..$this->ngroups()-1)]) {
		$_->backactivate($unitinputs,
			$unitoutputs,$dunitoutputs,$weights,$dweights);
	}
	return $targ;
}

sub backgradient {
	my ($this,$input,$unitinputs,$unitoutputs,$dunitoutputs,
		$output,$weights,$dweights,$nth)=@_;
	$this->set_gradienttarget($dunitoutputs,$output,$nth);
	for(@{$this->{groups}}[reverse (1..$this->ngroups()-1)]) {
		$_->backactivate($unitinputs,
			$unitoutputs,$dunitoutputs,$weights,$dweights);
	}
}

sub backprop {
	my ($this,$input,$unitinputs,$unitoutputs,$dunitoutputs,
		$output,$weights,$dweights,$target)=@_;
	$this->activate($input,$unitinputs,$unitoutputs,$output,$weights);
	$this->backactivate($input,$unitinputs,
		$unitoutputs,$dunitoutputs,$output,$weights,$dweights,$target);
}

sub dobackprop {
	my ($this,$pars,$in,$targ,$out) = @_;
	return $this->backprop($in,$pars->{UIn},
		$pars->{UOut},$pars->{DUOut},
		$out,$pars->{Wei},$pars->{DWei},
		$targ);
}

sub donthgradient {
	my ($this,$pars,$in,$out,$nth) = @_;
	return $this->backgradient($in,$pars->{UIn},
		$pars->{UOut},$pars->{DUOut},
		$out,$pars->{Wei},$pars->{DWei},
		$nth);
}

sub activate_p {
	my ($this,$in,$out,$pars) = @_;
	$this->activate($in,$pars->{UIn},$pars->{UOut},$out,
		$pars->{Wei});
}

sub build_file {
	my ($this,$fn) = @_;
	open F,$fn 
		or confess("Invalid filename $fn given");
	my $inp = join "\n",<F>;
	close F;
	$this->build($inp);
}

###########
package Neural::InputGroup;

sub new {
	my ($type,$n)=@_;
	bless {
		nin=>$n
	};
}

sub get_ostart { my ($this)=@_; return 0; }
sub get_noutputs { my ($this)=@_; return $this->{nin}; }

##########################################################################
package Neural::Examples;


=head2 Neural::Examples

Neural::Examples stores a set of example patterns and can be used to
evaluate the error on a network based on them.

Methods:

=over 8

=item new(inputsize, outputsize)

Returns a new example set.

=item addexample(in,out)

Adds a new example. The parameters are references to arrays.

=item nexamples()

Returns the number of examples in the net.

=item get_example(n)

Returns a list of three Math::DVector objects that give the input,
target and last output of the example, respectively. Both of these are
modifiable!!

=item evalfun(pars)

Evaluate the network with the parameters I<pars>, looping
through the examples. Adds to the element 'DWei' of I<pars>.

=cut

sub new($$) {
	my $type = shift;
	my $insize = shift;
	my $outsize = shift;
	my $this = {
		NBatch => 0,
		Examples => [],
		ExInd => 0 ,
		InSize => $insize,
		OutSize => $outsize,
	};
	bless $this,$type;
}

sub addexample($\@\@) {
	my $this = shift;
	my $net = $this->{Net};
	my $in = new Math::DVector($this->{InSize});
	my $out = new Math::DVector($this->{OutSize});
	my $target = new Math::DVector($this->{OutSize});
	$in->setlist(@{$_[0]});
	$out->zero;
	$target->setlist(@{$_[1]});
	push @{$this->{Examples}},[$in,$target,$out];
	return $#{$this->{Examples}};
}

sub nexamples($) {
	my $this = shift;
	return $#{$this->{Examples}}+1;
}

sub get_example($$) {
	my ($this,$i) = @_;
	return $this->{Examples}[$i];
}


sub evalnext ($$$) {
	my $this = shift;
	my $fref = shift;
	my $pvec = shift;
	my $ind = $this->{ExInd};
	my $net = $pvec->{Net};
				#	print "Dobackprop $ind ";
	$$fref += $net->dobackprop($pvec,$this->{Examples}[$ind][0],
		$this->{Examples}[$ind][1],$this->{Examples}[$ind][2]);
				#	print $this->{Examples}[$ind][0]->asstr," -> ",
				#	      $this->{Out}->asstr,
				#	      " ( ",$this->{Examples}[$ind][1]->asstr," )\n";
	$ind ++; if($ind > $#{$this->{Examples}}) {$ind = 0};
	$this->{ExInd} = $ind;
}

sub evalfun ($$) {
	my $this = shift;
	my $pars = shift;
	my $bat = $this->{NBatch};
	if (!$bat) {
		$bat = $#{$this->{Examples}} + 1;
	}
	my $fun=0;
	my $i;
	for ($i=0; $i<$bat; $i++) {
		$this->evalnext(\$fun,$pars);
	}
	return $fun;
}


##########################################################################
package Neural::Minimizer;

=head2 Neural::Minimizer

Neural::Minimizer completes the list of components for a simple
backpropagation neural net simulation. The minimizer is completely
generic, being given as argument only the current parameters (weights),
value of the function to be minimized and the gradient.
It then outputs the new parameters to be tried. The minimizer
consists of two objects, one that handles the connection to the
neural network and one that minimizes an arbitrary vector.

The interface to the Neural::Min_* classes is simple: 
the following functions must be defined

=over 8

=item set_net(net)

Set the network whose error is to be minimized to I<net>.

=item go

Start the minimization. 

=item set_direction(obj)

Set the direction method to I<obj>. 
The object must define the method
C<get_dir>(I<w,f,dw,pdir>) where I<w> are the current weights,
I<f> is the function value, I<dw> is the gradient vector and
I<pdir> is the previous search direction. The method should
return the direction by modifying the vector I<pdir>.

=item set_initstep(obj)

Set the initial step method to I<obj>. The object must
have a method C<get_istep>(I<w,f,dw,dir,pstep>).
The method should return a value indicating success or failure.
I<pstep> is the previous step value, return should modify this.

=item set_step(obj)

Set the step method to I<obj>. The method is 
C<get_step>(I<w,f,dw,dir,istep,step>). 
The step should be returned in I<step>.
For line search methods, the interface should
be expanded a little to allow evaluation of some points on the line.

=item set_conv(obj)

Set the convergence test method to I<obj>. The method is
C<get_conv>(I<w,f,dw,pf>) where I<pf> is the previous function value.

=item set_change_fn(obj,n)

Every I<n> rounds call C<obj-\>change_ex(pars)>. 
This function may alter something in the example set, for example
in order to do temporal difference learning.

=item reset

Reset the minimizer.

=back

The direction, initstep and step objects must also have the following
methods:

=over 8

=item alloc(I<state>,I<n>)

Allocate the internal state vectors to contain room for I<n> parameters.

=item reset(I<state>,minimizer)

Reset the internal state held by the minimizer.
The Minimizer argument is given so that the Min can query it for
number of parameters etc.

=item get_paramlist

Return the hash table Parameter -> [value,help]

=item set_param(param,val)

=back

=cut

package Neural::Minimizer;

sub new($) {
	my $type = shift;
	my $this = {
		'Min' => (),
		'Pars' => {
			'Tolerance' => 1.0E-5
			},
		'NPars' => (),
		NetPars => (),
		'Dir' => (),
		'Eval' => (),   # Object for evaluation
		'Direction' => (), # Object for search direction
		'IStep' => (), # Object for Initial step
		'Step' => (), # Object for line search
		'logsub' => (sub {print @_}),
		'atsteps' => -1,
	};
	bless $this,$type;
	$this->reset;
	return $this;
}

sub set_net($$) {
	my $this = shift;
	my $net = shift;
	$this->{NetPars} = new Neural::Pars($net);
	$this->{NPars} = $net->nweights;
	$this->{Dir} = new Math::DVector($net->nweights);
	$this->{Dir}->zero;
	for ("Direction","IStep","Step","Conv") {
		if($this->{$_}) {$this->{$_}->alloc($this->{NPars})};
	}
}

sub randw($;$$) {
	my $this = shift;
	$this->{NetPars}->rand_weights(@_);
}

sub setw {
	my $this = shift;
	$this->{NetPars}{Wei} = $_[0];
}

sub set_eval($$) {
	my $this = shift; $this->{Eval} = shift;
}

sub set_direction($$) {
	my $this = shift; $this->{Direction} = shift;
	$this->{Direction}->alloc($this->{NPars});
}

sub set_initstep($$) {
	my $this = shift; $this->{IStep} = shift;
	$this->{IStep}->alloc($this->{NPars});
}

sub set_step($$) {
	my $this = shift; $this->{Step} = shift;
	$this->{Step}->alloc($this->{NPars});
}

sub set_conv($$) {
	my $this = shift; $this->{Conv} = shift;
	$this->{Conv}->alloc($this->{NPars});
}

sub set_logsub($$) {
	my $this = shift;
	$this->{logsub} = shift;
}

sub set_change_fn($$$) {
	my ($this,$obj,$n) = @_;
	$this->{atsteps} = $n;
	$this->{objatsteps} = $obj;
}

sub reset {
	my $this = shift;
	$this->{f} = ();
	$this->{rou} = ();
	$this->{istep} = 0;
	$this->{step} = 0;
}

sub go {
	my $this = shift;
	my $conv=0;
	my $i;
	my $ret = 0;
	for($i=0; $i<10; $i++) {
		if(defined($this->{objatsteps}) && !($this->{rou}%$this->{atsteps})) {
			$this->{objatsteps}->change_ex( $this->{NetPars} );
		}
		$this->{rou}++;
		$this->{NetPars}{DWei}->zero;
		my $pf = $this->{f};
		$this->{f} = $this->{Eval}->evalfun( $this->{NetPars} );
		if($this->{rou}>1 && $this->{Conv}->get_conv(
			$this->{NetPars}{Wei},
			$this->{f},
			$this->{NetPars}{DWei},
			$pf)) {
			print "CONVERGED!\n";
			$ret=1;
			last;
		}
		$this->{Direction}->get_dir($this->{NetPars}->{Wei},$this->{f},
			$this->{NetPars}{DWei},$this->{Dir});
		$this->{IStep}->get_istep($this->{NetPars}->{Wei},$this->{f},
			$this->{NetPars}{DWei},$this->{Dir},$this->{istep});
		$this->{Step}->get_step($this->{NetPars}->{Wei},$this->{f},
			$this->{NetPars}{DWei},$this->{Dir},$this->{istep},
				$this->{step});
		$this->{NetPars}{Wei}->add_step($this->{Dir},$this->{step});
	};
	&{$this->{logsub}}("R: $this->{rou}, f: $this->{f}\n");
	return $ret;
}

# Test if the gradient we receive is in order.
sub test_grad {
	my $this = shift;
	$this->{NetPars}{DWei}->zero;
	my $f = $this->{Eval}->evalfun( $this->{NetPars} );
	print "Center: f = $f, pars = ",$this->{NetPars}{Wei}->asstr,
		", dwei = ",$this->{NetPars}{DWei}->asstr,"\n";
	my $dw = $this->{NetPars}{DWei}->copy;
	my $i;
	for ( $i=0; $i<$this->{NPars}; $i++) {
		my $sav;
		$sav = $this->{NetPars}{Wei}->getelem($i);
		$this->{NetPars}{Wei}->putelem($i,$sav+0.01);
		my $fnew = $this->{Eval}->evalfun( $this->{NetPars} );
		my $diff = $fnew-$f;
		my $gd = 0.01 * $dw->getelem($i);
		print "PAR $i: $f -> $fnew, $diff, $gd\n";
		print "UOUT: ",$this->{NetPars}{UOut}->asstr,"\n";
		$this->{NetPars}{Wei}->putelem($i,$sav);
	}
	print "pars = ",$this->{NetPars}{Wei}->asstr,"\n";
}
########################################################

=head1 Direction methods.


=head2 Neural::Dir_Steepest

Steepest descent. No parameters.

=cut

package Neural::Dir_Steepest;

@Neural::Dir_Steepest::ISA = ("Parametrized");

sub new($)  {
	my $type = shift;
	my $this = Parametrized->new;
	$this->{'Params'} = {
	};
	bless $this,$type;
}

sub get_dir($\$$\$\$) {
	my $this = shift;
#	print "To add_vec ",$_[0]->asstr," plus ",$_[2]->asstr, " Times ",
#		$this->{'Params'}{'Rate'}[0],"\n";
	$_[3]->set_vec($_[2],-1.0);
}

sub alloc{}

########################################################

=head2 Neural::Dir_Momentum

Momentum descent. One parameter, C<alpha>, which designates
the attenuation of the momentum.

=cut

package Neural::Dir_Momentum;

@Neural::Dir_Momentum::ISA = ("Parametrized");

sub new ($) {
	my $type = shift;
	my $this = Parametrized->new;
	$this->{'Params'} = {
		'alpha' => [0.9,"Attenuation of momentum"],
	};
	bless $this,$type;
}

sub alloc ($$) {
	my $this = shift;
#	$this->{'Curdir'} = new Math::DVector($_[0]);
#	$this->{'Curdir'} -> zero;
}

sub get_dir ($\$$\$\$) {
	my $this = shift;
# Multiply current direction by constant
	$_[3]->set_vec($_[3],$this->{Params}{alpha}[0]);
# and add the opposite of the gradient.
	$_[3]->add_vec($_[2],-1.0);
}

#######################################################

=head1 Initial step methods.


=head2 Neural::IStep_Fixed

Fixed step of length I<epsilon>.

=cut

package Neural::IStep_Fixed;

@Neural::IStep_Fixed::ISA = ("Parametrized");

sub new ($) {
	my $type = shift;
	my $this = Parametrized->new;
	$this->{'Params'} = {
		'epsilon' => [0.02,"The step euclidean length"],
	};
	bless $this,$type;
}

sub alloc ($$) { }

sub get_istep ($\$$\$\$$) {
	my $this = $_[0];
	$_[5] = $this->{Params}{epsilon}[0];
}

#######################################################

=head1 Step size methods.

=head2 Neural::Step_None

Do nothing (just take a step of the size given by the initial step).

=cut

package Neural::Step_None;

@Neural::Step_None::ISA = ("Parametrized");

sub new ($) {
	my $type = shift;
	my $this = Parametrized->new;
	$this->{'Params'} = { };
	bless $this,$type;
}

sub get_step ($\$$\$\$$$) {
	$_[6] = $_[5];
}

sub alloc {}

#######################################################

=head1 Convergence methods.

=head2 Neural::Conv_Accept

Converge when function low enough (if you know that you can fit
the data, use this)

=cut

package Neural::Conv_Accept;

@Neural::Conv_Accept::ISA = ("Parametrized");

sub new ($) {
	my $type = shift;
	my $this = Parametrized->new;
	$this->{'Params'} = { 
		'F' => ['0.01',"The lowest acceptable function minimum"]
	};
	bless $this,$type;
}

sub get_conv ($\$$\$$) {
	my $this = shift;
	if($_[1] <= $this->{Params}{F}[0]) {
		return 1;
	} else {
		return 0;
	}
}

sub alloc {}


#########################################################

package Neural::Basic;
bootstrap Neural::Basic;



##########################################################

=head1 BUGS

Lots of them.

=head1 AUTHOR

Tuomas J. Lukka (Tuomas.Lukka@Helsinki.FI)

=cut

1;
