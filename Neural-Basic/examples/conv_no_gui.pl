#!/usr/local/bin/perl -w
#
# This script demonstrates the use of Gann convolution
# group type

#use lib ('blib');
#use lib ('blib/lib');
#use lib ('blib/arch');
#use lib ('.');

# This requires Nick Ing-Simmons' blib module (in Tk-b11.01)
use blib;

use Neural::Basic;

srand;

# Basic convolution test.
# 3x3 matrix input, 2x2 output, no offset, no outside.
# Need to learn a simple function
# The input lattice has two layers: bias and 

$xor = new Neural::Net(9);

$bias=$xor->add_group("Bias");

$lat = new Neural::Lattice(3,3,1,[0],[1],[3]);

$ov = new Math::DVector(1);

$out=$xor->add_group("XYConvolution1",
	Input_Groups => [$bias],
	InputLattice => $lat,
	Activation => 3,
	N_Neurons => 1,
	Kernel_X => 2,
	Kernel_Y => 2,
	Offset_X => 0,
	Offset_Y => 0,
	Output_x => 2,
	Output_y => 2,
	Output_z => 1,
	Conv_Extension => $ov);


# The idea is that the last group is the output group always.

# Just fool around

$nin = $xor->inputsize;
$nout = $xor->outputsize;
$nun = $xor->nunits;
$nwei = $xor->nweights;
$ngr = $xor->ngroups;

print "Net: nin=$nin, nout=$nout, nun=$nun, nwei=$nwei, ngr=$ngr\n";

# print $xor->print_perl;

# Create the examples

$ex = new Neural::Examples (9,4);

# and add the example data.

# Convolution: 
#
#  a  b  =>  a+2b+0.5c
#  x  c

$ex->addexample([0,0,0, 0,0,1, 0,1,0],[0,0.5, 0.5, 2]);
$ex->addexample([1,1,0, 0,0,0, 1,1,1],[3,1,   0.5, 0.5]);

# Create the minimizer

$min = new Neural::Minimizer ();

# Set the methods: fixed steps in the direction of the steepest
# descent.

$min->set_direction(new Neural::Dir_Steepest);
$min->set_initstep(new Neural::IStep_Fixed);
$min->set_step(new Neural::Step_None);
$min->set_conv(new Neural::Conv_Accept);

$min->set_net($xor);
$min->set_eval($ex);

# Randomize the network 

$min->randw(-1.0,1.0);

# See if bit rot has bitten into gann_gen.c or somewhere else:
# do we still get a proper gradient

$min->test_grad;

# And GO!
# This return value of 1 means convergence.

while(! $min->go) {};

