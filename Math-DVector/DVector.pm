
package Math::DVector;
require DynaLoader;

@ISA="DynaLoader";

use strict;

sub aslist {
	my $this = shift;
	return map { $this->getelem($_) } 0..($this->getsize-1);
}

sub asstr {
	my $this = shift;
	return "[" . (join " ",(map {sprintf "%3f",$_;} $this->aslist)) . "]";
}

sub setlist {
	my $this = shift;
	for (0..($this->getsize-1) )
	 {$this->putelem($_,$_[$_]);}
}

sub copy {
	my $this = shift;
	my $ret = new Math::DVector($this->getsize);
	for (0..($this->getsize-1)) { $ret->putelem($_,$this->getelem($_)); }
	return $ret;
}

sub randomize {
	my $this = shift;
	my $min = shift; 
	my $max = shift;
	$this-> setlist( map {$min + rand($max-$min)} (0..$this->getsize-1) );
}

=head1 NAME

Math::DVector -- Fast, compact vectors using arrays of double.

=head1 DESCRIPTION

B<Math::DVector> implements a very simple class of vectors 
(arrays of double). 
Indexing starts from zero. 

The interface is somewhat arbitrary, I hope to remove some of
the redundant functions later and have a better interface
to this class.

Methods:

=over 8

=item new(I<size>)

Creates a new vector with initial size I<size>

=item aslist 

Returns a list with the elements of the vector.

=item setlist(I<list>)

Sets the vector values to list. If list is different size
than the vector, the surplus elements are ignored.

=item asstr

Returns a string with the elements of the vector separated by spaces,
the whole string surrounded by brackets.
(useful in print commands)

=item copy

Returns a new vector that is a copy of this vector

=item getelem(I<i>)

Returns the I<i>th element of the vector

=item putelem(I<i>,I<el>)

Set the I<i>th element of the vector to I<el>.

=item resize(I<n>)

Resize the vector to contain exactly I<n> elements.
Existing elements are preserved.  New elements have undefined values.

=item zero

Zero all elements of the vector.

=item getsize

Returns the size of the vector

=item add_vec(I<vec>,I<s>)

Add the values of vector I<vec> multiplied by I<s> to this vector.
Vectors needn't be same size.

=item set_vec(I<vec>,I<s>)

Set this vector to the values of vector I<vec> multiplied by I<s>.
No resizing.

=item add_step(I<vec>,I<s>)

Add the value of I<vec> scaled so that its euclidean length is I<s>
to this vector. Result is undefined if |I<vec>| is very small.

=item mul_dbl(I<s>)

Multiply the vector by a scale.

=item randomize(min,max)

Set all the elements of this vector to evenly distributed random values
between I<min> and I<max>.

=back

=head1 BUGS

Very arbitrary interface

Currently, the only mode of operation is "safe", checking the indices
on each element access, which is a pain in some operations.
This should be an external pragma, so that there are two different
DVector objects.

=head1 AUTHOR

Tuomas J. Lukka (Tuomas.Lukka@Helsinki.FI)


=cut

bootstrap Math::DVector;

1;
