#############################################################################
##
#W  algebra.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for 'FLMLOR's and algebras.
##
Revision.algebra_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFLMLOR( <obj> )
##
##  A FLMLOR in {\GAP} is a ring that is also a free left module.
##  Examples are magma rings (e.g. over the integers) or algebras.
##
IsFLMLOR := IsFreeLeftModule and IsLeftOperatorRing;


#############################################################################
##
#C  IsUnitalFLMLOR( <obj> )
##
##  A unital FLMLOR in {\GAP} is a unital ring that is also a free left
##  module.
##  Examples are unital magma rings or unital algebras (but also over the
##  integers).
##
IsUnitalFLMLOR := IsFreeLeftModule and IsLeftOperatorUnitalRing;


#############################################################################
##
#C  IsAlgebra( <obj> )
##
##  An algebra in {\GAP} is a ring that is also a left vector space.
##  Note that this means that being an algebra is not a property a ring can
##  get, since a ring is usually not represented as an external left set.
##
IsAlgebra := IsLeftVectorSpace and IsLeftOperatorRing;


#############################################################################
##
#C  IsUnitalAlgebra( <obj> )
##
##  A unital algebra in {\GAP} is a unital ring that is also a left vector
##  space.
##  Note that this means that being a unital algebra is not a property a
##  unital ring can get,
##  since a unital ring is usually not represented as an external left set.
##
IsUnitalAlgebra := IsLeftVectorSpace and IsLeftOperatorUnitalRing;


#############################################################################
##
#P  IsLieAlgebra( <A> )
##
##  An algebra <A> is called Lie algebra if $a * a = 0$ for all $a$ in <A>
##  and $( a * ( b * c ) ) + ( b * ( c * a ) ) + ( c * ( a * b ) ) = 0$
##  for all $a, b, c$ in <A> (Jacobi identity).
##
IsLieAlgebra := IsAlgebra and IsZeroSquaredRing and IsJacobianRing;
SetIsLieAlgebra := Setter( IsLieAlgebra );
HasIsLieAlgebra := Tester( IsLieAlgebra );


#############################################################################
##
#P  IsSimpleAlgebra( <L> )
##
##  is 'true' if the algebra <L> is simple, and 'false' otherwise.
##
IsSimpleAlgebra := NewProperty( "IsSimpleAlgebra", IsAlgebra );
SetIsSimpleAlgebra := Setter( IsSimpleAlgebra );
HasIsSimpleAlgebra := Tester( IsSimpleAlgebra );


#############################################################################
##
#A  GeneratorsOfLeftOperatorRing
##
GeneratorsOfLeftOperatorRing := NewAttribute(
    "GeneratorsOfLeftOperatorRing", IsLeftOperatorRing );
SetGeneratorsOfLeftOperatorRing := Setter( GeneratorsOfLeftOperatorRing );
HasGeneratorsOfLeftOperatorRing := Tester( GeneratorsOfLeftOperatorRing );


#############################################################################
##
#A  GeneratorsOfLeftOperatorUnitalRing
##
GeneratorsOfLeftOperatorUnitalRing := NewAttribute(
    "GeneratorsOfLeftOperatorUnitalRing", IsLeftOperatorUnitalRing );
SetGeneratorsOfLeftOperatorUnitalRing := Setter(
    GeneratorsOfLeftOperatorUnitalRing );
HasGeneratorsOfLeftOperatorUnitalRing := Tester(
    GeneratorsOfLeftOperatorUnitalRing );


#############################################################################
##
#A  GeneratorsOfAlgebra( <A> )
##
GeneratorsOfAlgebra := GeneratorsOfLeftOperatorRing;
SetGeneratorsOfAlgebra := SetGeneratorsOfLeftOperatorRing;
HasGeneratorsOfAlgebra := HasGeneratorsOfLeftOperatorRing;


#############################################################################
##
#A  GeneratorsOfUnitalAlgebra( <A> )
##
GeneratorsOfUnitalAlgebra := GeneratorsOfLeftOperatorUnitalRing;
SetGeneratorsOfUnitalAlgebra := SetGeneratorsOfLeftOperatorUnitalRing;
HasGeneratorsOfUnitalAlgebra := HasGeneratorsOfLeftOperatorUnitalRing;


