// DVector.c
// Implementation of fast vectors of double 
// Copyright (C) 1996 Tuomas J. Lukka
//
// This software may be redistributed under the same conditions as
// perl itself.
//

#pragma implementation

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "DVector.h"


DVector_Real &DVector::elem(int i) 
{
	static DVector_Real foo=0;
	if(i<0 || i>=m_nelems) {
		croak("DVector index error: %d (%d elems).",m_nelems,m_elems,i);
		assert(0);
	}
	return m_elems[i];
}

void DVector::ensure_size(int s)
{
	int i;
	if( s<= m_nelems ) return;
	DVector_Real *news = new DVector_Real [s];
	for(i=0; i<m_nelems; i++) 
		news[i] = m_elems[i];
	m_nelems = s;
	if(m_elems) delete[] m_elems;
	m_elems = news;
}

// Shrink (but don't realloc just yet)
// XXX Should store max size alloced
void DVector::resize(int s)
{
	ensure_size(s);
	m_nelems = s;
}

void DVector::chk_elems(int a,int b)
{
	if (a>=0 &&b<m_nelems && a <= b) return;
	croak("INVALID VECTOR ELEMS %d,%d (%d,%d)!\n",a,b,m_nelems,m_elems);
}

void DVector::add_vec(DVector *p,double s)
{
	int i;
	for(i=0; i< (m_nelems <? p->m_nelems); i++) {
		m_elems[i] += s * p->m_elems[i];
	}
}

void DVector::add_step(DVector *p,double s)
{
	int i;
	DVector_Real norm=0;
	for(i=0; i< (m_nelems <? p->m_nelems); i++) {
		norm += square(p->m_elems[i]);
	}
	norm = sqrt(norm);
	s /= norm;
	for(i=0; i< (m_nelems <? p->m_nelems); i++) {
		m_elems[i] += s * p->m_elems[i];
	}
}

void DVector::set_length(double l)
{
	int i;
	DVector_Real norm=0;
	for(i=0; i< m_nelems; i++) {
		norm += square(m_elems[i]);
	}
	norm = sqrt(norm);
	l /= norm;
	for(i=0; i< m_nelems; i++) {
		m_elems[i] *= l;
	}
}

void DVector::set_vec(DVector *p,double s)
{
	int i;
	for(i=0; i< (m_nelems <? p->m_nelems); i++) {
		m_elems[i] = s * p->m_elems[i];
	}
}

void DVector::mul_dbl(double scale)
{
	int i;
	for(i=0; i<m_nelems; i++) {
		m_elems[i] *= scale;
	}
}

void DVector::set_intvec(char *c,int n)
{
	int i;
	unsigned long *foo = (unsigned long *)c;
	resize(n);
	for(i=0; i<n; i++) {
		m_elems[i] = foo[i];
	}
}

void DVector::set_range(int s,int n,
	DVector *v,int vs)
{
	int i;
	assert(s>=0); assert(s+n<=m_nelems);
	assert(vs>=0); assert(vs+n<=v->m_nelems);
	for(i=0; i<n; i++) {
		m_elems[i+s] = v->m_elems[i+vs];
	}
}

