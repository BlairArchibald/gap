#############################################################################
##
#W  matrix.gi                   GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Alexander Hulpke
#W                                                           & Heiko Theissen
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains methods for matrices.
##
Revision.matrix_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  PrintArray( <array> ) . . . . . . . . . . . . . . . . pretty print matrix
##
InstallGlobalFunction(PrintArray,function( array )

    local   arr,  max,  l,  k;

    if not IsDenseList( array ) then
        Error( "<array> must be a dense list" );
    elif Length( array ) = 0  then
	Print( "[ ]\n" );
    elif array = [[]]  then
    	Print( "[ [ ] ]\n" );
    elif not ForAll( array, IsList )  then
	arr := List( array, String );
	max := Maximum( List( arr, Length ) );
	Print( "[ ", FormattedString( arr[ 1 ], max + 1 ) );
	for l  in [ 2 .. Length( arr ) ]  do
	    Print( ", ", FormattedString( arr[ l ], max + 1 ) );
	od;
	Print( " ]\n" );
    else
    	arr := List( array, x -> List( x, String ) );
    	max := Maximum( List( arr, x -> Maximum( List(x,Length) ) ) );
        Print( "[ " );
    	for l  in [ 1 .. Length( arr ) ]  do
    	    if l > 1  then
    	    	Print( "  " );
    	    fi;
            Print( "[ " );
            for k  in [ 1 .. Length( arr[ l ] ) ]  do
            	Print( FormattedString( arr[ l ][ k ], max + 1 ) );
            	if k = Length( arr[ l ] )  then
                    Print( " ]" );
            	else
                    Print( ", " );
            	fi;
            od;
            if l = Length( arr )  then
            	Print( " ]\n" );
            else
            	Print( ",\n" );
            fi;
    	od;
    fi;
end);


##########################################################################
##
#M  Display( <mat> )
##
InstallMethod( Display,
    "for a matrix",
    true,
    [IsMatrix ],
    0, PrintArray );


#############################################################################
##
#M  IsGeneralizedCartanMatrix( <A> )
##
InstallMethod( IsGeneralizedCartanMatrix,
    "for a matrix",
    true,
    [ IsMatrix ], 0,
    function( A )

    local n, i, j;

    if Length( A ) <> Length( A[1] ) then
      Error( "<A> must be a square matrix" );
    fi;

    n:= Length( A );
    for i in [ 1 .. n ] do
      if A[i][i] <> 2 then
        return false;
      fi;
    od;
    for i in [ 1 .. n ] do
      for j in [ i+1 .. n ] do
        if not IsInt( A[i][j] ) or not IsInt( A[j][i] )
           or 0 < A[i][j] or 0 < A[j][i] then
          return false;
        elif  ( A[i][j] = 0 and A[j][i] <> 0 )
           or ( A[j][i] = 0 and A[i][j] <> 0 ) then
          return false;
        fi;
      od;
    od;
    return true;
    end );


#############################################################################
##
#M  IsDiagonalMat(<mat>)
##
InstallMethod( IsDiagonalMat,
    "for a matrix",
    true,
    [ IsMatrix ], 0,
    function( mat )
   local  i, j,z;
    if IsEmpty(mat) then return true;fi;
    z:=Zero(mat[1][1]);
    for i  in [ 1 .. Length( mat ) ]  do
        for j  in [ 1 .. Length( mat[i] ) ]  do
            if mat[i][j] <> z and i <> j  then
                return false;
            fi;
        od;
    od;
    return true;
    end);

InstallOtherMethod( IsDiagonalMat, true, [ IsEmpty ], 0, ReturnTrue );


#############################################################################
##
#M  IsUpperTriangularMat(<mat>)
##
InstallMethod( IsUpperTriangularMat,
   "for a matrix",
    true,
    [ IsMatrix ], 0,
    function( mat )
   local  i, j,z;
    if IsEmpty(mat) then return true;fi;
    z:=Zero(mat[1][1]);
    for i  in [ 1 .. Length( mat ) ]  do
        for j  in [ 1 .. i-1]  do
            if mat[i][j] <> z  then
                return false;
            fi;
        od;
    od;
    return true;
    end);

#############################################################################
##
#M  IsLowerTriangularMat(<mat>)
##
InstallMethod( IsLowerTriangularMat,
    "for a matrix",
    true,
    [ IsMatrix ], 0,
    function( mat )
   local  i, j,z;
    if IsEmpty(mat) then return true;fi;
    z:=Zero(mat[1][1]);
    for i  in [ 1 .. Length( mat ) ]  do
        for j  in [ i+1 .. Length( mat[i] ) ]  do
            if mat[i][j] <> z  then
                return false;
            fi;
        od;
    od;
    return true;
    end);

#############################################################################
##
#M  DiagonalOfMat(<mat>)  . . . . . . . . . . . . . . . .  diagonal of matrix
##
##  'DiagonalOfMat' returns  the diagonal of  the matrix <mat>.  The diagonal
##  has the  same length  as the rows of  <mat>,  it is padded with zeros  if
##  <mat> has fewer rows than columns.
##
InstallGlobalFunction( DiagonalOfMat, function ( mat )
    local   diag, i;

    diag := [];
    i := 1;
    while i <= Length(mat) and i <= Length(mat[1]) do
        diag[i] := mat[i][i];
        i := i + 1;
    od;
    while 1 <= Length(mat) and i <= Length(mat[1]) do
        diag[i] := mat[1][1] - mat[1][1];
        i := i + 1;
    od;
    return diag;
end );


#############################################################################
##
#R  IsNullMapMatrix . . . . . . . . . . . . . . . . . . .  null map as matrix
##
DeclareRepresentation( "IsNullMapMatrix", IsMatrix, [  ] );

BindGlobal( "NullMapMatrix",
    Objectify( NewType( ListsFamily, IsNullMapMatrix ), [  ] ) );

InstallMethod( Length,
    "for null map matrix",
    true,
    [ IsNullMapMatrix ], 0,
    null -> 0 );

InstallMethod( \*,
    "for vector and null map matrix",
    true,
    [ IsVector, IsNullMapMatrix ], 0,
    function( v, null )
    return [  ];
end );

InstallOtherMethod( \*,
    "for empty list and null map matrix",
    true,
    [ IsList and IsEmpty, IsNullMapMatrix ], 0,
    function( v, null )
    return [  ];
end );

InstallMethod( \*,
    "for matrix and null map matrix",
    true,
    [ IsMatrix, IsNullMapMatrix ], 0,
    function( A, null )
    return List( A, row -> [  ] );
end );

InstallOtherMethod( \*,
    "for list and null map matrix",
    true,
    [ IsList, IsNullMapMatrix ], 0,
    function( A, null )
    return List( A, row -> [  ] );
end );

InstallMethod( ViewObj,
    "for null map matrix",
    true,
    [ IsNullMapMatrix ], 0,
    function( null )
    Print( "<null map>" );
end );

InstallMethod( PrintObj,
    "for null map matrix",
    true,
    [ IsNullMapMatrix ], 0,
    function( null )
    Print( "NullMapMatrix" );
end );


#############################################################################
##
#F  Matrix_CharacteristicPolynomialSameField( <fld>, <mat>, <ind> )
##
Matrix_CharacteristicPolynomialSameField := function( fld, mat, ind )
    local   d,  P,  L,  one,  zero,  vs,  i,  R,  M,  v,  p,  w,  h, j, sc;

    # <d> is dimension of the underlying vector space
    d := Length(mat);

    # catch the trivial case of a matrix of dimension zero
    if d = 0  then
        return Zero(ind);
    fi;

    # <P> contains all the order polynomials
    P   := [ ind^0 ];

    # <L> contains the spinned up basis
    L := [];

    # get the one and zero
    one  := One(fld);
    zero := Zero(fld);

    # get the vectorspace
    vs := FullRowSpace( fld, d );

    # span the whole vector space
    for i  in [ 1 .. d ]  do

        # did we already see the <i>.th base vector
        if not IsBound(L[i])  then

            # clear right sides <R>
            R := [];

            # <M> will be a list of zeros (for each repeat one more)
            M := [];

            # start with the standard base vector
            v := ShallowCopy( mat[1]*zero );
            v[i] := one;

            # spin vector around and construct polynomial
            repeat

                # start with appropriate polynomial x^(<j>-1)
                p := ShallowCopy(M);
                Add( p, one  );
                Add( M, zero );

                # divide by known left sides
                w := ShallowCopy(v);
                h := PositionNot( w, zero );
                while h <= Length(w) and IsBound(L[h])  do
                    if IsBound(R[h])  then # add -w[h]*R[h] to the beginning
                                           # of p
                        
                        if Length( p ) = Length( R[h] ) then
                            AddRowVector( p, R[h], -w[h] );
                        else        
                            for j in [1..Length(R[h])] do
                                p[j]:= p[j]-w[h]*R[h][j];
                            od;
                        fi;
                    fi;
                    
                    # add -w[h]*L[h] to the beginning of w
                    if Length( w ) = Length( L[h] ) then
                        AddRowVector( w, L[h], -w[h] );
                    else        
                        sc:= -w[h];
                        for j in [1..Length(L[h])] do
                            w[j]:= w[j] + sc*L[h][j];
                        od;
                    fi;
                    
                    h := PositionNot( w, zero );
                od;

                # if <w> is not the zero vector try next power
                if h <= Length(w)  then
                    R[h] := p * w[h]^-1;
                    L[h] := w * w[h]^-1;
                    v := v * mat;

                # otherwise, we know our order polynomial
                else
                    Add( P, UnivariatePolynomialByCoefficients(
                        ElementsFamily(FamilyObj(fld)), p, ind ) );
                fi;
            until h > Length(w);
        fi;
    od;

    # compute the product of all polynomials
    return Product(P);

end;


##########################################################################
##
#F  Matrix_MinimalPolynomialSameField( <fld>, <mat>, <ind> )
##
Matrix_MinimalPolynomialSameField := function( fld, mat, ind )
    local   W,  d,  P,  one,  zero,  vs,  dim,  v,  L,  R,  M,  p,  w,
            h,  zv,   cnt;

    # <W> will contain a spinned up basis
    W := [];

    # <d> is dimension of the underlying vector space
    d := Length(mat);

    # catch the trivial case of a matrix of dimension zero
    if d = 0  then
      return 0*Indeterminate(fld,ind);
    fi;

    # <P> contains all the order polynomials
    P   := [ Indeterminate(fld,ind)^0 ];

    # get the one and zero
    one  := One(fld);
    zero := Zero(fld);

    # get the vectorspace
    vs := FullRowSpace( fld, d );
    zv := Zero(vs);
    cnt:=Length(mat);

    # span the whole vector space
    dim := 0;
    while dim < d  do

        # next random vector
        repeat
            v := Random(vs);
	    # take rows from the matrix instead of random vectors. Then we
	    # don't have to create these random vectors.
	    #v:=mat[cnt];
	    #cnt:=cnt-1;
        until v <> zv;

        # clear right <R> and left sides <L>
        L := [];
        R := [];

        # <M> will be a list of zeros (for each repeat one more)
        M := [];

        # spin vector around and construct polynomial
        repeat

            # start with appropriate polynomial x^(<j>-1)
            p := ShallowCopy(M);
            Add( p, one  );
            Add( M, zero );

            # divide by known left sides
            w := ShallowCopy(v);
            ShrinkCoeffs(w);
            h := Length(w);
            while 0 < h and IsBound(L[h])  do
                AddCoeffs( p, R[h], -w[h] );
                h := AddCoeffs( w, L[h], -w[h] );
            od;
            ShrinkCoeffs(p);
            ShrinkCoeffs(w);

            # if <w> is not the zero vector try next power
            if 0 < h  then
                R[h] := p * w[h]^-1;
                L[h] := w * w[h]^-1;

                # enter vectors seen in <W>
                while 0 < h and IsBound(W[h])  do
                    h := AddCoeffs( w, W[h], -w[h] );
                od;
                ShrinkCoeffs(w);
                if 0 < h then
                    W[h] := w * w[h]^-1;
                    dim  := dim + 1;
                fi;

                # next power of <mat>
                v := v * mat;
                h := 1;

    	    # otherwise, we know our order polynomial
            else
                Add( P, UnivariatePolynomialByCoefficients(
                    ElementsFamily(FamilyObj(fld)), p, ind ) );
            fi;
        until h = 0;
    od;

    # compute LCM of all polynomials
    p := P[1];
    W := PolynomialRing( fld, [ind] );
    for h  in [ 2 .. Length(P) ]  do
        p := LcmOp( W, p, P[h] );
    od;
    return p;

end;


##########################################################################
##

