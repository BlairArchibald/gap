#############################################################################
##
#W  ghom.gi                  GAP library                       Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.ghom_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  GroupHomomorphismByImages( <G>, <H>, <Ggens>, <Hgens> )
##
InstallGlobalFunction( GroupHomomorphismByImages,
    function( G, H, Ggens, Hgens )
    local hom;
    hom:= GroupGeneralMappingByImages( G, H, Ggens, Hgens );
    if IsMapping( hom ) and IsTotal( hom ) then
      return GroupHomomorphismByImagesNC( G, H, Ggens, Hgens );
    else
      return fail;
    fi;
end );


#############################################################################
##
#M  RestrictedMapping(<hom>,<U>)
##
InstallMethod(RestrictedMapping,"create new GHBI",
  CollFamSourceEqFamElms,[IsGroupHomomorphism,IsGroup],0,
function(hom,U)
local rest,gens;
  gens:=GeneratorsOfGroup(U);
  rest:=GroupHomomorphismByImagesNC(U,Image(hom,U),gens,
					    List(gens,i->Image(hom,i)));
  if HasIsInjective(hom) and IsInjective(hom) then
    SetIsInjective(rest,true);
  fi;

  return rest;
end);


#############################################################################
##
#M  <a> = <b> . . . . . . . . . . . . . . . . . . . . . . . . . .  via images
##
InstallMethod( \=,
    "compare their AsGroupGeneralMappingByImages",
    IsIdenticalObj,
    [ IsGroupGeneralMapping, IsGroupGeneralMapping ], 0,
    function( a, b )
    local i;

    # force both to GroupGeneralMappingsByImages
    if not IsGroupGeneralMappingByImages( a ) then
      a:= AsGroupGeneralMappingByImages( a );
    fi;
    if not IsGroupGeneralMappingByImages( b ) then
      b:= AsGroupGeneralMappingByImages( b );
    fi;

    # try to fall back on homomorphism routines
    if IsSingleValued(a) and IsSingleValued(b) then
      # As both are single valued (and the appropriate flags are now set)
      # we will automatically fall in the routines for homomorphisms.
      # So this is not an infinite recursion.
#T is this really safe?
      return a = b;
    fi;

    # now do the hard test
    if Source(a)<>Source(b) 
       or Range(a)<>Range(b)
       or PreImagesRange(a)<>PreImagesRange(b)
       or ImagesSource(a)<>ImagesSource(b) then
      return false;
    fi;
    for i in PreImagesRange(a) do
      if Set(Images(a,i))<>Set(Images(b,i)) then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . . . . .  via images
##
##  The composition of two group general mappings can be computed as
##  a group general mapping by images, *provided* that
##  - elements of the source of the first map can be cheaply decomposed 
##    in terms of the generators
##    (This is needed for computing images with a
##    group general mapping by images.)
##    and
##  - we are *not* in the situation of the composition of a general mapping
##    with a nice monomorphism.
##    (Here it will usually be better to store the explicit composition
##    of two mappings, think of an isomorphism from a matrix group to a
##    permutation group, where both the operation homomorphism and the
##    isomorphism of two permutation groups can compute (pre)images
##    efficiently, contrary to the composition when this is written as
##    homomorphism by images.)
##
##  (If both general mappings know that they are in fact homomorphisms
##  then also the result will be constructed as a homomorphism.)
##
InstallMethod( CompositionMapping2,
    "for gp. hom. and gp. gen. mapp., using `AsGroupGeneralMappingByImages'",
    FamSource1EqFamRange2,
    [ IsGroupHomomorphism, IsGroupGeneralMapping ], 0,
function( hom1, hom2 )
  if (not KnowsHowToDecompose(Source(hom2))) or IsNiceMonomorphism(hom2) then
    TryNextMethod();
  fi;
  hom2 := AsGroupGeneralMappingByImages( hom2 );
  return GroupGeneralMappingByImages( Source( hom2 ), Range( hom1 ),
	  hom2!.generators, List( hom2!.genimages, img ->
		  ImagesRepresentative( hom1, img ) ) );
end);

InstallMethod( CompositionMapping2,
    "for two group homomorphisms, using `AsGroupGeneralMappingByImages'",
    FamSource1EqFamRange2,
    [ IsGroupHomomorphism, IsGroupHomomorphism ], 0,
function( hom1, hom2 )
  if (not KnowsHowToDecompose(Source(hom2))) or IsNiceMonomorphism(hom2) then
    TryNextMethod();
  fi;
  hom2 := AsGroupGeneralMappingByImages( hom2 );
  return GroupHomomorphismByImagesNC( Source( hom2 ), Range( hom1 ),
	  hom2!.generators, List( hom2!.genimages, img ->
		  ImagesRepresentative( hom1, img ) ) );
end);


#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . . . . . . . . . .  via images
##
InstallMethod( InverseGeneralMapping,
    "for PBG-Hom",
    true,
    [ IsPreimagesByAsGroupGeneralMappingByImages ], 0,
    hom -> InverseGeneralMapping( AsGroupGeneralMappingByImages( hom ) ) );

InstallOtherMethod( SetInverseGeneralMapping, true,
    [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
      HasAsGroupGeneralMappingByImages,
      IsGeneralMapping ], SUM_FLAGS,
    function( hom, inv )
    SetInverseGeneralMapping( AsGroupGeneralMappingByImages( hom ), inv );
    TryNextMethod();
end );


#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . .  via images
##
InstallMethod( ImagesRepresentative, "for PBG-Hom",
    FamSourceEqFamElm,
    [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages,
      IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
  return ImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
end );


#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative,
    "for PBG-Hom",
    FamRangeEqFamElm,
    [ IsPreimagesByAsGroupGeneralMappingByImages,
      IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return PreImagesRepresentative( AsGroupGeneralMappingByImages( hom ),
                   elm );
end );

InstallAttributeMethodByGroupGeneralMappingByImages
  ( CoKernelOfMultiplicativeGeneralMapping, IsGroup );
InstallAttributeMethodByGroupGeneralMappingByImages
  ( KernelOfMultiplicativeGeneralMapping, IsGroup );
InstallAttributeMethodByGroupGeneralMappingByImages( PreImagesRange, IsGroup );
InstallAttributeMethodByGroupGeneralMappingByImages( ImagesSource, IsGroup );
InstallAttributeMethodByGroupGeneralMappingByImages( IsSingleValued, IsBool );
InstallAttributeMethodByGroupGeneralMappingByImages( IsInjective, IsBool );
InstallAttributeMethodByGroupGeneralMappingByImages( IsTotal, IsBool );
InstallAttributeMethodByGroupGeneralMappingByImages( IsSurjective, IsBool );


#############################################################################
##

#M  GroupGeneralMappingByImages( <G>, <H>, <gens>, <imgs> ) . . . . make GHBI
##
InstallMethod( GroupGeneralMappingByImages,
    "for group, group, list, list",
    true,
    [ IsGroup, IsGroup, IsList, IsList ], 0,
    function( G, H, gens, imgs )
    local   filter,  hom;
    
    hom := rec( generators := Immutable( gens ),
                genimages  := Immutable( imgs ) );
    filter := IsGroupGeneralMappingByImages;
    if IsPcgs( gens )  then
        filter := filter and IsGroupGeneralMappingByPcgs;
        hom.pcgs := gens;
        if IsModuloPcgs( gens ) and not IsPcgs(gens) then
            hom.generators := Concatenation( gens,
                  DenominatorOfModuloPcgs( gens ) );
            hom.genimages := Concatenation( imgs, List
                ( DenominatorOfModuloPcgs( gens ), x -> One( H ) ) );
        elif IsModuloPcgsPermGroupRep( gens ) then
            hom.generators := Concatenation( gens,
                  GeneratorsOfGroup( gens!.denominator ) );
            hom.genimages := Concatenation( imgs, List
                ( GeneratorsOfGroup( gens!.denominator ), x -> One( H ) ) );
        fi;
    fi;
    if IsPermGroup( G )  then
        filter := filter and IsPermGroupGeneralMappingByImages;
    fi;
    if IsPermGroup( H )  then
        filter := filter and IsToPermGroupGeneralMappingByImages;
    fi;

    # Do we map a free group or an fp group by its standard generators?
    # (So we can used MappedWord for mapping)?
    if ((IsSubgroupFpGroup(G) and not HasParent(G))
        or IsFreeGroup(G)) and 
       gens=GeneratorsOfGroup(G) then
      filter := filter and IsFromFpGroupStdGensGeneralMappingByImages;
    fi;
    if IsSubgroupFpGroup(H) then
        filter := filter and IsToFpGroupGeneralMappingByImages;
    fi;
    Objectify( NewType( GeneralMappingsFamily
            ( ElementsFamily( FamilyObj( G ) ),
              ElementsFamily( FamilyObj( H ) ) ), filter ), hom );
    SetSource( hom, G );
    SetRange ( hom, H );
    return hom;
end );

InstallMethod( GroupHomomorphismByImagesNC,
    "for group, group, list, list",
    true,
    [ IsGroup, IsGroup, IsList, IsList ], 0,
    function( G, H, gens, imgs )
    local   hom;

    hom := GroupGeneralMappingByImages( G, H, gens, imgs );
    SetFilterObj( hom, IsMapping );
    if IsPcGroup( H )  then
        SetFilterObj( hom, IsToPcGroupHomomorphismByImages );
    fi;
    return hom;
end );


#############################################################################
##
#M  AsGroupGeneralMappingByImages( <map> )  . . . . .  for group homomorphism
##
InstallMethod( AsGroupGeneralMappingByImages,
    "for a group homomorphism",
    true,
    [ IsGroupHomomorphism ], 0,
    function( map )
    local gens;
    gens:= GeneratorsOfGroup( PreImagesRange( map ) );
    return GroupHomomorphismByImagesNC( Source( map ), Range( map ),
               gens, List( gens, g -> ImagesRepresentative( map, g ) ) );
    end );

InstallMethod( AsGroupGeneralMappingByImages,
    "for group general mapping",
    true,
    [ IsGroupGeneralMapping ], 0,
    function( map )
    local gens, cok;
    gens:= GeneratorsOfGroup( PreImagesRange( map ) );
    cok := GeneratorsOfGroup( CoKernelOfMultiplicativeGeneralMapping( map ) );
    return GroupGeneralMappingByImages( Source( map ), Range( map ),
           Concatenation( gens, List( cok, g -> One( Source( map ) ) ) ),
           Concatenation( List( gens, g -> ImagesRepresentative( map, g ) ),
                   cok ) );
    end );
    
#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . . . . . . .  for GHBI
##
InstallMethod( AsGroupGeneralMappingByImages,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], SUM_FLAGS,
    IdFunc );


#############################################################################
##
#M  <hom1> = <hom2> . . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( \=, 
    "homomorphism by images with homomorphism: compare generator images",
    IsIdenticalObj,
    [ IsGroupHomomorphism and IsGroupGeneralMappingByImages,
      IsGroupHomomorphism ], 1,
    function( hom1, hom2 )
    local   i;
    
    if    Source( hom1 ) <> Source( hom2 )
       or Range ( hom1 ) <> Range ( hom2 )  then
        return false;
    elif     IsGroupGeneralMappingByImages( hom2 )
         and Length( hom2!.generators ) < Length( hom1!.generators )  then
        return hom2 = hom1;
    fi;
    for i  in [ 1 .. Length( hom1!.generators ) ]  do
        if ImagesRepresentative( hom2, hom1!.generators[ i ] )
           <> hom1!.genimages[ i ]  then
            return false;
        fi;
    od;
    return true;
end );

