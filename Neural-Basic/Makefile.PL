# 
# I know that it isn't really correct to include 
# -L/usr/lib/gcc-lib/i486-debian-linux...
#

use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME => "Neural::Basic",
#	      VERSION_FROM => "Neural.pm",
	      VERSION => "0.01",
	      LIBS => ["-L/usr/lib/gcc-lib/i486-debian-linux/2.6.3/ -lgcc -lm"],
	      INC => "-I/usr/local/include -I../Math-DVector",
	      DEFINE => "-g",
	      OBJECT => "BasicGroups.o xs_BasicGroups.o gann_gen.o ",
	      depend => {"BasicGroups.c.PL" => "grouptypes",
			"xs_BasicGroups.xs" => "BasicGroups.c",
			"xs_BasicGroups.o" => "xs_BasicGroups.xs"
			},
	      clean => {FILES => "BasicGroups.*"},
	      XS => {"xs_BasicGroups.xs" => "xs_BasicGroups.c",
	      	     "gann_glue.xs"	 => "gann_glue.c"},
	      XSOPT => "-C++ -prototypes",
#	      PM => ["Basic.pm","BasicGroups.pm"],
	      NORECURS => 0,
	      TYPEMAPS => [qw/typemap BasicGroups.typ/],
	      NEEDS_LINKING => 1,
	      'dist' => { CI => "ci -l", COMPRESS=>"gzip -9", SUFFIX=>"gz" },
	      CC => "g++");