#M  Display( <ffe-mat> )
##
InstallMethod( Display,
    "for matrix of FFEs",
    true,
    [ IsFFECollColl and IsMatrix ],
    0,

function( m )
    local   deg,  chr,  zero,  w,  t,  x,  v,  f,  z,  y;

    if  IsZmodnZObj(m[1][1]) then
      Print("ZmodnZ matrix:\n");
      t:=List(m,i->List(i,i->i![1]));
      Display(t);
      Print("modulo ",DataType(TypeObj(m[1][1])),"\n");
#T what is this good for?
#T (The code for finite prime fields should handle this case,
#T and the output should look the same.)
    else
      # get the degree and characteristic
      deg  := Lcm( List( m, DegreeFFE ) );
      chr  := Characteristic(m[1][1]);
      zero := Zero(m[1][1]);

      # if it is a finite prime field,  use integers for display
      if deg = 1  then

        # compute maximal width
        w := LogInt( chr, 10 ) + 2;

        # create strings
        t := [];
        for x  in [ 2 .. chr ]  do
            t[x] := FormattedString( x-1, w );
        od;
#T useful only for (very) small characteristic, or?
        t[1] := FormattedString( ".", w );

        # print matrix
        for v  in m  do
            for x  in List( v, IntFFE )  do
#T !
                Print( t[x+1] );
            od;
            Print( "\n" );
        od;

      # if it a finite,  use mixed integers/z notation
#T ...
      else
	  Print( "z = Z(", chr^deg, ")\n" );

        # compute maximal width
        w := LogInt( chr^deg-1, 10 ) + 4;

        # create strings
        t := [];
        f := GF(chr^deg);
        z := Z(chr^deg);
        for x  in [ 0 .. Size(f)-2 ]  do
            y := z^x;
            if DegreeFFE(y) = 1  then
                t[x+2] := FormattedString( IntFFE(y), w );
#T !
            else
                t[x+2] := FormattedString(Concatenation("z^",String(x)),w);
            fi;
        od;
        t[1] := FormattedString( ".", w );

        # print matrix
        for v  in m  do
            for x  in v  do
                if x = zero  then
                    Print( t[1] );
                else
                    Print( t[LogFFE(x,z)+2] );
                fi;
            od;
            Print( "\n" );
        od;

      fi;
    fi;
end );


##########################################################################
##
#M  CharacteristicPolynomial( <field>, <matrix>, <indnum> )
##
InstallMethod( CharacteristicPolynomial, "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ], 0,
function( F, mat,inum )
    local fld, B;

    fld:= DefaultFieldOfMatrix( mat );

    if not IsSubset( F, fld ) then

      # Replace the matrix by a matrix with the same char. polynomial
      # but with entries in `F'.
      if not IsSubset( fld, F ) then
        fld:= ClosureField( fld, F );
      fi;
      B:= Basis( AsField( F, fld ) );
      mat:= BlownUpMat( B, mat );

    fi;

    return CharacteristicPolynomialMatrixNC( F, mat,inum);
end );

InstallMethod( CharacteristicPolynomialMatrixNC, "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ], 0,
  Matrix_CharacteristicPolynomialSameField);


#############################################################################
##
#M  MinimalPolynomial( <field>, <matrix>, <indnum> )
##
InstallMethod( MinimalPolynomial,
    "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ], 0,
function( F, mat,inum )
    local fld, B;

    fld:= DefaultFieldOfMatrix( mat );

    if not IsSubset( F, fld ) then

      # Replace the matrix by a matrix with the same minimal polynomial
      # but with entries in `F'.
      if not IsSubset( fld, F ) then
        fld:= ClosureField( fld, F );
      fi;
      B:= Basis( AsField( F, fld ) );
      mat:= BlownUpMat( B, mat );

    fi;

    return MinimalPolynomialMatrixNC( F, mat,inum);
end );

InstallMethod( MinimalPolynomialMatrixNC, "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ], 0,
  Matrix_MinimalPolynomialSameField);


#############################################################################
##
#M  Order( <mat> )  . . . . . . . . . . . . . . . . . . . . order of a matrix
##
OrderMatLimit := 1000;

InstallOtherMethod( Order,
    "generic method for ordinary matrices",
    true,
    [ IsOrdinaryMatrix ],
    0,

function ( mat )
    local   m, rank;

    # check that the argument is an invertible square matrix
    m := Length(mat);
    if m <> Length(mat[1])  then
        Error( "Order: <mat> must be a square matrix" );
    fi;
    rank:= RankMat( mat );
    if rank = fail then
      if not IsUnit( DeterminantMat( mat ) ) then
        Error( "Order: <mat> must be invertible" );
      fi;
    elif rank <> m  then
      Error( "Order: <mat> must be invertible" );
#T also test here that the determinant is in fact a unit in the ring
#T that is generated by the matrix entries?
#T (Do we need `IsPossiblyInvertibleMat' and `IsSurelyInvertibleMat',
#T the first meaning that the inverse in some ring exists,
#T the second meaning that the inverse exists in the ring generated by the
#T matrix entries?
#T For `Order', it is `IsSurelyInvertibleMat' that one wants to check;
#T then one can return `infinity' if the determinant is not a unit in the
#T ring generated by the matrix entries.)
    fi;
      

    # loop over the standard basis vectors
    return OrderMatTrial(mat,infinity);

end );

#############################################################################
##
#F  OrderMatTrial( <mat>,<lim> )
##
InstallGlobalFunction(OrderMatTrial,function(mat,lim)
local ord,i,vec,v,o;

  # loop over the standard basis vectors
  ord := 1;
  for i  in [1..Length(mat)]  do

    # compute the length of the orbit of the <i>th standard basis vector
    # (equivalently, of the orbit of `mat[<i>]',
    # the image of the standard basis vector under `mat')
    vec := mat[i];
    v   := vec * mat;
    o   := 1;
    while v <> vec  do
      v := v * mat;
      o := o + 1;
      if o>lim then
	return fail;
      elif OrderMatLimit = o  and Characteristic(v[1])=0 then
	  Info( InfoWarning, 1,
		"Order: warning, order of <mat> might be infinite" );
      fi;
    od;

    # raise the matrix to this length (new mat will fix basis vector)
    mat := mat ^ o;
    ord := ord * o;
  od;
  return ord;

end);


#############################################################################
##
#M  Order( <cycmat> ) . . . . . . . . . . .  order of a matrix of cyclotomics
##
##  The idea is to compute the minimal polynomial of the matrix,
##  and to decompose this polynomial into cyclotomic polynomials.
##  This is due to R. Beals, who used it in his `grim' package for {\GAP}~3.
##
InstallMethod( Order,
    "ordinary matrix of cyclotomics",
    true,
    [ IsOrdinaryMatrix and IsCyclotomicCollColl ],
    0,
    function( cycmat )

    local m,       # dimension of the matrix
          trace,   # trace of the matrix
          minpol,  # minimal polynomial of the matrix
          n,       # degree of `minpol'
          p,       # loop over small primes
          t,       # product of the primes `p'
          l,       # product of the values `p-1'
          ord,     # currently known factor of the order
          d,       # loop over the indices of cyclotomic polynomials
          phi,     # `Phi( d )'
          c,       # `d'-th cyclotomic polynomial
          q;       # quotient and remainder

    # Check that the argument is an invertible square matrix.
    m:= Length( cycmat );
    if m <> Length( cycmat[1] ) then
      Error( "Order: <cycmat> must be a square matrix" );
    elif RankMat( cycmat ) <> m  then
      Error( "Order: <cycmat> must be invertible" );
    fi;
#T Here I could compute the inverse;
#T its trace could be checked, too.
#T Additionally, if `mat' consists of (algebraic) integers
#T and the inverse does not then the order of `mat' is infinite.

    # If the order is finite then the trace must be an algebraic integer.
    trace:= TraceMat( cycmat );
    if not IsIntegralCyclotomic( trace ) then
      return infinity;
    fi;

    # If the order is finite then the absolute value of the trace 
    # is bounded by the dimension of the matrix.
#T compute this (approximatively) for arbitrary cyclotomics
#T (by the way: why isn't this function called `AbsRat'?)
    if IsInt( trace ) and Length( cycmat ) < AbsInt( trace ) then
      return infinity;
    fi;

    # Before we start to deal with polynomials,
    # we check whether the matrix has a *small* order.
#T !!!

    # Compute the minimal polynomial of the matrix.
    minpol:= MinimalPolynomial( Rationals, cycmat );
    n:= DegreeOfLaurentPolynomial( minpol );

    # The order is finite if and only if the minimal polynomial
    # is a product of cyclotomic polynomials.
    # (Note that cyclotomic polynomials over the rationals are irreducible.)

    # A necessary condition is that the constant term of the polynomial
    # is $\pm 1$, since this holds for every cyclotomic polynomial.
    if AbsInt( Value( minpol, 0 ) ) <> 1 then
      return infinity;
    fi;

    # Another necessary condition is that no irreducible factor
    # may occur more than once.
    # (Note that the minimal polynomial divides $X^{ord} - 1$.)
    if not IsOne( Gcd( minpol, Derivative( minpol ) ) ) then
      return infinity;
    fi;

    # Compute an upper bound `t' for the numbers $i$ with the property
    # that $\varphi(i) \leq n$ holds.
    # (Let $p_k$ denote the $k$-th prime divisor of $i$,
    # and $q_k$ the $k$-th prime; then clearly $q_k \leq p_k$ holds.
    # Now let $h$ be the smallest *positive* integer --be careful that the
    # products considered below are not empty-- such that
    # $\prod_{k=1}^h ( q_k - 1 ) \geq n$, and set $t = \prod_{k=1}^h q_k$.
    # If $i$ has the property $\varphi(i) \leq n$ then
    # $i \leq n \frac{i}{\varphi(i)} = n \prod_{k} \frac{p_k}{p_k-1}$.
    # Replacing $p_k$ by $q_k$ means to replace the factor
    # $\frac{p_k}{p_k-1}$ by a larger factor,
    # and if $i$ has less than $h$ prime divisors then
    # running over the first $h$ primes increases the value of the product
    # again, so we get $i \leq n \prod_{k=1}^h \frac{q_k}{q_k-1} \leq t$.)
    p:= 2;
    t:= 2;
    l:= 1;
    while l < n do
      p:= NextPrimeInt( p );
      t:= t * p;
      l:= l * ( p - 1 );
    od;

    # Divide by each possible cyclotomic polynomial.
    ord:= 1;
    for d in [ 1 .. t ] do

      phi:= Phi( d );
      if phi <= n then
        c:= CyclotomicPolynomial( Rationals, d );
        q:= QuotientRemainder( minpol, c );
        if IsZero( q[2] ) then
          minpol:= q[1];
          n:= n - phi;
          ord:= Lcm( ord, d );
          if n = 0 then

            # The minimal polynomial is a product of cyclotomic polynomials.
            return ord;

          fi;
        fi;
      fi;

    od;

    # The matrix has infinite order.
    return infinity;
    end );


#############################################################################
##
#M  Order( <ffe-mat> )  . . . . .  order of a matrix of finite field elements
##
InstallMethod( Order, "ordinary matrix of finite field elements", true,
    [ IsOrdinaryMatrix and IsFFECollColl ], 0,
function( mat )
local   o;
  # catch the (unlikely in GL but likely in group theory...) case that mat
  # has a small order

  # the following limit is very crude but seems to work OK. It picks small
  # orders but still does not cost too much if the order gets larger.
  o:=Characteristic(mat[1][1])^DegreeFFE(mat[1][1]); # size of field of
                                                     # first entry
  o:=QuoInt(Length(mat),o)*5; 

  o:=OrderMatTrial(mat,o);
  if o<>fail then
    return o;
  fi;

  o := ProjectiveOrder(mat);
  return o[1] * Order( o[2] );
end );


