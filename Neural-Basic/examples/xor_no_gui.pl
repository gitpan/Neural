#!/usr/local/bin/perl -w
#
# This script demonstrates the use of Gann without the GUI.
# 
# With the current defaults, it takes about 800 rounds
# to converge if the initial random values for the weights 
# are not really horrible. It may stay very close to
# 0.5 and 0.25 for a long time if you're unlucky (over 20000 iterations).
# If you're lucky, you can get away with 300 or less iterations.
#

#use lib ('blib');
#use lib ('blib/lib');
#use lib ('blib/arch');
#use lib ('.');

# This requires Nick Ing-Simmons' blib module (in Tk-b11.01)
use blib;

use Neural::Basic;

srand;

$xor = new Neural::Net(2);
 $bias=$xor->add_group("Bias");
$hidden=$xor->add_group("Basic",
	Input_Groups => [0,$bias],
	Activation => 2,
	N_Neurons => 2);
$out=$xor->add_group("Basic",
	Input_Groups => [$hidden,$bias],
	Activation => 3,
	N_Neurons => 1);

if(0) {
$xor = new Neural::Net(2);
# $bias=$xor->add_group("Bias");
$hidden=$xor->add_group("Basic",
#	Input_Groups => [0,$bias],
	Input_Groups => [0],
	Activation => 3,
	N_Neurons => 1);
$out=$xor->add_group("Basic",
#	Input_Groups => [$hidden,$bias],
	Input_Groups => [$hidden],
	Activation => 3,
	N_Neurons => 1);
}

# The idea is that the last group is the output group always.

# Just fool around

$nin = $xor->inputsize;
$nout = $xor->outputsize;
$nun = $xor->nunits;
$nwei = $xor->nweights;
$ngr = $xor->ngroups;

print "Xor: nin=$nin, nout=$nout, nun=$nun, nwei=$nwei, ngr=$ngr\n";

# print $xor->print_perl;

# Create the examples

$ex = new Neural::Examples (2,1);

# and add the example data.

$ex->addexample([0,0],[0]);
$ex->addexample([0,1],[1]);
$ex->addexample([1,0],[1]);
$ex->addexample([1,1],[0]);

$min = new Neural::Minimizer();

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

