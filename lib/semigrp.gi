#############################################################################
##
#W  semigrp.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for semigroups.
##
Revision.semigrp_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  Print( <S> )  . . . . . . . . . . . . . . . . . . . . . print a semigroup
##
InstallMethod( PrintObj, true,
    [ IsSemigroup and HasParent and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "Subsemigroup( ", Parent( S ), ", ",
           GeneratorsOfMagma( S ), " )" );
    end );

InstallMethod( PrintObj, true,
    [ IsSemigroup and HasParent ], 0,
    function( S )
    Print( "Subsemigroup( ", Parent( S ), ", ... )" );
    end );

InstallMethod( PrintObj, true,
    [ IsSemigroup and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "Semigroup( ", GeneratorsOfMagma( S ), " )" );
    end );

InstallMethod( PrintObj, true,
    [ IsSemigroup ], 0,
    function( S )
    Print( "Semigroup( ... )" );
    end );


#############################################################################
##
#M  NiceSemigroup( <S> )  . . . . . . . . . . nice semigroup isomorphic to <S>
##
InstallMethod( NiceSemigroup, true, [ IsSemigroup ], 0, IdFunc );


#############################################################################
##
#M  SemigroupByGenerators( <gens> ) . . . . . . semigroup generated by <gens>
##
InstallMethod( SemigroupByGenerators, true, [ IsCollection ], 0,
    function( gens )
    local S;
    S:= Objectify( NewKind( FamilyObj( gens ),
                            IsSemigroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagma( S, AsList( gens ) );
    return S;
    end );


#############################################################################
##
#M  AsSemigroup( <S> )  . . . . . . . . . . . view a semigroup as a semigroup
##
InstallMethod( AsSemigroup, true, [ IsSemigroup ], 0, IdFunc );


#############################################################################
##
#F  Semigroup( <gen>, ... ) . . . . . . . . semigroup generated by collection
#F  Semigroup( <gens> ) . . . . . . . . . . semigroup generated by collection
##
Semigroup := function( arg )

    # special case for matrices, because they may look like lists
    if Length( arg ) = 1 and IsMatrix( arg[1] ) then
      return SemigroupByGenerators( [ arg[1] ] );

    # list of generators
    elif Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return SemigroupByGenerators( arg );

    # generators
    elif 0 < Length( arg ) then
      return SemigroupByGenerators( arg );

    # no argument given, error
    else
      Error("usage: Semigroup(<gen>,...),Semigroup(<gens>),Semigroup(<D>)");
    fi;
end;


#############################################################################
##
#F  Subsemigroup( <S>, <gens> ) . . .  subsemigroup of <S> generated by <gens>
##
Subsemigroup := function( S, gens )
    local SS;

    if not IsSemigroup( S ) then
      Error( "<S> must be a semigroup" );
    fi;

    if   IsHomogeneousList( gens )
       and IsIdentical( FamilyObj( S ), FamilyObj( gens ) )
       and ForAll( gens, s -> s in S ) then
      SS:= SemigroupByGenerators( gens );
      SetParent( SS, S );
      return SS;
    else
      Error( "<gens> must be a nonempty list of elements in <S>" );
    fi;
end;


#############################################################################
##
#F  SubsemigroupNC( <S>, <gens> ) . .  subsemigroup of <S> generated by <gens>
##
SubsemigroupNC := function( S, gens )
    local SS;
    SS:= SemigroupByGenerators( gens );
    SetParent( SS, S );
    return SS;
end;


#############################################################################
##
#E  semigrp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