#############################################################################
##
#M  IsZero( <mat> )
##
InstallMethod( IsZero,
    "method for a matrix",
    true,
    [ IsMatrix ], 0,
    function( mat )

    local ncols,  # number of columns
          zero,   # zero coefficient
          row;    # loop over rows in 'obj'

    ncols:= DimensionsMat( mat )[2];
    zero:= Zero( mat[1][1] );
    for row in mat do
      if PositionNot( row, zero ) <= ncols then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##

#M  AbelianInvariantsOfList( <list> ) . . . . .  abelian invariants of a list
##
InstallMethod( AbelianInvariantsOfList,
    true,
    [ IsCyclotomicCollection ],
    0,

function ( list )
    local   invs, elm;

    invs := [];
    for elm  in list  do
        if elm = 0  then
            Add( invs, 0 );
        elif 1 < elm  then
            Append( invs, List( Collected(FactorsInt(elm)), x->x[1]^x[2] ) );
        elif elm < -1 then
            Append( invs, List( Collected(FactorsInt(-elm)), x->x[1]^x[2] ) );
        fi;
    od;
    Sort(invs);
    return invs;
end );

InstallOtherMethod( AbelianInvariantsOfList,
    true,
    [ IsList and IsEmpty ],
    0,

function( list )
    return [];
end );


#############################################################################
##
#M  BaseMat( <mat> )  . . . . . . . . . .  base for the row space of a matrix
##
InstallMethod( BaseMat,
    "generic method for matrices",
    true,
    [ IsMatrix ],
    0,

function ( mat )
    local  base, m, n, i, k, zero;

    base := [];

    if not IsEmpty( mat ) then

       # make a copy to avoid changing the original argument
       mat := List( mat, ShallowCopy );
      m := Length(mat);
       n := Length(mat[1]);
       zero := Zero( mat[1][1] );

       # triangulize the matrix
       TriangulizeMat( mat );

       # and keep only the nonzero rows of the triangular matrix
       i := 1;
       for k  in [1..n]  do
           if i <= m  and mat[i][k] <> zero  then
               Add( base, mat[i] );
               i := i + 1;
           fi;
       od;

    fi;

    # return the base
    return base;
end );


#############################################################################
##
#M  DefaultFieldOfMatrix( <ffe-mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "method for a matrix over a finite field",
    true,
    [ IsMatrix and IsFFECollColl ],
    0,

function( mat )
    local   deg,  j;

    deg := 1;
    for j  in mat  do
        deg := LcmInt( deg, DegreeFFE(j) );
    od;
    return GF( Characteristic(FamilyObj(mat[1][1])), deg );
end );


#############################################################################
##
#M  DefaultFieldOfMatrix( <cyc-mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "method for a matrix over the cyclotomics",
    true,
    [ IsMatrix and IsCyclotomicCollColl ],
    0,

function( mat )
    local   deg,  j;

    deg := 1;
    for j  in mat  do
        deg := LcmInt( deg, Conductor(j) );
    od;
    return CF( deg );
end );


#############################################################################
##
#M  DepthOfUpperTriangularMatrix( <mat> )
##
InstallMethod( DepthOfUpperTriangularMatrix,
    true,
    [ IsMatrix ],
    0,

function( mat )
    local   dim,  zero,  i,  j;

    # find the correct layer of <m>
    dim  := Length(mat);
    zero := Zero(mat[1][1]);
    for i  in [ 1 .. dim-1 ]  do
        for j  in [ 1 .. dim-i ]  do
            if mat[j][i+j] <> zero  then
                return i;
            fi;
        od;
    od;
    return dim;

end);

InstallOtherMethod( SumIntersectionMat,
  true, [ IsEmpty, IsMatrix ], 0,
function(a,b)
  b:=List(b,ShallowCopy);
  TriangulizeMat(b);
  b:=Filtered(b,i->not IsZero(i));
  return [b,a];
end);

InstallOtherMethod( SumIntersectionMat,
  true, [ IsMatrix, IsEmpty ], 0,
function(a,b)
  a:=List(a,ShallowCopy);
  TriangulizeMat(a);
  a:=Filtered(a,i->not IsZero(i));
  return [a,b];
end);

InstallOtherMethod( SumIntersectionMat,
  IsIdenticalObj, [ IsEmpty, IsEmpty ], 0,
function(a,b)
  return [a,b];
end);


#############################################################################
##
#M  DeterminantMat( <mat> )
##
## Fractions free method, will never introduce denominators
##
## This method is better for cyclotomics, but pivotting is really needed
##
InstallMethod( DeterminantMat,
    "fraction-free method",
    true,
    [ IsOrdinaryMatrix ], 0,
    function ( mat )
    local   det, sgn, row, zero, m, i, j, k, mult, row2, piv;
    
    # check that the argument is a square matrix and get the size
    m := Length(mat);
    zero := Zero(mat[1][1]);
    if m <> Length(mat[1])  then
        Error("DeterminantMat: <mat> must be a square matrix");
    fi;
    
    # make a copy to avoid changing the orginal argument
    mat := List(mat,ShallowCopy);
    
    # run through all columns of the matrix
    i := 0;  det := 1;  sgn := 1;
    for k  in [1..m]  do
        
        # find a nonzero entry in this column
        #N  26-Oct-91 martin if <mat> is an rational matrix look for a pivot
        j := i + 1;
        while j <= m and mat[j][k] = zero  do j := j+1;  od;
        
        # if there is a nonzero entry
        if j <= m  then
            
            # increment the rank
            i := i + 1;
            
            # make its row the current row
            if i <> j  then
                row := mat[j];  mat[j] := mat[i];  mat[i] := row;
                sgn := -sgn;
            else
                row := mat[j];
            fi;
            piv := row[k];
            
            # clear all entries in this column
            # Then divide through by det, this, amazingly, works, due
            #  to a theorem about 3x3 determinants
            for j  in [i+1..m]  do
                row2 := mat[j];
                mult := -row2[k];
                if  mult <> zero then
                    MultRowVector( row2, piv );
                    AddRowVector( row2, row, mult, k, m );
                    MultRowVector( row2, Inverse(det) );
                else
                    MultRowVector( row2, piv/det);
                fi;
            od;

            det := piv;
        else
            return zero;
        fi;
        

    od;

    # return the determinant
    return sgn * det;
end);


#############################################################################
##
#M  DeterminantMat( <mat> )
##
## direct Gaussian elimination, not avoiding denominators
#T  This method at the moment is  better for finite fields
##  another method is installed for cyclotomics. Anything else falls
##  through here also.
##
InstallMethod( DeterminantMat,"non fraction free",
    true, [ IsOrdinaryMatrix and IsFFECollColl], 0,
function( mat )
    local   m,  zero,  det,  sgn,  k,  j,  row,  l,  norm,
            row2, x;

    Info( InfoMatrix, 1, "DeterminantMat called" );

    # check that the argument is a square matrix, and get the size
    m := Length(mat);
    if m <> Length(mat[1])  then
        Error( "<mat> must be a square matrix" );
    fi;
    zero := Zero(mat[1][1]);

    # normalize rows using the inverse
    if IsFFECollColl(mat)  then
        norm := true;
    else
        norm := false;
    fi;

    # make a copy to avoid changing the orginal argument
    mat := List( mat, ShallowCopy );
    det := One(zero);
    sgn := det;

    # run through all columns of the matrix
    for k  in [ 1 .. m ]  do

        # look for a nonzero entry in this column
        j := k;
        while j <= m and mat[j][k] = zero  do
            j := j+1;
        od;

        # if there is a nonzero entry
        if j <= m  then

            # increment the rank, ...
            Info( InfoMatrix, 2, "  nonzero columns: ", k );

            # ... make its row the current row, ...
            if k <> j then
                row    := mat[j];
                mat[j] := mat[k];
                mat[k] := row;
                sgn    := -sgn;
            else
                row := mat[j];
            fi;

            # ... and normalize the row.
            x := row[k];
            det := det * x;
            MultRowVector( mat[k], Inverse(x) );
            
            # clear all entries in this column, adjust only columns > k
            # (Note that we need not clear the rows from 'k+1' to 'j'.)
            for l  in [ j+1 .. m ]  do
                row2 := mat[l];
                x := row2[k];
                if x <> zero then
                    AddRowVector( row2, row, -x, k+1, m );
                fi;
            od;

        # the determinant is zero
        else
            Info( InfoMatrix, 1, "DeterminantMat returns ", zero );
            return zero;
        fi;
    od;
    det := sgn * det;
    Info( InfoMatrix, 1, "DeterminantMat returns ", det );

    # return the determinant
    return det;

end );

#############################################################################
##
#M  DeterminantMat( <mat> )
##
##  This method is now never faster than the other methods.
##
##
#InstallMethod( DeterminantMat,"method for GF(2)",
#    true, [ IsOrdinaryMatrix and IsFFECollColl], 0,
#function(mat)
#  local   det, sgn, row, zero, m, i, j, k, l;
#  # we are only better for GF(2)
#  m:=mat[1][1];
#  if DegreeFFE(m)>1 or Characteristic(m)>2 then
#    TryNextMethod();
#  fi;

#  # the old GAP3 code
#  # check that the argument is a square matrix and get the size
#  m := Length(mat);
#  zero := 0*mat[1][1];
#  if m <> Length(mat[1])  then
#      Error("DeterminantMat: <mat> must be a square matrix");
#  fi;

#  # make a copy to avoid changing the orginal argument
#  mat := ShallowCopy( mat );

#  # run through all columns of the matrix
#  i := 0;  det := 1;  sgn := 1;
#  for k  in [1..m]  do

#      # find a nonzero entry in this column
#      #N  26-Oct-91 martin if <mat> is an rational matrix look for a pivot
#      j := i + 1;
#      while j <= m and mat[j][k] = zero  do j := j+1;  od;

#      # if there is a nonzero entry
#      if j <= m  then

#	  # increment the rank
#	  i := i + 1;

	  # make its row the current row
#	  if i <> j  then
#	      row := mat[j];  mat[j] := mat[i];  mat[i] := row;
#	      sgn := -sgn;
#	  fi;

	  # clear all entries in this column
#	  for j  in [i+1..m]  do
#	      mat[j] := (mat[i][k]*mat[j]-mat[j][k]*mat[i])/det;
#	  od;

#	  det := mat[i][k];
#      fi;

#  od;

  # return the determinant
#  if i < m  then det := zero;  fi;
#  return sgn * det;
#end);


#############################################################################
##
#M  DimensionsMat( <mat> )
##
InstallMethod( DimensionsMat,
    true,
    [ IsMatrix ],
    0,
    A -> [ Length(A), Length(A[1]) ] );

#############################################################################
##
#M  DiagonalizeMat(<integers>,<mat>)
##
InstallMethod( DiagonalizeMat, "over the integers",
    true, [ IsIntegers,IsMatrix  and IsMutable], 0,
    function(I,mat) DiagonalizeIntMat(mat);end);

#############################################################################
##
#M  ElementaryDivisorsMat(<mat>)  . . . . . . elementary divisors of a matrix
##
##  'ElementaryDivisors' returns a list of the elementary divisors, i.e., the
##  unique <d> with '<d>[<i>]' divides '<d>[<i>+1]' and <mat>  is  equivalent
##  to a diagonal matrix with the elements '<d>[<i>]' on the diagonal.
##
InstallMethod( ElementaryDivisorsMat, "generic method for euclidean rings",
    true, [ IsEuclideanRing,IsMatrix ], 0,

function ( ring,mat )
    local  divs, gcd, zero, m, n, i, k;

    # make a copy to avoid changing the original argument
    mat := List( mat, ShallowCopy );
    m := Length(mat);  n := Length(mat[1]);

    # diagonalize the matrix
    DiagonalizeMat(ring, mat );

    # get the diagonal elements
    divs := [];
    for i  in [1..Minimum(m,n)]  do
        divs[i] := mat[i][i];
    od;
    if divs <> []  then zero := divs[1] - divs[1];  fi;

    # transform the divisors so that every divisor divides the next
    for i  in [1..Length(divs)-1]  do
        for k  in [i+1..Length(divs)]  do
            if divs[i] = zero and divs[k] <> zero  then
                divs[i] := divs[k];
                divs[k] := zero;
            elif divs[i] <> zero
              and EuclideanRemainder(ring, divs[k], divs[i] ) <> zero  then
                gcd     := Gcd(ring, divs[i], divs[k] );
                divs[k] := divs[k] / gcd * divs[i];
                divs[i] := gcd;
            fi;
        od;
        divs[i] := StandardAssociate( ring,divs[i] );
    od;

    return divs;
end );

InstallOtherMethod( ElementaryDivisorsMat,
    "compatibility method for integers",
    true, [ IsMatrix ], 0, mat->ElementaryDivisorsMat(Integers,mat));


#############################################################################
##
#F  MutableCopyMat( <mat> )
##
InstallGlobalFunction( MutableCopyMat, mat -> List( mat, ShallowCopy ) );


#############################################################################
##
#F  MutableTransposedMat( <mat> ) . . . . . . . . . .  transposed of a matrix
##
InstallGlobalFunction( MutableTransposedMat, function( mat )
    local trn, n, m, j;

    m:= Length( mat );
    if m = 0 then return []; fi;

    # initialize the transposed
    m:= [ 1 .. m ];
    n:= [ 1 .. Length( mat[1] ) ];
    trn:= [];

    # copy the entries
    for j in n do
      trn[j]:= mat{ m }[j];
      ConvertToVectorRep( trn[j] );
    od;

    # return the transposed
    return trn;
end );


#############################################################################
##
#M  NullspaceMat( <mat> ) . . . . . . basis of solutions of <vec> * <mat> = 0
##
InstallMethod( NullspaceMat,
        "generic method for ordinary matrices",
        true,
        [ IsOrdinaryMatrix ],
        0,
        mat -> SemiEchelonMatTransformation(mat).relations);