#############################################################################
##
#A  DerivedSeriesOfAlgebra( <A> )
##
DerivedSeriesOfAlgebra := NewAttribute( "DerivedSeriesOfAlgebra",
    IsAlgebra );
SetDerivedSeriesOfAlgebra := Setter( DerivedSeriesOfAlgebra );
HasDerivedSeriesOfAlgebra := Tester( DerivedSeriesOfAlgebra );


#############################################################################
##
#A  DerivedSubalgebra( <A> )
##
DerivedSubalgebra := NewAttribute( "DerivedSubalgebra", IsAlgebra );
SetDerivedSubalgebra := Setter( DerivedSubalgebra );
HasDerivedSubalgebra := Tester( DerivedSubalgebra );


#############################################################################
##
#A  AdjointBasis( <B> )
##
##  For the basis <B> of a (Lie) algebra $L$, this function returns a
##  particular basis $C$ of the matrix space generated by $ad L$,
##  namely a basis consisting of elements of the form $ad x_i$,
##  where $x_i$ is a basis element of <B>.
##
AdjointBasis := NewAttribute( "AdjointBasis", IsBasis );
SetAdjointBasis := Setter( AdjointBasis );
HasAdjointBasis := Tester( AdjointBasis );


#############################################################################
##
#A  IndicesOfAdjointBasis( <B> )
##
IndicesOfAdjointBasis := NewAttribute( "IndicesOfAdjointBasis", IsBasis );
SetIndicesOfAdjointBasis := Setter( IndicesOfAdjointBasis );
HasIndicesOfAdjointBasis := Tester( IndicesOfAdjointBasis );


#############################################################################
##
#A  RadicalOfAlgebra( <A> )
##
RadicalOfAlgebra := NewAttribute( "RadicalOfAlgebra", IsAlgebra );
SetRadicalOfAlgebra := Setter( RadicalOfAlgebra );
HasRadicalOfAlgebra := Tester( RadicalOfAlgebra );


#############################################################################
##
#A  TrivialSubalgebra( <A> )
##
TrivialSubFLMLOR := NewAttribute( "TrivialSubFLMLOR", IsFLMLOR );
SetTrivialSubFLMLOR := Setter( TrivialSubFLMLOR );
HasTrivialSubFLMLOR := Tester( TrivialSubFLMLOR );

TrivialSubalgebra := TrivialSubFLMLOR;
SetTrivialSubalgebra := SetTrivialSubFLMLOR;
HasTrivialSubalgebra := HasTrivialSubFLMLOR;


#############################################################################
##
#A  NullAlgebra( <R> )  . . . . . . . . . . zero dimensional algebra over <R>
##
#T or store this in the family ?
##
NullAlgebra := NewAttribute( "NullAlgebra", IsRing );
SetNullAlgebra := Setter( NullAlgebra );
HasNullAlgebra := Tester( NullAlgebra );


#############################################################################
##
#O  ProductSpace( <U>, <V> )
##
##  is the vector space $\langle u * v ; u \in U, v \in V \rangle$,
##  where $U$ and $V$ are vector spaces.
##
##  If $<U> = <V>$ is known to be an algebra then the product space is also
##  an algebra.
##  If <U> and <V> are known to be ideals in an algebra $A$
##  then the product space is known to be an algebra and an ideal in $A$.
##
ProductSpace := NewOperation( "ProductSpace",
    [ IsFreeLeftModule, IsFreeLeftModule ] );


#############################################################################
##
#O  DirectSumOfAlgebras( <A1>, <A2> )
#O  DirectSumOfAlgebras( <list> )
##
##  is the direct sum of the two algebras <A1> and <A2> resp. of the algebras
##  in the list <list>.
##
##  If all involved algebras are associative algebras then the result is also
##  known to be associative.
##  If all involved algebras are Lie algebras then the result is also known
##  to be a Lie algebra.
##
##  All involved algebras must have the same left acting domain.
##
##  The default case is that the result is a s.c. algebra.
##
##  If all involved algebras are matrix algebras, and either both are Lie
##  algebras or both are associative then the result is again a
##  matrix algebra of the appropriate type.
##
DirectSumOfAlgebras := NewOperation( "DirectSumOfAlgebras",
    [ IsDenseList ] );


