#############################################################################
##
#W  rwsgrp.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file  contains the generic methods for  groups  defined by rewriting
##  systems.
##
Revision.rwsgrp_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyByRws, IsObject ],
    0,

function( fam, elm )
    elm := [ Immutable(elm) ];
    return Objectify( fam!.defaultType, elm );
end );


#############################################################################
##
#M  PrintObj( <elm-by-rws> )
##
InstallMethod( PrintObj,
    true,
    [ IsMultiplicativeElementWithInverseByRws and IsPackedElementDefaultRep ],
    0,

function( obj )
    Print( obj![1] );
end );


#############################################################################
##
#M  UnderlyingElement( <elm-by-rws> )
##
InstallMethod( UnderlyingElement,
    true,
    [ IsMultiplicativeElementWithInverseByRws and IsPackedElementDefaultRep ],
    0,

function( obj )
    return obj![1];
end );


#############################################################################
##
#M  ExtRepOfObj( <elm-by-rws> )
##
InstallMethod( ExtRepOfObj,
    true,
    [ IsMultiplicativeElementWithInverseByRws ],
    0,

function( obj )
    return ExtRepOfObj( UnderlyingElement( obj ) );
end );


#############################################################################
##

#M  Comm( <elm-by-rws>, <elm-by-rws> )
##
InstallMethod( Comm,
    "rws-element, rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedComm( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  InverseOp( <elm-by-rws> )
##
InstallMethod( InverseOp,
    "rws-element",
    true,
    [ IsMultiplicativeElementWithInverseByRws ],
    0,

function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return ElementByRws( fam, ReducedInverse( fam!.rewritingSystem,
        UnderlyingElement(obj) ) );
end );


#############################################################################
##
#M  LeftQuotient( <elm-by-rws>, <elm-by-rws> )
##
InstallMethod( LeftQuotient,
    "rws-element, rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedLeftQuotient( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  OneOp( <elm-by-rws> )
##
InstallMethod( OneOp,
    "rws-element",
    true,
    [ IsMultiplicativeElementWithInverseByRws ],
    0,

function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return ElementByRws( fam, ReducedOne(fam!.rewritingSystem) );
end );


#############################################################################
##
#M  Quotient( <elm-by-rws>, <elm-by-rws> )
##
InstallMethod( \/,
    "rws-element, rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedQuotient( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  <elm-by-rws> * <elm-by-rws>
##
InstallMethod( \*,
    "rws-element * rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedProduct( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  <elm-by-rws> ^ <elm-by-rws>
##
InstallMethod( \^,
    "rws-element ^ rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedConjugate( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  <elm-by-rws> ^ <int>
##
InstallMethod( \^,
    "rws-element ^ int",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsInt ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedPower( fam!.rewritingSystem,
        UnderlyingElement(left), right ) );
end );


#############################################################################
##
#M  <elm-by-rws> = <elm-by-rws>
##
InstallMethod( \=,
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    return UnderlyingElement(left) = UnderlyingElement(right);
end );


#############################################################################
##
#M  <elm-by-rws> < <elm-by-rws>
##
InstallMethod( \<,
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    return UnderlyingElement(left) < UnderlyingElement(right);
end );


#############################################################################
##

#M  MultiplicativeElementsWithInversesFamilyByRws( <rws> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    true,
    [ IsRewritingSystem and IsBuiltFromGroup ],
    0,

function( rws )
    local   fam;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
        "MultiplicativeElementsWithInversesFamilyByRws(...)",
        IsMultiplicativeElementWithInverseByRws 
          and IsAssociativeElement,
        IsElementsFamilyByRws );

    # store the rewriting system
    fam!.rewritingSystem := Immutable(rws);

    # create the default type for the elements
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    # that's it
    return fam;

end );



#############################################################################
##

#M  GroupByRws( <rws> )
##
InstallMethod( GroupByRws,
    true,
    [ IsRewritingSystem and IsBuiltFromGroup ],
    0,

function( rws )

    # it must be confluent
    if not IsConfluent(rws)  then
        Error( "the rewriting system must be confluent" );
    fi;

    # use the no-check to do the work
    return GroupByRwsNC(rws);
end );


#############################################################################
##
#M  GroupByRwsNC( <rws> )
##
InstallMethod( GroupByRwsNC,
    true,
    [ IsRewritingSystem and IsBuiltFromGroup ],
    100,

function( rws )
    local   fam,  gens,  g,  id,  grp;

    # give the rewriting system a chance to optimise itself
    ReduceRules(rws);

    # construct a new family containing the group elements
    fam := MultiplicativeElementsWithInversesFamilyByRws(rws);

    # construct the generators
    gens := [];
    for g  in GeneratorsOfRws(rws)  do
        Add( gens, ElementByRws( fam, ReducedForm( rws, g ) ) );
    od;
    id := ElementByRws( fam, ReducedOne(rws) );

    # and a group
    grp := GroupByGenerators( gens, id );

    # it is the whole family
    SetIsWholeFamily( grp, true );

    # check the true methods
    if HasIsFinite( rws ) then
      SetIsFinite( grp, IsFinite( rws ) );
    fi;
    if IsPolycyclicCollector( rws ) then
      SetFamilyPcgs( grp, DefiningPcgs( ElementsFamily(FamilyObj(grp)) ) );
      SetHomePcgs( grp, DefiningPcgs( ElementsFamily(FamilyObj(grp)) ) );
    fi;

    # that's it
    return grp;

end );


#############################################################################
##

#E

