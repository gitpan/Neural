# 
# Edit the LIBS line below to contain the location of your libgcc
#

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "Math::DVector",
	VERSION => "0.02",
	LIBS => ["-lm -L/usr/lib/gcc-lib/i486-debian-linux/2.6.3/ -lgcc"],
	INC => "-I/usr/local/include",
	DEFINE => "-g",
	OBJECT => "DVector.o DVector_glue.o",
	XSOPT => "-C++ -prototypes",
	NORECURS => 0,
	NEEDS_LINKING => 1,
	'dist' => { CI => "ci -l", COMPRESS=>"gzip -9", SUFFIX=>"gz" },
	CC => "g++",
);
