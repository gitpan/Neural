// gann_gen.c
// GANN - Artificial neural network library
// Copyright (C) 1996 Tuomas J. Lukka
//

#pragma implementation

/*

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "DVector.h"
#include "gann_gen.h"


// Activation functions
//  Should use tables and linear interpolation for speed, but
//  That's version 2.

GANN_Real GANN_Null(GANN_Real x) {return 0;}
GANN_Real GANN_DNull(GANN_Real x) {return 0;}

GANN_Real GANN_Tanh(GANN_Real x) {return tanh(x);}
GANN_Real GANN_DTanh(GANN_Real x) {if(x>30 || x<-30) return 0.0;
	else return 1.0/square(cosh(x));}

GANN_Real GANN_Logistic(GANN_Real x) {
	if(x>35) return 1; if(x<-35) return 0;
	return 1.0/(1.0+exp(-x));}
GANN_Real GANN_DLogistic(GANN_Real x) {
	GANN_Real y = GANN_Logistic(x);
	return y*(1.0-y);}

GANN_Real GANN_Linear(GANN_Real x) {return x;}
GANN_Real GANN_DLinear(GANN_Real x) {return 1;}

// This must match with gann_gen.h
struct GANN_ActivationStruct 
 GANN_Activations[] = 
{ 
 {GANN_Null,GANN_DNull},
 {GANN_Tanh,GANN_DTanh},
 {GANN_Logistic,GANN_DLogistic},
 {GANN_Linear,GANN_DLinear},
}
;


// GANN_Lattice

GANN_Lattice::GANN_Lattice(int x,int y,int z,int ostart)
{
	int i;
	m_xsize = x; m_ysize = y; m_zsize = z;
	m_lstarts = new int[z];
	m_lxincr = new int[z];
	m_lyincr = new int[z];
	for(i=0; i<z; i++) {
		m_lstarts[i] = ostart + i*x*y;
		m_lxincr[i] = 1;
		m_lyincr[i] = x;
	}
}