InstallMethod( \=,
    "homomorphism with general mapping: test b=a",
    IsIdenticalObj,
    [ IsGroupHomomorphism,
      IsGroupHomomorphism and IsGroupGeneralMappingByImages ], 0,
    function( hom1, hom2 )
    return hom2 = hom1;
end );

InstallMethod( \<,
    "group homomorphisms: Images of smallest generators",
    IsIdenticalObj,
    [ IsGroupHomomorphism, IsGroupHomomorphism ], 0,
    function(a,b)
    local gens;
    if Source(a)<>Source(b) then
      return Source(a)<Source(b);
    elif Range(a)<>Range(b) then
      return Range(a)<Range(b);
    else
      # The standard comparison is to compare the image lists on the set of
      # elements of the source. If however x and y have the same images under
      # a and b, certainly all their products have. Therefore it is sufficient
      # to test this on the of smallest generators.
      gens:=GeneratorsSmallest(Source(a));
      return List(gens,i->Image(a,i))<List(gens,i->Image(b,i));
    fi;
    end);


#############################################################################
##
#M  ImagesSource( <hom> ) . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ImagesSource, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ], 
    2, # rank higher than the next method to avoid infinite recursions
    hom -> SubgroupNC( Range( hom ), hom!.genimages ) );

InstallMethod( ImagesSource, "group homomorphisms", true,
    [ IsGroupHomomorphism ], 0,
    hom -> SubgroupNC( Range( hom ), List(GeneratorsOfGroup(Source(hom)),
          i->Image(hom,i))) );

