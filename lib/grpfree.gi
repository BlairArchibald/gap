#############################################################################
##
#W  grpfree.gi                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for free groups.
##
##  Free groups are treated as   special cases of finitely presented  groups.
##  This  is done by making  the elements (more specifically, the generators)
##  of  a  free group to   have  the property   IsElementOfFpGroup.  See  the
##  function  FreeGroup().    In addition,   elements  of  a free   group are
##  (associative) words, that is they have a normal  form that allows an easy
##  equalitity test.  
##
Revision.grpfree_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  Iterator( <G> )
##
##  The implementation of iterator and enumerator for free groups is more
##  complicated than for free semigroups and monoids, since one has to be
##  careful to avoid cancellation of generators and their inverses when
##  building words.
##  So the iterator for a free group of rank $n$ uses the following ordering.
##  Enumerate signless words (that is, forget about the signs of exponents)
##  as given by the enumerator of free monoids, and for each such word
##  consisting of $k$, say, pairs of generators/exponents, enumerate all
##  $2^k$ possibilities of signs for the exponents.
##
##  The enumerator for a free group uses a different succession, in order to
##  make the bijection of words and positive integers easy to calculate.
##
##  There are exactly $2n (2n-1)^{l-1}$ words of length $l$, for $l > 0$.
##
##  So the word corresponding to the integer
##  $m = 1 + \sum_{i=1}^{l-1} 2n (2n-1)^{i-1} + m^{\prime}$,
##  with $1 \leq m^{\prime} \leq 2n (2n-1)^l$,
##  is the $m^{\prime}$-th word of length $l$.
##
##  Write $m^{\prime} - 1 = c_1 - 1 + \sum_{i=2}^l (c_i - 1) 2n (2n-1)^{i-2}$
##  where $1 \leq c_1 \leq 2n$ and $1 \leq c_i \leq 2n-1$ for
##  $2 \leq i \leq l$.
##
##  Let $(s_1, s_2, \ldots, s_{2n}) = (g_1, g_1^{-1}, g_2, \ldots, g_n^{-1})$
##  and translate the coefficient vector $(c_1, c_2, \ldots, c_l)$ to
##  $s(c_1) s(c_2) \cdots s(c_l)$, defined by $s(c_1) = s_{c_1}$, and
##  \[ s(c_{i+1}) = \left\{ \begin{array}{lcl}
##         s_{c_{i+1}}   & ; & c_i \equiv 1 \bmod 2, c_{i+1} \leq c_i \\
##         s_{c_{i+1}}   & ; & c_i \equiv 0 \bmod 2, c_{i+1} \leq c_{i-2} \\
##         s_{c_{i+1}+1} & ; & \mbox{\rm otherwise}
##                            \end{array} \right.    \]
##
DeclareRepresentation( "IsFreeGroupIteratorRep",
    IsComponentObjectRep,
    [ "family", "nrgenerators", "exp", "word", "counter", "length" ] );

InstallMethod( NextIterator,
    "for mutable iterator of a free group",
    true,
    [ IsIterator and IsMutable and IsFreeGroupIteratorRep ], 0,
    function( iter )

    local word,
          oldword,
          exp,
          len,
          pos,
          i;

    # Increase the counter.
    # Get the next sign distribution of same length if possible.
    word:= iter!.word;
    oldword:= ShallowCopy( word );
    exp:= iter!.exp;
    len:= Length( word );
    pos:= 2;
    while pos <= len and word[ pos ] < 0 do
      pos:= pos + 2;
    od;
    if pos <= len then
      for i in [ 2, 4 .. pos ] do
        word[i]:= - word[i];
      od;
    else

      # We have enumerated all sign vectors,
      # so we must take the next tuple.
      FreeSemigroup_NextWordExp( iter );

    fi;

    return ObjByExtRep( iter!.family, 1, exp, oldword );
    end );

InstallMethod( IsDoneIterator,
    "for iterator of a free group",
    true,
    [ IsIterator and IsFreeGroupIteratorRep ], 0,
    ReturnFalse );

