#############################################################################
##
#W  listcoef.gi                 GAP Library                      Frank Celler
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  The  '<Something>RowVector' functions operate  on row vectors, that is to
##  say (where it  makes sense) that the vectors  must have the  same length,
##  for example 'AddRowVector'  requires that  the  two involved row  vectors
##  have the same length.
##
##  The '<DoSomething>Coeffs' functions  operate  on row vectors  which might
##  have different lengths.  They will return the new length without counting
##  trailing zeros, however they will *not*  necessarily remove this trailing
##  zeros.  The  only  exception to this  rule  is 'RemoveOuterCoeffs'  which
##  returns the number of elements removed at the beginning.
##
##  The '<Something>Coeffs' functions operate on row vectors which might have
##  different lengths, the returned result will have trailing zeros removed.
##
Revision.listcoef_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  AddRowVector( <list1>, <list2>, <mult>, <from>, <to> )
##
InstallMethod( AddRowVector,
        "kernel method for plain lists of cyclotomics",
        IsCollsCollsElmsXX,
        [ IsSmallList and IsDenseList and IsMutable and
          IsCyclotomicCollection and IsPlistRep,
      IsDenseList and IsCyclotomicCollection and IsPlistRep,
      IsCyclotomic,
      IsPosInt,
      IsPosInt ],
    0,
        ADD_ROW_VECTOR_5_FAST
        );

InstallMethod( AddRowVector,
        "kernel method for small lists",
        IsCollsCollsElmsXX,
        
    [ IsSmallList and IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement,
      IsPosInt,
      IsPosInt ],
    0,
        ADD_ROW_VECTOR_5
        );

InstallMethod( AddRowVector,
        "generic method",
    IsCollsCollsElmsXX,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement,
      IsPosInt,
      IsPosInt ],
    0,
        function( l1, l2, m, f, t )
    local   i;
    
    for i  in [ f .. t ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end 
  );

L1_IMMUTABLE_ERROR:=function(arg)
  if IsMutable(arg[1]) then
    TryNextMethod();
  else
    Error("arg[1] must be mutable");
  fi;
end;

InstallOtherMethod( AddRowVector,"error if immutable",true,
    [ IsList,IsObject,IsObject,IsPosInt,IsPosInt],0,
L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  AddRowVector( <list1>, <list2>, <mult> )
##
InstallOtherMethod( AddRowVector,
        "kernel method for plain lists of cyclotomics(3 args)",
        IsCollsCollsElms,
        [ IsSmallList and IsDenseList and IsMutable and IsCyclotomicCollection
          and IsPlistRep,
      IsDenseList and IsPlistRep and IsCyclotomicCollection,
      IsCyclotomic ],
    0,
        ADD_ROW_VECTOR_3_FAST );

InstallOtherMethod( AddRowVector,
        "kernel method for small lists (3 args)",
        IsCollsCollsElms,
    [ IsSmallList and IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
        ADD_ROW_VECTOR_3 );

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (5 args, last 2 ignored)",
        IsCollsCollsElmsXX,
    [ IsGF2VectorRep and IsMutable,
      IsGF2VectorRep,
      IS_FFE, IsPosInt, IsPosInt ],0,
        function(sum, vec, mult, from, to)
    AddRowVector( sum, vec, mult);
end);

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (3 args)",
        IsCollsCollsElms,
    [ IsGF2VectorRep and IsMutable,
      IsGF2VectorRep,
      IS_FFE ],0,
        ADDCOEFFS_GF2VEC_GF2VEC_MULT );
        
InstallOtherMethod( AddRowVector,
        "kernel method for vecffe (5 args -- ignores last 2)",
        IsCollsCollsElmsXX,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsRowVector and IsPlistRep and IsFFECollection,
      IS_FFE, IsPosInt, IsPosInt ],0,
        function( sum, vec, mult, from, to)
    AddRowVector(sum,vec,mult);
end);

InstallOtherMethod( AddRowVector,
        "kernel method for vecffe (3 args)",
        IsCollsCollsElms,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsRowVector and IsPlistRep and IsFFECollection,
      IS_FFE ],0,
        ADD_ROWVECTOR_VECFFES_3 );
        
