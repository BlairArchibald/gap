#############################################################################
##
#W  coll.gi                     GAP library                  Martin Schoenert
#W                                                            & Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains methods for collections in general.
##
Revision.coll_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  CollectionsFamily(<F>)  . . . . . . . . . . . . . . . . .  generic method
##
InstallMethod( CollectionsFamily,
    "for a family",
    true, [ IsFamily ], 90,
    function ( F )
    local   colls, coll_req, coll_imp, elms_flags, tmp;
    coll_req := IsCollection;
    coll_imp := IsObject;
    elms_flags := F!.IMP_FLAGS;
    for tmp  in CATEGORIES_COLLECTIONS  do
        if IS_SUBSET_FLAGS( elms_flags, FLAGS_FILTER( tmp[1] ) )  then
            coll_imp := coll_imp and tmp[2];
        fi;
    od;
    colls := NewFamily( "CollectionsFamily(...)", coll_req, coll_imp );
    SetElementsFamily( colls, F );
    return colls;
    end );


#############################################################################
##
#V  IteratorsFamily
##
BIND_GLOBAL( "IteratorsFamily", NewFamily( "IteratorsFamily", IsIterator ) );


#############################################################################
##
#M  ViewObj( <iter> ) . . . . . . . . . . . . . . . . . . .  view an iterator
##
InstallMethod( ViewObj,
    "for an iterator",
    true,
    [ IsIterator ], 0,
    function( iter )
    if IsMutable( iter ) then
      Print( "<iterator>" );
    else
      Print( "<iterator (immutable)>" );
    fi;
    end );


#############################################################################
##
#M  PrintObj( <iter> )  . . . . . . . . . . . . . . . . . . print an iterator
##
InstallMethod( PrintObj,
    "for an iterator",
    true, [ IsIterator ], 0,
    function( iter )
    if IsMutable( iter ) then
      Print( "<iterator>" );
    else
      Print( "<iterator (immutable)>" );
    fi;
#T this is not nice!
    end );


#############################################################################
##
#M  IsEmpty(<C>)  . . . . . . . . . . . . . . . test if a collection is empty
##
InstallImmediateMethod( IsEmpty,
    IsCollection and HasSize, 0,
    function ( C )
    return (Size( C ) = 0);
    end );

InstallMethod( IsEmpty,
    "for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    return (Size( C ) = 0);
    end );

InstallMethod( IsEmpty,
    "for a list",
    true, [ IsList ], 0,
    function ( list )
    return (Length( list ) = 0);
    end );
#T non-homogeneous lists should know that they are nonempty


#############################################################################
##
#M  IsTrivial(<C>)  . . . . . . . . . . . . . test if a collection is trivial
##
InstallImmediateMethod( IsTrivial,
    IsCollection and HasSize, 0,
    function ( C )
    return (Size( C ) = 1);
    end );

InstallMethod( IsTrivial,
    "for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    return (Size( C ) = 1);
    end );

InstallImmediateMethod( IsTrivial,
    IsCollection and HasIsNonTrivial, 0,
    C -> not IsNonTrivial( C ) );


#############################################################################
##
#M  IsNonTrivial( <C> ) . . . . . . . . .  test if a collection is nontrivial
##
InstallImmediateMethod( IsNonTrivial,
    IsCollection and HasIsTrivial, 0,
    C -> not IsTrivial( C ) );

InstallMethod( IsNonTrivial,
    "for a collection",
    true,
    [ IsCollection ], 0,
    C -> Size( C ) <> 1 );


#############################################################################
##
#M  IsFinite(<C>) . . . . . . . . . . . . . .  test if a collection is finite
##
InstallImmediateMethod( IsFinite,
    IsCollection and HasSize, 0,
    function ( C )
    return not IsIdenticalObj( Size( C ), infinity );
    end );

InstallMethod( IsFinite,
    "for a collection",
    true,
    [ IsCollection ], 0,
    function ( C )
    return Size( C ) < infinity;
    end );


#############################################################################
##
#M  IsWholeFamily(<C>)  . . .  test if a collection contains the whole family
##
InstallMethod( IsWholeFamily,
    "for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    Error( "cannot test whether <C> contains the family of its elements" );
    end );


#############################################################################
##
#M  Size(<C>) . . . . . . . . . . . . . . . . . . . . .  size of a collection
##
InstallImmediateMethod( Size,
    IsCollection and HasIsFinite, 0,
    function ( C )
    if IsFinite( C ) then
        TryNextMethod();
    fi;
    return infinity;
    end );

InstallImmediateMethod( Size,
    IsCollection and HasAsList, 0,
    function ( C )
    return Length( AsList( C ) );
    end );

InstallMethod( Size,
    "for a collection",
    true,
    [ IsCollection ], 0,
    function ( C )
    return Length( Enumerator( C ) );
    end );


#############################################################################
##
#M  Representative( <C> ) . . . . . . . . . . for a collection that is a list
##
InstallMethod( Representative,
    "for a collection that is a list",
    true,
    [ IsCollection and IsList ], 0,
    function ( C )
    local   elm;
    if IsEmpty( C ) then
      Error( "<C> must be nonempty to have a representative" );
    else
      return C[1];
    fi;
    end );