InstallMethod( Iterator,
    "for a free group",
    true,
    [ IsAssocWordWithInverseCollection and IsWholeFamily ], 0,
    G -> Objectify( NewType( IteratorsFamily,
                                 IsIterator
                             and IsMutable
                             and IsFreeGroupIteratorRep ),
                    rec(
                         family         := ElementsFamily( FamilyObj( G ) ),
                         nrgenerators   := Length( GeneratorsOfGroup( G ) ),
                         exp            := 0,
                         word           := [],
                         length         := 0,
                         counter        := [ 0, 0 ]
                        )
                   ) );

InstallMethod( ShallowCopy,
    "for iterator of a free group",
    true,
    [ IsIterator and IsFreeGroupIteratorRep ], 0,
    iter -> Objectify( Subtype( TypeObj( iter ), IsMutable ),
                    rec(
                         family         := iter!.family,
                         nrgenerators   := iter!.nrgenerators,
                         exp            := iter!.exp,
                         word           := ShallowCopy( iter!.word ),
                         length         := iter!.length,
                         counter        := ShallowCopy( iter!.counter )
                        )
                   ) );


#############################################################################
##
#M  Enumerator( <G> )
##
DeclareRepresentation( "IsFreeGroupEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "family", "nrgenerators" ] );

InstallMethod( \[\],
    "for enumerator of a free group",
    true,
    [ IsFreeGroupEnumerator, IsPosInt ], 0,
    function( enum, nr )

    local n,
          2n,
          nn,
          l,
          power,
          word,
          exp,
          maxexp,
          cc,
          sign,
          i,
          c;

    if nr = 1 then
      return One( enum!.family );
    fi;

    n:= enum!.nrgenerators;
    2n:= 2 * n;
    nn:= 2n - 1;

    # Compute the length of the word corresponding to 'nr'.
    l:= 0;
    power:= 2n;
    nr:= nr - 1;
    while 0 < nr do
      nr:= nr - power;
      l:= l+1;
      power:= power * nn;
    od;
    nr:= nr + power / nn - 1;

    # Compute the vector of the '(nr + 1)'-th element of length 'l'.
    exp:= 0;
    maxexp:= 1;
    c:= nr mod 2n;
    nr:= ( nr - c ) / 2n;
    cc:= c;
    if c mod 2 = 0 then
      sign:= 1;
    else
      sign:= -1;
      c:= c-1;
    fi;
    word:= [ c/2 + 1 ];
    for i in [ 1 .. l ] do

      # translate 'c'
      if cc < c or ( cc mod 2 = 1 and cc-2 < c ) then
        c:= c+1;
      fi;

      if c = cc then
        exp:= exp + 1;
      else

        Add( word, sign * exp );
        if maxexp < exp then
          maxexp:= exp;
        fi;
        exp:= 1;

        cc:= c;
        if c mod 2 = 0 then
          sign:= 1;
        else
          sign:= -1;
          c:= c-1;
        fi;
        Add( word, c/2 + 1 );
      fi;
      c:= nr mod nn;
      nr:= ( nr - c ) / nn;
    od;
    Add( word, sign * exp );

    # Return the element.
    return ObjByExtRep( enum!.family, 1, maxexp, word );
    end );

InstallMethod( Position,
    "for enumerator of a free group",
    IsCollsElmsX,
    [ IsFreeGroupEnumerator, IsAssocWordWithInverse, IsZeroCyc ], 0,
    function( enum, elm, zero )

    local l,
          len,
          i,
          n,
          2n,
          nn,
          nr,
          j,
          power,
          c,
          cc,
          exp;

    elm:= ExtRepOfObj( elm );
    l:= Length( elm );

    if l = 0 then
      return 1;
    fi;

    # Calculate the length of the word.
    len:= 0;
    for i in [ 2, 4 .. l ] do
      exp:= elm[i];
      if 0 < exp then
        len:= len + elm[i];
      else
        len:= len - elm[i];
      fi;
    od;

    # Calculate the number of words of smaller length, plus 1.
    n:= enum!.nrgenerators;
    2n:= 2 * n;
    nn:= 2n - 1;
    nr:= 2;
    power:= 2n;
    for i in [ 1 .. len-1 ] do
      nr:= nr + power;
      power:= power * nn;
    od;

    # Add the position in the words of length 'len'.
    c:= 2 * elm[1] - 1;
    exp:= elm[2];
    if 0 < exp then
      c:= c-1;
    else
      exp:= -exp;
    fi;
    nr:= nr + c;
    power:= 2n;
    cc:= c;
    c:= c - ( c mod 2 );
    for j in [ 2 .. exp ] do
      nr:= nr + c * power;
      power:= power * nn;
    od;

    for i in [ 4, 6 .. l ] do
      c:= 2 * elm[ i-1 ] - 1;
      exp:= elm[i];
      if 0 < exp then
        c:= c-1;
      else
        exp:= -exp;
      fi;
      if cc < c or ( cc mod 2 = 1 and cc - 2 < c ) then
        cc:= c;
        c:= c - 1;
      else
        cc:= c;
      fi;
      nr:= nr + c * power;
      power:= power * nn;
      c:= cc - ( cc mod 2 );
      for j in [ 2 .. exp ] do
        nr:= nr + c * power;
        power:= power * nn;
      od;
    od;

    return nr;
    end );

InstallMethod( Enumerator,
    "for enumerator of a free group",
    true,
    [ IsAssocWordWithInverseCollection and IsWholeFamily and IsGroup ], 0,
#T generalize!
    function( G )
    local enum;
    enum:= Objectify( NewType( FamilyObj( G ), IsFreeGroupEnumerator ),
                    rec( family        := ElementsFamily( FamilyObj( G ) ),
                         nrgenerators  := Length( GeneratorsOfGroup( G ) ) )
                     );
    SetUnderlyingCollection( enum, G );
    return enum;
    end );


#############################################################################
##
#M  IsWholeFamily( <G> )
##
##  If all magma generators of the family are among the group generators
##  of <G> then <G> contains the whole family of its elements.
##
InstallMethod( IsWholeFamily,
    "for a free group",
    true,
    [ IsAssocWordWithInverseCollection and IsGroup ], 0,
    function( M )
    if IsSubset( MagmaGeneratorsOfFamily( ElementsFamily( FamilyObj( M ) ) ),
                 GeneratorsOfGroup( M ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Random( <M> )
##
#T isn't this a generic group method? (without guarantee about distribution)
##
InstallMethod( Random,
    "for a free group",
    true,
    [ IsAssocWordWithInverseCollection and IsGroup ], 0,
    function( M )

    local len,
          result,
          gens,
          i;

    # Get a random length for the word.
    len:= Random( Integers );
    if 0 < len then
      len:= 2 * len;
    elif len < 0 then
      len:= -2 * len - 1;
    else
      return One( M );
    fi;

    # Multiply 'len' random generator powers.
    gens:= GeneratorsOfGroup( M );
    result:= Random( gens ) ^ Random( Integers );
    for i in [ 2 .. len ] do
      result:= result * Random( gens ) ^ Random( Integers );
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . . . . .  for a free group
##
InstallMethod( Size,
    "for a free group",
    true,
    [ IsAssocWordWithInverseCollection and IsGroup ], 0,
    function( G )
    if IsTrivial( G ) then
      return 1;
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  MagmaGeneratorsOfFamily( <F> )
##
InstallMethod( MagmaGeneratorsOfFamily,
    "for a family of assoc. words",
    true,
    [ IsAssocWordWithInverseFamily ], 0,
    function( F )

    local gens;

    # Make the generators.
    gens:= List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) );
    Append( gens, List( [ 1 .. Length( F!.names ) ],
                 i -> ObjByExtRep( F, 1, 1, [ i, -1 ] ) ) );
    Add( gens, One( F ) );

    # Return the magma generators.
    return gens;
    end );


#############################################################################
##
#F  FreeGroup( <rank> ) . . . . . . . . . . . . . .  free group of given rank
#F  FreeGroup( <rank>, <name> )
#F  FreeGroup( <name1>, <name2>, ... )
#F  FreeGroup( <names> )
#F  FreeGroup( infinity, <name>, <init> )
##
InstallGlobalFunction( FreeGroup, function ( arg )

    local   names,      # list of generators names
            F,          # family of free group element objects
            G;          # free group, result

    # Get and check the argument list, and construct names if necessary.
    if   Length( arg ) = 1 and arg[1] = infinity then
      names:= InfiniteListOfNames( "f" );
    elif Length( arg ) = 2 and arg[1] = infinity then
      names:= InfiniteListOfNames( arg[2] );
    elif Length( arg ) = 3 and arg[1] = infinity then
      names:= InfiniteListOfNames( arg[2], arg[3] );
    elif Length( arg ) = 1 and IsInt( arg[1] ) and 0 <= arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( "f", String(i) ) );
      MakeImmutable( names );
    elif Length( arg ) = 2 and IsInt( arg[1] ) and 0 <= arg[1] then
      names:= List( [ 1 .. arg[1] ],
                    i -> Concatenation( arg[2], String(i) ) );
      MakeImmutable( names );
    elif Length( arg ) = 1 and IsList( arg[1] ) and IsEmpty( arg[1] ) then
      names:= arg[1];
    elif 1 <= Length( arg ) and ForAll( arg, IsString ) then
      names:= arg;
    elif Length( arg ) = 1 and IsList( arg[1] ) then
      names:= arg[1];
    else
      Error("usage: FreeGroup(<name1>,<name2>..) or FreeGroup(<rank>)");
    fi;

    # Construct the family of element objects of our group.
    F:= NewFamily( "FreeGroupElementsFamily", IsAssocWordWithInverse 
                            and IsElementOfFpGroup,
			    CanEasilySortElements, # the free group can.
			    CanEasilySortElements # the free group can.
			    );

    # Install the data (names, no. of bits available for exponents, types).
    StoreInfoFreeMagma( F, names, IsAssocWordWithInverse 
            and IsElementOfFpGroup );

    # Make the group.
    if IsEmpty( names ) then
      G:= GroupByGenerators( [], One( F ) );
    elif IsFinite( names ) then
      G:= GroupByGenerators( List( [ 1 .. Length( names ) ],
                     i -> ObjByExtRep( F, 1, 1, [ i, 1 ] ) ) );
    else
      G:= GroupByGenerators( InfiniteListOfGenerators( F ) );
      SetIsFinitelyGeneratedGroup( G, false );
    fi;

    SetIsWholeFamily( G, true );

    # Store whether the group is trivial.
    SetIsTrivial( G, Length( names ) = 0 );

    # Store the whole group in the family.
    FamilyObj(G)!.wholeGroup := G;
    SetFilterObj(G,IsGroupOfFamily);

    # Return the free group.
    return G;
end );


#############################################################################
##
#M  FreeGeneratorsOfFpGroup( <F> )
##
InstallMethod( FreeGeneratorsOfFpGroup,
    "for a free group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily and IsFreeGroup ], 0,
    GeneratorsOfGroup );


#############################################################################
##
#M  RelatorsOfFpGroup( <F> )
##
InstallMethod( RelatorsOfFpGroup,
    "for a free group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily and IsFreeGroup ], 0,
    F -> [] );


#############################################################################
##
#M  FreeGroupOfFpGroup( <F> )
##
InstallMethod( FreeGroupOfFpGroup,
    "for a free group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily and IsFreeGroup ], 0,
    IdFunc );


#############################################################################
##
#M  UnderlyingElement( w )
##
InstallMethod( UnderlyingElement,
    "for an element of a free group",
    true,
    [ IsElementOfFreeGroup ], 0,
    IdFunc );


#############################################################################
##
#M  ElementOfFpGroup( w )
##
InstallMethod( ElementOfFpGroup,
    "for a family of free group elements, and an assoc. word",
    true,
    [ IsElementOfFpGroupFamily and IsAssocWordWithInverseFamily,
      IsAssocWordWithInverse ], 0,
    function( fam, w ) return w; end );


#############################################################################
##
##  The methods for  testing equality, multiplying,  etc. are the same as for
##  IsAssocWordWithInverse.  However,  these methods   have to   be installed
##  again  for IsElementOfFpGroup in order   to  guarantee that they will  be
##  chosen over methods for elements of a finitely presented group.
##
#M  install            methods for all free group elements.
##
InstallMethod( InverseOp,
    "for a free group element",
    true,
    [ IsElementOfFreeGroup ], 0,
    AssocWordWithInverse_Inverse );

#############################################################################
##
#M  Install (internal) methods for elements of free groups (8 bits)
##

methname8b1 := "for a free group element (8 bits)";
methname8b2 := "for two free group elements (8 bits)";
methname16b1 := "for a free group element (16 bits)";
methname16b2 := "for two free group elements (16 bits)";
methname32b1 := "for a free group element (32 bits)";
methname32b2 := "for two free group elements (32 bits)";

InstallMethod( ExtRepOfObj,
    methname8b1,
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    8Bits_ExtRepOfObj );

InstallMethod( \=,
        methname8b1,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is8BitsAssocWord,
      IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    8Bits_Equal );

InstallMethod( \<,
        methname8b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is8BitsAssocWord,
      IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    8Bits_Less );

InstallMethod( \*,
        methname8b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is8BitsAssocWord, 
      IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    8Bits_Product );

InstallMethod( OneOp,
        methname8b1,
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    x -> 8Bits_AssocWord( FamilyObj( x )!.types[1], [] ) );

InstallMethod( \^,
    "for a free group element (8 bits), and a small integer",
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord,
      IsSmallIntRep and IsInt ], 0,
    8Bits_Power );

InstallMethod( ExponentSyllable,
    "for a free group element (8 bits), and a pos. integer",
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord, IsPosInt ], 0,
    8Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for a free group element (8 bits), and an integer",
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord, IsInt ], 0,
    8Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
        methname8b1,
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    8Bits_NumberSyllables );

