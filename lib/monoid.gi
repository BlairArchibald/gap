#############################################################################
##
#W  monoid.gi                   GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains generic methods for monoids.
##


#############################################################################
##
#M  PrintObj( <M> ) . . . . . . . . . . . . . . . . . . . . .  print a monoid
##

InstallMethod( String,
    "for monoid",
    true,
    [ IsMonoid ], 0,
    function( M )
    return "Monoid( ... )";
    end );

InstallMethod( PrintObj,
    "for monoid with known generators",
    true,
    [ IsMonoid and HasGeneratorsOfMonoid ], 0,
    function( M )
    Print( "Monoid( ", GeneratorsOfMagmaWithOne( M ), " )" );
    end );

InstallMethod( String,
    "for monoid with known generators",
    true,
    [ IsMonoid and HasGeneratorsOfMonoid ], 0,
    function( M )
    return STRINGIFY( "Monoid( ", GeneratorsOfMagmaWithOne( M ), " )" );
    end );

InstallMethod( PrintString,
    "for monoid with known generators",
    true,
    [ IsMonoid and HasGeneratorsOfMonoid ], 0,
    function( M )
    return PRINT_STRINGIFY( "Monoid( ", GeneratorsOfMagmaWithOne( M ), " )" );
    end );

#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . . . view a monoid
##
InstallMethod( ViewString,
    "for a monoid",
    true,
    [ IsMonoid ], 0,
    function( M )
    return "<monoid>" ;
    end );

#############################################################################
##
#M  MonoidByGenerators( <gens> )  . . . . . . . .  monoid generated by <gens>
##

InstallOtherMethod(MonoidByGenerators, "for a collection",
[IsCollection],
function(gens)
  local M, pos;

  M := Objectify(NewType(FamilyObj(gens), IsMonoid
                                          and IsAttributeStoringRep), rec());
  gens := AsList(gens);

  if CanEasilyCompareElements(gens) and IsFinite(gens)
      and IsMultiplicativeElementWithOneCollection(gens) then
    SetOne(M, One(gens));
    pos := Position(gens, One(gens));
    if pos <> fail then
      SetGeneratorsOfMagma(M, gens);
      if Length(gens) = 1 then # Length(gens) <> 0 since One(gens) in gens
        SetIsTrivial(M, true);
      elif not IsPartialPermCollection(gens) or One(gens) =
          One(gens{Concatenation([1 .. pos - 1], [pos + 1 .. Length(gens)])}) then
        # if gens = [PartialPerm([1,2]), PartialPerm([1])], then removing the One
        # = gens[1] from this, it is not possible to recreate the semigroup using
        # Monoid(PartialPerm([1])) (since the One in this case is
        # PartialPerm([1]) not PartialPerm([1,2]) as it should be.
        gens := ShallowCopy(gens);
        Remove(gens, pos);
      fi;
    else
      SetGeneratorsOfMagma(M, Concatenation([One(gens)], gens));
    fi;
  fi;

  SetGeneratorsOfMagmaWithOne(M, gens);
  return M;
end);

