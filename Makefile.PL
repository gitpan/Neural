use ExtUtils::MakeMaker;

WriteMakefile(
	VERSION_FROM => "VERSION_INFO",
	NAME => "Neural",
	'dist' => { CI => "ci -l", COMPRESS=>"gzip -9", SUFFIX=>"gz" },
	DIR => ["Math-DVector","Neural-Basic","Parametrized"],
	NEEDS_LINKING => 1,
);
