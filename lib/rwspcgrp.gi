#############################################################################
##
#W  rwspcgrp.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file   contains  the methods  for  groups  defined  by  a polycyclic
##  collector.
##
Revision.rwspcgrp_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  IsConfluent( <pc-group> )
##
InstallOtherMethod( IsConfluent,
    true,
    [ IsPcGroup ],
    0,

function( g )
    local   gens,  fam,  exps,  R,  R1,  k,  gk,  j,  gj,  i,  gi,  r;

    gens := GeneratorsOfGroup(g);
    fam  := ElementsFamily(FamilyObj(g));
    exps := fam!.rewritingSystem![SCP_RELATIVE_ORDERS];

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' starting part 1" );
    R := Runtime();  R1 := R;

    # Consistency relations: gk * ( gj * gi ) = ( gk * gj ) * gi
    for k  in [ 1 .. Length(gens) ]  do
        gk := gens[k];
        for j  in [ 1 .. k-1 ]  do
            gj := gens[j];
            for i  in [ 1 .. j-1 ]  do
                gi := gens[i];
                r  := [ gk * ( gj * gi ), ( gk * gj ) * gi ];
                if r[1] <> r[2]  then
                    return false;
                fi;
            od;
        od;
    od;

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 1 took ", Runtime()-R, " ms, ",
          "starting part 2" );
    R := Runtime();

    # Consistency relations: gj^ej-1 * ( gj * gi ) = ( gj^ej-1 * gj ) * gi
    for j  in [ 1 .. Length(gens) ]  do
        gj := gens[j];
        for i  in [ 1 .. j-1 ]  do
            gi := gens[i];
            r  := [ gj^(exps[j]-1)*(gj*gi), (gj^(exps[j]-1)*gj)*gi ];
            if r[1] <> r[2]  then
                return false;
            fi;
        od;
    od;

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 2 took ", Runtime()-R, " ms, ",
          "'IsConfluent' starting part 3" );
    R := Runtime();

    # Consistency relations: gj * ( gi^ei-1 * gi ) = ( gj * gi^ei-1 ) * gi
    for j  in [ 1 .. Length( gens ) ]  do
        gj := gens[j];
        for i  in [ 1 .. j-1 ]  do
            gi := gens[i];
            r := [ gj*(gi^(exps[i]-1)*gi), (gj*gi^(exps[i]-1))*gi ];
            if r[1] <> r[2]  then
                return false;
            fi;
        od;
    od;

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 3 took ", Runtime()-R, " ms, ",
          "'IsConfluent' starting part 4" );
    R := Runtime();

    # Consistency relations: gj * ( gi^ei-1 * gi ) = ( gj * gi^ei-1 ) * gi
    for i  in [ 1 .. Length(gens) ]  do
        gi := gens[ i ];
        r := [ gi*(gi^(exps[i]-1)*gi), (gi*gi^(exps[i]-1))*gi ];
        if r[1] <> r[2]  then
            return false;
        fi;
    od;
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 4 took, ", Runtime()-R, " ms" );
    Info( InfoTiming + InfoConfluence, 1,
          "'IsConfluent' took ", Runtime()-R1, " ms" );

    # Report if one check failed and <all> was set.
    return true;

end );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <rws> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "generic method",
    true,
    [ IsPolycyclicCollector ],
    0,

function( rws )
    local   fam,  pcs;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
      "MultiplicativeElementsWithInversesFamilyByPolycyclicCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsAssociativeElement,
      IsObject,
      IsElementsFamilyByRws );

    # store the rewriting system
    fam!.rewritingSystem := Immutable(rws);

    # create the default kind for the elements
    fam!.defaultKind := NewKind( fam, IsElementByRwsDefaultRep );

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(rws), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##

#R  IsNBitsPcWordRep
##
IsNBitsPcWordRep := NewRepresentation(
    "IsNBitsPcWordRep",
    IsDataObjectRep, [] );