InstallMethod(TriangulizedNullspaceMat,"generic method",
  true,[IsOrdinaryMatrix],0,
function ( mat )
    local   nullspace, m, n, min, empty, i, k, row, zero, one;#

    # triangulize the transposed of the matrix
    mat := MutableTransposedMat( Reversed( mat ) );
    TriangulizeMat( mat );
    m := Length(mat);
    n := Length(mat[1]);
    zero := Zero( mat[1][1] );
    one  := One( mat[1][1] );
    min := Minimum( m, n );

    # insert empty rows to bring the leading term of each row on the diagonal
    empty := 0*mat[1];
    i := 1;
    while i <= Length(mat)  do
        if i < n  and mat[i][i] = zero  then
            for k in Reversed([i..Minimum(Length(mat),n-1)])  do
                mat[k+1] := mat[k];
            od;
            mat[i] := empty;
        fi;
        i := i+1;
    od;
    for i  in [ Length(mat)+1 .. n ]  do
        mat[i] := empty;
    od;

    # 'mat' now  looks  like  [ [1,2,0,2], [0,0,0,0], [0,0,1,3], [0,0,0,0] ],
    # and the solutions can be read in those columns with a 0 on the diagonal
    # by replacing this 0 by a -1, in  this  example  [2,-1,0,0], [2,0,3,-1].
    nullspace := [];
    for k  in Reversed([1..n]) do
        if mat[k][k] = zero  then
            row := [];
            for i  in [1..k-1]  do row[n-i+1] := -mat[i][k];  od;
            row[n-k+1] := one;
            for i  in [k+1..n]  do row[n-i+1] := zero;  od;
            ConvertToVectorRep( row );
            Add( nullspace, row );
        fi;
    od;

    return nullspace;
end );


#############################################################################
##
#M  ProjectiveOrder( <mat> )  . . . . . . . . . . . . . . . order mod scalars
##
InstallMethod( ProjectiveOrder,
    "ordinary matrix of finite field elements",
    true,
    [ IsOrdinaryMatrix and IsFFECollColl ],
    0,

function( mat )
    local   p,  c;

    # construct the minimal polynomial of <A>
    p := MinimalPolynomial( DefaultFieldOfMatrix(mat), mat );

    # check if <A> is invertible
    c := CoefficientsOfUnivariatePolynomial(p);
    if c[1] = Zero(c[1])  then
        Error( "matrix <mat> must be invertible" );
    fi;

    # compute the order of <p>
    return ProjectiveOrder(p);
end );


#############################################################################
##
#M  RankMat( <mat> )  . . . . . . . . . . . . . . . . . . .  rank of a matrix
##
InstallMethod( RankMat,
    "generic method for matrices",
    true,
    [ IsMatrix ],
    0,
        function(mat)
    local n,i,z,j,t,rk,k,piv,row,x,m;

    # make a copy to avoid changing the original argument
    m := Length(mat);
    n := Length(mat[1]);
    z := Zero(mat[1][1]);
    mat := List(mat, ShallowCopy);

    # run through all columns of the matrix
    rk := 0;
    for i in [1..n] do

        # find a nonzero entry in this column
        #N  26-Oct-91 martin if <mat> is a rational matrix look for a pivot
        j := rk+1;
        while j <= m and mat[j][i] = z  do
            j := j+1;
        od;

        # if there is a nonzero entry
        if (j <= m) then

            # increment the rank
            rk := rk+1;

            # make its row the current row
            t := mat[j];
            if j > rk then
                mat[j] := mat[rk];
                mat[rk] := t;
            fi;

            # clear all entries below in this column
            # (if possible, otherwise return `fail')
            piv := Inverse(t[i]);
            if piv = fail then
              return fail;
            fi;
            piv := - piv;
            for k in [rk+1..m] do
                row := mat[k];
                x := row[i];
                if x <> z then
                    AddRowVector(row,t,piv*x);
                fi;
            od;
        fi;
    od;

    # return the rank (the number of linear independent rows)
    return rk;
end);


#############################################################################
##
#M  SemiEchelonMat( <mat> )
##
InstallMethod( SemiEchelonMat,
    "generic method for matrices",
    true,
    [ IsMatrix ],
    0,
    function( mat )

    local zero,      # zero of the field of <mat>
          nrows,     # number of rows in <mat>
          ncols,     # number of columns in <mat>
          vectors,   # list of basis vectors
          heads,     # list of pivot positions in 'vectors'
          i,         # loop over rows
          j,         # loop over columns
          x,         # a current element
          nzheads,   # list of non-zero heads
          row;       # the row of current interest
    

    mat:= List( mat, ShallowCopy );
    nrows:= Length( mat );
    ncols:= Length( mat[1] );

    zero:= Zero( mat[1][1] );

    heads:= ListWithIdenticalEntries( ncols, 0 );
    nzheads := [];
    vectors := [];

    for i in [ 1 .. nrows ] do
        
        row := mat[i];
        # Reduce the row with the known basis vectors.
        for j in [ 1 .. Length(nzheads) ] do
            x := row[nzheads[j]];
            if x <> zero then
                AddRowVector( row, vectors[ j ], - x );
            fi;
        od;

        j := PositionNot( row, zero );
        if j <= ncols then

            # We found a new basis vector.
            MultRowVector(row, Inverse(row[j]));
            Add( vectors, row );
            Add( nzheads, j);
            heads[j]:= Length( vectors );

        fi;

    od;

    return rec( heads   := heads,
                vectors := vectors );
    end );


#############################################################################
##
#M  SemiEchelonMatTransformation( <mat> )
##
InstallMethod( SemiEchelonMatTransformation,
    "generic method for matrices",
    true,
    [ IsMatrix ],
    0,

function( mat )

    local zero,      # zero of the field of <mat>
          nrows,     # number of rows in <mat>
          ncols,     # number of columns in <mat>
          vectors,   # list of basis vectors
          heads,     # list of pivot positions in 'vectors'
          i,         # loop over rows
          j,         # loop over columns
          T,         # transformation matrix
          coeffs,    # list of coefficient vectors for 'vectors'
          relations, # basis vectors of the null space of 'mat'
          row, head, x, row2;

    mat:= List( mat, ShallowCopy );
    nrows := Length( mat );
    ncols := Length( mat[1] );

    zero  := Zero( mat[1][1] );

    heads   := ListWithIdenticalEntries( ncols, 0 );
    vectors := [];

    T         := IdentityMat( nrows, zero );
    coeffs    := [];
    relations := [];

    for i in [ 1 .. nrows ] do
        
        row := mat[i];
        row2 := T[i];
        
        # Reduce the row with the known basis vectors.
        for j in [ 1 .. ncols ] do
            head := heads[j];
            if head <> 0 then
                x := - row[j];
                if x <> zero then
                    AddRowVector( row2  , coeffs[ head ] , x );
                    AddRowVector( row,    vectors[ head ], x );
                fi;
            fi;
        od;

        j:= PositionNot( row, zero );
        if j <= ncols then

            # We found a new basis vector.
            Add( coeffs,  row2   / row[j] );
            Add( vectors, row / row[j] );
            heads[j]:= Length( vectors );

        else
            Add( relations, row2 );
        fi;

    od;

    return rec( heads     := heads,
                vectors   := vectors,
                coeffs    := coeffs,
                relations := relations );
end );


InstallMethod( SemiEchelonMatTransformation,
        "special method for GF(2)",
        true,
        [ IsMatrix and IsMutable and IsFFECollColl and IsGF2MatrixRep],
        0,

function( mat )

    local zero,      # zero of the field of <mat>
          nrows,     # number of rows in <mat>
          ncols,     # number of columns in <mat>
          vectors,   # list of basis vectors
          heads,     # list of pivot positions in 'vectors'
          i,         # loop over rows
          j,         # loop over columns
          T,         # transformation matrix
          coeffs,    # list of coefficient vectors for 'vectors'
          relations, # basis vectors of the null space of 'mat'
          row, head, row2;

    mat:= List( mat, ShallowCopy );
    nrows := Length( mat );
    ncols := Length( mat[1] );

    zero  := 0*Z(2);

    heads   := ListWithIdenticalEntries( ncols, 0 );
    vectors := [];

    T         := IdentityMat( nrows, GF(2) );
    coeffs    := [];
    relations := [];

    for i in [ 1 .. nrows ] do
        
        row := mat[i];
        row2 := T[i];
        
        # Reduce the row with the known basis vectors.
        for j in [ 1 .. ncols ] do
            head := heads[j];
            if head <> 0 then
                if row[j] <> zero then
                    AddRowVector( row2  , coeffs[ head ] );
                    AddRowVector( row,    vectors[ head ]);
                fi;
            fi;
        od;

        j:= PositionNot( row, zero );
        if j <= ncols then

            # We found a new basis vector.
            Add( coeffs,  row2 );
            Add( vectors, row  );
            heads[j]:= Length( vectors );

        else
            Add( relations, row2 );
        fi;

    od;

    return rec( heads     := heads,
                vectors   := vectors,
                coeffs    := coeffs,
                relations := relations );
end );


#############################################################################
##
#M  SemiEchelonMats( <mats> )
##
InstallGlobalFunction( SemiEchelonMats, function( mats )

    local zero,      # zero coefficient
          m,         # number of rows
          n,         # number of columns
          v,
          vectors,   # list of matrices in the echelonized basis
          heads,     # list with info about leading entries
          mat,       # loop over generators of 'V'
          i, j,      # loop over rows and columns of the matrix
          k,
          scalar;

    zero:= Zero( mats[1][1][1] );
    m:= Length( mats[1]    );
    n:= Length( mats[1][1] );

    # Compute an echelonized basis.
    vectors := [];
    heads   := ListWithIdenticalEntries( n, 0 );
    heads   := List( [ 1 .. m ], x -> ShallowCopy( heads ) );

    for mat in mats do

      # Reduce the matrix modulo 'ech'.
      mat:= List( mat, ShallowCopy );
      for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do
          if heads[i][j] <> 0 and mat[i][j] <> zero then

            # Compute 'mat:= mat - mat[i][j] * vectors[ heads[i][j] ];'
            scalar:= - mat[i][j];
            v:= vectors[ heads[i][j] ];
            for k in [ 1 .. m ] do
              AddRowVector( mat[k], v[k], scalar );
            od;

          fi;
        od;
      od;

      # Get the first nonzero column.
      i:= 1;
      j:= PositionNot( mat[1], zero );
      while n < j and i < m do
        i:= i + 1;
        j:= PositionNot( mat[i], zero );
      od;

      if j <= n then

        # We found a new basis vector.
        Add( vectors, mat / mat[i][j] );
        heads[i][j]:= Length( vectors );

      fi;

    od;

    # Return the result.
    return rec(
                vectors := vectors,
                heads   := heads
               );
end );


#############################################################################
##
#M  TransposedMat( <mat> )  . . . . . . . . . . . . .  transposed of a matrix
##
InstallMethod( TransposedMat,
    "generic method for matrices",
    true,
    [ IsMatrix ],
    0,
    MutableTransposedMat );

InstallOtherMethod(TransposedMat,
  "method for empty matrices",true,[IsList],0,
function(mat)
  if mat<>[] and mat<>[[]] then
    TryNextMethod();
  fi;
  return mat;
end);


############################################################################
##

#M  IsMonomialMatrix( <mat> )
##
InstallMethod( IsMonomialMatrix,
    "generic method for matrices",
    true,
    [ IsMatrix ],
    0,

function( M )

    local zero,  # zero of the base ring
          len,   # length of rows
          found, # store positions of nonzero elements
          row,   # loop over rows
          j;     # position of first non-zero element

    zero:= Zero(M[1][1]);
    len:= Length( M[1] );
    if Length( M ) <> len  then
        return false;
    fi;
    found:= BlistList( M, [] );
    for row  in M  do
        j := PositionNot( row, zero );
        if len < j or found[j]  then
            return false;
        fi;
        if PositionNot( row, zero, j ) <= len  then
            return false;
        fi;
        found[j] := true;
    od;
    return true;
end );


##########################################################################
##
#M  InverseMatMod( <cyc-mat>, <integer> )
##
InstallMethod( InverseMatMod,
    "generic method for matrix and integer",
    IsCollCollsElms,
    [ IsMatrix,
      IsInt ],
    0,

function( mat, m )
    local   n,  MM,  inv,  perm,  i,  pj,  elem,  liste,  l;

    if Length(mat) <> Length(mat[1])  then
        Error( "<mat> must be a square matrix" );
    fi;

    n  := Length(mat);
    MM := List( mat, x -> List( x, y -> y mod m ) );

    # construct the identity matrix
    inv := IdentityMat( n, Cyclotomics );
    perm := [];

    # loop over the rows
    for i  in [ 1 .. n ]  do

        pj := 1;
        while MM[i][pj] = 0  do
            pj := pj + 1;
            if pj > n then
                Error( "<mat> is not invertible mod <m>" );
            fi;
        od;
        perm[pj] := i;
        elem   := MM[i][pj];
        MM[i]  := List( MM[i],  x -> (x/elem) mod m );
        inv[i] := List( inv[i], x -> (x/elem) mod m );

        liste  := [ 1 .. i-1 ];
        Append( liste, [i+1..n] );
        for l in liste do
            elem   := MM[l][pj];
            MM[l]  := MM[l] - MM[i] * elem;
            MM[l]  := List( MM[l], x -> x mod m );
            inv[l] := inv[l] - inv[i] * elem;
            inv[l] := List( inv[l], x -> x mod m );
        od;
    od;
    return List( perm, i->inv[i] );
end );