#############################################################################
##
#M  PreImagesRange( <hom> ) . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( PreImagesRange,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> SubgroupNC( Source( hom ), hom!.generators ) );


#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( InverseGeneralMapping,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    return GroupGeneralMappingByImages( Range( hom ),   Source( hom ),
                                        hom!.genimages, hom!.generators );
    end );

InstallMethod( InverseGeneralMapping,
    "for bijective GHBI",
    true,
    [ IsGroupGeneralMappingByImages and IsBijective ], 0,
    function( hom )
    hom := GroupHomomorphismByImagesNC( Range( hom ),   Source( hom ),
                                        hom!.genimages, hom!.generators );
    SetIsBijective( hom, true );
    return hom;
end );


#############################################################################
##
#F  MakeMapping( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallGlobalFunction( MakeMapping, function( hom )
    local   elms,       # elements of subgroup of '<hom>.source'
            elmr,       # representatives of <elms> in '<hom>.elements'
            imgs,       # elements of subgroup of '<hom>.range'
            imgr,       # representatives of <imgs> in '<hom>.images'
            rep,        # one new element of <elmr> or <imgr>
            i, j, k;    # loop variables

    # if necessary compute the mapping with a Dimino algorithm
    if not IsBound( hom!.elements )  then
        hom!.elements := [ One( Source( hom ) ) ];
        hom!.images   := [ One( Range ( hom ) ) ];
        for i  in [ 1 .. Length( hom!.generators ) ]  do
            elms := ShallowCopy( hom!.elements );
            elmr := [ One( Source( hom ) ) ];
            imgs := ShallowCopy( hom!.images );
            imgr := [ One( Range( hom ) ) ];
            j := 1;
            while j <= Length( elmr )  do
                for k  in [ 1 .. i ]  do
                    rep := elmr[j] * hom!.generators[k];
                    if not rep in hom!.elements  then
                        Append( hom!.elements, elms * rep );
                        Add( elmr, rep );
                        rep := imgr[j] * hom!.genimages[k];
                        Append( hom!.images, imgs * rep );
                        Add( imgr, rep );
                    fi;
                od;
                j := j + 1;
            od;
            SortParallel( hom!.elements, hom!.images );
            IsSSortedList( hom!.elements );  # give a hint that this is a set