InstallMethod( ExponentSums,
        methname8b1,
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord ], 0,
    8Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "for a free group element (8 bits), and two integers",
    true,
    [ IsElementOfFreeGroup and Is8BitsAssocWord, IsInt, IsInt ], 0,
    8Bits_ExponentSums3 );

#############################################################################
##
#M  Install (internal) methods for elements of free groups (16 bits)
##
InstallMethod( ExtRepOfObj,
    methname16b1,
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    16Bits_ExtRepOfObj );

InstallMethod( \=,
    methname16b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is16BitsAssocWord,
      IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    16Bits_Equal );

InstallMethod( \<,
    methname16b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is16BitsAssocWord,
      IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    16Bits_Less );

InstallMethod( \*,
    methname16b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is16BitsAssocWord, 
      IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    16Bits_Product );

InstallMethod( OneOp,
    methname16b1,
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    x -> 16Bits_AssocWord( FamilyObj( x )!.types[2], [] ) );

InstallMethod( \^,
    "for a free group element (16 bits), and a small integer",
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord,
      IsSmallIntRep and IsInt ], 0,
    16Bits_Power );

InstallMethod( ExponentSyllable,
    "for a free group element (16 bits), and a pos. integer",
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord, IsPosInt ], 0,
    16Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for a free group element (16 bits), and an integer",
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord, IsInt ], 0,
    16Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    methname16b1,
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    16Bits_NumberSyllables );