#############################################################################
##
#M  KroneckerProduct( <mat1>, <mat2> )
##
InstallMethod( KroneckerProduct,
    "generic method for matrices",
    IsIdenticalObj,
    [ IsMatrix,
      IsMatrix ],
    0,

function ( mat1, mat2 )
    local i, row1, row2, row, kroneckerproduct;
    kroneckerproduct := [];
    for row1  in mat1  do
        for row2  in mat2  do
            row := [];
            for i  in row1  do
                Append( row, i * row2 );
            od;
#T application of the new 'AddRowVector' function?
            ConvertToVectorRep( row );
            Add( kroneckerproduct, row );
        od;
    od;
    return kroneckerproduct;
end );


#############################################################################
##
#M  SolutionMat( <mat>, <vec> ) . . . . . . . . . .  one solution of equation
##
##  One solution <x> of <x> * <mat> = <vec> or `fail'.
##
InstallMethod( SolutionMat,
    "generic method for ordinary matrix and vector",
    IsCollsElms,
    [ IsOrdinaryMatrix,
      IsRowVector ],
    0,

function ( mat, vec )
    local   h, v, tmp, i, l, r, s, c, zero;

    # Transpose <mat> and solve <mat> * x = <vec>.
    mat  := MutableTransposedMat( mat );
    vec  := ShallowCopy( vec );
    l    := Length( mat );
    r    := 0;
    zero := Zero( mat[1][1] );
    Info( InfoMatrix, 1, "SolutionMat called" );

    # Run through all columns of the matrix.
    c := 1;
    while c <= Length( mat[ 1 ] ) and r < l  do

        # Find a nonzero entry in this column.
        s := r + 1;
        while s <= l and mat[ s ][ c ] = zero  do s := s + 1;  od;

        # If there is a nonzero entry,
        if s <= l  then

            # increment the rank.
            Info( InfoMatrix, 2, "  nonzero columns ", c );
            r := r + 1;

            # Make its row the current row and normalize it.
            tmp := mat[ s ][ c ] ^ -1;
            v := mat[ s ];  mat[ s ] := mat[ r ];  mat[ r ] := tmp * v;
            v := vec[ s ];  vec[ s ] := vec[ r ];  vec[ r ] := tmp * v;

            # Clear all entries in this column.
            for s  in [ 1 .. Length( mat ) ]  do
                if s <> r and mat[ s ][ c ] <> zero  then
                    tmp := mat[ s ][ c ];
                    mat[ s ] := mat[ s ] - tmp * mat[ r ];
                    vec[ s ] := vec[ s ] - tmp * vec[ r ];
                fi;
            od;
        fi;
        c := c + 1;
    od;

    # Find a solution.
    for i  in [ r + 1 .. l ]  do
        if vec[ i ] <> zero  then return fail;  fi;
    od;
    h := [];
    s := Length( mat[ 1 ] );
    v := Zero( mat[ 1 ][ 1 ] );
    r := 1;
    c := 1;
    while c <= s and r <= l  do
        while c <= s and mat[ r ][ c ] = zero  do
            c := c + 1;
            Add( h, v );
        od;
        if c <= s  then
            Add( h, vec[ r ] );
            r := r + 1;
            c := c + 1;
        fi;
    od;
    while c <= s  do Add( h, v );  c := c + 1;  od;

    Info( InfoMatrix, 1, "SolutionMat returns" );
    return h;
end );


############################################################################
##
#M  SumIntersectionMat( <M1>, <M2> )  . .  sum and intersection of two spaces
##
##  performs  Zassenhaus' algorithm to  compute bases   for the  sum and  the
##  intersection of spaces generated by the rows of the matrices <M1>, <M2>.
##
##  returns a   list of length 2,   at first position  a base  of the sum, at
##  second position   a base  of    the intersection.   Both bases    are  in
##  semi-echelon form.
##
InstallMethod( SumIntersectionMat,
    IsIdenticalObj,
    [ IsMatrix,
      IsMatrix ],
    0,

function( M1, M2 )

    local n,      # number of columns
          mat,    # matrix for Zassenhaus algorithm
          zero,   # zero vector
          v,      # loop over 'M1' and 'M2'
          heads,  # list of leading positions
          sum,    # base of the sum
          i,      # loop over rows of 'mat'
          int;    # base of the intersection

    if   Length( M1 ) = 0 then
      return [ M2, M1 ];
    elif Length( M2 ) = 0 then
      return [ M1, M2 ];
    elif Length( M1[1] ) <> Length( M2[1] ) then
      Error( "dimensions of matrices are not compatible" );
    elif Zero( M1[1][1] ) <> Zero( M2[1][1] ) then
      Error( "fields of matrices are not compatible" );
    fi;

    n:= Length( M1[1] );
    mat:= [];
    zero:= Zero( M1[1] );

    # Set up the matrix for Zassenhaus' algorithm.
    mat:= [];
    for v in M1 do
      v:= ShallowCopy( v );
      Append( v, v );
      ConvertToVectorRep( v );
      Add( mat, v );
    od;
    for v in M2 do
      v:= ShallowCopy( v );
      Append( v, zero );
      ConvertToVectorRep( v );
      Add( mat, v );
    od;

    # Transform `mat' into semi-echelon form.
    mat   := SemiEchelonMat( mat );
    heads := mat.heads;
    mat   := mat.vectors;

    # Extract the bases for the sum \ldots
    sum:= [];
    for i in [ 1 .. n ] do
      if heads[i] <> 0 then
        Add( sum, mat[ heads[i] ]{ [ 1 .. n ] } );
      fi;
    od;

    # \ldots and the intersection.
    int:= [];
    for i in [ n+1 .. Length( heads ) ] do
      if heads[i] <> 0 then
        Add( int, mat[ heads[i] ]{ [ n+1 .. 2*n ] } );
      fi;
    od;

    # return the result
    return [ sum, int ];
end );


#############################################################################
##
#M  TriangulizeMat( <mat> ) . . . . . bring a matrix in upper triangular form
##
InstallMethod( TriangulizeMat,
    "generic method for mutable matrices",
    true,
    [ IsMatrix and IsMutable ],
    0,

function ( mat )
    local   m, n, i, j, k, row, zero, x, row2;

    Info( InfoMatrix, 1, "TriangulizeMat called" );

    if not IsEmpty( mat ) then

       # get the size of the matrix
       m := Length(mat);
       n := Length(mat[1]);
       zero := Zero( mat[1][1] );

       # make sure that the rows are mutable
       for i in [ 1 .. m ] do
         if not IsMutable( mat[i] ) then
           mat[i]:= ShallowCopy( mat[i] );
         fi;
       od;

       # run through all columns of the matrix
       i := 0;
       for k  in [1..n]  do

           # find a nonzero entry in this column
           j := i + 1;
           while j <= m and mat[j][k] = zero  do j := j + 1;  od;

           # if there is a nonzero entry
           if j <= m  then

               # increment the rank
               Info( InfoMatrix, 2, "  nonzero columns: ", k );
               i := i + 1;

               # make its row the current row and normalize it
               row    := mat[j];
               mat[j] := mat[i];
               MultRowVector( row, Inverse(row[k]) );
               mat[i] := row;

               # clear all entries in this column
               for j  in [1..i-1] do
                   row2 := mat[j];
                   x := row2[k];
                   if   x <> zero  then
                       AddRowVector( row2, row, - x );
                   fi;
               od;
               for j  in [i+1..m] do
                   row2 := mat[j];
                   x := row2[k];
                   if   x <> zero  then
                       AddRowVector( row2, row, - x );
                   fi;
               od;

           fi;

       od;

    fi;

    Info( InfoMatrix, 1, "TriangulizeMat returns" );
end );

# special method to cope with 0-dimensional matrices
InstallOtherMethod(TriangulizeMat,"empty list",true,
  [IsList and IsEmpty and IsPlistRep],0,Ignore);

InstallOtherMethod( TriangulizeMat,
  "error message for immutable matrices", true, [ IsMatrix ], 0,
function(m)
  if IsMutable(m) and ForAll(m,IsMutable) then
    TryNextMethod();
  else
    Error("The matrix <m> must be mutable to be triangulizable");
  fi;
end);

#############################################################################
##
#M  TriangulizeMat( <mat> ) . . . . . bring a matrix in upper triangular form
##
InstallGlobalFunction(TriangulizeMatGF2,function ( mat )
    local   m, n, i, j, k, row, zero;

    if Length(mat) > 0 then 

       # get the size of the matrix
       m := Length(mat);
       n := Length(mat[1]);
       zero := 0*Z(2);
   
        # make sure that the rows are mutable
       for i in [ 1 .. m ] do
           if not IsMutable( mat[i] ) then
               mat[i]:= ShallowCopy( mat[i] );
           fi;
       od;
     
     # run through all columns of the matrix
       i := 0;
       for k  in [1..n]  do
   
           # find a nonzero entry in this column
           j := i + 1;
           while j <= m and mat[j][k] = zero  do j := j + 1;  od;
   
           # if there is a nonzero entry
           if j <= m  then
   
               # increment the rank
               i := i + 1;
   
               row := mat[j];  mat[j] := mat[i];  mat[i] := row;
   
               # clear all entries in this column
               for j  in [1..i-1] do
                   if  mat[j][k] <> zero  then
                       AddRowVector(mat[j],row);
                   fi;
               od;
               for j  in [i+1..m] do
                   if  mat[j][k] <> zero  then
                       AddRowVector(mat[j],row);
                   fi;
               od;
   
           fi;
   
       od;
   
    fi;

end);

InstallMethod( TriangulizeMat, "method for matrices of packed GF2-vectors",
 true, [ IsMatrix and IsMutable and IsFFECollColl], 0,
function ( mat )
 if not ForAll(mat,IsGF2VectorRep) then
    TryNextMethod();
  fi;
  TriangulizeMatGF2(mat);
end);

InstallMethod( TriangulizeMat, "method GF(2) matrices",
  true, [ IsMatrix and IsMutable and IsFFECollColl and IsGF2MatrixRep], 10,
  TriangulizeMatGF2);




#############################################################################
##
#M  UpperSubdiagonal( <mat>, <pos> )
##
InstallMethod( UpperSubdiagonal,
    true,
    [ IsMatrix,
      IsPosInt ],
    0,

function( mat, l )
    local   dim,  exp,  i;

    # collect exponents in <e>
    dim := Length(mat);
    exp := [];

    # run through the diagonal
    for i  in [ 1 .. dim-l ]  do
        Add( exp, mat[i][l+i] );
    od;

    # and return
    return exp;

end );


#############################################################################
##

#F  BaseFixedSpace( <mats> )  . . . . . . . . . . . .  calculate fixed points
##
##  'BaseFixedSpace' returns a base of the vector space $V$ such that
##  $M v = v$ for all $v$ in $V$ and all matrices $M$ in the list <mats>.
##
InstallGlobalFunction( BaseFixedSpace, function( matrices )

    local I,            # identity matrix
          size,         # dimension of vector space
          E,            # linear system
          M,            # one matrix of 'matrices'
          N,            # M - I
          j;

    I := matrices[1]^0;
    size := Length(I);
    E := List( [ 1 .. size ], x -> [] );
    for M  in matrices  do
        N := M - I;
        for j  in [ 1..size ]  do
            Append( E[ j ], N[ j ] );
        od;
    od;
    return NullspaceMat( E );
end );