#############################################################################
##
#O  AsAlgebra( <F>, <A> ) . . . . . . . . . . .  view <A> as algebra over <F>
##
AsFLMLOR := NewOperation( "AsFLMLOR", [ IsRing, IsCollection ] );

AsAlgebra := AsFLMLOR;


#############################################################################
##
#O  AsUnitalAlgebra( <F>, <A> )  . . . .  view <A> as unital algebra over <F>
##
AsUnitalFLMLOR := NewOperation( "AsUnitalFLMLOR",
    [ IsRing, IsCollection ] );

AsUnitalAlgebra := AsUnitalFLMLOR;


#############################################################################
##
#O  AsSubalgebra( <A>, <S> )  . . . . . . . . . view <S> as subalgebra of <A>
##
AsSubFLMLOR := NewOperation( "AsSubFLMLOR", [ IsFLMLOR, IsCollection ] );

AsSubalgebra := AsSubFLMLOR;


#############################################################################
##
#O  AsUnitalSubalgebra( <A>, <S> )  . .  view <S> as unital subalgebra of <A>
##
AsUnitalSubFLMLOR := NewOperation( "AsUnitalSubFLMLOR",
    [ IsFLMLOR, IsDomain ] );

AsUnitalSubalgebra := AsUnitalSubFLMLOR;


#############################################################################
##
#O  FpAlgebra( <F>, <A> )
##
##  Construct an isomorphic finitely presented <F>-algebra
##  of the algebra <A>.
##
FpAlgebra := NewOperation( "FpAlgebra", [ IsDivisionRing, IsAlgebra ] );


#############################################################################
##
#F  EmptySCTable( <dim>, <zero> )
#F  EmptySCTable( <dim>, <zero>, \"symmetric\" )
#F  EmptySCTable( <dim>, <zero>, \"antisymmetric\" )
##
##  'EmptySCTable' returns a structure constants table for an algebra of
##  dimension <dim>, describing trivial multiplication.
##  <zero> must be the zero of the coefficients domain.
##  If the multiplication is known to be (anti)commutative then
##  this can be indicated by the optional third argument.
##
##  For filling up the s.c. table, see "SetEntrySCTable".
##
EmptySCTable := NewOperationArgs( "EmptySCTable" );


#############################################################################
##
#F  SetEntrySCTable( <T>, <i>, <j>, <list> )
##
##  sets the entry of the structure constants table <T> that describes the
##  product of the <i>-th basis element with the <j>-th basis element to the
##  value given by the list <list>.
##
##  If <T> is known to be antisymmetric or symmetric then also the value
##  '<T>[<i>][<j>]' is set.
##
##  <list> must be of the form
##  $[ c_{ij}^{k_1}, k_1, c_{ij}^{k_2}, k_2, ... ]$.
##
SetEntrySCTable := NewOperationArgs( "SetEntrySCTable" );


#############################################################################
##
#F  GapInputSCTable( <T>, <varname> )
##
##  is a string that describes the structure constants table <T> in terms of
##  'EmptySCTable' and 'SetEntrySCTable'.
##  The assignments are made to the variable <varname>.
##
GapInputSCTable := NewOperationArgs( "GapInputSCTable" );


#############################################################################
##
#F  IdentityFromSCTable( <T> )
##
##  Let <T> be a s.c. table of an algebra $A$ of dimension $n$.
##  'IdentityFromSCTable( <T> )' is either 'fail' or the vector of length
##  $n$ that contains the coefficients of the multipicative identity of $A$
##  w.r.t. the basis that belongs to <T>.
##
IdentityFromSCTable := NewOperationArgs( "IdentityFromSCTable" );


#############################################################################
##
#F  QuotientFromSCTable( <T>, <num>, <den> )
##
##  Let <T> be a s.c. table of an algebra $A$ of dimension $n$.
##  'QuotientFromSCTable( <T> )' is either 'fail' or the vector of length
##  $n$ that contains the coefficients of the quotient of <num> and <den>
##  w.r.t. the basis that belongs to <T>.
##
##  We solve the equation system $<num> = x <den>$.
##  If no solution exists, 'fail' is returned.
##
##  In terms of the basis $B$ with vectors $b_1, \ldots, b_n$ this means
##  for $<num> = \sum_{i=1}^n a_i b_i$,
##      $<den> = \sum_{i=1}^n c_i b_i$,
##      $x     = \sum_{i=1}^n x_i b_i$ that
##  $a_k = \sum_{i,j} c_i x_j c_{ijk}$ for all $k$.
##  Here $c_{ijk}$ denotes the structure constants w.r.t. $B$.
##  This means $a = x M$ with $M_{ik} = \sum_{j=1}^n c_{ijk} c_j$.
##
QuotientFromSCTable := NewOperationArgs( "QuotientFromSCTable" );