InstallMethod( ExponentSums,
    methname16b1,
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord ], 0,
    16Bits_ExponentSums1 );


InstallOtherMethod( ExponentSums,
    "for a free group element (16 bits), and two integers",
    true,
    [ IsElementOfFreeGroup and Is16BitsAssocWord, IsInt, IsInt ], 0,
    16Bits_ExponentSums3 );

#############################################################################
##
#M  Install (internal) methods for elements of free groups (32 bits)
##
InstallMethod( ExtRepOfObj,
    methname32b1,
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    32Bits_ExtRepOfObj );

InstallMethod( \=,
    methname32b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is32BitsAssocWord,
      IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    32Bits_Equal );

InstallMethod( \<,
    methname32b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is32BitsAssocWord,
      IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    32Bits_Less );

InstallMethod( \*,
    methname32b2,
    IsIdenticalObj,
    [ IsElementOfFreeGroup and Is32BitsAssocWord, 
      IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    32Bits_Product );

InstallMethod( OneOp,
    methname32b1,
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    x -> 32Bits_AssocWord( FamilyObj( x )!.types[3], [] ) );

InstallMethod( \^,
    "for a free group element (32 bits), and a small integer",
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord, 
      IsSmallIntRep and IsInt ], 0,
    32Bits_Power );