InstallOtherMethod( MonoidByGenerators,
    "for collection and identity",
    IsCollsElms,
    [ IsCollection, IsMultiplicativeElementWithOne ], 0,
    function( gens, id )
    local M;
    M:= Objectify( NewType( FamilyObj( gens ),
                            IsMonoid and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    SetOne( M, Immutable( id ) );
    return M;
    end );

InstallOtherMethod( MonoidByGenerators,
    "for empty collection and identity",
    true,
    [ IsEmpty, IsMultiplicativeElementWithOne ], 0,
    function( gens, id )
    local M;
    M:= Objectify( NewType( CollectionsFamily( FamilyObj( id ) ),
                                IsMonoid
                            and IsTrivial
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    SetOne( M, Immutable( id ) );
    return M;
    end );

InstallImmediateMethod( GeneratorsOfSemigroup,
IsMonoid and HasGeneratorsOfMonoid and IsAttributeStoringRep, 0,
function(M)

  if Length(GeneratorsOfMonoid(M)) = infinity then 
    TryNextMethod();
  fi;

  if CanEasilyCompareElements(One(M)) and One(M) in GeneratorsOfMonoid(M) then 
    return GeneratorsOfMonoid(M);
  fi;
  return Concatenation([One(M)], GeneratorsOfMonoid(M));
end);

#############################################################################
##
#M  AsMonoid( <D> ) . . . . . . . . . . . . . .  domain <D>, viewed as monoid
##
InstallMethod( AsMonoid,
    "for a monoid",
    true,
    [ IsMonoid ], 100,
    IdFunc );

#

InstallMethod(AsMonoid,
"for a semigroup with known generators",
[IsSemigroup and HasGeneratorsOfSemigroup],
function(S)
  local gens, pos;

  if not (IsMultiplicativeElementWithOneCollection(S)
          and One(S) <> fail and One(S) in S) then
    return fail;
  fi;

  gens := GeneratorsOfSemigroup(S);

  if CanEasilyCompareElements(gens) then
    pos := Position(gens, One(S));
    if pos <> fail then
      gens := ShallowCopy(gens);
      Remove(gens, pos);
    fi;
  fi;
  return Monoid(gens);
end);

#

InstallMethod( AsMonoid,
    "generic method for a collection",
    true,
    [ IsCollection ], 0,
    function ( D )
    local   M,  L;

    D := AsSSortedList( D );
    L := ShallowCopy( D );
    M := TrivialSubmagmaWithOne( MonoidByGenerators( D ) );
    SubtractSet( L, AsSSortedList( M ) );
    while not IsEmpty(L)  do
        M := ClosureMagmaDefault( M, L[1] );
        SubtractSet( L, AsSSortedList( M ) );
    od;
    if Length( AsSSortedList( M ) ) <> Length( D )  then
        return fail;
    fi;
    M := MonoidByGenerators( GeneratorsOfMonoid( M ), One( D[1] ) );
    SetAsSSortedList( M, D );
    SetIsFinite( M, true );
    SetSize( M, Length( D ) );

    # return the monoid
    return M;
    end );


#############################################################################
##
#M  AsSubmonoid( <G>, <U> )
##
InstallMethod( AsSubmonoid,
    "generic method for a domain and a collection",
    IsIdenticalObj,
    [ IsDomain, IsCollection ], 0,
    function( G, U )
    local S;
    if not IsSubset( G, U ) then
      return fail;
    fi;
    if IsMagmaWithOne( U ) then
      if not IsAssociative( U ) then
        return fail;
      fi;
      S:= SubmonoidNC( G, GeneratorsOfMagmaWithOne( U ) );
    else
      S:= SubmagmaWithOneNC( G, AsList( U ) );
      if not IsAssociative( S ) then
        return fail;
      fi;
    fi;
    UseIsomorphismRelation( U, S );
    UseSubsetRelation( U, S );
    return S;
    end );


#############################################################################
##
#M  IsCommutative( <M> ) . . . . . . . . . .  test if a monoid is commutative
##
InstallMethod( IsCommutative,
    "for associative magma-with-one",
    true,
    [ IsMagmaWithOne and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfMagmaWithOne ) );


#############################################################################
##
#F  Monoid( <gen>, ... )
#F  Monoid( <obj> )
#F  Monoid( <gens>, <id> )
##

InstallGlobalFunction( Monoid, function( arg )
  local out, i;
  
  if Length(arg)=0 or (Length(arg)=1 and HasIsEmpty(arg[1]) and IsEmpty(arg[1]))
   then 
    Error("usage: cannot create a monoid with no generators,");
    return;

  # special case for matrices, because they may look like lists
  elif Length( arg ) = 1 and IsMatrix( arg[1] )  then
    return MonoidByGenerators( [ arg[1] ] );

  # special case for matrices, because they look like lists
  elif Length( arg ) = 2 and IsMatrix( arg[1] )  then
    return MonoidByGenerators( arg );

  # list of generators
  elif Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] )  then
    return MonoidByGenerators( arg[1] );

  # list of generators plus identity
  elif Length( arg ) = 2 and IsList( arg[1] ) and not IsEmpty(arg[1]) then
    return MonoidByGenerators( arg[1], arg[2] );

  # generators and collections of generators 
  elif (IsMultiplicativeElementWithOne(arg[1]) 
        and IsGeneratorsOfSemigroup([arg[1]]))
    or (IsMultiplicativeElementWithOneCollection(arg[1])
        and IsGeneratorsOfSemigroup(arg[1])) 
    or (HasIsEmpty(arg[1]) and IsEmpty(arg[1])) then
    out:=[];
    for i in [1..Length(arg)] do
      #so that we can pass the options record in the Semigroups package 
      if i=Length(arg) and IsRecord(arg[i]) then
        return MonoidByGenerators(out, arg[i]);
      elif IsMultiplicativeElementWithOne(arg[i]) and IsGeneratorsOfSemigroup([arg[i]]) then
        Add(out, arg[i]);
      elif IsGeneratorsOfSemigroup(arg[i]) then
        if HasGeneratorsOfSemigroup(arg[i]) or IsMagmaIdeal(arg[i]) then
          Append(out, GeneratorsOfSemigroup(arg[i]));
        elif IsList(arg[i]) then 
          Append(out, arg[i]);
        else 
          Append(out, AsList(arg[i]));
        fi;
      else
        if not IsEmpty(arg[i]) then 
          Error( "Usage: Monoid(<gen>,...), Monoid(<gens>), Monoid(<D>)," );
          return;
        fi;
      fi;
    od;
    return MonoidByGenerators(out);

  # generators
  elif 0 < Length( arg )  then
    return MonoidByGenerators( arg );
  # no argument given, error
  else
    Error( "Usage: Monoid(<gen>,...), Monoid(<gens>), Monoid(<D>)," );
    return;
  fi;
end);

#############################################################################
##
#E

