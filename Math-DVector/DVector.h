// DVector.h
// Implementation of fast vectors of double 
// Copyright (C) 1996 Tuomas J. Lukka
//
// This software may be redistributed under the same conditions as
// perl itself.

typedef double DVector_Real;

inline double square(double x) {return x*x;}

// Vector.
//  TODO: add vector addition, multiplication etc.
//  NOTE: no assignment operator currently defined.
class DVector {
	int m_nelems;
	DVector_Real *m_elems;
	DVector(DVector&);
	DVector &operator=(DVector &);
public:
	DVector(int size) {m_nelems = 0; m_elems = NULL; ensure_size(size);
		zero();};
	~DVector() {if(m_elems) delete[] m_elems;};
	DVector_Real &elem(int i) ;
	int exists(int i) {return i>=0 && i<m_nelems;}
	double getelem(int i) {return m_elems[i];};
	void putelem(int i,double e) {m_elems[i] = e;};
	int getsize() {return m_nelems;}
	void ensure_size(int s); // Just grow
	void resize(int s);
	void chk_elems(int a,int b); // if a..b exists, return 1; else abort.
	void zero() {int i; for(i=0; i<m_nelems; i++) m_elems[i]=0.0;}
	void add_vec(DVector *p,double s);
	void add_step(DVector *p,double s);
	void set_vec(DVector *p,double s);
	void mul_dbl(double s);
	void set_intvec(char *s,int n);
	void set_range(int s,int n,DVector *p,int vs);
	void set_length(double l);
};
