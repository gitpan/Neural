extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}
#include "DVector.h"


MODULE=Math::DVector	PACKAGE=Math::DVector

DVector *
DVector::new(siz)
	int siz;

void
DVector::DESTROY()

double
DVector::getelem(i)
	int i;

void
DVector::putelem(i,e)
	int i;
	double e;

void
DVector::ensure_size(s)
	int s;

void
DVector::resize(s)
	int s;

int
DVector::getsize()

void 
DVector::zero()

void
DVector::add_vec(v,s)
	DVector *v;
	double s;

void
DVector::add_step(v,s)
	DVector *v;
	double s;

void
DVector::set_vec(v,s)
	DVector *v;
	double s;

void
DVector::mul_dbl(s)
	double s;

void 
DVector::set_intvec(s,n)
	char *s;
	int n;

void
DVector::set_range(s,n,v,vs)
	int s
	int n
	DVector *v
	int vs

void 
DVector::set_length(l)
	double l;
