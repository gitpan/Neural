// gann_gen.h
// GANN - Artificial neural network library
// Copyright (C) 1996 Tuomas J. Lukka
//

#pragma interface

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


// Gann - perl interfaced ANN simulator optimized for vectorization,
//  avoiding "class Unit, class Link"
// 
// Basic classes: Net, Group, Activation, Vector
//
// No classes for: Unit, Link
//
// Idea: Net is a machine that is given several vectors to operate
// on. Vectors: Input, Output, Unitoutputs, Target, Weights, Wderivs.
// No building of permanent data structs in memory or problems
// resulting from that. Same structure can be used with several 
// sets of weights at the same time. Performance is pretty good.

// Only the structure is stored in memory, not any of the current 
// Values. Therefore, no complicated setting / bugs.

#define PPRINT(f,args...) {sprintf(buffer,f,##args); sv_catpv(s,buffer);}

#define GANN_ABORT(a) {fprintf(stderr,"GANN ABORT:" a); abort();}
#define GANN_LOG(form,args...) {fprintf(stderr,"GANN:" form "\n", ##args);}

#define GANN_Vector DVector

// For use with perl:
//
struct sv; typedef struct sv SV;

typedef double GANN_Real;

// This structure is here to make xsub compilation easier.
// Now we can pass variable-sized arrays of integers to subroutines in these
// structs
struct GANN_iarr {
	int n;
	int *i;
};

enum GANN_Activation {
	ACT_NULL=0,
	ACT_TANH,
	ACT_LOGISTIC,
	ACT_LINEAR
	
};

extern struct GANN_ActivationStruct {
	double (*act)(GANN_Real);
	double (*dact)(GANN_Real);
} GANN_Activations[];


// Group gives no info about method of storing weights.
// BasicGroup = one group. TranslatedGroup = Convolution over some input
// All arguments given to groups as pointers are owned by the groups
// for storage
class GANN_Group {
	GANN_Group *next,*prev;
protected:
friend class GANN_Net;
friend class GANN_CompositeGroup;
	int m_wstart;
	int m_nweights;
	int m_noutputs;
	int m_ostart;

public:
	GANN_Group(int wstart,int ostart) {m_wstart = wstart; m_ostart = ostart;
		next=NULL; prev=NULL;}
	virtual ~GANN_Group() {};
	virtual int activate(GANN_Vector *UnitInputs,
		GANN_Vector *UnitOutputs,
		GANN_Vector *Weights) = 0;
	virtual int backactivate(GANN_Vector *UnitInputs,
		GANN_Vector *UnitOutputs,
		GANN_Vector *DUnitOutputs,
		GANN_Vector *Weights,
		GANN_Vector *DWeights) = 0;
//	virtual void print(FILE *f) {fprintf(f,"GANN_Group(%d,%d)\n",
//					m_ostart,m_wstart);};
	int get_noutputs() {return m_noutputs;};
	int get_ostart() {return m_ostart;}
//	virtual void which_weights(int gfrom,int *start,int *end)
//		{*start=0; *end=0;};
//	virtual void perl_pweights(SV *s) {return;};
//	virtual int get_nneurons();
};



// Current implementation is unoptimized. 
// Later on, include generation of code for several special cases.
// A 3D lattice which can have layers from different groups.
// This is for the convolution groups.
// Currently, the implementation is such that you specify the xyz sizes
// and for each layer the input offset and x increment and y increment.
//
// This class is simply a description of the lattice properties.
class GANN_Lattice {
	int m_xsize,m_ysize,m_zsize,
		*m_lstarts,*m_lxincr,*m_lyincr;
public:
	GANN_Lattice(int x,int y,int z,
		int *lstarts,int *lxincr,int *lyincr) {
	  m_xsize=x; m_ysize=y; m_zsize=z; m_lstarts=lstarts; m_lxincr=lxincr;
	  m_lyincr=lyincr;};
	GANN_Lattice(int x,int y,int z,int ostart);
	~GANN_Lattice() {delete[] m_lstarts; delete[]m_lxincr; delete[]m_lyincr;};
	int operator()(int x,int y,int z) {
		if (x>=0 && y>=0 && z>=0 && x<m_xsize && y<m_ysize && z<m_zsize);
		  return m_lstarts[z] + x * m_lxincr[z] + y * m_lyincr[z];
		return -1;
	}
	int x() {return m_xsize;}
	int y() {return m_ysize;}
	int z() {return m_zsize;}
	int inside(int x,int y,int z) {return (*this)(x,y,z)!=-1;}
};