InstallOtherMethod( AddRowVector,
        "generic method",
    IsCollsCollsElms,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
        
function( l1, l2, m )
    local   i;
    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end 
  );
        
InstallOtherMethod( AddRowVector,
        "generic method",
    IsCollsCollsElms,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
        
function( l1, l2, m )
    local   i;
    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end 
  );

InstallOtherMethod( AddRowVector,"error if immutable",true,
    [ IsList,IsObject,IsObject],0,L1_IMMUTABLE_ERROR);

InstallOtherMethod( AddRowVector, "do nothing if mult is zero",
        IsCollsCollsElms,
        [ IsList, IsObject, IsObject and IsZero], SUM_FLAGS,
        ReturnTrue);

#############################################################################
##
#M  AddRowVector( <list1>, <list2> )
##
InstallOtherMethod( AddRowVector,
        "kernel method for plain lists of cyclotomics (2 args)",
    IsIdenticalObj,
        [ IsSmallList and IsDenseList and IsMutable and
          IsCyclotomicCollection and IsPlistRep,
      IsDenseList and IsCyclotomicCollection and IsPlistRep ],
    0,
        ADD_ROW_VECTOR_2_FAST
        );

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (2 args)",
        IsIdenticalObj,
    [ IsGF2VectorRep and IsMutable and IsRowVector,
      IsGF2VectorRep and IsRowVector],0,
        ADDCOEFFS_GF2VEC_GF2VEC );

InstallOtherMethod( AddRowVector,
        "kernel method for vecffe (2 args)",
        IsIdenticalObj,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsRowVector and IsPlistRep and IsFFECollection],0,
        ADD_ROWVECTOR_VECFFES_2 );

InstallOtherMethod( AddRowVector,
        "generic method (2 args)",
    IsIdenticalObj,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    local   i;

    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + l2[i];
    od;
end );

InstallOtherMethod( AddRowVector,
        "kernel method for small lists (2 args)",
    IsIdenticalObj,
    [ IsSmallList and IsDenseList and IsMutable,
      IsDenseList ],
    0,
        ADD_ROW_VECTOR_2);

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (2 args)",
        IsIdenticalObj,
    [ IsGF2VectorRep and IsMutable,
      IsGF2VectorRep],0,
        ADDCOEFFS_GF2VEC_GF2VEC );
        
InstallOtherMethod( AddRowVector,
        "generic method",
    IsCollsCollsElms,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
        
function( l1, l2, m )
    local   i;
    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end 
  );
        
InstallOtherMethod( AddRowVector,
        "generic method",
    IsCollsCollsElms,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
        
function( l1, l2, m )
    local   i;
    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end 
  );

InstallOtherMethod( AddRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
        L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  LeftShiftRowVector( <list>, <shift> )
##
InstallMethod( LeftShiftRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsPosInt ],
    0,

function( l, s )
    local   i;

    for i  in [ 1 .. Length(l)-s ]  do
        l[i] := l[i+s];
    od;
    for i  in [ Length(l)-s+1 .. Length(l) ]  do
        Unbind(l[i]);
    od;
end );

InstallOtherMethod( LeftShiftRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  LeftShiftRowVector( <list>, <no-shift> )
##
InstallOtherMethod( LeftShiftRowVector,
    true,
    [ IsDenseList,
      IsInt and IsZeroCyc ],
    SUM_FLAGS,

function( l, s )
    return;
end );


#############################################################################
##
#M  MultRowVector( <list1>, <poss1>, <list2>, <poss2>, <mult> )
##
InstallMethod( MultRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, p1, l2, p2, m )
    l1{p1} := m * l2{p2};
end );