#############################################################################
##
#F  TestJacobi( <T> )
##
##  tests whether the structure constants table <T> satisfies the Jacobi
##  identity
##  $[ v_i, [ v_j,v_k ] ] + [ v_j, [ v_k,v_i ] ] + [ v_k, [ v_i,v_j ] ] = 0$
##  for all basis vectors $v_i$ of the underlying algebra,
##  where $i \leq j \leq k$
##  (Thus antisymmetry is assumed.)
##
##  The function returns 'true' if the Jacobi identity is satisfied,
##  and a failing triple '[ i, j, k ]' otherwise.
##
TestJacobi := NewOperationArgs( "TestJacobi" );


#############################################################################
##
#O  ClosureLeftOperatorRing( <A>, <a> )
#O  ClosureLeftOperatorRing( <A>, <S> )
##
##  For a left operator ring <A> and either an element <a> of its elements
##  family or a left operator ring <S> (over the same left acting domain),
##  'ClosureLeftOperatorRing' returns the left operator ring generated by
##  both arguments.
##
ClosureLeftOperatorRing := NewOperation( "ClosureLeftOperatorRing",
    [ IsLeftOperatorRing, IsObject ] );

ClosureAlgebra := ClosureLeftOperatorRing;


#############################################################################
##
#F  MutableBasisOfClosureUnderAction( <F>, <Agens>, <gens>, <from>, <init>,
#F                                    <maxdim> )
##
##  Let <F> be a ring, and <Agens> a list of generators for an <F>-algebra
##  $A$,
##  <gens> be a list of vectors in the elements family of the family of $A$,
##  and <from> one of \"left\", \"right\", \"both\"; it means that elements
##  of <A> act via multiplication from the respective side(s).
##
##  <init> is a list of initial generating vectors.
##  It usually contains 'One( <A> )' in the case of unital algebras,
##  the algebra generators of <A> in the case of other algebras,
##  and ideal generators in the ideal case.
##
##  <maxdim> is an upper bound for the dimension of the closure.
##
##  'MutableBasisOfClosureUnderAction' returns a mutable basis of the
##  <F>-free left module generated by the vectors in <gens>
##  and their images under the action of $A$.
##
MutableBasisOfClosureUnderAction := NewOperationArgs(
    "MutableBasisOfClosureUnderAction" );


#############################################################################
##
##  Domain constructors
##

#############################################################################
##
#O  AlgebraByGenerators(<F>,<gens>) . . . . . . . . <F>-algebra by generators
#O  AlgebraByGenerators( <F>, <gens>, <zero> )
##
FLMLORByGenerators := NewOperation( "FLMLORByGenerators",
    [ IsRing, IsCollection ] );

AlgebraByGenerators := FLMLORByGenerators;


#############################################################################
##
#F  Algebra( <F>, <gens> )
#F  Algebra( <F>, <gens>, <zero> )
#F  Algebra( <F>, <gens>, "basis" )
#F  Algebra( <F>, <gens>, <zero>, "basis" )
##
##  'Algebra( <F>, <gens> )' is the algebra over the division ring
##  <F>, generated by the vectors in the list <gens>.
##
##  If there are three arguments, a division ring <F> and a list <gens>
##  and an element <zero>,
##  then 'Algebra( <F>, <gens>, <zero> )' is the <F>-algebra
##  generated by <gens>, with zero element <zero>.
##
##  If the last argument is the string '\"basis\"' then the vectors in
##  <gens> are known to form a basis of the algebra (as an <F>-vector space).
##
FLMLOR := NewOperationArgs( "FLMLOR" );

Algebra := FLMLOR;