#############################################################################
##
#M  PrintObj( <IsNBitsPcWordRep> )
##
InstallMethod( PrintObj,
    true,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,

function( obj )
    local   names,  word,  len,  i;

    names := KindObj(obj)![PCWP_NAMES];
    word  := ExtRepOfObj(obj);
    len   := Length(word) - 1;
    if len < 0 then
        Print( "<identity> of ..." );
    else
        i := 1;
        while i < len do
            Print( names[ word[i] ] );
            if word[i+1] <> 1 then
                Print( "^", word[i+1] );
            fi;
            Print( "*" );
            i := i+2;
        od;
        Print( names[word[i]] );
        if word[i+1] <> 1 then
            Print( "^", word[ i+1 ] );
        fi;
    fi;
end );


#############################################################################
##
#M  Inverse( <IsNBitsPcWordRep> )
##
InstallMethod( Inverse,
    true,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,

function( obj )
    return FinPowConjCol_ReducedPowerSmallInt(
        KindObj(obj)![PCWP_COLLECTOR], obj, -1 );
end );


#############################################################################
##
#M  Comm( <IsNBitsPcWordRep>, <IsNBitsPcWordRep> )
##
InstallMethod( Comm,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
    NBitsPcWord_Comm );


#############################################################################
##
#M  LeftQuotient( <IsNBitsPcWordRep>, <IsNBitsPcWordRep> )
##
InstallMethod( LeftQuotient,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
    NBitsPcWord_LeftQuotient );


#############################################################################
##
#M  <IsNBitsPcWordRep> / <IsNBitsPcWordRep>
##
InstallMethod( \/,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
    NBitsPcWord_Quotient );


#############################################################################
##
#M  <IsNBitsPcWordRep> * <IsNBitsPcWordRep>
##
InstallMethod( \*,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
    NBitsPcWord_Product );


#############################################################################
##

#R  Is8BitsPcWordRep
##
Is8BitsPcWordRep := NewRepresentation(
    "Is8BitsPcWordRep",
    IsNBitsPcWordRep, [] );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <8bits-sc> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "8 bits family",
    true, 
    [ IsPolycyclicCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsKindSingleCollector
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    local   fam,  i,  pcs;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily3( NewKind( FamilyOfFamilies,
                           IsFamily and IsFamilyDefaultRep
                           and IsElementsFamilyBy8BitsSingleCollector ),
      "MultiplicativeElementsWithInversesFamilyBy8BitsSingleCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
      and IsAssociativeElement );

    # store the rewriting system
    fam!.rewritingSystem := Immutable(sc);

    # create the default kind for the elements
    fam!.defaultKind := NewKind( fam, IsElementByRwsDefaultRep );

    # create the special 8 bits kind
    fam!.8BitsKind := NewKind( fam, Is8BitsPcWordRep );

    # copy the assoc word kind
    for i  in [ AWP_FIRST_ENTRY .. AWP_FIRST_FREE-1 ]  do
        fam!.8BitsKind![i] := sc![SCP_DEFAULT_KIND]![i];
    od;

    # default kind to use
    fam!.8BitsKind![AWP_PURE_KIND] := fam!.8BitsKind;

    # store the names
    fam!.8BitsKind![PCWP_NAMES] := FamilyObj(ReducedOne(sc))!.names;

    # force the single collector to return elements of that kind
    sc := ShallowCopy(sc);
    sc![SCP_DEFAULT_KIND] := fam!.8BitsKind;
    fam!.8BitsKind![PCWP_COLLECTOR] := sc;

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(sc), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyBy8BitsSingleCollector,
      Is8BitsAssocWord ],
    0,

function( fam, elm )
    return 8Bits_AssocWord( fam!.8BitsKind, ExtRepOfObj(elm) );
end );


#############################################################################
##
#M  UnderlyingElement( <Is8BitsPcWordRep> )
##
InstallMethod( UnderlyingElement,
    true,
    [ Is8BitsPcWordRep ],
    0,

function( obj )
    local   fam;

    fam := UnderlyingFamily( FamilyObj(obj)!.rewritingSystem );
    return ObjByExtRep( fam, 8Bits_ExtRepOfObj(obj) );
end );


#############################################################################
##
#M  ExtRepOfObj( <Is8BitsPcWordRep> )
##
InstallMethod( ExtRepOfObj,
    true,
    [ Is8BitsPcWordRep ],
    0,
    8Bits_ExtRepOfObj );