InstallImmediateMethod( RepresentativeSmallest,
    IsCollection and HasEnumeratorSorted, 1000,
    function( C )
    C:= EnumeratorSorted( C );
    if IsEmpty( C ) then
      TryNextMethod();
    else
      return C[1];
    fi;
    end );

InstallImmediateMethod( RepresentativeSmallest,
    IsCollection and HasAsSSortedList, 1000,
    function( C )
    C:= AsSSortedList( C );
    if IsEmpty( C ) then
      TryNextMethod();
    else
      return C[1];
    fi;
    end );

InstallMethod( RepresentativeSmallest,
    "for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    local   elm;
    for elm in EnumeratorSorted( C ) do
        return elm;
    od;
    Error( "<C> must be nonempty to have a representative" );
    end );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . . . . . . . . . . . . . .  for a list
#M  Random( <C> ) . . . . . . . . . . . . . . . . . . . . .  for a collection
##
##  The default function for random selection in a finite collection computes
##  an enumerator of <C> and selects a random element of this list using the
##  function `RANDOM_LIST', which is a pseudo random number generator.
##
InstallMethod( Random,
    "for an internal list",
    true,
    [ IsList and IsInternalRep ], 100,
#T ?
    RANDOM_LIST );

InstallMethod( Random,
    "for a (finite) collection",
    true,
    [ IsCollection ], 10,
    function ( C )
    if not IsFinite( C ) then
        TryNextMethod();
    fi;
    return RANDOM_LIST( Enumerator( C ) );
    end );


#############################################################################
##
#M  PseudoRandom( <list> )  . . . . . . . . . . . . . . . . . . .  for a list
##
InstallMethod( PseudoRandom,
    "for an internal list",
    true,
    [ IsList and IsInternalRep ], 100,
#T ?
    RANDOM_LIST );


#############################################################################
##
#M  AsList( <coll> )
##
InstallMethod( AsList,
    "for a collection",
    true,
    [ IsCollection ],
    0,
    coll -> ConstantTimeAccessList( Enumerator( coll ) ) );

InstallMethod( AsList,
    "for collections that are constant time access lists",
    true,
    [ IsCollection and IsConstantTimeAccessList ],
    0,
    Immutable );


#############################################################################
##
#M  AsSSortedList( <coll> )
##
InstallMethod( AsSSortedList,
    "for a collection",
    true,
    [ IsCollection ],
    0,
    coll -> ConstantTimeAccessList( EnumeratorSorted( coll ) ) );

InstallOtherMethod( AsSSortedList,
    "for a collection that is a constant time access list",
    true,
    [ IsCollection and IsConstantTimeAccessList ],
    0,
    l->AsSSortedListList(AsPlist(l)) );


#############################################################################
##
#M  Enumerator( <C> )
##
InstallImmediateMethod( Enumerator,
    IsCollection and HasAsList, 0,
    AsList );


InstallMethod( Enumerator,
    "for a collection with known `AsList' value",
    true,
    [ IsCollection and HasAsList ], SUM_FLAGS,
    AsList );

InstallMethod( Enumerator,
    "for a collection with known `AsSSortedList' value",
    true,
    [ IsCollection and HasAsSSortedList ], SUM_FLAGS,
    AsSSortedList );

InstallMethod( Enumerator,
    "for a collection that is a list",
    true,
    [ IsCollection and IsList ], 0,
    Immutable );


#############################################################################
##
#M  EnumeratorSorted(<C>)
##
InstallImmediateMethod( EnumeratorSorted,
    IsCollection and HasAsSSortedList, 0,
    AsSSortedList );


InstallMethod( EnumeratorSorted,
    "for a collection",
    true,
    [ IsCollection ], 0,
    coll -> AsSSortedListList(AsPlist( Enumerator( coll ) ) ));

InstallMethod( EnumeratorSorted,
    "for a collection with known `AsSSortedList' value",
    true,
    [ IsCollection and HasAsSSortedList ], SUM_FLAGS,
    AsSSortedList );

InstallMethod( EnumeratorSorted, "for a collection that is a plist",
    true, [ IsCollection and IsPlistRep ], 0,
    AsSSortedListList);