InstallMethod( ExponentSyllable,
    "for a free group element (32 bits), and a pos. integer",
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord, IsPosInt ], 0,
    32Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for a free group element (32 bits), and an integer",
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord, IsInt ], 0,
    32Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    methname32b1,
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    32Bits_NumberSyllables );

InstallMethod( ExponentSums,
    methname32b1,
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord ], 0,
    32Bits_ExponentSums1 );


InstallOtherMethod( ExponentSums,
    "for a free group element (32 bits), and two integers",
    true,
    [ IsElementOfFreeGroup and Is32BitsAssocWord, IsInt, IsInt ], 0,
    32Bits_ExponentSums3 );

#############################################################################
##
#M  Install            methods for elements of free groups (inf bits)
##
InstallMethod( ExtRepOfObj,
    "for a free group element (inf bits)",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    InfBits_ExtRepOfObj );

InstallMethod( \=,
    "for two free group elements (inf bits)",
    IsIdenticalObj,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord,
      IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    InfBits_Equal );

InstallMethod( \<,
    "for two free group elements (inf bits)",
    IsIdenticalObj,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord,
      IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    InfBits_Less );

InstallMethod( \*,
    "for two free group elements (inf bits)",
    IsIdenticalObj,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord, 
      IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    AssocWord_Product );