#T MakeImmutable!
        od;
    fi;
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  for GHBI
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    local   C,          # co kernel of <hom>, result
            gen,        # one generator of <C>
            i, k;       # loop variables

    # make sure we have the mapping
    if not IsBound( hom!.elements )  then
        MakeMapping( hom );
    fi;

    # start with the trivial co kernel
    C := TrivialSubgroup( Range( hom ) );

    # for each element of the source and each generator of the source
    for i  in [ 1 .. Length( hom!.elements ) ]  do
        for k  in [ 1 .. Length( hom!.generators ) ]  do

            # the co kernel must contain the corresponding Schreier generator
            gen := hom!.images[i] * hom!.genimages[k]
                 / hom!.images[ Position( hom!.elements,
                                         hom!.elements[i]*hom!.generators[k])];
            C := ClosureSubgroup( C, gen );

        od;
    od;

    # return the co kernel
    return C;
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . . .  for GHBI
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> CoKernelOfMultiplicativeGeneralMapping(
               InverseGeneralMapping( hom ) ) );

#############################################################################
##
#M  IsInjective( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( IsInjective,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> IsSingleValued( InverseGeneralMapping( hom ) ) );

#############################################################################
##
#F  ImagesRepresentativeGMBIByElementsList( <hom>, <elm> )
##
InstallGlobalFunction( ImagesRepresentativeGMBIByElementsList,
function( hom, elm )
  local   p;
  if not IsBound( hom!.elements )  then
      MakeMapping( hom );
  fi;
  p := Position( hom!.elements, elm );
  if p <> fail  then  return hom!.images[ p ];
		else  return fail;             fi;
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ImagesRepresentative,
    "for GHBI and mult.-elm.-with-inverse",
    FamSourceEqFamElm,
    [ IsGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    ImagesRepresentativeGMBIByElementsList);

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . . .  for GHBI
##
InstallMethod( PreImagesRepresentative,
    "for GHBI and mult.-elm.-with-inverse",
    FamRangeEqFamElm,
    [ IsGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    if IsBound( hom!.images )  and elm in hom!.images  then
        return hom!.elements[ Position( hom!.images, elm ) ];
    else
        return ImagesRepresentative( InverseGeneralMapping( hom ), elm );
    fi;
end );


#############################################################################
##
#M  ViewObj( <hom> )  . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ViewObj,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    Print( hom!.generators, " -> ", hom!.genimages );
end );


#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( PrintObj,
    "for group general mapping b.i.",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    Print( "GroupGeneralMappingByImages( ",
           Source( hom ), ", ", Range(  hom ), ", ",
           hom!.generators, ", ", hom!.genimages, " )" );
    end );