InstallMethod( EnumeratorSorted, "for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    l->AsSSortedListList(AsPlist(l)));


#############################################################################
##
#M  ViewObj( <enum> ) . . . . . . . . . . . . . . . . . .  view an enumerator
##
InstallMethod( ViewObj,
    "for an enumerator",
    true,
    [ IsList and IsAttributeStoringRep ], 0,
    function( enum )
    Print( "<enumerator>" );
    end );


#############################################################################
##
#M  PrintObj( <enum> )  . . . . . . . . . . . . . . . . . print an enumerator
##
InstallMethod( PrintObj,
    "for an enumerator",
    true,
    [ IsList and IsAttributeStoringRep ], 0,
    function( enum )
    Print( "<enumerator>" );
    end );
#T this is not nice!


#############################################################################
##
#R  IsEnumeratorOfSubsetDefaultRep
##
DeclareRepresentation( "IsEnumeratorOfSubsetDefaultRep",
    IsAttributeStoringRep,
    [ "list", "blist" ] );


#############################################################################
##
#M  Length( <senum> ) . . . . . . . . . . . . . .  for enumerators of subsets
##
InstallMethod( Length,
    "for enumerator of subset in default repres.",
    true,
    [ IsList and IsEnumeratorOfSubsetDefaultRep ], 0,
    senum -> SIZE_BLIST( senum!.blist ) );


#############################################################################
##
#M  <senum>[ <num> ]  . . . . . . . . . . . . . .  for enumerators of subsets
##
InstallMethod( \[\],
    "for enumerator of subset in default repres., and pos. integer",
    true,
    [ IsList and IsEnumeratorOfSubsetDefaultRep, IsPosInt ], 0,
    function( senum, num )
    local pos;
    pos:= PositionNthTrueBlist( senum!.blist, num );
    if pos = fail then
      Error( "List Element: <list>[", num, "] must have an assigned value" );
    else
      return senum!.list[ pos ];
    fi;
    end );


#############################################################################
##
#M  PositionCanonical( <senum>, <elm> ) . . . . .  for enumerators of subsets
##
InstallMethod( PositionCanonical,
    "for enumerator of subset in default repres., and object",
    true,
    [ IsList and IsEnumeratorOfSubsetDefaultRep, IsObject ], 0,
    function( senum, elm )
    local pos;
    
    pos:= PositionCanonical( senum!.list, elm );
    if pos = fail or not senum!.blist[ pos ] then
      return fail;
    else
      return SIZE_BLIST( senum!.blist{ [ 1 .. pos ] } );
    fi;
    end );


#############################################################################
##
#M  ConstantTimeAccessList( <senum> ) . . . . . .  for enumerators of subsets
##
InstallMethod( ConstantTimeAccessList,
    "for enumerator of subset in default repres.",
    true,
    [ IsList and IsEnumeratorOfSubsetDefaultRep ], 0,
    senum -> senum!.list{ LIST_BLIST( [ 1 .. Length( senum!.list ) ],
                                     senum!.blist ) } );


#############################################################################
##
#F  EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )
##
InstallGlobalFunction( EnumeratorOfSubset,
    function( arg )

    local list, blist, Fam;

    # Get and check the arguments.
    if Length( arg ) < 2 or 3 < Length( arg ) then
      Error( "usage: EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )" );
    fi;
    list:= arg[1];
    blist:= arg[2];

    # Determine the family of the result.
    if IsHomogeneousList( list ) then
      Fam:= FamilyObj( list );
    elif Length( arg ) = 2 then
      Error( "missing third argument <ishomog> for inhomog. <list>" );
    elif arg[3] = true then
      Fam:= FamilyObj( list );
    else
      Fam:= ListsFamily;
    fi;

    # Construct the enumerator.
    return Objectify( NewType( Fam,
                               IsList and IsEnumeratorOfSubsetDefaultRep ),
                      rec( list  := list,
                           blist := blist ) );
    end );


#############################################################################
##
#F  List( <coll> )
#F  List( <coll>, <func> )
##
InstallGlobalFunction( List,
    function( arg )
    local tnum, C, func, res, i, elm, l;
    l := Length(arg);
    if l = 0 then
      Error( "usage: List( <C>[, <func>] )" );
    fi;
    tnum:= TNUM_OBJ_INT( arg[1] );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        return ShallowCopy( C );
      else
        func:= arg[2];
        res := [];
        i   := 0;
        for elm in C do
          i:= i+1;
          res[i]:= func( elm );
        od;
        return res;
      fi;
    else
      return CallFuncList( ListOp, arg );
    fi;
end );


#############################################################################
##
#M  ListOp( <coll> )
##
InstallMethod( ListOp,
    "for a collection",
    true,
    [ IsCollection ], 0,
    C -> ShallowCopy( Enumerator( C ) ) );

InstallMethod( ListOp,
    "for a collection that is a list",
    true,
    [ IsCollection and IsList ], 0,
    ShallowCopy );


#############################################################################
##
#M  ListOp( <coll>, <func> )
##
InstallOtherMethod( ListOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   res, i, elm;
    res := [];
    i   := 0;
    for elm in C do
      i:= i+1;
      res[i]:= func( elm );
    od;
    return res;
    end );

#############################################################################
##
#M  SortedList( <C> )
##
InstallMethod( SortedList, "for a list or collection",
    true, [ IsListOrCollection ], 0,
function(C)
local l;
  l:=List(C);
  if not IsDenseList(l) then
    l:=List(l,i->i);
  fi;
  Sort(l);
  return l;
end);

InstallMethod( AsSortedList, "for a list or collection",
        true, [ IsListOrCollection ], 0, 
        function(l) 
    local s;
    s := SortedList(l);
    MakeImmutable(s);
    return s;
end);

#############################################################################
##
#M  SSortedList( <C> )
##
InstallMethod( SSortedList,
    "for a collection",
    true, [ IsCollection ], 0,
    C -> ShallowCopy( EnumeratorSorted( C ) ) );

InstallMethod( SSortedList,
    "for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    SSortedListList );


#############################################################################
##
#M  SSortedList( <C>, <func> )
##
InstallOtherMethod( SSortedList,
    "for a collection, and a function",
    true, [ IsCollection, IsFunction ], 0,
    function ( C, func )
    return SSortedListList( List( C, func ) );
    end );


#############################################################################
##
#M  Iterator(<C>)
##
InstallMethod( Iterator,
    "for a collection",
    true, [ IsCollection ], 0,
    C -> IteratorList( Enumerator( C ) ) );

InstallMethod( Iterator,
    "for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    C -> IteratorList( C ) );

InstallOtherMethod( Iterator,
    "for a mutable iterator",
    true,
    [ IsIterator and IsMutable ], 0,
    IdFunc );
#T or change the for-loop to accept iterators?


#############################################################################
##
#M  IteratorSorted(<C>)
##
InstallMethod( IteratorSorted,
    "for a collection",
    true, [ IsCollection ], 0,
    C -> IteratorList( EnumeratorSorted( C ) ) );

InstallMethod( IteratorSorted,
    "for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    C -> IteratorList( SSortedListList( C ) ) );


#############################################################################
##
#M  NextIterator( <iter> ) . . . . . . for immutable iterator (error message)
##
InstallOtherMethod( NextIterator,
    "for an immutable iterator (print a reasonable error message)",
    true,
    [ IsIterator ], 0,
    function( iter )
    if IsMutable( iter ) then
      TryNextMethod();
    fi;
    Error( "no `NextIterator' method for immutable iterator <iter>" );
    end );


#############################################################################
##
#R  IsTrivialIteratorRep( <iter> )
##
DeclareRepresentation( "IsTrivialIteratorRep",
    IsComponentObjectRep, [ "element", "isDone" ] );


#############################################################################
##
#F  TrivialIterator( <elm> )
##
InstallGlobalFunction( TrivialIterator, function( elm )
    return Objectify( NewType( IteratorsFamily,
                                   IsIterator
                               and IsMutable
                               and IsTrivialIteratorRep ),
                      rec( element := elm, isDone := false ) );
end );

InstallMethod( IsDoneIterator,
    "for a trivial iterator",
    true,
    [ IsIterator and IsTrivialIteratorRep ], 0,
    iter -> iter!.isDone );

InstallMethod( NextIterator,
    "for a mutable trivial iterator",
    true,
    [ IsIterator and IsMutable and IsTrivialIteratorRep ], 0,
    function( iter )
    iter!.isDone:= true;
    return iter!.element;
    end );

InstallMethod( Iterator,
    "for a trivial collection",
    true,
    [ IsCollection and IsTrivial ], SUM_FLAGS,
    D -> TrivialIterator( Enumerator( D )[1] ) );

InstallMethod( ShallowCopy,
    "for a trivial iterator",
    true,
    [ IsIterator and IsTrivialIteratorRep ], 0,
    function( iter )
    if iter!.isDone then
      return iter;
    else
      return TrivialIterator( iter!.elm );
    fi;
    end );


#############################################################################
##
#F  Sum( <coll> )
#F  Sum( <coll>, <func> )
#F  Sum( <coll>, <init> )
#F  Sum( <coll>, <func>, <init> )
##
InstallGlobalFunction( Sum,
    function( arg )
    local tnum, C, func, sum, i, l;
    l := Length( arg );
    if l = 0 then
      Error( "usage: Sum( <C>[, <func>][, <init>] )" );
    fi;
    tnum:= TNUM_OBJ_INT( arg[1] );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        if IsEmpty( C ) then
          sum:= 0;
        else
          sum:= C[1];
          for i in [ 2 .. Length( C ) ] do
            sum:= sum + C[i];
          od;
        fi;
      elif l = 2 and IsFunction( arg[2] ) then
        func:= arg[2];
        if IsEmpty( C ) then
          sum:= 0;
        else
          sum:= func( C[1] );
          for i in [ 2 .. Length( C ) ] do
            sum:= sum + func( C[i] );
          od;
        fi;
      elif l = 2 then
        sum:= arg[2];
        for i in C do
          sum:= sum + i;
        od;
      elif l = 3 and IsFunction( arg[2] ) then
        func:= arg[2];
        sum:= arg[3];
        for i in C do
          sum:= sum + func( i );
        od;
      else
        Error( "usage: Sum( <C>[, <func>][, <init>] )" );
      fi;
      return sum;
    else
      return CallFuncList( SumOp, arg );
    fi;
end );


#############################################################################
##
#M  SumOp( <C> )  . . . . . . . . . . . . . . . . . . . for a list/collection
##
InstallMethod( SumOp,
    "for a list/collection",
    true,
    [ IsListOrCollection ], 0,
    function ( C )
    local   sum;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        sum := NextIterator( C );
        while not IsDoneIterator( C ) do
            sum := sum + NextIterator( C );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  SumOp( <C>, <func> )  . . . . . . . for a list/collection, and a function
##
InstallOtherMethod( SumOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   sum;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        sum := func( NextIterator( C ) );
        while not IsDoneIterator( C ) do
            sum := sum + func( NextIterator( C ) );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  SumOp( <C>, <init> )  . . . . . .  for a list/collection, and init. value
##
InstallOtherMethod( SumOp,
    "for a list/collection, and init. value",
    true,
    [ IsListOrCollection, IsAdditiveElement ], 0,
    function ( C, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init + NextIterator( C );
    od;
    return init;
    end );


#############################################################################
##
#M  SumOp( <C>, <func>, <init> )  . for a list/coll., a func., and init. val.
##
InstallOtherMethod( SumOp,
    "for a list/collection, and a function, and an initial value",
    true,
    [ IsListOrCollection, IsFunction, IsAdditiveElement ], 0,
    function ( C, func, init )
    local   sum, i;
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init + func( NextIterator( C ) );
    od;
    return init;
    end );


#############################################################################
##
#F  Product( <coll> )
#F  Product( <coll>, <func> )
#F  Product( <coll>, <init> )
#F  Product( <coll>, <func>, <init> )
##
InstallGlobalFunction( Product,
    function( arg )
    local tnum, C, func, product, i, l;
    l := Length(arg);
    if l = 0 then
      Error( "usage: Product( <C>[, <func>][, <init>] )" );
    fi;
    tnum:= TNUM_OBJ_INT( arg[1] );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        if IsEmpty( C ) then
          product:= 1;
        else
          product:= C[1];
          for i in [ 2 .. Length( C ) ] do
            product:= product * C[i];
          od;
        fi;
      elif l = 2 and IsFunction( arg[2] ) then
        func:= arg[2];
        if IsEmpty( C ) then
          product:= 1;
        else
          product:= func( C[1] );
          for i in [ 2 .. Length( C ) ] do
            product:= product * func( C[i] );
          od;
        fi;
      elif l = 2 then
        product:= arg[2];
        for i in C do
          product:= product * i;
        od;
      elif l = 3 and IsFunction( arg[2] ) then
        func:= arg[2];
        product:= arg[3];
        for i in C do
          product:= product * func( i );
        od;
      else
        Error( "usage: Product( <C>[, <func>][, <init>] )" );
      fi;
      return product;
    else
      return CallFuncList( ProductOp, arg );
    fi;
end );


#############################################################################
##
#M  ProductOp( <C> )  . . . . . . . . . . . . . . . . . for a list/collection
##
InstallMethod( ProductOp,
    "for a list/collection",
    true,
    [ IsListOrCollection ], 0,
    function ( C )
    local   prod;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        prod := NextIterator( C );
        while not IsDoneIterator( C ) do
            prod := prod * NextIterator( C );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );


#############################################################################
##
#M  ProductOp( <C>, <func> )  . . . . . for a list/collection, and a function
##
InstallOtherMethod( ProductOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   prod, i;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        prod := func( NextIterator( C ) );
        while not IsDoneIterator( C ) do
            prod := prod * func( NextIterator( C ) );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );


#############################################################################
##
#M  ProductOp( <C>, <init> )  . . . .  for a list/collection, and init. value
##
InstallOtherMethod( ProductOp,
    "for a list/collection, and initial value",
    true,
    [ IsListOrCollection, IsMultiplicativeElement ], 0,
    function ( C, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init * NextIterator( C );
    od;
    return init;
    end );


#############################################################################
##
#M  ProductOp( <C>, <func>, <init> )  . . . for list/coll., func., init. val.
##
InstallOtherMethod( ProductOp,
    "for a list/collection, a function, and an initial value",
    true,
    [ IsListOrCollection, IsFunction, IsMultiplicativeElement ], 0,
    function ( C, func, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init * func( NextIterator( C ) );
    od;
    return init;
    end );


#############################################################################
##
#F  ProductMod(<l>,<m>) . . . . . . . . . . . . . . . . . .  Product(l) mod m
##
ProductMod := function(l,m)
local i,p;
  if l=[] then
    p:=1;
  else
    p:=l[1]^0;
  fi;
  for i in l do
    p:=p*i mod m;
  od;
  return p;
end;


#############################################################################
##
#F  Filtered( <coll>, <func> )
##
InstallGlobalFunction( Filtered,
    function( C, func )
    local tnum, res, i, elm;
    tnum:= TNUM_OBJ_INT( C );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      res := [];
      i   := 0;
      for elm in C do
        if func( elm ) then
          i:= i+1;
          res[i]:= elm;
        fi;
      od;
      return res;
    else
      return FilteredOp( C, func );
    fi;
end );


#############################################################################
##
#M  FilteredOp( <C>, <func> ) . . . . . extract elements that have a property
##
InstallMethod( FilteredOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local res, elm;
    res := [];
    for elm in C do
        if func( elm ) then
            Add( res, elm );
        fi;
    od;
    return res;
    end );

InstallMethod( FilteredOp,
    "for an empty list/collection, and a function",
    true,
    [ IsEmpty, IsFunction ], SUM_FLAGS,
    function( list, func )
    return [];
    end );


#############################################################################
##
#F  Number( <coll> )
#F  Number( <coll>, <func> )
##
InstallGlobalFunction( Number,
    function( arg )
    local tnum, C, func, nr, elm,l;
    l := Length( arg );
    if l = 0 then
      Error( "usage: Number( <C>[, <func>] )" );
    fi;
    tnum:= TNUM_OBJ_INT( arg[1] );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        nr := 0;
        for elm in C do
            nr := nr + 1;
        od;
        return nr;
      else
        func:= arg[2];
        nr := 0;
        for elm in C do
            if func( elm ) then
                nr:= nr + 1;
            fi;
        od;
        return nr;
      fi;
    else
      return CallFuncList( NumberOp, arg );
    fi;
end );


#############################################################################
##
#M  NumberOp( <C>, <func> ) . . . . . . . count elements that have a property
##
InstallMethod( NumberOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local nr, elm;
    nr := 0;
    for elm in C do
        if func( elm ) then
            nr:= nr + 1;
        fi;
    od;
    return nr;
    end );


#############################################################################
##
#M  NumberOp( <C> ) . . . . . . . . . . . count elements that have a property
##
InstallOtherMethod( NumberOp,
    "for a list/collection",
    true,
    [ IsListOrCollection ], 0,
    function ( C )
    local nr, elm;
    nr := 0;
    for elm in C do
        nr := nr + 1;
    od;
    return nr;
    end );


#############################################################################
##
#F  ForAll( <coll>, <func> )
##
InstallGlobalFunction( ForAll,
    function( C, func )
    local tnum, elm;
    tnum:= TNUM_OBJ_INT( C );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
          if not func( elm ) then
              return false;
          fi;
      od;
      return true;
    else
      return ForAllOp( C, func );
    fi;
end );


#############################################################################
##
#M  ForAllOp( <C>, <func> ) . . .  test a property for all elements of a list
##
InstallMethod( ForAllOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local elm;
    for elm in C do
        if not func( elm ) then
            return false;
        fi;
    od;
    return true;
    end );

InstallOtherMethod( ForAllOp,
    "for an empty list/collection, and a function",
    true,
    [ IsEmpty, IsFunction ], SUM_FLAGS,
    ReturnTrue );


#############################################################################
##
#F  ForAny( <coll>, <func> )
##
InstallGlobalFunction( ForAny,
    function( C, func )
    local tnum, elm;
    tnum:= TNUM_OBJ_INT( C );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
          if func( elm ) then
              return true;
          fi;
      od;
      return false;
    else
      return ForAnyOp( C, func );
    fi;
end );


#############################################################################
##
#M  ForAnyOp( <C>, <func> ) . . . . test a property for any element of a list
##
InstallMethod( ForAnyOp,
    "for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local elm;
    for elm in C do
        if func( elm ) then
            return true;
        fi;
    od;
    return false;
    end );

InstallOtherMethod( ForAnyOp,
    "for an empty list/collection, and a function",
    true,
    [ IsEmpty, IsFunction ], SUM_FLAGS,
    ReturnFalse );


#############################################################################
##
#M  ListX(<obj>,...)
##
ListXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                ListXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, CallFuncList( gens[i+1], vals ) );
end;
MAKE_READ_ONLY_GLOBAL( "ListXHelp" );

BIND_GLOBAL( "ListXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                ListXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, gens[i+1]( val1, val2 ) );
end );

BIND_GLOBAL( "ListXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val2  in gen  do
                ListXHelp2( result, gens, i+1, val1, val2 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, gens[i+1]( val1 ) );
end );

BIND_GLOBAL( "ListXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val1  in gen  do
                ListXHelp1( result, gens, i+1, val1 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, gens[i+1]() );
end );

InstallGlobalFunction( ListX, function ( arg )
    local   result;
    result := [];
    ListXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  SetX(<obj>,...)
##
SetXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                SetXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, CallFuncList( gens[i+1], vals ) );
end;
MAKE_READ_ONLY_GLOBAL( "SetXHelp" );

BIND_GLOBAL( "SetXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                SetXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, gens[i+1]( val1, val2 ) );
end );

BIND_GLOBAL( "SetXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val2  in gen  do
                SetXHelp2( result, gens, i+1, val1, val2 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, gens[i+1]( val1 ) );
end );

BIND_GLOBAL( "SetXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val1  in gen  do
                SetXHelp1( result, gens, i+1, val1 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, gens[i+1]() );
end );

InstallGlobalFunction( SetX, function ( arg )
    local   result;
    result := [];
    SetXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  SumX(<obj>,...)
##
SumXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                result := SumXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := CallFuncList( gens[i+1], vals );
    else
        result := result + CallFuncList( gens[i+1], vals );
    fi;
    return result;
end;
MAKE_READ_ONLY_GLOBAL( "SumXHelp" );

BIND_GLOBAL( "SumXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                result := SumXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1, val2 );
    else
        result := result + gens[i+1]( val1, val2 );
    fi;
    return result;
end );

BIND_GLOBAL( "SumXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val2  in gen  do
                result := SumXHelp2( result, gens, i+1, val1, val2 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1 );
    else
        result := result + gens[i+1]( val1 );
    fi;
    return result;
end );

BIND_GLOBAL( "SumXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val1  in gen  do
                result := SumXHelp1( result, gens, i+1, val1 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]();
    else
        result := result + gens[i+1]();
    fi;
    return result;
end );

InstallGlobalFunction( SumX, function ( arg )
    local   result;
    result := fail;
    result := SumXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  ProductX(<obj>,...)
##
ProductXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                result := ProductXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := CallFuncList( gens[i+1], vals );
    else
        result := result * CallFuncList( gens[i+1], vals );
    fi;
    return result;
end;
MAKE_READ_ONLY_GLOBAL( "ProductXHelp" );

BIND_GLOBAL( "ProductXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                result := ProductXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1, val2 );
    else
        result := result * gens[i+1]( val1, val2 );
    fi;
    return result;
end );

BIND_GLOBAL( "ProductXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val2  in gen  do
                result := ProductXHelp2( result, gens, i+1, val1, val2 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1 );
    else
        result := result * gens[i+1]( val1 );
    fi;
    return result;
end );

BIND_GLOBAL( "ProductXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val1  in gen  do
                result := ProductXHelp1( result, gens, i+1, val1 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]();
    else
        result := result * gens[i+1]();
    fi;
    return result;
end );

InstallGlobalFunction( ProductX, function ( arg )
    local   result;
    result := fail;
    result := ProductXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  IsSubset( <C1>, <C2> )
##
InstallMethod( IsSubset,
    "for two collections in different families",
    IsNotIdenticalObj,
    [ IsCollection,
      IsCollection ],
    0,
    ReturnFalse );

InstallMethod( IsSubset,
    "for empty list and collection",
    true,
    [ IsList and IsEmpty,
      IsCollection ],
    0,
    function( empty, coll )
    return IsEmpty( coll );
    end );

InstallMethod( IsSubset,
    "for collection and empty list",
    true,
    [ IsCollection,
      IsList and IsEmpty ],
    0,
    ReturnTrue );

InstallMethod( IsSubset,
    "for two collections, the first containing the whole family",
    IsIdenticalObj,
    [ IsCollection and IsWholeFamily,
      IsCollection ],
    SUM_FLAGS+2,
    ReturnTrue );


InstallMethod( IsSubset,
    "for two collections, check for identity",
    IsIdenticalObj,
    [ IsCollection,
      IsCollection ],
    SUM_FLAGS+1,

function ( D, E )
    if not IsIdenticalObj( D, E ) then
        TryNextMethod();
    fi;
    return true;
end );


InstallMethod( IsSubset,
    "for two collections with known sizes, check sizes",
    IsIdenticalObj,
    [ IsCollection and HasSize,
      IsCollection and HasSize ],
    SUM_FLAGS,

function ( D, E )
    if Size( E ) <= Size( D ) then
        TryNextMethod();
    fi;
    return false;
end );


InstallOtherMethod( IsSubset,
    "for two internal lists",
    IsIdenticalObj,
    [ IsList and IsInternalRep,
      IsList and IsInternalRep ],
    0,
    IsSubsetSet );


InstallMethod( IsSubset,
    "for two collections that are internal lists",
    IsIdenticalObj,
    [ IsCollection and IsList and IsInternalRep,
      IsCollection and IsList and IsInternalRep ], 0,
    IsSubsetSet );


InstallMethod( IsSubset,
    "for two collections with known `AsSSortedList'",
    IsIdenticalObj,
    [ IsCollection and HasAsSSortedList,
      IsCollection and HasAsSSortedList ],
    0,

function ( D, E )
    return IsSubsetSet( AsSSortedList( D ), AsSSortedList( E ) );
end );


InstallMethod( IsSubset,
    "for two collections (loop over the elements of the second)",
    IsIdenticalObj,
    [ IsCollection,
      IsCollection ],
    0,

function( D, E )
    return ForAll( E, e -> e in D );
end );


#############################################################################
##
#M  Intersection( <C>, ... )
##
BIND_GLOBAL( "IntersectionSet", function ( C1, C2 )
    local   I;
    if Length( C1 ) < Length( C2 ) then
        I := Set( C1 );
        IntersectSet( I, C2 );
    else
        I := Set( C2 );
        IntersectSet( I, C1 );
    fi;
    return I;
end );

InstallOtherMethod( Intersection2,
    "for two lists (not necessarily in the same family)",
    true,
    [ IsList, IsList ], 0,
    IntersectionSet );

InstallMethod( Intersection2,
    "for two collections in the same family, both lists",
    IsIdenticalObj,
    [ IsCollection and IsList, IsCollection and IsList ], 0,
    IntersectionSet );

InstallMethod( Intersection2,
    "for two collections in different families",
    IsNotIdenticalObj,
    [ IsCollection, IsCollection ], 0,
    function( C1, C2 ) return []; end );

InstallMethod( Intersection2,
    "for two collections in the same family, the second being a list",
    IsIdenticalObj,
    [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C1 ) then
        I := ShallowCopy( AsSSortedList( C1 ) );
        IntersectSet( I, C2 );
    else
        I := [];
        for elm in C2 do
            if elm in C1 then
                AddSet( I, elm );
            fi;
        od;
    fi;
    return I;
    end );

InstallMethod( Intersection2,
    "for two collections in the same family, the first being a list",
    IsIdenticalObj,
    [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C2 ) then
        I := ShallowCopy( AsSSortedList( C2 ) );
        IntersectSet( I, C1 );
    else
        I := [];
        for elm in C1 do
            if elm in C2 then
                AddSet( I, elm );
            fi;
        od;
    fi;
    return I;
    end );

InstallMethod( Intersection2,
    "for two collections in the same family",
    IsIdenticalObj,
    [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            I := ShallowCopy( AsSSortedList( C1 ) );
            IntersectSet( I, AsSSortedList( C2 ) );
        else
            I := [];
            for elm in C1 do
                if elm in C2 then
                    AddSet( I, elm );
                fi;
            od;
        fi;
    elif IsFinite( C2 ) then
        I := [];
        for elm in C2 do
            if elm in C1 then
                AddSet( I, elm );
            fi;
        od;
    else
        TryNextMethod();
    fi;
    return I;
    end );

InstallGlobalFunction( Intersection, function ( arg )
    local   I,          # intersection, result
            D,          # domain or list, running over the arguments
            copied,     # true if I is a list not identical to anything else
            i;          # loop variable

    # unravel the argument list if necessary
    if Length(arg) = 1  then
        arg := arg[1];
    fi;

    # start with the first domain or list
    I := arg[1];
    copied := false;

    # loop over the other domains or lists
    for i  in [2..Length(arg)]  do
        D := arg[i];
        if IsList( I ) and IsList( D )  then
            if not copied then I := Set( I ); fi;
            IntersectSet( I, D );
            copied := true;
        else
            I := Intersection2( I, D );
            copied := false;
        fi;
    od;

    # return the intersection
    if IsList( I ) and not IsSSortedList( I ) then
        I := Set( I );
    fi;
    return I;
end );


#############################################################################
##
#M  Union(<C>,...)
##
BIND_GLOBAL( "UnionSet", function ( C1, C2 )
    local   I;
    if Length( C1 ) < Length( C2 ) then
        I := Set( C2 );
        UniteSet( I, C1 );
    else
        I := Set( C1 );
        UniteSet( I, C2 );
    fi;
    return I;
end );

InstallMethod( Union2,
    "for two collections that are lists",
    IsIdenticalObj,
    [ IsCollection and IsList, IsCollection and IsList ], 0,
    UnionSet );

InstallOtherMethod( Union2,
    "for two lists",
    true, [ IsList, IsList ], 0,
    UnionSet );

InstallMethod( Union2,
    "for two collections, the second being a list",
    IsIdenticalObj, [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   I;
    if IsFinite( C1 ) then
        I := ShallowCopy( AsSSortedList( C1 ) );
        UniteSet( I, C2 );
    else
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    "for two collections, the first being a list",
    IsIdenticalObj, [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   I;
    if IsFinite( C2 ) then
        I := ShallowCopy( AsSSortedList( C2 ) );
        UniteSet( I, C1 );
    else
        Error("sorry, cannot unite <C1> with the infinite collection <C2>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    "for two collections",
    IsIdenticalObj, [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   I;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            I := ShallowCopy( AsSSortedList( C1 ) );
            UniteSet( I, AsSSortedList( C2 ) );
        else
            Error("sorry, cannot unite <C1> with the infinite collection <C2>");
        fi;
    elif IsFinite( C2 ) then
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    else
        TryNextMethod();
    fi;
    return I;
    end );

InstallGlobalFunction( Union, function ( arg )
    local   U,          # union, result
            D,          # domain or list, running over the arguments
            copied,     # true if I is a list not identical to anything else
            i;          # loop variable

    # unravel the argument list if necessary
    if Length(arg) = 1  then
        arg := arg[1];
    fi;

    # empty case first
    if Length( arg ) = 0  then
        return [  ];
    fi;

    # start with the first domain or list
    U := arg[1];
    copied := false;

    # loop over the other domains or lists
    for i  in [2..Length(arg)]  do
        D := arg[i];
        if IsList( U ) and IsList( D )  then
            if not copied then U := Set( U ); fi;
            UniteSet( U, D );
            copied := true;
        else
            U := Union2( U, D );
            copied := false;
        fi;
    od;

    # return the union
    if IsList( U ) and not IsSSortedList( U ) then
        U := Set( U );
    fi;
    return U;
end );


#############################################################################
##
#M  Difference(<C1>,<C2>)
##
InstallOtherMethod( Difference,
    "for empty list, and collection",
    true, [ IsList and IsEmpty, IsListOrCollection ], 0,
    function ( C1, C2 )
    return [];
    end );

InstallOtherMethod( Difference,
    "for collection, and empty list",
    true, [ IsCollection, IsList and IsEmpty ], 0,
    function ( C1, C2 )
    return ShallowCopy( C1 );
    end );

InstallOtherMethod( Difference,
    "for two lists (assume one can produce a sorted result)",
    true, [ IsList, IsList ], 0,
    function ( C1, C2 )
    C1 := Set( C1 );
    SubtractSet( C1, C2 );
    return C1;
    end );

InstallMethod( Difference,
    "for two collections that are lists",
    IsIdenticalObj, [ IsCollection and IsList, IsCollection and IsList ], 0,
    function ( C1, C2 )
    C1 := Set( C1 );
    SubtractSet( C1, C2 );
    return C1;
    end );

InstallMethod( Difference,
    "for two collections",
    IsIdenticalObj, [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   D, elm;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            D := ShallowCopy( AsSSortedList( C1 ) );
            SubtractSet( D, AsSSortedList( C2 ) );
        else
            D := [];
            for elm in C1 do
                if not elm in C2 then
                    AddSet( D, elm );
                fi;
            od;
        fi;
    else
        Error("sorry, cannot subtract from the infinite domain <C1>");
    fi;
    return D;
    end );

InstallMethod( Difference,
    "for two collections, the first being a list",
    IsIdenticalObj, [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   D, elm;
    if IsFinite( C2 )  then
        D := Set( C1 );
        SubtractSet( D, AsSSortedList( C2 ) );
    else
        D := [];
        for elm in C1 do
            if not elm in C2 then
                AddSet( D, elm );
            fi;
        od;
    fi;
    return D;
    end );

InstallMethod( Difference,
    "for two collections, the second being a list",
    IsIdenticalObj, [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   D;
    if IsFinite( C1 ) then
        D := ShallowCopy( AsSSortedList( C1 ) );
        SubtractSet( D, C2 );
    else
        Error( "sorry, cannot subtract from the infinite domain <D>" );
    fi;
    return D;
    end );

#############################################################################
##
#E

