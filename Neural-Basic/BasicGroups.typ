TYPEMAP
GANN_BiasGroup *		O_GANN_BiasGroup 
GANN_BasicGroup *		O_GANN_BasicGroup 
GANN_XYConvolution1Group *		O_GANN_XYConvolution1Group 


OUTPUT
O_GANN_BiasGroup
	sv_setref_pv( $arg, "Neural::BiasGroup", (void*)$var );
O_GANN_BasicGroup
	sv_setref_pv( $arg, "Neural::BasicGroup", (void*)$var );
O_GANN_XYConvolution1Group
	sv_setref_pv( $arg, "Neural::XYConvolution1Group", (void*)$var );


INPUT
O_GANN_BiasGroup
	if( sv_isobject($arg) && (SvTYPE(SvRV($arg)) == SVt_PVMG) )
	$var = ($type)SvIV((SV*)SvRV( $arg ));
	else{
	warn( \"${Package}::$func_name() -- $var is not a blessed SV reference\" );
	XSRETURN_UNDEF;
	}
O_GANN_BasicGroup
	if( sv_isobject($arg) && (SvTYPE(SvRV($arg)) == SVt_PVMG) )
	$var = ($type)SvIV((SV*)SvRV( $arg ));
	else{
	warn( \"${Package}::$func_name() -- $var is not a blessed SV reference\" );
	XSRETURN_UNDEF;
	}
O_GANN_XYConvolution1Group
	if( sv_isobject($arg) && (SvTYPE(SvRV($arg)) == SVt_PVMG) )
	$var = ($type)SvIV((SV*)SvRV( $arg ));
	else{
	warn( \"${Package}::$func_name() -- $var is not a blessed SV reference\" );
	XSRETURN_UNDEF;
	}