#############################################################################
##
#F  Subalgebra( <A>, <gens> ) . . . . . subalgebra of <A> generated by <gens>
##
##  is the $F$-algebra generated by <gens>, with parent algebra <A>, where
##  $F$ is the left acting domain of <A>.
##
##  *Note* that being a subalgebra of <A> means to be an algebra, to be
##  contained in <A>, *and* to have the same left acting domain as <A>.
##
#F  Subalgebra( <A>, <gens>, "basis" )
##
##  is the subalgebra of <A> for that <gens> is a list of basis vectors.
##  It is *not* checked whether <gens> really are linearly independent
##  and whether all in <gens> lie in <A>.
##
SubFLMLOR := NewOperationArgs( "SubFLMLOR" );

Subalgebra := SubFLMLOR;


#############################################################################
##
#F  SubalgebraNC( <A>, <gens>, "basis" )
#F  SubalgebraNC( <A>, <gens> )
##
##  'SubalgebraNC' does not check whether all in <gens> lie in <A>.
##
SubFLMLORNC := NewOperationArgs( "SubFLMLORNC" );

SubalgebraNC := SubFLMLORNC;


#############################################################################
##
#O  UnitalAlgebraByGenerators(<F>,<gens>) .  unital <F>-algebra by generators
#O  UnitalAlgebraByGenerators( <F>, <gens>, <zero> )
##
UnitalFLMLORByGenerators := NewOperation( "UnitalFLMLORByGenerators",
    [ IsDivisionRing, IsCollection ] );

UnitalAlgebraByGenerators := UnitalFLMLORByGenerators;


#############################################################################
##
#F  UnitalAlgebra( <F>, <gens> )
#F  UnitalAlgebra( <F>, <gens>, <zero> )
#F  UnitalAlgebra( <F>, <gens>, "basis" )
#F  UnitalAlgebra( <F>, <gens>, <zero>, "basis" )
##
##  'UnitalAlgebra( <F>, <gens> )' is the unital algebra over the division
##  ring <F>, generated by the vectors in the list <gens>.
##
##  If there are three arguments, a division ring <F> and a list <gens>
##  and an element <zero>,
##  then 'UnitalAlgebra( <F>, <gens>, <zero> )' is the unital <F>-algebra
##  generated by <gens>, with zero element <zero>.
##
##  If the last argument is the string '\"basis\"' then the vectors in
##  <gens> are known to form a basis of the algebra (as an <F>-vector space).
##
UnitalFLMLOR := NewOperationArgs( "UnitalFLMLOR" );

UnitalAlgebra := UnitalFLMLOR;


#############################################################################
##
#F  UnitalSubalgebra( <A>, <gens> ) . .  unital subalg. of <A> gen. by <gens>
##
##  is the unital algebra generated by <gens>, with parent algebra <V>.
##
#F  UnitalSubalgebra( <A>, <gens>, "basis" )
##
##  is the unital subalgebra of <A> for that <gens> is a list of basis
##  vectors.
##  It is *not* checked whether <gens> really are linearly independent
##  and whether all in <gens> lie in <A>.
##
UnitalSubFLMLOR := NewOperationArgs( "UnitalSubFLMLOR" );

UnitalSubalgebra := UnitalSubFLMLOR;


#############################################################################
##
#F  UnitalSubalgebraNC( <A>, <gens>, "basis" )
#F  UnitalSubalgebraNC( <A>, <gens> )
##
##  'UnitalSubalgebraNC' does not check whether all in <gens> lie in <V>.
##
UnitalSubFLMLORNC := NewOperationArgs( "UnitalSubFLMLORNC" );

UnitalSubalgebraNC := UnitalSubFLMLORNC;