#############################################################################
##
#M  ObjByExtRep( <fam>, <elm> )
##
InstallMethod( ObjByExtRep,
    true,
    [ IsElementsFamilyBy8BitsSingleCollector,
      IsList ],
    0,

function( fam, elm )
    return 8Bits_AssocWord( fam!.8BitsKind, elm );
end );


#############################################################################
##
#M  <Is8BitsPcWordRep> = <Is8BitsPcWordRep>
##
InstallMethod( \=,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep ],
    0,
    8Bits_Equal );


#############################################################################
##
#M  <Is8BitsPcWordRep> < <Is8BitsPcWordRep>
##
InstallMethod( \<,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep ],
    0,
    8Bits_Less );


#############################################################################
##

#R  Is16BitsPcWordRep
##
Is16BitsPcWordRep := NewRepresentation(
    "Is16BitsPcWordRep",
    IsNBitsPcWordRep, [] );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <16bits-sc> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "16 bits family",
    true, 
    [ IsPolycyclicCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsKindSingleCollector
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    local   fam,  i,  pcs;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily3( NewKind( FamilyOfFamilies,
                           IsFamily and IsFamilyDefaultRep
                           and IsElementsFamilyBy16BitsSingleCollector ),
      "MultiplicativeElementsWithInversesFamilyBy16BitsSingleCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
      and IsAssociativeElement );

    # store the rewriting system
    fam!.rewritingSystem := Immutable(sc);

    # create the default kind for the elements
    fam!.defaultKind := NewKind( fam, IsElementByRwsDefaultRep );

    # create the special 8 bits kind
    fam!.16BitsKind := NewKind( fam, Is16BitsPcWordRep );

    # copy the assoc word kind
    for i  in [ AWP_FIRST_ENTRY .. AWP_FIRST_FREE-1 ]  do
        fam!.16BitsKind![i] := sc![SCP_DEFAULT_KIND]![i];
    od;

    # default kind to use
    fam!.16BitsKind![AWP_PURE_KIND] := fam!.16BitsKind;

    # store the names
    fam!.16BitsKind![PCWP_NAMES] := FamilyObj(ReducedOne(sc))!.names;

    # force the single collector to return elements of that kind
    sc := ShallowCopy(sc);
    sc![SCP_DEFAULT_KIND] := fam!.16BitsKind;
    fam!.16BitsKind![PCWP_COLLECTOR] := sc;

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(sc), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyBy16BitsSingleCollector,
      Is16BitsAssocWord ],
    0,

function( fam, elm )
    return 16Bits_AssocWord( fam!.16BitsKind, ExtRepOfObj(elm) );
end );


#############################################################################
##
#M  UnderlyingElement( <Is16BitsPcWordRep> )
##
InstallMethod( UnderlyingElement,
    true,
    [ Is16BitsPcWordRep ],
    0,

function( obj )
    local   fam;

    fam := UnderlyingFamily( FamilyObj(obj)!.rewritingSystem );
    return ObjByExtRep( fam, 16Bits_ExtRepOfObj(obj) );
end );


#############################################################################
##
#M  ExtRepOfObj( <Is16BitsPcWordRep> )
##
InstallMethod( ExtRepOfObj,
    true,
    [ Is16BitsPcWordRep ],
    0,
    16Bits_ExtRepOfObj );


#############################################################################
##
#M  ObjByExtRep( <fam>, <elm> )
##
InstallMethod( ObjByExtRep,
    true,
    [ IsElementsFamilyBy16BitsSingleCollector,
      IsList ],
    0,

function( fam, elm )
    return 16Bits_AssocWord( fam!.16BitsKind, elm );
end );


#############################################################################
##
#M  <Is16BitsPcWordRep> = <Is16BitsPcWordRep>
##
InstallMethod( \=,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep ],
    0,
    16Bits_Equal );


#############################################################################
##
#M  <Is16BitsPcWordRep> < <Is16BitsPcWordRep>
##
InstallMethod( \<,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep ],
    0,
    16Bits_Less );


#############################################################################
##