InstallOtherMethod( MultRowVector,"error if immutable",true,
    [ IsList,IsObject,IsObject,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  MultRowVector( <list>, <mul> )
##
InstallOtherMethod( MultRowVector,
        "two argument generic method",
    true,
    [ IsDenseList and IsMutable,
      IsMultiplicativeElement ],
    0,

function( l, m )
    local   i;

    for i  in [ 1 .. Length(l) ]  do
        l[i] := m * l[i];
    od;
end );

InstallOtherMethod( MultRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);

InstallOtherMethod( MultRowVector,
        "Two argument kernel method for small list",
    IsCollsElms,
    [ IsSmallList and IsDenseList and IsMutable,
      IsMultiplicativeElement ],
    0,
    MULT_ROW_VECTOR_2    
);

InstallOtherMethod( MultRowVector,
        "Two argument kernel method for plain list of cyclotomics and an integer",
    IsCollsElms,
        [ IsSmallList and IsDenseList and IsMutable and IsPlistRep and
          IsCyclotomicCollection,
      IsCyclotomic ],
    0,
    MULT_ROW_VECTOR_2_FAST    
);

InstallOtherMethod( MultRowVector,
        "kernel method for vecffe (2 args)",
        IsCollsElms,
        [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
          IsFFE],0,
        MULT_ROWVECTOR_VECFFES );


#############################################################################
##
#M  RightShiftRowVector( <list>, <shift>, <fill> )
##
InstallMethod( RightShiftRowVector,
    true,
    [ IsList and IsMutable,
      IsPosInt,
      IsObject ],
    0,

function( l, s, f )
    local   i;

    l{s+[1..Length(l)]} := l{[1..Length(l)]};
    for i  in [ 1 .. s ]  do
        l[i] := f;
    od;
end );

InstallOtherMethod( RightShiftRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  RightShiftRowVector( <list>, <no-shift>, <fill> )
##
InstallOtherMethod( RightShiftRowVector,
    true,
    [ IsList,
      IsInt and IsZeroCyc,
      IsObject ],
    SUM_FLAGS,

function( l, s, f )
    return;
end );


#############################################################################
##
#M  ShrinkRowVector( <list> )
##
InstallMethod( ShrinkRowVector,
    true,
    [ IsList and IsMutable ],
    0,

function( l1 )
    local   z;

    if 0 = Length(l1)  then
        return;
    else
        z := l1[1] * 0;
        while 0 < Length(l1) and l1[Length(l1)] = z  do
            Unbind( l1[Length(l1)] );
        od;
    fi;
end );

InstallOtherMethod( ShrinkRowVector,"error if immutable",true,
    [ IsList],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
InstallMethod( AddCoeffs,
    "generic methods",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, p1, l2, p2, m )
    local   i,  zero,  n1;

    if Length(p1) <> Length(p2)  then
        Error( "positions lists have different lengths" );
    fi;
    for i  in [ 1 .. Length(p1) ]  do
        if not IsBound(l1[p1[i]])  then
            l1[p1[i]] := m*l2[p2[i]];
        else
            l1[p1[i]] := l1[p1[i]] + m*l2[p2[i]];
        fi;
    od;
    if 0 < Length(l1)  then
        zero := Zero(l1[1]);
        n1   := Length(l1);
        while 0 < n1 and l1[n1] = zero  do
            n1 := n1 - 1;
        od;
    else
        n1 := 0;
    fi;
    return n1;
end );

InstallOtherMethod( AddCoeffs,"error if immutable", true,
    [ IsList,IsObject,IsObject,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  AddCoeffs( <list1>, <list2>, <mul> )
##
InstallOtherMethod( AddCoeffs,
    "generic methods",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, l2, m )
    local   pos;

    pos := [ 1 .. Length(l2) ];
    return AddCoeffs( l1, pos, l2, pos, m );
end );

InstallOtherMethod( AddCoeffs,"error if immutable", true,
    [ IsList,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  AddCoeffs( <list1>, <list2> )
##
InstallOtherMethod( AddCoeffs,
    "generic methods",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    local   len,  zero,  pos;

    if 0 = Length(l2)  then
        if 0 = Length(l1)  then
            return 0;
        else
            len  := Length(l1);
            zero := Zero(l1[1]);
            while 0 < len and l1[len] = zero  do
                len := len - 1;
            od;
            return len;
        fi;
    else
        pos := [ 1 .. Length(l2) ];
        return AddCoeffs( l1, pos, l2, pos, One(l2[1]) );
    fi;
end );

InstallOtherMethod( AddCoeffs,"error if immutable", true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  MultCoeffs( <list1>, <list2>, <len2>, <list3>, <len3> )
##
InstallMethod( MultCoeffs,
    true,
    [ IsList and IsMutable,
      IsDenseList,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, l2, n2, l3, n3 )
    local   zero,  i,  z,  j,  n1;

    # catch the trivial cases
    if n2 = 0  then
        return 0;
    elif n3 = 0  then
        return 0;
    fi;
    zero := Zero(l2[1]);
    if IsIdenticalObj( l1, l2 )  then
        l2 := ShallowCopy(l2);
    elif IsIdenticalObj( l1, l3 )  then
        l3 := ShallowCopy(l3);
    fi;

    # fold the product
    for i  in [ 1 .. n2+n3-1 ]  do
        z := zero;
        for j  in [ Maximum(i+1-n3,1) .. Minimum(n2,i) ]  do
            z := z + l2[j]*l3[i+1-j];
        od;
        l1[i] := z;
    od;

    # return the length of <l1>
    n1 := n2+n3-1;
    while 0 < n1 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
    return n1;

end );

InstallOtherMethod( MultCoeffs,"error if immutable", true,
    [ IsList,IsObject,IsInt,IsObject,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffs( <list1>, <len1>, <list2>, <len2> )
##
InstallMethod( ReduceCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, l2, n2 )
    local   zero,  k,  l,  q,  ll,  i;

    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n2 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
        
    # reduce coeffs
    while n1 >= n2  do
        q := -l1[n1]/l2[n2];
        l := n1-n2;
        for i  in [ n1-n2+1 .. n1 ]  do 
            l1[i] := l1[i]+q*l2[i-n1+n2];
            if l1[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end );

InstallOtherMethod( ReduceCoeffs,"error if immutable", true,
    [ IsList,IsInt,IsObject,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffs( <list1>, <list2> )
##
InstallOtherMethod( ReduceCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    return ReduceCoeffs( l1, Length(l1), l2, Length(l2) );
end );

InstallOtherMethod( ReduceCoeffs,"error if immutable", true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list1>, <len1>, <list2>, <len2>, <mod> )
##
InstallMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsDenseList,
      IsInt,
      IsInt ],
    0,

function( l1, n1, l2, n2, p )
    local   zero,  k,  l,  q,  ll,  i;

    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n2 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
        
    # reduce coeffs
    while n1 >= n2  do
        q := -l1[n1]/l2[n2] mod p;
        l := n1-n2;
        for i  in [ n1-n2+1 .. n1 ]  do 
            l1[i] := (l1[i]+q*l2[i-n1+n2] mod p) mod p;
            if l1[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsInt,IsObject,IsInt,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list1>, <list2>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsInt ],
    0,

function( l1, l2, p )
    return ReduceCoeffsMod( l1, Length(l1), l2, Length(l2), p );
end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsObject,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list>, <len>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsInt ],
    0,

function( l1, n1, p )
    local   zero,  n2,  i;

    # catch trivial cases
    if 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
        
    # reduce coeffs
    n2 := 0;
    for i  in [ 1 .. n1 ]  do
        l1[i] := l1[i] mod p;
        if l1[i] <> zero  then
            n2 := i;
        fi;
    od;
    return n2;

end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsInt,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt ],
    0,

function( l1, p )
    return ReduceCoeffsMod( l1, Length(l1), p );
end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  RemoveOuterCoeffs( <list>, <coef> )
##
InstallMethod( RemoveOuterCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsObject ],
    0,

function( l, c )
    local   n,  m,  i;

    if 0 = Length(l)  then
        return 0;
    fi;
    n := Length(l);
    while 0 < n and l[n] = c  do
        Unbind(l[n]);
        n := n-1;
    od;
    if n = 0  then
        return 0;
    fi;
    m := 0;
    while m < n and l[m+1] = c  do
        m := m+1;
    od;
    if 0 = m  then
        return 0;
    fi;
    for i  in [ m+1 .. n ]  do
        l[i-m] := l[i];
    od;
    for i  in [ 1 .. m ]  do
        Unbind(l[n-i+1]);
    od;
    return m;
end );

InstallOtherMethod( RemoveOuterCoeffs,"error if immutable", true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ShrinkCoeffs( <list> )
##
InstallMethod( ShrinkCoeffs,
    true,
    [ IsList and IsMutable ],
    0,

function( l1 )
    ShrinkRowVector(l1);
    return Length(l1);
end );

InstallOtherMethod( ShrinkCoeffs,"error if immutable", true,
    [ IsList],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  CoeffsMod( <list>, <len>, <mod> )
##
InstallMethod( CoeffsMod,
    true,
    [ IsDenseList,
      IsInt,
      IsInt ],
    0,

function( l1, n1, p )
    l1 := ShallowCopy(l1);
    ReduceCoeffsMod( l1, n1, p );
    ShrinkRowVector(l1);
    return l1;
end );


#############################################################################
##
#M  CoeffsMod( <list>, <mod> )
##
InstallOtherMethod( CoeffsMod,
    true,
    [ IsDenseList,
      IsInt ],
    0,

function( l1, p )
    return CoeffsMod( l1, Length(l1), p );
end );


#############################################################################
##
#M  PowerModCoeffs( <list1>, <len1>, <exp>, <list2>, <len2> )
##
InstallMethod( PowerModCoeffs,
    true,
    [ IsDenseList,
      IsInt,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, exp, l2, n2 )
    local   c,  n3;

    if exp <= 0  then
        Error( "power <exp> must be positive" );
    fi;
    l1 := ShallowCopy(l1);
    n1 := ReduceCoeffs( l1, n1, l2, n2 );
    if n1 = 0  then
        return [];
    fi;
    c  := [ One(l1[1]) ];
    n3 := 1;
    while exp <> 0 do
        if exp mod 2 = 1  then
            n3 := MultCoeffs( c, c, n3, l1, n1 );
            n3 := ReduceCoeffs( c, n3, l2, n2 );
        fi;
        exp := QuoInt( exp, 2 );
        if exp <> 0  then
            l1 := ProductCoeffs( l1, n1, l1, n1 );
            n1 := ReduceCoeffs( l1, Length(l1), l2, n2 );
        fi;
    od;
    return c;
end );


#############################################################################
##
#M  PowerModCoeffs( <list1>, <exp>, <list2> )
##
InstallOtherMethod( PowerModCoeffs,
    true,
    [ IsDenseList,
      IsInt,
      IsDenseList ],
    0,

function( l1, exp, l2 )
    return PowerModCoeffs( l1, Length(l1), exp, l2, Length(l2) );
end );


#############################################################################
##
#M  ProductCoeffs( <list1>, <len1>, <list2>, <len2> )
##
InstallMethod( ProductCoeffs,
    true,
    [ IsDenseList,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, l2, n2 )
    local   p;

    p := [];
    MultCoeffs( p, l1, n1, l2, n2 );
    ShrinkRowVector(p);
    return p;
end );


#############################################################################
##
#M  ProductCoeffs( <list1>, <list2> )
##
InstallOtherMethod( ProductCoeffs,
    true,
    [ IsDenseList,
      IsDenseList ],
    0,

function( l1, l2 )
    return ProductCoeffs( l1, Length(l1), l2, Length(l2) );
end );


#############################################################################
##
#M  ShiftedCoeffs( <list>, <shift> )
##
InstallMethod( ShiftedCoeffs,
    true,
    [ IsDenseList,
      IsInt ],
    0,

function( l, shift )
    if 0 = Length(l)  then
        return [];
    fi;
    l := ShallowCopy(l);
    if shift < 0  then
        LeftShiftRowVector( l, -shift );
        ShrinkRowVector(l);
        return l;
    elif shift = 0  then
        ShrinkRowVector(l);
        return l;
    else
        RightShiftRowVector( l, shift, Zero(l[1]) );
        ShrinkRowVector(l);
        return l;
    fi;
end );


#############################################################################
##
#F  QuotRemPolList( <f>, <g>) 
##
##  Quotient and  Remainder  of polynomials   given as  list,  is  needed for
##  algebraic extensions and fits best here.
##
QuotRemPolList := function(f,g)
local q,m,n,i,c,k,z;
  q:=[];
  f:=ShallowCopy(f);
  g:=ShallowCopy(g);
  z:=0*g[1];
  n:=Length(g);
  while n>0 and g[n]=z do
    Unbind(g[n]);
    n:=n-1;
  od;
  n:=Length(g);
  m:=Length(f);
  for i  in [0..(m-n)]  do
    c:=f[m-i]/g[n];
    q[m-n-i+1]:=c;
    for k in [1..n] do
      f[m-i-n+k]:=f[m-i-n+k]-c*g[k];
    od;
  od;
  return [q,f];
end;

#############################################################################
##
#M  WeightVecFFE( <vec> )
##
InstallMethod(WeightVecFFE,"generic",true,[IsList],0,
function(v)
local z,i,n;
  z:=Zero(v[1]);
  n:=0;
  for i in [1..Length(v)] do
    if v[i]<>z then n:=n+1;fi;
  od;
  return n;
end);

#############################################################################
##
#M  DistanceVecFFE( <vec1>,<vec2> )
##
InstallMethod(DistanceVecFFE,"generic",IsIdenticalObj,[IsList,IsList],0,
function(v,w)
local i,n;
  n:=0;
  for i in [1..Length(v)] do
    if v[i]<>w[i] then n:=n+1;fi;
  od;
  return n;
end);

#############################################################################
##
#M  DistancesDistributionVecFFEsVecFFE( <vecs>,<vec> )
##
InstallMethod(DistancesDistributionVecFFEsVecFFE,"generic",IsCollsElms,
  [IsList, IsList],0,
function(vecs,vec)
local d,i;
  d:=ListWithIdenticalEntries(Length(vec)+1,0);
  for i in vecs do
    i:=DistanceVecFFE(i,vec);
    d[i+1]:=d[i+1]+1;
  od;
  return d;
end);

#############################################################################
##
#M  DistancesDistributionMatFFEVecFFE( <mat>,<f>,<vec> )
##
InstallMethod(DistancesDistributionMatFFEVecFFE,"generic",IsCollsElmsElms,
  [IsMatrix,IsFFECollection, IsList],0,
function(mat,f,vec)
local d,i,j,l,m,z,cnt,v,pos;
  f:=AsSSortedList(f);
  Assert(1,f[1]=Zero(f[1]));
  l:=Length(f);
  m:=Length(mat);
  d:=ListWithIdenticalEntries(Length(vec)+1,0);
  cnt:=ListWithIdenticalEntries(m,1);
  z:=Zero(vec);
  v:=DistanceVecFFE(z,vec);
  d[v+1]:=d[v+1]+1;
  for j in [1..l^m-1] do
    pos:=m;
    while cnt[pos]=l do
      cnt[pos]:=1;
      pos:=pos-1;
    od;

    cnt[pos]:=cnt[pos]+1;

    v:=z;
    for i in [1..m] do
      v:=v+f[cnt[i]]*mat[i];
    od;

    v:=DistanceVecFFE(v,vec);
    d[v+1]:=d[v+1]+1;
  od;
  return d;
end);

#############################################################################
##
#M  AClosestVectorCombinationsMatFFEVecFFE( <mat>,<f>,<vec>,<l>,<stop> )
##
InstallMethod(AClosestVectorCombinationsMatFFEVecFFE,"generic",
  function(a,b,c,d,e)
    return HasElementsFamily(a) and IsIdenticalObj(b,c)
           and IsIdenticalObj(ElementsFamily(a),b);
  end,
  [IsMatrix,IsFFECollection, IsList, IsInt,IsInt],0,
function(mat,f,vec,len,stop)
local d,b,bd,i,j,l,comb,umat,z,cnt,v,pos;

  f:=AsSSortedList(f);
  Assert(1,f[1]=Zero(f[1]));
  f:=f{[2..Length(f)]}; # we want to exclude linear combinations with `zero'.
  l:=Length(f);
  z:=Zero(vec);
  if len=0 then
    return z;
  else
    bd:=infinity;
  fi;
  for comb in Combinations([1..Length(mat)],len) do
    umat:=mat{comb};
    cnt:=ListWithIdenticalEntries(len,1);
    v:=Sum(umat)*f[1]; # the combination 1,1 .. 1
    d:=DistanceVecFFE(v,vec);
    if d<bd then
      bd:=d;
      b:=v;
    fi;

    # we let the coefficient of the first vector to be always 1. This in
    # effect runs projectively through the linear combinations, which is
    # just fine.
    for j in [1..l^(len-1)-1] do
      if bd<=stop then
        return b;
      fi;
      pos:=len;
      while cnt[pos]=l do
	cnt[pos]:=1;
	pos:=pos-1;
      od;
      cnt[pos]:=cnt[pos]+1;
      v:=z;
      for i in [1..len] do
	v:=v+f[cnt[i]]*umat[i];
      od;
      d:=DistanceVecFFE(v,vec);
      if d<bd then
	bd:=d;
	b:=v;
      fi;
    od;
  od;

  return b;

end);

#############################################################################
##
#M  CosetLeadersMatFFE( <mat>,<f> )
##
##  returns a list of representatives of minimal weight for the cosets of
##  the vector space generated by the rows of <mat> over the finite field
##  <f>. All rows of <mat> must have the same length, and all elements must
##  lie in <f>. The rows of <mat> must be linearly independent.
InstallMethod(CosetLeadersMatFFE,"generic",IsCollsElms,
  [IsMatrix,IsFFECollection],0,
function(mat,f)
local m,bas,umat,z,reps,found,fs,l,cnt,sy,len,pos,v,comb,k,symod,fl,i,j;

  m:=Length(mat);
  bas:= Immutable( IdentityMat(Length(mat[1]),One(f)) );
  z:=Zero(mat[1]);
  reps:=[z];
  found:=Size(f)^Length(mat)-1;
  symod:=found+1;

  fs:=Size(f);
  fl:=AsSSortedList(f);
  Assert(1,f[1]=Zero(f[1]));
  f:=fl{[2..Length(fl)]}; # we want to exclude linear combinations with `zero'.
  l:=Length(f);

  # now run through all vectors in the space in ascending weigth
  for len in [1..Length(mat[1])] do
    for comb in Combinations([1..Length(mat[1])],len) do
      umat:=bas{comb};
      cnt:=ListWithIdenticalEntries(len,1);
      v:=Sum(umat)*f[1]; # the combination 1,1 .. 1
      sy:=0;
      for i in mat do
	sy:=sy*fs+Position(fl,v*i)-1;
      od;
      if not IsBound(reps[sy+1]) then
	reps[sy+1]:=v;
	for k in f do
	  sy:=0;
	  for i in mat do
	    sy:=sy*fs+Position(fl,k*v*i)-1;
	  od;
	  reps[sy+1]:=v*k;
	od;
	found:=found-l;
	if found=0 then 
	  return reps;
	fi;
      fi;

      # we let the coefficient of the first vector to be always 1. This in
      # effect runs projectively through the linear combinations, which is
      # just fine.
      for j in [1..l^(len-1)-1] do
	pos:=len;
	while cnt[pos]=l do
	  cnt[pos]:=1;
	  pos:=pos-1;
	od;
	cnt[pos]:=cnt[pos]+1;
	v:=z;
	for i in [1..len] do
	  v:=v+f[cnt[i]]*umat[i];
	od;

	sy:=0;
	for i in mat do
	  sy:=sy*fs+Position(fl,v*i)-1;
	od;
	if not IsBound(reps[sy+1]) then
	  reps[sy+1]:=v;
	  for k in f do
	    sy:=0;
	    for i in mat do
	      sy:=sy*fs+Position(fl,k*v*i)-1;
	    od;
	    reps[sy+1]:=v*k;
	  od;
	  found:=found-l;
	  if found=0 then 
	    return reps;
	  fi;
	fi;

      od;
    od;
  od;
  Error("did not find representatives!");
end);

#############################################################################
##
#E  listcoef.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