##########################################################################
##
#F  BaseSteinitzVectors( <bas>, <mat> )
##
##  find vectors extending mat to a basis spanning the span of <bas>.
##  'BaseSteinitz'  returns a
##  record  describing  a base  for the factorspace   and ways   to decompose
##  vectors:
##
##  zero:           zero of <V> and <U>
##  factorzero:     zero of complement
##  subspace:       triangulized basis of <mat>
##  factorspace:    base of a complement of <U> in <V>
##  heads:          a list of integers i_j, such that  if i_j>0 then a vector
##                  with head j is at position i_j  in factorspace.  If i_j<0
##                  then the vector is in subspace.
##
##
InstallGlobalFunction( BaseSteinitzVectors, function(bas,mat)
local z,l,b,i,j,k,stop,v,dim,h,zv;

  # catch trivial case
  if Length(bas)=0 then
    return rec(subspace:=[],factorspace:=[]);
  fi;

  z:=Zero(bas[1][1]);
  zv:=Zero(bas[1]);
  if Length(mat)>0 then
    mat:=List(mat,ShallowCopy);
    TriangulizeMat(mat);
  fi;
  bas:=List(bas,ShallowCopy);
  dim:=Length(bas[1]);
  l:=Length(bas)-Length(mat); # missing dimension
  b:=[];
  h:=[];
  i:=1;
  j:=1;
  while Length(b)<l do
    stop:=false;
    repeat
      if j<=dim and (Length(mat)<i or mat[i][j]=z) then
	# Add vector from bas with j-th component not zero (if any exists)
        v:=PositionProperty(bas,k->k[j]<>z);
	if v<>fail then
	  # add the vector
	  v:=bas[v];
	  v:=1/v[j]*v; # normed
	  Add(b,v);
	  h[j]:=Length(b);
	# if fail, then this dimension is only dependent (and not needed)
        fi;
      else
        stop:=true;
	# check whether we are running to fake zero columns
	if i<=Length(mat) then
	  # has a step, clean with basis vector
	  v:=mat[i];
	  v:=1/v[j]*v; # normed
	  h[j]:=-i;
        else
	  v:=fail;
	fi;
      fi;
      if v<>fail then
	# clean j-th component from bas with v
	for k in [1..Length(bas)] do
	  bas[k]:=bas[k]-bas[k][j]/v[j]*v;
	od;
	v:=Zero(v);
	bas:=Filtered(bas,k->k<>v);
      fi;
      j:=j+1;
    until stop;
    i:=i+1;
  od;
  # add subspace indices
  while i<=Length(mat) do
    if mat[i][j]<>z then
      h[j]:=-i;
      i:=i+1;
    fi;
    j:=j+1;
  od;
  return rec(factorspace:=b,
             factorzero:=zv,
	     subspace:=mat,
	     heads:=h);
end );


#############################################################################
##
#F  BlownUpMat( <B>, <mat> )
##
InstallGlobalFunction( BlownUpMat, function ( B, mat )

    local result,  # blown up matrix, result
          vectors, # basis vectors of 'B'
          row,     # loop over rows of 'mat'
          b,       # loop over 'vectors'
          resrow,  # one row of 'result'
          entry;   # loop over 'row'

    vectors:= BasisVectors( B );
    result:= [];
    for row in mat do
      for b in vectors do
        resrow:= [];
        for entry in row do
          Append( resrow, Coefficients( B, entry * b ) );
        od;
        ConvertToVectorRep( resrow );
        Add( result, resrow );
      od;
    od;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  BlownUpVector( <B>, <vector> )
##
InstallGlobalFunction( BlownUpVector, function ( B, vector )

    local result,  # blown up vector, result
          entry;   # loop over 'vector'

    result:= [];
    for entry in vector do
      Append( result, Coefficients( B, entry ) );
    od;
    ConvertToVectorRep( result );

    # Return the result.
    return result;
end );


#############################################################################
##
#F  DiagonalizeIntMatNormDriven(<mat>)  . . . . diagonalize an integer matrix
##
##  'DiagonalizeIntMatNormDriven'  diagonalizes  the  integer  matrix  <mat>.
##
##  It tries to keep the entries small  through careful  selection of pivots.
##
##  First it selects a nonzero entry for which the  product of row and column
##  norm is minimal (this need not be the entry with minimal absolute value).
##  Then it brings this pivot to the upper left corner and makes it positive.
##
##  Next it subtracts multiples of the first row from the other rows, so that
##  the new entries in the first column have absolute value at most  pivot/2.
##  Likewise it subtracts multiples of the 1st column from the other columns.
##
##  If afterwards not  all new entries in the  first column and row are zero,
##  then it selects a  new pivot from those  entries (again driven by product
##  of norms) and reduces the first column and row again.
##
##  If finally all offdiagonal entries in the first column  and row are zero,
##  then it  starts all over again with the submatrix  '<mat>{[2..]}{[2..]}'.
##
##  It is  based  upon  ideas by  George Havas  and code by  Bohdan Majewski.
##  G. Havas and B. Majewski, Integer Matrix Diagonalization, JSC, to appear
##
#T  Should this test for mutability? SL

InstallGlobalFunction( DiagonalizeIntMatNormDriven, function ( mat )
    local   nrrows,     # number of rows    (length of <mat>)
            nrcols,     # number of columns (length of <mat>[1])
            rownorms,   # norms of rows
            colnorms,   # norms of columns
            d,          # diagonal position
            pivk, pivl, # position of a pivot
            norm,       # product of row and column norms of the pivot
            clear,      # are the row and column cleared
            row,        # one row
            col,        # one column
            ent,        # one entry of matrix
            quo,        # quotient
            h,          # gap width in shell sort
            k, l,       # loop variables
            max, omax;  # maximal entry and overall maximal entry

    # give some information
    Info( InfoMatrix, 1, "DiagonalizeMat called" );
    omax := 0;

    # get the number of rows and columns
    nrrows := Length( mat );
    if nrrows <> 0  then
        nrcols := Length( mat[1] );
    else
        nrcols := 0;
    fi;
    rownorms := [];
    colnorms := [];

    # loop over the diagonal positions
    d := 1;
    Info( InfoMatrix, 2, "  divisors:" );

    while d <= nrrows and d <= nrcols  do

        # find the maximal entry
        Info( InfoMatrix, 3, "    d=", d );
        if 3 <= InfoLevel( InfoMatrix ) then
            max := 0;
            for k  in [ d .. nrrows ]  do
                for l  in [ d .. nrcols ]  do
                    ent := mat[k][l];
                    if   0 < ent and max <  ent  then
                        max :=  ent;
                    elif ent < 0 and max < -ent  then
                        max := -ent;
                    fi;
                od;
            od;
            Info( InfoMatrix, 3, "    max=", max );
            if omax < max  then omax := max;  fi;
        fi;

        # compute the Euclidean norms of the rows and columns
        for k  in [ d .. nrrows ]  do
            row := mat[k];
            rownorms[k] := row * row;
        od;
        for l  in [ d .. nrcols ]  do
            col := mat{[d..nrrows]}[l];
            colnorms[l] := col * col;
        od;
        Info( InfoMatrix, 3, "    n" );

        # push rows containing only zeroes down and forget about them
        for k  in [ nrrows, nrrows-1 .. d ]  do
            if k < nrrows and rownorms[k] = 0  then
                row         := mat[k];
                mat[k]      := mat[nrrows];
                mat[nrrows] := row;
                norm             := rownorms[k];
                rownorms[k]      := rownorms[nrrows];
                rownorms[nrrows] := norm;
            fi;
            if rownorms[nrrows] = 0  then
                nrrows := nrrows - 1;
            fi;
        od;

        # quit if there are no more nonzero entries
        if nrrows < d  then
            #N  1996/04/30 mschoene should 'break'
            Info( InfoMatrix, 3, "  overall maximal entry ", omax );
            Info( InfoMatrix, 1, "DiagonalizeMat returns" );
            return;
        fi;

        # push columns containing only zeroes right and forget about them
        for l  in [ nrcols, nrcols-1 .. d ]  do
            if l < nrcols and colnorms[l] = 0  then
                col                      := mat{[d..nrrows]}[l];
                mat{[d..nrrows]}[l]      := mat{[d..nrrows]}[nrcols];
                mat{[d..nrrows]}[nrcols] := col;
                norm             := colnorms[l];
                colnorms[l]      := colnorms[nrcols];
                colnorms[nrcols] := norm;
            fi;
            if colnorms[nrcols] = 0  then
                nrcols := nrcols - 1;
            fi;
        od;

        # sort the rows with respect to their norms
        h := 1;  while 9 * h + 4 < nrrows-(d-1)  do h := 3 * h + 1;  od;
        while 0 < h  do
            for l  in [ h+1 .. nrrows-(d-1) ]  do
                norm := rownorms[l+(d-1)];
                row := mat[l+(d-1)];
                k := l;
                while h+1 <= k  and norm < rownorms[k-h+(d-1)]  do
                    rownorms[k+(d-1)] := rownorms[k-h+(d-1)];
                    mat[k+(d-1)] := mat[k-h+(d-1)];
                    k := k - h;
                od;
                rownorms[k+(d-1)] := norm;
                mat[k+(d-1)] := row;
            od;
            h := QuoInt( h, 3 );
        od;

        # choose a pivot in the '<mat>{[<d>..]}{[<d>..]}' submatrix
        # the pivot must be the topmost nonzero entry in its column,
        # now that the rows are sorted with respect to their norm
        pivk := 0;  pivl := 0;
        norm := Maximum(rownorms) * Maximum(colnorms) + 1;
        for l  in [ d .. nrcols ]  do
            k := d;
            while mat[k][l] = 0  do
                k := k + 1;
            od;
            if rownorms[k] * colnorms[l] < norm  then
                pivk := k;  pivl := l;
                norm := rownorms[k] * colnorms[l];
            fi;
        od;
        Info( InfoMatrix, 3, "    p" );

        # move the pivot to the diagonal and make it positive
        if d <> pivk  then
            row       := mat[d];
            mat[d]    := mat[pivk];
            mat[pivk] := row;
        fi;
        if d <> pivl  then
            col                    := mat{[d..nrrows]}[d];
            mat{[d..nrrows]}[d]    := mat{[d..nrrows]}[pivl];
            mat{[d..nrrows]}[pivl] := col;
        fi;
        if mat[d][d] < 0  then
            MultRowVector(mat[d],-1);
        fi;

        # now perform row operations so that the entries in the
        # <d>-th column have absolute value at most pivot/2
        clear := true;
        row := mat[d];
        for k  in [ d+1 .. nrrows ]  do
            quo := BestQuoInt( mat[k][d], mat[d][d] );
            if quo = 1  then
                AddRowVector(mat[k], row, -1);
            elif quo = -1  then
                AddRowVector(mat[k], row);
            elif quo <> 0  then
                AddRowVector(mat[k], row, -quo);
            fi;
            clear := clear and mat[k][d] = 0;
        od;
        Info( InfoMatrix, 3, "    c" );

        # now perform column operations so that the entries in
        # the <d>-th row have absolute value at most pivot/2
        col := mat{[d..nrrows]}[d];
        for l  in [ d+1 .. nrcols ]  do
            quo := BestQuoInt( mat[d][l], mat[d][d] );
            if quo = 1  then
                mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - col;
            elif quo = -1  then
                mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] + col;
            elif quo <> 0  then
                mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - quo * col;
            fi;
            clear := clear and mat[d][l] = 0;
        od;
        Info( InfoMatrix, 3, "    r" );

        # repeat until the <d>-th row and column are totally cleared
        while not clear  do

            # compute the Euclidean norms of the rows and columns
            # that have a nonzero entry in the <d>-th column resp. row
            for k  in [ d .. nrrows ]  do
                if mat[k][d] <> 0  then
                    row := mat[k];
                    rownorms[k] := row * row;
                fi;
            od;
            for l  in [ d .. nrcols ]  do
                if mat[d][l] <> 0  then
                    col := mat{[d..nrrows]}[l];
                    colnorms[l] := col * col;
                fi;
            od;
            Info( InfoMatrix, 3, "    n" );

            # choose a pivot in the <d>-th row or <d>-th column
            pivk := 0;  pivl := 0;
            norm := Maximum(rownorms) * Maximum(colnorms) + 1;
            for l  in [ d+1 .. nrcols ]  do
                if 0 <> mat[d][l] and rownorms[d] * colnorms[l] < norm  then
                    pivk := d;  pivl := l;
                    norm := rownorms[d] * colnorms[l];
                fi;
            od;
            for k  in [ d+1 .. nrrows ]  do
                if 0 <> mat[k][d] and rownorms[k] * colnorms[d] < norm  then
                    pivk := k;  pivl := d;
                    norm := rownorms[k] * colnorms[d];
                fi;
            od;
            Info( InfoMatrix, 3, "    p" );

            # move the pivot to the diagonal and make it positive
            if d <> pivk  then
                row       := mat[d];
                mat[d]    := mat[pivk];
                mat[pivk] := row;
            fi;
            if d <> pivl  then
                col                    := mat{[d..nrrows]}[d];
                mat{[d..nrrows]}[d]    := mat{[d..nrrows]}[pivl];
                mat{[d..nrrows]}[pivl] := col;
            fi;
            if mat[d][d] < 0  then
                MultRowVector(mat[d],-1);
            fi;

            # now perform row operations so that the entries in the
            # <d>-th column have absolute value at most pivot/2
            clear := true;
            row := mat[d];
            for k  in [ d+1 .. nrrows ]  do
                quo := BestQuoInt( mat[k][d], mat[d][d] );
	        if quo = 1  then
                    AddRowVector(mat[k],row,-1);
                elif quo = -1  then
                    AddRowVector(mat[k],row);
                elif quo <> 0  then
                    AddRowVector(mat[k], row, -quo);
                fi;
                clear := clear and mat[k][d] = 0;
            od;
            Info( InfoMatrix, 3, "    c" );

            # now perform column operations so that the entries in
            # the <d>-th row have absolute value at most pivot/2
            col := mat{[d..nrrows]}[d];
            for l  in [ d+1.. nrcols ]  do
                quo := BestQuoInt( mat[d][l], mat[d][d] );
                if quo = 1  then
                    mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - col;
                elif quo = -1  then
                    mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] + col;
                elif quo <> 0  then
                    mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - quo * col;
                fi;
                clear := clear and mat[d][l] = 0;
            od;
            Info( InfoMatrix, 3, "    r" );

        od;

        # print the diagonal entry (for information only)
        Info( InfoMatrix, 3, "    div=" );
        Info( InfoMatrix, 2, "      ", mat[d][d] );

        # go on to the next diagonal position
        d := d + 1;

    od;

    # close with some more information
    Info( InfoMatrix, 3, "  overall maximal entry ", omax );
    Info( InfoMatrix, 1, "DiagonalizeMat returns" );