#R  Is32BitsPcWordRep
##
Is32BitsPcWordRep := NewRepresentation(
    "Is32BitsPcWordRep",
    IsNBitsPcWordRep, [] );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <32bits-sc> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "32 bits family",
    true, 
    [ IsPolycyclicCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsKindSingleCollector
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    local   fam,  i,  pcs;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily3( NewKind( FamilyOfFamilies,
                           IsFamily and IsFamilyDefaultRep
                           and IsElementsFamilyBy32BitsSingleCollector ),
      "MultiplicativeElementsWithInversesFamilyBy32BitsSingleCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
      and IsAssociativeElement );

    # store the rewriting system
    fam!.rewritingSystem := Immutable(sc);

    # create the default kind for the elements
    fam!.defaultKind := NewKind( fam, IsElementByRwsDefaultRep );

    # create the special 8 bits kind
    fam!.32BitsKind := NewKind( fam, Is32BitsPcWordRep );

    # copy the assoc word kind
    for i  in [ AWP_FIRST_ENTRY .. AWP_FIRST_FREE-1 ]  do
        fam!.32BitsKind![i] := sc![SCP_DEFAULT_KIND]![i];
    od;

    # default kind to use
    fam!.32BitsKind![AWP_PURE_KIND] := fam!.32BitsKind;

    # store the names
    fam!.32BitsKind![PCWP_NAMES] := FamilyObj(ReducedOne(sc))!.names;

    # force the single collector to return elements of that kind
    sc := ShallowCopy(sc);
    sc![SCP_DEFAULT_KIND] := fam!.32BitsKind;
    fam!.32BitsKind![PCWP_COLLECTOR] := sc;

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(sc), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyBy32BitsSingleCollector,
      Is32BitsAssocWord ],
    0,

function( fam, elm )
    return 32Bits_AssocWord( fam!.32BitsKind, ExtRepOfObj(elm) );
end );


#############################################################################
##
#M  UnderlyingElement( <Is32BitsPcWordRep> )
##
InstallMethod( UnderlyingElement,
    true,
    [ Is32BitsPcWordRep ],
    0,

function( obj )
    local   fam;

    fam := UnderlyingFamily( FamilyObj(obj)!.rewritingSystem );
    return ObjByExtRep( fam, 32Bits_ExtRepOfObj(obj) );
end );


#############################################################################
##
#M  ExtRepOfObj( <Is32BitsPcWordRep> )
##
InstallMethod( ExtRepOfObj,
    true,
    [ Is32BitsPcWordRep ],
    0,
    32Bits_ExtRepOfObj );


#############################################################################
##
#M  ObjByExtRep( <fam>, <elm> )
##
InstallMethod( ObjByExtRep,
    true,
    [ IsElementsFamilyBy32BitsSingleCollector,
      IsList ],
    0,

function( fam, elm )
    return 32Bits_AssocWord( fam!.32BitsKind, elm );
end );


#############################################################################
##
#M  <Is32BitsPcWordRep> = <Is32BitsPcWordRep>
##
InstallMethod( \=,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep ],
    0,
    32Bits_Equal );


#############################################################################
##
#M  <Is32BitsPcWordRep> < <Is32BitsPcWordRep>
##
InstallMethod( \<,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep, 
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep ],
    0,
    32Bits_Less );


#############################################################################
##

#F  SingleCollector_GroupRelators( ... )
##
SingleCollector_GroupRelators := function(
    gens, rods, powersp, powersn, commpp, commpn, commnp, commnn, conjpp,
    conjpn, conjnp, conjnn, conflicts )

    local   col,  i,  seen,  j,  rhs;
    
    # be verbose
    # Print( "#I  SingleCollector_GroupRelators: ", Length(Flat(powersp)),
    #        "/", Length(Flat(powersn)), " ", Length(Flat(commpp)), "/",
    #        Length(Flat(commpn)), "/", Length(Flat(commnp)), "/",
    #        Length(Flat(commnn)), " ", Length(Flat(conjpp)), "/",
    #        Length(Flat(conjpn)), "/", Length(Flat(conjnp)), "/",
    #        Length(Flat(conjnn)), " ", Length(conflicts), "\n" );

    # start with an empty single collector
    col := SingleCollector( gens, rods );

    # we want to use positive powers first
    for i  in [ 1 .. Length(rods) ]  do
        if IsBound(powersp[i])  then
            SetPower( col, i, powersp[i]^-1 * gens[i]^rods[i] );
        fi;
    od;

    # we want to use positive conjugates/commutators first
    for i  in [ 1 .. Length(gens) ]  do
        for j  in [ 1 .. i-1 ]  do
            if IsBound(conjpp[i][j])  then
                rhs := ( (gens[i]^-1)^gens[j] * conjpp[i][j] ) ^ -1;
                SetConjugate( col, i, j, rhs );
                if IsBound(commpp[i][j])  then
                    Add( conflicts, commpp[i][j] );
                fi;
            elif IsBound(commpp[i][j])  then
                rhs := gens[i]*(Comm(gens[j],gens[i])*commpp[i][j])^-1;
                SetConjugate( col, i, j, rhs );
            fi;
        od;
    od;

    # everything must a consequence
    Append( conflicts, Flat(powersn) );
    Append( conflicts, Flat(conjpn)  );
    Append( conflicts, Flat(conjnp)  );
    Append( conflicts, Flat(conjnn)  );
    Append( conflicts, Flat(commpn)  );
    Append( conflicts, Flat(commnp)  );
    Append( conflicts, Flat(commnn)  );

    # return the rewriting system
    return col;

