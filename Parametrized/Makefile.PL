#
# Parametrized class Makefile.PL
#
# Copyright (C) 1996 Tuomas J. Lukka
#

use ExtUtils::MakeMaker;
use Config;

&WriteMakefile(
	NAME => 'Parametrized',
	NEEDS_LINKING => 0,
	VERSION => "0.02",
	dist => {SUFFIX => 'gz', COMPRESS => 'gzip -9', CI => 'ci -l'},
);