end );


#############################################################################
##
#F  IdentityMat( <m>[, <F>] ) . . . . . . . . identity matrix of a given size
##
#T change this to 2nd argument the identity of the field/ring?
##
InstallGlobalFunction( IdentityMat, function ( arg )
    local   id, m, zero, one, row, i, f;

    # check the arguments and get dimension, zero and one
    if Length(arg) = 1  then
        m    := arg[1];
        zero := 0;
        one  := 1;
        f := Rationals;
    elif Length(arg) = 2  and IsRing(arg[2])  then
        m    := arg[1];
        f := arg[2];
        zero := Zero( arg[2] );
        one  := One(  arg[2] );
        if one = fail then
            Error( "ring must be a ring-with-one" );
        fi;
    elif Length(arg) = 2  then
        m    := arg[1];
        zero := Zero( arg[2] );
        one  := One( arg[2] );
        if IsFFE(arg[2]) then
            f := Characteristic(arg[2]); # ConvertToVectorRep also takes the
	                               # characteristic instead of the field
        else
            f := false;
        fi;
                
    else
        Error("usage: IdentityMat( <m>[, <F>] )");
    fi;

    # special treatment for 0-dimensional spaces
    if m=0 then
      return NullMapMatrix;
    fi;

    # make an empty row
    row := ListWithIdenticalEntries(m,zero);

    # make the identity matrix
    id := [];
    for i  in [1..m]  do
        id[i] := ShallowCopy( row );
        id[i][i] := one;
        if f <> false then
           ConvertToVectorRep( id[i], f );
        else
            ConvertToVectorRep( id[i] );
        fi;
    od;

    # return the identity matrix
    return id;
end );


#############################################################################
##
#F  NullMat( <m>, <n> [, <F>] ) . . . . . . . . . null matrix of a given size
##
InstallGlobalFunction( NullMat, function ( arg )
    local   null, m, n, zero, row, i, k, f;

    if Length(arg) = 2  then
        m    := arg[1];
        n    := arg[2];
        f := Rationals;
    elif Length(arg) = 3  and IsRing(arg[3])  then
        m    := arg[1];
        n    := arg[2];
        f := arg[3];
    elif Length(arg) = 3  then
        m    := arg[1];
        n    := arg[2];
        f := Field(arg[3]);
    else
        Error("usage: NullMat( <m>, <n> [, <F>] )");
    fi;
    zero := Zero(f);

    # make an empty row
    row := [];
    for k  in [1..n]  do row[k] := zero;  od;
    ConvertToVectorRep( row, f );

    # make the null matrix
    null := [];
    for i  in [1..m]  do
        null[i] := ShallowCopy( row );
    od;

    # return the null matrix
    return null;
end );


#############################################################################
##
#F  NullspaceModQ( <E>, <q> ) . . . . . . . . . . .  nullspace of <E> mod <q>
##
##  <E> must be a matrix of integers modulo <q> and <q>  a prime power.  Then
##  'NullspaceModQ' returns  the set of  all vectors of  integers modulo <q>,
##  which solve the homogeneous equation system given by <E> modulo <q>.
##
InstallGlobalFunction( NullspaceModQ, function( E, q )

    local  facs,         # factors of <q>
           p,            # prime of facs
           n,            # <q> = p^n
           field,        # field with p elements
           B,            # E over GF(p)
           null,         # basis of nullspace of B
           elem,         # all elements solving E mod p^i-1
           e,            # one elem
           r,            # inhomogenous part mod p^i-1
           newelem,      # all elements solving E mod p^i
           sol,          # solution of E * x = r mod p^i
           new, o,
           j, i;

    # factorize q
    facs  := FactorsInt( q );
    p     := facs[1];
    n     := Length( facs );
    field := GF(p);

    # solve homogeneous system mod p
    B    := One( field ) * E;
    null := NullspaceMat( B );
    if null = []  then
        return [];
    fi;

    # set up
    elem := List( AsList( FreeLeftModule(field,null,"basis") ),
            x -> List( x, IntFFE ) );
#T !
    newelem := [ ];
    o := One( field );

    # run trough powers
    for i  in [ 2..n ]  do
        for e  in elem  do
            r   := o * ( - (e * E) / (p ^ ( i - 1 ) ) );
            sol := SolutionMat( B, r );
            if sol <> fail then
                for j  in [ 1..Length( elem ) ]  do
                    new := e + ( p^(i-1) * List( o * elem[j] + sol, IntFFE ) );
#T !
                    AddSet( newelem, new );
                od;
            fi;
        od;
        if Length( newelem ) = 0  then
            return [];
        fi;
        elem    := newelem;
        newelem := [ ];
    od;
    return elem;
end );


#############################################################################
##
#F  PermutationMat( <perm>, <dim> [, <F> ] ) . . . . . .  permutation matrix
##
InstallGlobalFunction( PermutationMat, function( arg )

    local i,       # loop variable
          perm,    # permutation
          dim,     # desired dimension of the permutation matrix
          F,       # field of the matrix entries (defauled to 'Rationals')
          mat;     # matrix corresponding to 'perm', result

    if not ( ( Length( arg ) = 2 or Length( arg ) = 3 )
             and IsPerm( arg[1] ) and IsInt( arg[2] ) ) then
      Error( "usage: PermutationMat( <perm>, <dim> [, <F> ] )" );
    fi;

    perm:= arg[1];
    dim:= arg[2];
    if Length( arg ) = 2 then
      F:= Rationals;
    else
      F:= arg[3];
    fi;

    mat:= NullMat( dim, dim, F );

    for i in [ 1 .. dim ] do
        mat[i][ i^perm ]:= One( F );
       if IsFFECollection(F) and IsField(F) then 
           ConvertToVectorRep( mat[i], F );
       elif IsFFE(F) or IsFFECollection(F) then
           ConvertToVectorRep( mat[i], Field(F));
       fi;
    od;

    return mat;
end );


#############################################################################
##
#F  DiagonalMat( <vector> )
##
InstallGlobalFunction( DiagonalMat, function( vector )

    local zerovec,
          M,
          i;

    M:= [];
    zerovec:= Zero( vector[1] );
    zerovec:= List( vector, x -> zerovec );
    for i in [ 1 .. Length( vector ) ] do
      M[i]:= ShallowCopy( zerovec );
      M[i][i]:= vector[i];
    od;
    ConvertToVectorRep( M[i] );
    return M;
end );


#############################################################################
##
#F  ReflectionMat( <coeffs> )
#F  ReflectionMat( <coeffs>, <root> )
#F  ReflectionMat( <coeffs>, <conj> )
#F  ReflectionMat( <coeffs>, <conj>, <root> )
##
InstallGlobalFunction( ReflectionMat, function( arg )

    local coeffs,     # coefficients vector, first argument
          w,          # root of unity, second argument (optional)
          conj,       # conjugation function, third argument (optional)
          M,          # matrix of the reflection, result
          n,          # length of 'coeffs'
          one,        # identity of the ring over that 'coeffs' is written
          c,          # coefficient of 'M'
          i,          # loop over rows of 'M'
          j,          # loop over columns of 'M'
          row;        # one row of 'M'

    # Get and check the arguments.
    if    Length( arg ) < 1 or 3 < Length( arg )
       or not IsList( arg[1] ) then
      Error( "usage: ReflectionMat( <coeffs> [, <conj> ] [, <k> ] )" );
    fi;
    coeffs:= arg[1];
    if   Length( arg ) = 1 then
      w:= -1;
      conj:= List( coeffs, ComplexConjugate );
    elif Length( arg ) = 2 then
      if not IsFunction( arg[2] ) then
        w:= arg[2];
        conj:= List( coeffs, ComplexConjugate );
      else
        w:= -1;
        conj:= arg[2];
        if not IsFunction( conj ) then
          Error( "<conj> must be a function" );
        fi;
        conj:= List( coeffs, conj );
      fi;
    elif Length( arg ) = 3 then
      conj:= arg[2];
      if not IsFunction( conj ) then
        Error( "<conj> must be a function" );
      fi;
      conj:= List( coeffs, conj );
      w:= arg[3];
    fi;

    # Construct the matrix.
    M:= [];
    one:= coeffs[1] ^ 0;
    w:= w * one;
    n:= Length( coeffs );
    c:= ( w - one ) / ( coeffs * conj );
    for i in [ 1 .. n ] do
      row:= [];
      for j in [ 1 .. n ] do
        row[j]:= conj[i] * c * coeffs[j];
      od;
      row[i]:= row[i] + one;
      ConvertToVectorRep( row );
      M[i]:= row;
    od;

    # Return the result.
    return M;
end );


#########################################################################
##
#F  RandomInvertibleMat( <m> [, <R>] )  . . . make a random invertible matrix
##
##  'RandomInvertibleMat' returns a invertible   random matrix with  <m> rows
##  and columns  with elements  taken from  the  ring <R>, which defaults  to
##  'Integers'.
##
InstallGlobalFunction( RandomInvertibleMat, function ( arg )
    local   mat, m, R, i, row, k;

    # check the arguments and get the list of elements
    if Length(arg) = 1  then
        m := arg[1];
        R := Integers;
    elif Length(arg) = 2  then
        m := arg[1];
        R := arg[2];
    else
        Error("usage: RandomInvertibleMat( <m> [, <R>] )");
    fi;

    # now construct the random matrix
    mat := [];
    for i  in [1..m]  do
        repeat
            row := [];
            for k  in [1..m]  do
                row[k] := Random( R );
            od;
            ConvertToVectorRep( row, R );
            mat[i] := row;
        until NullspaceMat( mat ) = [];
    od;

    return mat;
end );


#############################################################################
##
#F  RandomMat( <m>, <n> [, <R>] ) . . . . . . . . . . .  make a random matrix
##
##  'RandomMat' returns a random matrix with <m> rows and  <n>  columns  with
##  elements taken from the ring <R>, which defaults to 'Integers'.
##
InstallGlobalFunction( RandomMat, function ( arg )
    local   mat, m, n, R, i, row, k;

    # check the arguments and get the list of elements
    if Length(arg) = 2  then
        m := arg[1];
        n := arg[2];
        R := Integers;
    elif Length(arg) = 3  then
        m := arg[1];
        n := arg[2];
        R := arg[3];
    else
        Error("usage: RandomMat( <m>, <n> [, <F>] )");
    fi;

    # now construct the random matrix
    mat := [];
    for i  in [1..m]  do
        row := [];
        for k  in [1..n]  do
            row[k] := Random( R );
        od;
        ConvertToVectorRep( row, R );
        mat[i] := row;
    od;
    
    # put into optimal form
    ConvertToMatrixRep(mat);
    return mat;
end );


#############################################################################
##
#F  RandomUnimodularMat( <m> )  . . . . . . . . . .  random unimodular matrix
##
InstallGlobalFunction( RandomUnimodularMat, function ( m )
    local  mat, c, i, j, k, l, a, b, v, w, gcd;

    # start with the identity matrix
    mat := IdentityMat( m );

    for c  in [1..m]  do

        # multiply two random rows with a random? unimodular 2x2 matrix
        i := Random([1..m]);
        repeat
            j := Random([1..m]);
        until j <> i;
        repeat
            a := Random( Integers );  b := Random( Integers );
            gcd := Gcdex( a, b );
        until gcd.gcd = 1;
        v := mat[i];  w := mat[j];
        mat[i] := ShallowCopy(gcd.coeff1 * v + gcd.coeff2 * w);
        mat[j] := ShallowCopy(gcd.coeff3 * v + gcd.coeff4 * w);

        # multiply two random cols with a random? unimodular 2x2 matrix
        k := Random([1..m]);
        repeat
            l := Random([1..m]);
        until l <> k;
        repeat
            a := Random( Integers );  b := Random( Integers );
            gcd := Gcdex( a, b );
        until gcd.gcd = 1;
        for i  in [1..m]  do
            v := mat[i][k];  w := mat[i][l];
            mat[i][k] := gcd.coeff1 * v + gcd.coeff2 * w;
            mat[i][l] := gcd.coeff3 * v + gcd.coeff4 * w;
            ConvertToVectorRep( mat[i] );
        od;

    od;

    return mat;
end );