InstallMethod( PrintObj,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages and IsMapping ], 0,
    function( hom )
    Print( "GroupHomomorphismByImages( ",
           Source( hom ), ", ", Range(  hom ), ", ",
           hom!.generators, ", ", hom!.genimages, " )" );
    end );


#############################################################################
##
#M  ConjugatorAutomorphism( <G>, <g> )
##
InstallMethod( ConjugatorAutomorphism, "group and mult.-elm.-with-inverse",
    IsCollsElms,
        [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
function( G, g )
local   fam,  inn;

  fam := ElementsFamily( FamilyObj( G ) );
  inn := Objectify( NewType( GeneralMappingsFamily( fam, fam ),
		  IsConjugatorAutomorphismRep ), rec() );
  SetConjugatorInnerAutomorphism(inn,g);
  SetSource( inn, G );
  SetRange ( inn, G );
  return inn;
end );

#############################################################################
##
#M  InnerAutomorphism( <G>, <g> ) . . . . . . . . . . . .  inner automorphism
##
InstallMethod( InnerAutomorphism, "group and mult.-elm.-with-inverse",
  IsCollsElms,
      [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
function( G, g )
local hom;
  
  hom:=ConjugatorAutomorphism(G,g);
  SetIsInnerAutomorphism(hom,true);
  return hom;
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <inn> )  . . . . .  for inner automorphism
##
InstallMethod( AsGroupGeneralMappingByImages,
    "for inner automorphism",
    true,
    [ IsConjugatorAutomorphismRep ], 0,
    function( inn )
    local   G,  gens;
    
    G := Source( inn );
    gens := GeneratorsOfGroup( G );
    inn := GroupGeneralMappingByImages( G, G, gens,
                   OnTuples( gens, ConjugatorInnerAutomorphism(inn) ) );
    SetIsBijective( inn, true );
    return inn;
end );

#############################################################################
##
#M  InverseGeneralMapping( <inn> )  . . . . . . . . .  for inner automorphism
##
InstallMethod( InverseGeneralMapping,"for conjugator automorphism",
    true, [ IsConjugatorAutomorphismRep ], 0,
function( inn )
    return ConjugatorAutomorphism( Source( inn ), 
             ConjugatorInnerAutomorphism(inn)^ -1 );
end );

InstallMethod( InverseGeneralMapping,"for inner automorphism",
    true, [ IsInnerAutomorphism ], 0,
function( inn )
    return InnerAutomorphism( Source( inn ), 
             ConjugatorInnerAutomorphism(inn)^ -1 );
end );

#############################################################################
##
#M  CompositionMapping2( <inn1>, <inn2> ) . . . . . . for inner automorphisms
##
InstallMethod( CompositionMapping2, "conjugator automorphisms", IsIdenticalObj,
        [ IsConjugatorAutomorphismRep, IsConjugatorAutomorphismRep ], 0,
function( inn1, inn2 )
  if not IsIdenticalObj( Source( inn1 ), Source( inn2 ) )  then
    TryNextMethod();
  fi;
  return ConjugatorAutomorphism( Source( inn1 ),
		  ConjugatorInnerAutomorphism(inn2)
		  *ConjugatorInnerAutomorphism(inn1));
end );

InstallMethod( CompositionMapping2, "inner automorphisms", IsIdenticalObj,
        [ IsInnerAutomorphism, IsInnerAutomorphism ], 0,
function( inn1, inn2 )
  if not IsIdenticalObj( Source( inn1 ), Source( inn2 ) )  then
    TryNextMethod();
  fi;
  return InnerAutomorphism( Source( inn1 ),
		  ConjugatorInnerAutomorphism(inn2)
		  *ConjugatorInnerAutomorphism(inn1));
end );

#############################################################################
##
#M  ImagesRepresentative( <inn>, <g> )  . . . . . . .  for inner automorphism
##
InstallMethod( ImagesRepresentative, "<inn>, <g>", FamSourceEqFamElm,
        [ IsConjugatorAutomorphismRep, IsMultiplicativeElementWithInverse ], 0,
    function( inn, g )
    return g ^ ConjugatorInnerAutomorphism(inn);
end );

#############################################################################
##
#M  ImagesSet( <inn>, <U> ) . . . . . . . . . . . . .  for inner automorphism
##
InstallMethod( ImagesSet,
    "for inner automorphism, and group",
    CollFamSourceEqFamElms,
        [ IsConjugatorAutomorphismRep, IsGroup ], 0,
    function( inn, U )
    return U ^ ConjugatorInnerAutomorphism(inn);
end );

#############################################################################
##
#M  PreImagesRepresentative( <inn>, <g> ) . . . . . .  for inner automorphism
##
InstallMethod( PreImagesRepresentative, "<inn>, <g>", FamRangeEqFamElm,
        [ IsConjugatorAutomorphismRep, IsMultiplicativeElementWithInverse ], 0,
    function( inn, g )
    return g ^ ( ConjugatorInnerAutomorphism(inn) ^ -1 );
end );

#############################################################################
##
#M  PreImagesSet( <inn>, <U> )  . . . . . . . . . . .  for inner automorphism
##
InstallMethod( PreImagesSet,
    "for inner automorphism, and group",
    CollFamRangeEqFamElms,
        [ IsConjugatorAutomorphismRep, IsGroup ], 0,
    function( inn, U )
    return U ^ ( ConjugatorInnerAutomorphism(inn) ^ -1 );
end );


#############################################################################
##
#M  ViewObj( <inn> )  . . . . . . . . . . . . . . . .  for inner automorphism
##
InstallMethod( ViewObj,
    "for inner automorphism",
    true,
    [ IsConjugatorAutomorphismRep ], 0,
    function( inn )
    Print( "^", ConjugatorInnerAutomorphism(inn) );
    end );


#############################################################################
##
#M  PrintObj( <inn> ) . . . . . . . . . . . . . . . .  for inner automorphism
##
InstallMethod( PrintObj, "for conjugator automorphism", true,
    [ IsConjugatorAutomorphismRep ], 0,
function( inn )
  Print( "ConjugatorAutomorphism( ", Source( inn ), ", ",
	  ConjugatorInnerAutomorphism(inn), " )" );
end );

InstallMethod( PrintObj, "for inner automorphism", true,
    [ IsInnerAutomorphism ], 0,
function( inn )
  Print( "InnerAutomorphism( ", Source( inn ), ", ",
	  ConjugatorInnerAutomorphism(inn), " )" );
end );

#############################################################################
##
#M  IsConjugatorAutomorphism( <hom> )
##
InstallOtherMethod( IsConjugatorAutomorphism, "group homomorphism",true,
  [IsGroupGeneralMapping],0,
function(hom)
local s, rep;
  s:=Source(hom);
  if not (IsGroupHomomorphism(hom) and IsBijective(hom) and
          s=Range(hom)) then
    return false;
  fi;
  rep:=RepresentativeOperation(s,GeneratorsOfGroup(s),
         List(GeneratorsOfGroup(s),i->ImagesRepresentative(hom,i)),OnTuples);
  if rep<>fail then
    SetConjugatorInnerAutomorphism(hom,rep);
    return true;
  else
    return false;
  fi;
end);

#############################################################################
##
#M  IsInnerAutomorphism( <hom> )
##
InstallOtherMethod( IsInnerAutomorphism, "group homomorphism",true,
  [IsGroupGeneralMapping],0,
function(hom)
  return IsConjugatorAutomorphism(hom) and 
    ConjugatorInnerAutomorphism(hom) in Source(hom);
end);


#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) check whether N \unlhd G?
##
InstallGlobalFunction( NaturalHomomorphismByNormalSubgroup, function(G,N)
  if not (IsSubgroup(G,N) and IsNormal(G,N)) then
    Error("<N> must be a normal subgroup of <G>");
  fi;
  return NaturalHomomorphismByNormalSubgroupNC(G,N);
end );

InstallMethod( NaturalHomomorphismByNormalSubgroupOp,
    "for group, and trivial group (delegate to `IdentityMapping')",
    IsIdenticalObj,
    [ IsGroup, IsGroup and IsTrivial ], SUM_FLAGS,
    function( G, T )
    return IdentityMapping( G );
end );


#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . .  if given by pcgs
##
InstallMethod( ImagesRepresentative,
    "for total GGMBPCGS, and mult.-elm.-with-inverse",
    FamSourceEqFamElm,
        [ IsGroupGeneralMappingByPcgs and IsTotal,
                                        # ^ because of `ExponentsOfPcElement'
          IsMultiplicativeElementWithInverse ],
        100,  # to override methods for `IsPerm( <elm> )'
    function( hom, elm )
    local   exp;
    
    exp := ExponentsOfPcElement( hom!.pcgs, elm );
    return WordVector( hom!.genimages, One( Range( hom ) ), exp );
end );


#############################################################################
##
#M  IsomorphismPermGroup( <G> ) . . . . . . . . .  by right regular operation
##
InstallMethod( IsomorphismPermGroup, "right regular operation", true,
        [ IsGroup and IsFinite ], 0,
    function( G )
    local   nice;
    
    nice := OperationHomomorphism( G, G, OnRight,"surjective" );
    SetIsBijective( nice, true );
    return nice;
end );

#############################################################################
##
#M  IsomorphismPcGroup( <G> ) . . . . . . . .  via permutation representation
##
InstallMethod( IsomorphismPcGroup, "via permutation representation", true,
        [ IsGroup and IsFinite ], 0,
function( G )
local p,a;
  p:=IsomorphismPermGroup(G);
  a:=IsomorphismPcGroup(Image(p));
  if a=fail then
    return a;
  else
    return p*a;
  fi;
end);


#############################################################################
##
#F  GroupHomomorphismByFunction( <D>, <E>, <fun> )
#F  GroupHomomorphismByFunction( <D>, <E>, <fun>, <invfun> )
##
InstallGlobalFunction( GroupHomomorphismByFunction, function ( arg )
    local   map;        # mapping <map>, result

    # no inverse function given
    if Length(arg) = 3  then

      # make the general mapping
      map:= Objectify(
        NewType(GeneralMappingsFamily(ElementsFamily(FamilyObj(arg[1])),
        ElementsFamily(FamilyObj(arg[2]))),
                               IsSPMappingByFunctionRep
                           and IsSingleValued
                           and IsTotal and IsGroupHomomorphism ),
                       rec( fun:= arg[3] ) );

    # inverse function given
    elif Length(arg) = 4  then

      # make the mapping
      map:= Objectify(
        NewType(GeneralMappingsFamily(ElementsFamily(FamilyObj(arg[1])),
        ElementsFamily(FamilyObj(arg[2]))),
                               IsSPMappingByFunctionWithInverseRep
                           and IsBijective
			   and IsGroupHomomorphism),
                       rec( fun    := arg[3],
                            invFun := arg[4] ) );

    # otherwise signal an error
    else
      Error( "usage: GroupHomomorphismByFunction( <D>, <E>, <fun>[, <inv>] )" );
    fi;

    SetSource(map,arg[1]);
    SetRange(map,arg[2]);
    # return the mapping
    return map;
end );


#############################################################################
##
#E