#############################################################################
##
#F  LieAlgebra( <L> )
#F  LieAlgebra( <F>, <gens> )
#F  LieAlgebra( <F>, <gens>, <zero> )
#F  LieAlgebra( <F>, <gens>, "basis" )
#F  LieAlgebra( <F>, <gens>, <zero>, "basis" )
##
##  *Note* that the algebra returned by 'LieAlgebra' does not contain the
##  vectors in <gens>.
##  Instead the elements of this algebra are elements in a family of Lie
##  objects.
##  This allows to create Lie algebras from ring elements with respect to
##  the Lie bracket as product.  But of course the product in the Lie
##  algebra is the usual '\*'.
##
##  'LieAlgebra( <L> )' is the Lie algebra isomorphic to <L> as a vector
##  space but with the Lie bracket as product.
##
##  'LieAlgebra( <F>, <gens> )' is the Lie algebra over the division ring
##  <F>, generated *as Lie algebra* by the Lie objects corresponding to the
##  vectors in the list <gens>.
##
##  If there are three arguments, a division ring <F> and a list <gens>
##  and an element <zero>,
##  then 'LieAlgebra( <F>, <gens>, <zero> )' is the corresponding <F>-Lie
##  algebra with zero element the Lie object corresponding to <zero>.
##
##  If the last argument is the string '\"basis\"' then the vectors in
##  <gens> are known to form a basis of the algebra (as an <F>-vector space).
##
##  *Note* that even if each element in <gens> is already a Lie element,
##  i.e., is of the form 'LieElement( <elm> )' for an object <elm>,
##  the elements of the result lie in the Lie family of the family that
##  contains <gens> as a subset.
##
LieAlgebra := NewOperationArgs( "LieAlgebra" );


#############################################################################
##
#A  LieAlgebraByDomain( <A> )
##
##  is a Lie algebra isomorphic to the algebra <A> as a vector space,
##  but with the Lie bracket as product.
##
LieAlgebraByDomain := NewAttribute( "LieAlgebraByDomain", IsAlgebra );


#############################################################################
##
#O  LieAlgebraByGenerators( <F>, <gens> )
#O  LieAlgebraByGenerators( <F>, <gens>, <zero> )
##
LieAlgebraByGenerators := NewOperation( "LieAlgebraByGenerators",
    [ IsDivisionRing, IsCollection ] );


#############################################################################
##
#O  AsLieAlgebra( <F>, <A> ) . . . . . . . . view <A> as Lie algebra over <F>
##
##  Note that the multiplication in <A> is the same as in the result.
##
AsLieAlgebra := NewOperation( "AsLieAlgebra",
    [ IsDivisionRing, IsCollection ] );


#############################################################################
##
#F  FreeAssociativeAlgebra( <R>, <rank> )
#F  FreeAssociativeAlgebra( <R>, <rank>, <name> )
#F  FreeAssociativeAlgebra( <R>, <name1>, <name2>, ... )
##
FreeAssociativeAlgebra := NewOperationArgs( "FreeAssociativeAlgebra" );


#############################################################################
##
#F  SCAlgebra( <R>, <A> )
##
##  is the algebra <A> represented as s.c. algebra over <R>.
##
SCAlgebra := NewOperation( "SCAlgebra", [ IsDivisionRing, IsAlgebra ] );
#T necessary ?


#############################################################################
##
#F  AlgebraByStructureConstants( <R>, <sctable> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <name> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <name1>, <name2>, ... )
##
##  returns a free left module $A$ over the ring <R>,
##  with multiplication defined by the structure constants table <sctable>
##  of length $n$, say.
##
##  The algebra generators of $A$ are linearly independent
##  abstract vector space generators
##  $x_1, x_2, \ldots, x_n$ which are multiplied according to the formula
##  $ x_i x_j = \sum_{k=1}^n c_{ijk} x_k$
##  where '$c_{ijk}$ = <sctable>[i][j][1][i_k]'
##  and '<sctable>[i][j][2][i_k] = k'.
##
AlgebraByStructureConstants := NewOperationArgs(
    "AlgebraByStructureConstants" );


#############################################################################
##
#F  LieAlgebraByStructureConstants( <R>, <sctable> )
#F  LieAlgebraByStructureConstants( <R>, <sctable>, <name> )
#F  LieAlgebraByStructureConstants( <R>, <sctable>, <name1>, <name2>, ... )
##
##  'LieAlgebraByStructureConstants' does the same as
##  'AlgebraByStructureConstants', except that the result is assumed to be
##  a Lie algebra.
##
LieAlgebraByStructureConstants := NewOperationArgs(
    "LieAlgebraByStructureConstants" );


#############################################################################
##
#P  IsAlgebraHomomorphism( <map> )
##
##  A mapping $f$ is an algebra homomorphism if source and range are algebras
##  over the same division ring,
##  and if $f$ is a ring homomorphism and a vector space homomorphism.
#T really necessary to test linearity?
##
IsAlgebraHomomorphism := NewProperty( "IsAlgebraHomomorphism",
                                      IsMapping );
#T file 'alghom.g'!


#############################################################################
##
#E  algebra.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