#############################################################################
##
#F  SimultaneousEigenvalues( <matlist>, <expo> ) . . . . . . . . .eigenvalues
##
##  The matgroup  generated  by  <matlist>  must be  an   abelian p-group  of
##  exponent <expo>.  The matrices in  matlist must be  matrices over GF(<q>)
##  for some prime <q>. Then the eigenvalues of <mat>  in the splitting field
##  GF(<q>^r) for some r are powers of an element ksi in the splitting field,
##  which is of order <expo>.
##
##  'SimultaneousEigenspaces'  returns a matrix  of intergers mod <expo>, say
##  (a_{i,j}), such that the  power ksi^a_{i,j} is an  eigenvalue of the i-th
##  matrix in <matlist> and the eigenspaces of  the different matrices to the
##  eigenvalues ksi^a_{i,j} for fixed j are equal.
##
InstallGlobalFunction( SimultaneousEigenvalues,
    function( arg )

    local matlist, expo,
            q,       # characteristic of field of matrices
            r,       # such that <q>^r is splitting field
            field,   # GF(<q>^r)
            ksi,     # <expo>-root of field
            eival,   # exponents of eigenvalues of the matrices
            eispa,   # eigenspaces of the matrices
            eigen,   # exponents of simultaneous eigenvalues
            I,       # identity matrix
            w,       # ksi^w is candidate for a eigenvalue
            null,    # basis of nullspace
            i, Split;

    Split := function( space, i )
        local   int,   # intersection of two row spaces
                j;

        for j  in [1..Length(eival[i])]  do
            if 0 < Length( eispa[i][j] )  then
                int := SumIntersectionMat( space, eispa[i][j] )[2];
                if 0 < Length( int ) then
                    Append( eigen[i],
                            List( int, x -> eival[i][j] ) );
                    if i < Length( matlist )  then
                        Split( int, i+1 );
                    fi;
                fi;
            fi;
        od;
    end;

    matlist := arg[1];
    expo    := arg[2];

    # compute ksi
    if Length( arg ) = 2 then
        q := Characteristic( matlist[1][1][1] );

        # get splitting field
        r := 1;
        while EuclideanRemainder( q^r - 1, expo ) <> 0  do
            r := r+1;
        od;
        field := GF(q^r);
        ksi   := GeneratorsOfField(field)[1]^((q^r - 1) / expo);
    else
        ksi := arg[3];
    fi;

    # set up eigenvalues and spaces and Idmat
    eival  := List( matlist, x -> [] );
    eispa  := List( matlist, x -> [] );
    I      := matlist[1]^0;

    # calculate eigenvalues and spaces for each matrix
    for i in [1..Length(matlist)]  do
        for w in [0..expo-1]  do
            null := NullspaceMat( matlist[i] - (ksi^w * I) );
            if 0 < Length(null)  then
                Add( eival[i], w );
                Add( eispa[i], null );
            fi;
        od;
    od;

    # now make the eigenvalues simultaneous
    eigen := List( matlist, x -> [] );
    for i  in [1..Length(eival[1])]  do
        Append( eigen[1], List( eispa[1][i], x -> eival[1][i] ) );
        if Length( matlist ) > 1  then
            Split( eispa[1][i], 2 );
        fi;
    od;

    # return
    return eigen;
end );

#############################################################################
##
#F  FlatBlockMat( <blockmat> ) . . . . . . . . . . . convert block mat to mat
##
InstallGlobalFunction( FlatBlockMat, function( block )
    local d, l, mat, i, j, h, k, a, b;

    d := Length( block );
    l := Length( block[1][1] );
    mat := List( [1..d*l], x -> List( [1..d*l], y -> false ) );
    for i in [1..d] do
        for j in [1..d] do
            for h in [1..l] do
                for k in [1..l] do
                    a := (i-1)*l + h;
                    b := (j-1)*l + k;
                    mat[a][b] := block[i][j][h][k];
                od;
            od;
        od;
    od;
    return mat;
end );

#############################################################################
##
#F  DirectSumMat( <matlist> ) . . . . . . . . . . . create block diagonal mat
#F  DirectSumMat( mat1,..,matn )  . . . . . . . . . create block diagonal mat
##
InstallGlobalFunction( DirectSumMat, function (arg)                     
    local  c, r, res, m, f, F;
    if Length(arg)=1 and not IsMatrix(arg[1]) then
        arg:=arg[1];
    fi;
    f:=function(m)                                        
        if Length(m)=0 then
            return 0;    
        else                            
            return Length(m[1]);
        fi;
    end;                     
    r:=1; m:=[ ];
    while m = [ ] and r <= Length( arg ) do
      m:= arg[r]; r:=r+1;
    od;
    if m <> [ ] then
      F:= DefaultField( m[1][1] );
    else
      F:= Rationals;
    fi;                    
    res:=List(NullMat(Sum(arg,Length),Sum(arg,f),F),ShallowCopy);
    r:=0;
    c:=0;          
    for m in arg do   
        res{r+[1..Length(m)]}{c+[1..f(m)]}:=m;
        r:=r+Length(m);
        c:=c+f(m);
    od;
    return res;
end );


#############################################################################
##
#F  TraceMat( <mat> ) . . . . . . . . . . . . . . . . . . . trace of a matrix
##
InstallGlobalFunction( TraceMat, function ( mat )
    local   trc, m, i;

    # check that the element is a square matrix
    m := Length(mat);
    if m <> Length(mat[1])  then
        Error("TraceMat: <mat> must be a square matrix");
    fi;

    # sum all the diagonal entries
    trc := mat[1][1];
    for i  in [2..m]  do
        trc := trc + mat[i][i];
    od;

    # return the trace
    return trc;
end );


#############################################################################
##
#M  Trace( <mat> )  . . . . . . . . . . . . . . . . . . . . . .  for a matrix
##
InstallOtherMethod( Trace,
    "generic method for matrices",
    true,
    [ IsMatrix ], 0,
    TraceMat );


#############################################################################
##
#M JordanDecomposition( <mat> )
##
InstallMethod( JordanDecomposition,
           "method for matrices",
           true,
           [IsMatrix], 0,
function( mat )

  local F,p,B,f,g,fac,ff,h,w;

# The algorithm is due to R. Beals

  F:= DefaultFieldOfMatrix( mat );
  p:= Characteristic( F );

# First we determine a squarefree polynomial 'g' such that 'g^d(mat)=0'.

  f:= CharacteristicPolynomial( F, mat );
  if p = 0 or p > Length( mat ) then
    g:= f/Gcd( f, Derivative( f ) );
  else
    fac:= Factors(f);
    g:= One( F );
    ff:= [ ];
    for h in fac do
      if not h in ff then
        g:= g*h;
        Add( ff, h );
      fi;
    od;
  fi;

  if f=g then return [ mat, 0*mat ]; fi;

# Now 'B' will be the semisimple part of the matrix 'mat'.

  w:= GcdRepresentation( g, Derivative( g ) )[2];
  w:= w*g;
  B:= ShallowCopy( mat );
  while Value( g, B ) <> 0*B do
    B:= B - Value( w, B );
  od;

  return [ B, mat-B ];

end );

#############################################################################
##
#F  OnSubspacesByCanonicalBasis(<bas>,<mat>)
##
InstallGlobalFunction(OnSubspacesByCanonicalBasisGF2,function( mat, obj )
  #mat:=ShallowCopy(mat);
  #mat:=PROD_LIST_SCL_DEFAULT(mat,obj); # this produced a *mutable* product
  # (Hooray, so we do not even need `ShallowCopy'. But this should be better
  # done via a defined interface!)
  mat:=ShallowCopy(mat*obj);
  TriangulizeMatGF2(mat); # this function works on full vectors, so no
			  # further `ShallowCopy' level is needed!
  return mat;
end);

InstallGlobalFunction(OnSubspacesByCanonicalBasis,function( mat, obj )
  mat:=ShallowCopy(mat*obj);
  TriangulizeMat(mat);
  return mat;
end);

#############################################################################
##

#F  NOT READY: BaseNullspace( <struct> )
##
#T BaseNullspace := function( struct )
#T     if   IsMat( struct ) then
#T       return NullspaceMat( struct );
#T     elif IsRecord( struct ) then
#T       if not IsBound( struct.baseNullspace ) then
#T         if not IsBound( struct.operations ) then
#T           Error( "<struct> must have 'operations' entry" );
#T         fi;
#T         struct.baseNullspace:=
#T             struct.operations.BaseNullspace( struct );
#T       fi;
#T       return struct.baseNullspace;
#T     else
#T       Error( "<struct> must be a matrix or a record" );
#T     fi;
#T     end;


##########################################################################
##
#F  NOT READY: MatricesOps.InvariantForm( <D> )
##
#T MatricesOps.InvariantForm := function( D )
#T     local F,          # field
#T           q,          # size of 'F'
#T           A,          # 'F'-algebra generated by 'D'
#T           nr,         # word number
#T           word,       # loop over algebra elements
#T           i,          # loop variable
#T           ns,         # file for a nullspace
#T           sb1,        # standard basis of 'D'
#T           T,          # contragredient representation
#T           sb2,        # standard basis of 'T'
#T           M;          # invariant form, result
#T
#T     if   not ( IsList( D ) and ForAll( D, IsMatrix ) ) then
#T       Error( "<D> must be a list of matrices" );
#T     elif Length( D ) = 0 then
#T       Error( "need at least one matrix" );
#T     fi;
#T
#T     F:= Field( Flat( D ) );
#T     if not IsFinite( F ) then
#T       Error( "sorry, for finite fields only" );
#T     fi;
#T     q:= Size( F );
#T
#T     # Search for an algebra element of nullity 1.
#T     # Use normed words only, that is, words of the form $I + w$.
#T     # Write the 'D' nullspace of the nullity 1 word to 'ns'.
#T     A:= Algebra( F, D );
#T     nr:= 1;
#T     repeat
#T       nr:= nr + q;
#T       word:= ElementAlgebra( A, nr );
#T       ns:= NullspaceMat( word );
#T     until Length( ns ) = 1;
#T
#T     # Compute the standard basis for the natural module of 'D',
#T     # starting with the word of nullity 1, write output to 'sb1'
#T     sb1:= BasisVectors( StandardBasis( Module( A, ns ) ) );
#T
#T     # Check whether the whole space is spanned.
#T     if Length( sb1 ) < Length( ns[1] ) then
#T       Error( "representation is reducible" );
#T     fi;
#T
#T     # Make the contragredient representation 'T'.
#T     T:= Algebra( A.field, List( D, x -> TransposedMat( x^-1 ) ) );
#T
#T     # Write the 'T' nullspace of the nullity 1 word to 'ns'.
#T     ns:= NullspaceMat( ElementAlgebra( T, nr ) );
#T
#T     # Compute the standard basis for the natural module of 'T',
#T     # starting with the word of nullity 1, write output to 'sb2'
#T     sb2:= BasisVectors( StandardBasis( Module( T, ns ) ) );
#T
#T     # If 'D' and 'T' are equivalent then
#T     # the invariant matrix is 'M = sb1^(-1) * sb2',
#T     # since 'sb1 * D[i] * sb1^(-1) = sb2 * T[i] * sb2^(-1)' implies
#T     # that 'D[i] * M * D[i]^{tr} = M'.
#T     M:= sb1^-1 * sb2;
#T
#T     # Check for equality.
#T     for i in [ 1 .. Length( D ) ] do
#T       if D[i] * M * TransposedMat( D[i] ) <> M then
#T         return false;
#T       fi;
#T     od;
#T
#T     # Return the result.
#T     return M;
#T     end;


#############################################################################
##
#F  NOT READY: BaseOrthogonalSpaceMat( <mat> )
##
#T # ##  Let $V$ be the row space generated by the rows of <mat> (over any field
#T # ##  that contains all entries of <mat>).  'BaseOrthogonalSpaceMat( <mat> )'
#T # ##  computes a base of the orthogonal space of $V$.
#T # ##
#T # ##  The rows of <mat> need not be linearly independent.
#T # ##
#T # #T  Note that this means to transpose twice ...
#T # ##
#T # BaseOrthogonalSpaceMat := function( mat )
#T #     return NullspaceMat( TransposedMat( mat ) );
#T #     end;


#############################################################################
##

#E