end;

#############################################################################
##
#M  PolycyclicFactorGroupByRelators( <efam>, <gens>, <rels> )
##
InstallMethod( PolycyclicFactorGroupByRelators,
    true,
    [ IsFamily,
      IsList,
      IsList ],
    0,

function( efam, gens, rels )
    local   i,  r,  rel,  powersp,  powersn,  powlst,  commpp,
            commpn,  commnp,  commnn,  conjpp,  conjpn,  conjnp,
            conjnn,  conflicts,  n,  g1,  e1,  g2,  e2,  g3,  e3,  g4,
            e4,  rods,  col;

    # check the generators
    for i  in [ 1 .. Length(gens) ]  do
        if 1 <> NumberSyllables(gens[i])  then
            Error( gens[i], " must be a word of length 1" );
        elif 1 <> ExponentSyllable( gens[i], 1 )  then
            Error( gens[i], " must be a word of length 1" );
        elif i <> GeneratorSyllable( gens[i], 1 )  then
            Error( gens[i], " must be generator number ", i );
        fi;
    od;

    # first convert relations into relators
    r := [];
    for rel  in rels  do
        if IsList(rel)  then
            if 2 <> Length(rel)  then
                Error( rel, " is not a relation" );
            fi;
            AddSet( r, rel[1] / rel[2] );
        else
            AddSet( r, rel );
        fi;
    od;
    rels := r;

    # power relation
    powersp := [];
    powersn := [];
    powlst  := [];

    # commutator pos, pos
    commpp := List( gens, x -> [] );

    # commutator pos, neg
    commpn := List( gens, x -> [] );

    # commutator neg, pos
    commnp := List( gens, x -> [] );

    # commutator neg, neg
    commnn := List( gens, x -> [] );

    # conjugate pos, pos
    conjpp := List( gens, x -> [] );

    # conjugate pos, neg
    conjpn := List( gens, x -> [] );

    # conjugate neg, pos
    conjnp := List( gens, x -> [] );

    # conjugate neg, neg
    conjnn := List( gens, x -> [] );

    # conflicts are collected in this list and tested later
    conflicts := [];

    # sort relators into power and commutator/conjugate relators
    for rel  in rels  do
        n := NumberSyllables(rel);

        # a word with only one or two syllabel is a power
        if n = 1 or n = 2  then
            Add( powlst, rel );

        # ignore the trivial word
        elif 2 < n  then

            # extract the first four entries
            g1 := GeneratorSyllable( rel, 1 );
            e1 := ExponentSyllable(  rel, 1 );
            g2 := GeneratorSyllable( rel, 2 );
            e2 := ExponentSyllable(  rel, 2 );
            g3 := GeneratorSyllable( rel, 3 );
            e3 := ExponentSyllable(  rel, 3 );
            if 3 < n  then
                g4 := GeneratorSyllable( rel, 4 );
                e4 := ExponentSyllable( rel, 4 );
            fi;

            # a word starting with gi^-1gjgi is a conjugate or commutator
            if e1 = -1 and e3 = 1 and g1 = g3  then

                # gi^-1 gj^-1 gi gj is a commutator
                if 3<n and e2 = -1 and e4 = 1 and g2 = g4 and g2 < g1  then
                    if IsBound(commpp[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commpp[g1][g2] := rel;
                    fi;

                # gi^-1 gj^-1 gi is a conjugate
                elif e2 = -1 and g1 < g2  then
                    if IsBound(conjnp[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjnp[g2][g1] := rel;
                    fi;

                # gi^-1 gj gi gj^-1 is a commutator
                elif 3<n and e2 = 1 and e4 = -1 and g2 = g4 and g2 < g1  then
                    if IsBound(commpn[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commpn[g1][g2] := rel;
                    fi;

                # gi^-1 gj gi is a conjugate
                elif e2 = 1 and g1 < g2  then
                    if IsBound(conjpp[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjpp[g2][g1] := rel;
                    fi;

                # impossible
                else
                    Error( "illegal relator ", rel );
                fi;

            # a word starting with gigjgi^-1 is a conjugate or commutator
            elif e1 = 1 and e3 = -1 and g1 = g3  then

                # gi gj gi^-1 gj^-1 is a commutator
                if 3 < n and e2 = 1 and e4 = -1 and g2 = g4 and g2 < g1  then
                    if IsBound(commnn[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commnn[g1][g2] := rel;
                    fi;

                # gi gj gi^-1 is a conjugate
                elif e2 = 1 and g1 < g2  then
                    if IsBound(conjpn[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjpn[g2][g1] := rel;
                    fi;

                # gi gj^-1 gi^-1 gj is a commutator
                elif 3<n and e2 = -1 and e4 = 1 and g2 = g4 and g2 < g1  then
                    if IsBound(commnp[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commnp[g1][g2] := rel;
                    fi;

                # gi gj^-1 gi^-1 gj is a conjugate
                elif e2 = -1 and g1 < g2  then
                    if IsBound(conjnp[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjnp[g2][g1] := rel;
                    fi;

                # impossible
                else
                    Error( "illegal relator ", rel );
                fi;

            # it must be a power
            else
                Add( powlst, rel );
            fi;
        fi;
    od;

    # now check the powers
    rods := List( gens, x -> 0 );
    for rel  in powlst  do
        g1 := GeneratorSyllable( rel, 1 );
        e1 := ExponentSyllable(  rel, 1 );
        if rods[g1] <> 0  then
            if IsBound(powersp[g1])  then
                Add( conflicts, rel );
            else
                Add( conflicts, rel );
            fi;
        else
            rods[g1] := AbsInt(e1);
            if e1 < 0  then
                powersn[g1] := rel;
            else
                powersp[g1] := rel;
            fi;
        fi;
    od;

    # now decide which collector to use
    if ForAny( rods, x -> x = 0 )  then
        Error( "not ready yet, only finite polycyclic groups are allowed" );
    else
        col := SingleCollector_GroupRelators( gens, rods, powersp, powersn,
                   commpp, commpn, commnp, commnn, conjpp, conjpn,
                   conjnp, conjnn, conflicts );
    fi;

    # give the system a chance to optimise itself
    ReduceRules(col);

    # check that the system is confluent
    e1 := ReducedOne(col);
    for rel  in conflicts  do
        if ReducedForm( col, rel ) <> e1  then
            Error( "relator ", rel, " is not trivial" );
        fi;
    od;

    # return the group described by this system
    return GroupByRws(col);

end );


#############################################################################
##
#M  PolycyclicFactorGroup( <fgrp>, <rels> )
##


#############################################################################
InstallMethod( PolycyclicFactorGroup,
    IsIdentical,
    [ IsFreeGroup,
      IsHomogeneousList ],
    0,

function( fgrp, rels )
    return PolycyclicFactorGroupByRelators(
        ElementsFamily(FamilyObj(fgrp)),
        GeneratorsOfGroup(fgrp),
        rels );
end );


#############################################################################
InstallMethod( PolycyclicFactorGroup,
    true,
    [ IsFreeGroup,
      IsList and IsEmpty ],
    0,

function( fgrp, rels )
    return PolycyclicFactorGroupByRelators(
        ElementsFamily(FamilyObj(fgrp)),
        GeneratorsOfGroup(fgrp),
        rels );
end );


#############################################################################
##

#E  rwspcgrp.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
