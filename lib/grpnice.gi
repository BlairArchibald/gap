#############################################################################
##
#W  grpnice.gi                  GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This  file  contains generic     methods   for groups handled    by  nice
##  monomorphisms..
##
Revision.grpnice_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  SetNiceMonomorphism(<G>,<hom>)
##
##  This setter method is special because we want to tell every nice
##  monomorphism that it is one.
InstallMethod(SetNiceMonomorphism,"set `IsNiceomorphism' property",true,
  [IsGroup,IsGroupGeneralMapping],SUM_FLAGS+10, #override system setter
function(G,hom)
  SetFilterObj(hom,IsNiceMonomorphism);
  TryNextMethod();
end);

#############################################################################
##
#M  GeneratorsOfMagmaWithInverses( <group> )  .  get generators from nice obj
##
InstallMethod( GeneratorsOfMagmaWithInverses,
    true,
    [ IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( grp )
    local   nice;
    nice := NiceMonomorphism(grp);
    return List( GeneratorsOfGroup(NiceObject(grp)),
                 x -> PreImagesRepresentative(nice,x) );
end );


#############################################################################
##
#M  SmallGeneratingSet( <group> )  .  get generators from nice obj
##
InstallMethod( SmallGeneratingSet, true,
    [ IsGroup and IsHandledByNiceMonomorphism ], NICE_FLAGS,

function( grp )
    local   nice;
    nice := NiceMonomorphism(grp);
    return List( SmallGeneratingSet(NiceObject(grp)),
                 x -> PreImagesRepresentative(nice,x) );
end );


#############################################################################
##
#M  GroupByNiceMonomorphism( <nice>, <group> )  construct group with nice obj
##
InstallMethod( GroupByNiceMonomorphism,
    true,
    [ IsGroupHomomorphism,
      IsGroup ],
    0,

function( nice, grp )
    local   fam,  pre;

    fam := FamilyObj( Source(nice) );
    pre := Objectify(NewType(fam,IsGroup and IsAttributeStoringRep), rec());
    SetIsHandledByNiceMonomorphism( pre, true );
    SetNiceMonomorphism( pre, nice );
    SetNiceObject( pre, grp );
    SetOne(pre,One(Source(nice)));
    if HasSize(grp) then
      SetSize(pre,Size(grp));
    fi;
    return pre;
end );


#############################################################################
##
#M  NiceObject( <group> ) . . . . . . . . . . . . .  get nice object of group
##
InstallMethod( NiceObject,
    true,
    [ IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( G )
    local   nice,  img,  D;
    
    nice := NiceMonomorphism( G );
    img := ImagesSet( nice, G );
    if     IsOperationHomomorphism( nice )
       and HasBaseOfGroup( UnderlyingExternalSet( nice ) )  then
        if not IsBound( UnderlyingExternalSet( nice )!.basePermImage )  then
            D := HomeEnumerator( UnderlyingExternalSet( nice ) );
            UnderlyingExternalSet( nice )!.basePermImage :=
	      List(BaseOfGroup(UnderlyingExternalSet(nice)),
		   b->PositionCanonical(D,b));
        fi;
        SetBaseOfGroup( img, UnderlyingExternalSet( nice )!.basePermImage );
    fi;
    return img;
end );


#############################################################################
##
#M  NiceMonomorphism( <group> )	. . construct a nice monomorphism from parent
##
InstallMethod(NiceMonomorphism,
    "for subgroups that get the nice monomorphism by their parent",
    true,
    [ IsGroup and IsHandledByNiceMonomorphism and HasParent],
    0,

function(G)
    local P;

    P :=Parent(G);
    if not IsHandledByNiceMonomorphism(P)  then
        TryNextMethod();
    fi;
    return NiceMonomorphism(P);
end );

#############################################################################
##
#M  NiceMonomorphism( <G> ) . . . . . . . . . . . . . . . . regular operation
##
InstallMethod( NiceMonomorphism, "regular operation", true,
        [ IsGroup and IsHandledByNiceMonomorphism ], 0,
    function( G )
    local   mon;
    
    if not HasGeneratorsOfGroup( G )  then
        TryNextMethod();
    elif not HasOne( G )  then
        if IsEmpty( GeneratorsOfGroup( G ) )  then
            TryNextMethod();
        else
            SetOne( G, One( GeneratorsOfGroup( G )[ 1 ] ) );
        fi;
    fi;
    mon := OperationHomomorphism( G, AsList( G ), OnRight );
    SetIsInjective( mon, true );
    return mon;
end );


#############################################################################
##
#M  \=( <G>, <H> )  . . . . . . . . . . . . . .  test if two groups are equal
##
PropertyMethodByNiceMonomorphismCollColl( \=,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  \in( <elm>, <G> ) . . . . . . . . . . . . . . . . .  test if <elm> in <G>
##
InstallMethod( \in,
    "by nice monomorphism",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( elm, G )
    local   nice,  img;
    
    nice := NiceMonomorphism( G );
    img  := ImagesRepresentative( nice, elm );
    return img<>fail and img in NiceObject( G )
       and PreImagesRepresentative( nice, img ) = elm;
end );


#############################################################################
##
#M  CanEasilyTestMembership( <permgroup> )
##
InstallTrueMethod(CanEasilyTestMembership,IsHandledByNiceMonomorphism);

#############################################################################
##
#M  AbelianInvariants( <G> )  . . . . . . . . . abelian invariants of a group
##
AttributeMethodByNiceMonomorphism( AbelianInvariants,
    [ IsGroup ] );


#############################################################################
##
#M  Centralizer( <G>, <H> )   . . . . . . . . . . . . centralizer of subgroup
##
SubgroupMethodByNiceMonomorphismCollColl( CentralizerOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Centralizer( <G>, <elm> ) . . . . . . . . . . . .  centralizer of element
##
SubgroupMethodByNiceMonomorphismCollElm( CentralizerOp,
    [ IsGroup, IsObject ] );


#############################################################################
##
#M  ChiefSeries( <G> )  . . . . . . . . . . . . . . . chief series of a group
##
GroupSeriesMethodByNiceMonomorphism( ChiefSeries,
    [ IsGroup ] );


#############################################################################
##
#M  ClosureGroup( <G>, <U> )  . . . . . . . . . . closure of group with group
##
GroupMethodByNiceMonomorphismCollColl( ClosureGroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . . . . . . . . closure of group with element
##
GroupMethodByNiceMonomorphismCollElm( ClosureGroup,
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . . . .  commutator factor group of a group
##
AttributeMethodByNiceMonomorphism( CommutatorFactorGroup,
    [ IsGroup ] );


#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )  . . . . commutator subgroup of two groups
##
GroupMethodByNiceMonomorphismCollColl( CommutatorSubgroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  ConjugacyClasses
##
InstallMethod(ConjugacyClasses,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism],NICE_FLAGS,
function(g)
local mon,cl,clg,c,i;
   mon:=NiceMonomorphism(g);
   cl:=ConjugacyClasses(NiceObject(g));
   clg:=[];
   for i in cl do
     c:=ConjugacyClass(g,PreImagesRepresentative(mon,Representative(i)));
     if HasStabilizerOfExternalSet(i) then
       SetStabilizerOfExternalSet(c,PreImages(mon,StabilizerOfExternalSet(i)));
     fi;
     Add(clg,c);
   od;
   return clg;
end);


#############################################################################
##
#M  ConjugateGroup( <G>, <g> )	. . . . . . . . . . . . . .  conjugate of <G>
##
GroupMethodByNiceMonomorphismCollElm( ConjugateGroup,
    [ IsGroup and HasParent, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#M  Core( <G>, <U> )  . . . . . . . . . . . . . . . .  core of a <U> in a <G>
##
GroupMethodByNiceMonomorphismCollColl( CoreOp,
    [ IsGroup, IsGroup ] );


##############################################################################
##
#M  DerivedLength( <G> ) . . . . . . . . . . . . . . derived length of a group
##
AttributeMethodByNiceMonomorphism( DerivedLength,
    [ IsGroup ] );


#############################################################################
##
#M  DerivedSeriesOfGroup( <G> ) . . . . . . . . . . derived series of a group
##
GroupSeriesMethodByNiceMonomorphism( DerivedSeriesOfGroup,
    [ IsGroup ] );


#############################################################################
##
#M  DerivedSubgroup( <G> )  . . . . . . . . . . . derived subgroup of a group
##
SubgroupMethodByNiceMonomorphism( DerivedSubgroup,
    [ IsGroup ] );


#############################################################################
##
#M  ElementaryAbelianSeries( <G> )  . .  elementary abelian series of a group
##
GroupSeriesMethodByNiceMonomorphism( ElementaryAbelianSeries,
    [ IsGroup ] );


#############################################################################
##
#M  Exponent( <G> ) . . . . . . . . . . . . . . . . . . . . . exponent of <G>
##
AttributeMethodByNiceMonomorphism( Exponent,
    [ IsGroup ] );


#############################################################################
##
#M  FittingSubgroup( <G> )  . . . . . . . . . . . Fitting subgroup of a group
##
SubgroupMethodByNiceMonomorphism( FittingSubgroup,
    [ IsGroup ] );


#############################################################################
##
#M  FrattiniSubgroup( <G> ) . . . . . . . . . .  Frattini subgroup of a group
##
SubgroupMethodByNiceMonomorphism( FrattiniSubgroup,
    [ IsGroup ] );


#############################################################################
##
#M  Index( <G>, <H> ) . . . . . . . . . . . . . . . . . . index of <H> in <G>
##
AttributeMethodByNiceMonomorphismCollColl( IndexOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Intersection2( <G>, <H> ) . . . . . . . . . . . .  intersection of groups
##
GroupMethodByNiceMonomorphismCollColl( Intersection2,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsCentral( <G>, <U> )  . . . . . . . . is a group centralized by another?
##
PropertyMethodByNiceMonomorphismCollColl( IsCentral,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . test if a group is cyclic
##
PropertyMethodByNiceMonomorphism( IsCyclic,
    [ IsGroup ] );


#############################################################################
##
#M  IsElementaryAbelian( <G> )  . . . . test if a group is elementary abelian
##
PropertyMethodByNiceMonomorphism( IsElementaryAbelian,
    [ IsGroup ] );


#############################################################################
##
#M  IsMonomialGroup( <G> )  . . . . . . . . . . . test if a group is monomial
##
PropertyMethodByNiceMonomorphism( IsMonomialGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsNilpotentGroup( <G> ) . . . . . . . . . .  test if a group is nilpotent
##
PropertyMethodByNiceMonomorphism( IsNilpotentGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsNormal( <G>, <U> )  . . . . . . . . . . . . . test if <U> normal in <G>
##
PropertyMethodByNiceMonomorphismCollColl( IsNormalOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsPerfectGroup( <G> ) . . . . . . . . . . . .  test if a group is perfect
##
PropertyMethodByNiceMonomorphism( IsPerfectGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsSimpleGroup( <G> )  . . . . . . . . . . . . . test if a group is simple
##
PropertyMethodByNiceMonomorphism( IsSimpleGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsSolvableGroup( <G> )  . . . . . . . . . . . test if a group is solvable
##
PropertyMethodByNiceMonomorphism( IsSolvableGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsSubset( <G>, <H> ) . . . . . . . . . . . . .  test for subset of groups
##
PropertyMethodByNiceMonomorphismCollColl( IsSubset,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsSupersolvableGroup( <G> ) . . . . . .  test if a group is supersolvable
##
PropertyMethodByNiceMonomorphism( IsSupersolvableGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsomorphismPcGroup
##
InstallMethod(IsomorphismPcGroup,"via niceomorphisms",true,
  [IsGroup and IsHandledByNiceMonomorphism],NICE_FLAGS,
function(g)
local mon,iso,xset;
   mon:=NiceMonomorphism(g);
   iso:=IsomorphismPcGroup(NiceObject(g));
   if iso=fail then
     return fail;
   else
     return mon*iso;
   fi;
end);

#############################################################################
##
#M  JenningsSeries( <G> ) . . . . . . . . . . .  jennings series of a p-group
##
GroupSeriesMethodByNiceMonomorphism( JenningsSeries,
    [ IsGroup ] );


#############################################################################
##
#M  LowerCentralSeriesOfGroup( <G> )  . . . . lower central series of a group
##
GroupSeriesMethodByNiceMonomorphism( LowerCentralSeriesOfGroup,
    [ IsGroup ] );

#############################################################################
##
#M  MaximalSubgroupClassReps( <G> )
##
SubgroupsMethodByNiceMonomorphism( MaximalSubgroupClassReps, [ IsGroup ] );

#############################################################################
##
#M  NormalSubgroups( <G> )
##
SubgroupsMethodByNiceMonomorphism( NormalSubgroups, [ IsGroup ] );


#############################################################################
##
#M  NormalClosure( <G>, <U> ) . . . . normal closure of a subgroup in a group
##
GroupMethodByNiceMonomorphismCollColl( NormalClosureOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  NormalIntersection( <G>, <U> )  . . . . . intersection with normal subgrp
##
GroupMethodByNiceMonomorphismCollColl( NormalIntersection,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Normalizer( <G>, <U> )  . . . . . . . . . . . .  normalizer of <U> in <G>
##
SubgroupMethodByNiceMonomorphismCollColl( NormalizerOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . no. of conj. classes of elements in a group
##
AttributeMethodByNiceMonomorphism( NrConjugacyClasses,
    [ IsGroup ] );


#############################################################################
##
#M  NrConjugacyClassesInSupergroup( <U>, <H> ) . . . . . . . .  no of classes
##
AttributeMethodByNiceMonomorphismCollColl( NrConjugacyClassesInSupergroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  PCentralSeriesOp( <G>, <p> )  . . . . . .  . . . . . . <p>-central series
##
GroupSeriesMethodByNiceMonomorphismCollOther( PCentralSeriesOp,
    [ IsGroup, IsPosInt ] );


#############################################################################
##
#M  PCoreOp( <G>, <p> ) . . . . . . . . . . . . . . . . . . p-core of a group
##
SubgroupMethodByNiceMonomorphismCollOther( PCoreOp,
    [ IsGroup, IsPosInt ] );


#############################################################################
##
#M  RadicalGroup( <G> ) . . . . . . . . . . . . . . . . .  radical of a group
##
SubgroupMethodByNiceMonomorphism( RadicalGroup,
    [ IsGroup ] );


#############################################################################
##
#M  RationalClasses
##
InstallMethod(RationalClasses,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism],NICE_FLAGS,
function(g)
local mon,cl,clg,c,i;
   mon:=NiceMonomorphism(g);
   cl:=RationalClasses(NiceObject(g));
   clg:=[];
   for i in cl do
     c:=RationalClass(g,PreImagesRepresentative(mon,Representative(i)));
     if HasStabilizerOfExternalSet(i) then
       SetStabilizerOfExternalSet(c,PreImages(mon,StabilizerOfExternalSet(i)));
     fi;
     if HasGaloisGroup(i) then
       SetGaloisGroup(c,GaloisGroup(i));
     fi;
     Add(clg,c);
   od;
   return clg;
end);


#############################################################################
##
#M  RightCosets
##
InstallMethod(RightCosetsNC,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup],NICE_FLAGS,
function(g,u)
local mon,rt;
   mon:=NiceMonomorphism(g);
   rt:=RightTransversal(ImagesSet(mon,g),ImagesSet(mon,u));
   rt:=List(rt,i->RightCoset(u,PreImagesRepresentative(mon,i)));
   return rt;
end);


#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . . . . . . . . size of <G>
##
AttributeMethodByNiceMonomorphism( Size,
    [ IsGroup ] );


#############################################################################
##
#M  SubnormalSeries( <G>, <U> ) . subnormal series from a group to a subgroup
##
GroupSeriesMethodByNiceMonomorphismCollColl( SubnormalSeriesOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . . . . . Sylow subgroup of a group
##
SubgroupMethodByNiceMonomorphismCollOther( SylowSubgroupOp,
    [ IsGroup, IsPosInt ] );


#############################################################################
##
#M  UpperCentralSeriesOfGroup( <G> )  . . . . upper central series of a group
##
GroupSeriesMethodByNiceMonomorphism( UpperCentralSeriesOfGroup,
    [ IsGroup ] );


#############################################################################
##
#M  RepresentativeOperation( <G> )  . . . . upper central series of a group
##
InstallOtherMethod(RepresentativeOperationOp,"nice group on elements",
  IsCollsElmsElmsX,[IsHandledByNiceMonomorphism and IsGroup,
  IsMultiplicativeElementWithInverse,IsMultiplicativeElementWithInverse,
  IsFunction],10,
function(G,a,b,op)
local hom,rep;
  if op<>OnPoints then
    TryNextMethod();
  fi;
  hom:=NiceMonomorphism(G);
  rep:=RepresentativeOperation(NiceObject(G),Image(hom,a),Image(hom,b),
                               OnPoints);
  if rep<>fail then
    rep:=PreImagesRepresentative(hom,rep);
  fi;
  return rep;
end);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . . .  via nicomorphism
##
InstallMethod( NaturalHomomorphismByNormalSubgroupOp, IsIdenticalObj,
        [ IsHandledByNiceMonomorphism and IsGroup, IsGroup ], NICE_FLAGS,
    function( G, N )
    local   nice;
    
    nice := NiceMonomorphism( G );
    G := ImagesSet( nice,G );
    N := ImagesSet   ( nice, N );
    return CompositionMapping( NaturalHomomorphismByNormalSubgroup( G, N ),
                   nice );
end );

#############################################################################
##
#M  GroupGeneralMappingByImages( <G>, <H>, <gens>, <imgs> ) . . . . make GHBI
##
RUN_IN_GGMBI:=false; # If somebody would call `GHBI' to make a
                     # NiceMonomorphism, we would get an infinite recursion.
		     # Therefore the method sets this flag (test whether it
		     # had been called already) and -- if yes -- passes
		     # gently to the next method.

InstallMethod( GroupGeneralMappingByImages,
   "from a group handled by a niceomorphism",true,
    [ IsGroup and IsHandledByNiceMonomorphism, IsGroup, IsList, IsList ], 0,
function( G, H, gens, imgs )
local nice,geni,map2;
  if RUN_IN_GGMBI=true then
    TryNextMethod(); 
  fi;
  RUN_IN_GGMBI:=true;
  nice:=NiceMonomorphism(G);
  geni:=List(gens,i->Image(nice,i));
  map2:=GroupGeneralMappingByImages(NiceObject(G),H,geni,imgs);
  RUN_IN_GGMBI:=false;
  return CompositionMapping(map2,nice);
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <niceomorphism> )
##
InstallMethod( AsGroupGeneralMappingByImages,
  "for Niceomorphisms: avoid recursion",true,
  [IsGroupGeneralMapping and IsNiceMonomorphism],NICE_FLAGS,
function(hom)
local h;
  # we actually want to use the next method with `RUN_IN_GGMBI' set to
  # `true'. Therefore we redispatch, but will skip this method the second
  # time.
  if RUN_IN_GGMBI=true then
    TryNextMethod();
  fi;
  RUN_IN_GGMBI:=true;
  h:=AsGroupGeneralMappingByImages(hom);
  RUN_IN_GGMBI:=false;
  return h;
end);

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative, "for PBG-Niceo",
    FamRangeEqFamElm,
    [ IsPreimagesByAsGroupGeneralMappingByImages and IsNiceMonomorphism,
      IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
local p;
  # avoid the double dispatch for `AsGroupGeneralMappingByImages'
  RUN_IN_GGMBI:=true;
  p:=PreImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
  RUN_IN_GGMBI:=false;
  return p;
end );

#############################################################################
##
#E  grpnice.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