InstallMethod( OneOp,
    "for a free group element (inf bits)",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    x -> InfBits_AssocWord( FamilyObj( x )!.types[4], [] ) );

InstallMethod( \^,
    "for a free group element (inf bits), and a small integer",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord,
      IsSmallIntRep and IsInt ], 0,
    AssocWordWithInverse_Power );

InstallMethod( ExponentSyllable,
    "for a free group element (inf bits), and a pos. integer",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord, IsPosInt ], 0,
    InfBits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for a free group element (inf bits), and an integer",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord, IsInt ], 0,
    InfBits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "for a free group element (inf bits)",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    InfBits_NumberSyllables );

InstallMethod( ExponentSums,
    "for a free group element (inf bits)",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord ], 0,
    InfBits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "for a free group element (inf bits), and two integers",
    true,
    [ IsElementOfFreeGroup and IsInfBitsAssocWord, IsInt, IsInt ], 0,
    InfBits_ExponentSums3 );

#############################################################################
##
#M  Install            methods for elements of free groups, mixed bit type
##
InstallMethod( \=,
    "for two free group elements (using extrep)",
    IsIdenticalObj,
    [ IsElementOfFreeGroup, IsElementOfFreeGroup ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y ); end );

InstallMethod( \<,
    "for two free group elements (using extrep)",
    IsIdenticalObj,
    [ IsElementOfFreeGroup, IsElementOfFreeGroup ], 0,
    function( x, y )
    return ExtRepOfObj( x ) < ExtRepOfObj( y ); end );

InstallMethod( \*,
    "for two free group elements (using extrep)",
    IsIdenticalObj,
    [ IsElementOfFreeGroup, IsElementOfFreeGroup ], 0,
    AssocWord_Product );


#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod( ViewObj,
    "subgroup of free group",
    true,
    [ IsFreeGroup ], 0,
function(G)
  if IsGroupOfFamily(G) then
    if Length(GeneratorsOfGroup(G))>VIEWLEN*10 then
      Print("<free group with ",Length(GeneratorsOfGroup(G))," generators>");
    else
      Print("<free group on the generators ",GeneratorsOfGroup(G),">");
    fi;
  else
    Print("Group(");
    if HasGeneratorsOfGroup(G) then
      if not IsBound(G!.gensWordLengthSum) then
	G!.gensWordLengthSum:=Sum(List(GeneratorsOfGroup(G),Length));
      fi;
      if G!.gensWordLengthSum<=VIEWLEN*30 then
        Print(GeneratorsOfGroup(G));
      else
        Print("<",Length(GeneratorsOfGroup(G))," generators>");
      fi;
    else
      Print("<free, no generators known>");
    fi;
    Print(")");
  fi;
end);


#############################################################################
##
#M  \.( <F>, <n> )  . . . . . . . . . .  access to generators of a free group
##
InstallAccessToGenerators( IsSubgroupFpGroup and IsGroupOfFamily
                                             and IsFreeGroup,
                           "free group containing the whole family",
                           GeneratorsOfMagmaWithInverses );


#############################################################################
##
#E

