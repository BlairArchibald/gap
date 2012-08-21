#############################################################################
##
#W  mapphomo.gd                 GAP library                     Thomas Breuer
#W                                                         and Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the definitions of properties of mappings preserving
##  algebraic structure.
##
##  1. properties and attributes of gen. mappings that respect multiplication
##  2. properties and attributes of gen. mappings that respect addition
##  3. properties and attributes of gen. mappings that respect scalar mult.
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##
Revision.mapphomo_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. properties and attributes of gen. mappings that respect multiplication
##

#############################################################################
##
#P  RespectsMultiplication( <mapp> )
##
##  Let <mapp> be a general mapping with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsMultiplication' returns `true' if
##  $S$ and $R$ are magmas such that
##  $(s_1,r_1), (s_2,r_2) \in F$ implies $(s_1 \* s_2,r_1 \* r_2) \in F$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsMultiplication' returns `true'
##  if and only if the equation
##  `<s1>^<mapp> * <s2>^<mapp> = (<s1>*<s2>)^<mapp>'
##  holds for all <s1>, <s2> in $S$.
##
DeclareProperty( "RespectsMultiplication", IsGeneralMapping );


#############################################################################
##
#P  RespectsOne( <mapp> )
##
##  Let <mapp> be a general mapping with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsOne' returns `true' if
##  $S$ and $R$ are magmas-with-one such that
##  $( `One('S'), One('R')' ) \in F$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsOne' returns `true'
##  if and only if the equation
##  `One( S )^<mapp> = One( R )'
##  holds.
##
DeclareProperty( "RespectsOne", IsGeneralMapping );


#############################################################################
##
#P  RespectsInverses( <mapp> )
##
##  Let <mapp> be a general mapping with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsInverses' returns `true' if
##  $S$ and $R$ are magmas-with-inverses such that
##  $(s,r) \in F$ implies $(s^{-1},r^{-1}) \in F$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsInverses' returns `true'
##  if and only if the equation
##  `Inverse( <s> )^<mapp> = Inverse( <s>^<mapp> )'
##  holds for all <s> in $S$.
##
DeclareProperty( "RespectsInverses", IsGeneralMapping );


#############################################################################
##
#M  RespectsOne( <mapp> )
##
InstallTrueMethod( RespectsOne,
    RespectsMultiplication and RespectsInverses );


#############################################################################
##
#P  IsGroupGeneralMapping( <mapp> )
#P  IsGroupHomomorphism( <mapp> )
##
##  A `GroupGeneralMapping' is a mapping which respects multiplication and
##  inverses. If it is total and single valued it is called a group
##  homomorphism.
##
DeclareSynonymAttr( "IsGroupGeneralMapping",
    IsGeneralMapping and RespectsMultiplication and RespectsInverses );

DeclareSynonymAttr( "IsGroupHomomorphism",
    IsGroupGeneralMapping and IsMapping );


#############################################################################
##
#A  KernelOfMultiplicativeGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping.
##  Then `KernelOfMultiplicativeGeneralMapping' returns the set of all
##  elements in the source of <mapp> that have the identity of the range in
##  their set of images.
##
##  (This is a monoid if <mapp> respects multiplication and one,
##  and if the source of <mapp> is associative.)
##
DeclareAttribute( "KernelOfMultiplicativeGeneralMapping",
    IsGeneralMapping );


#############################################################################
##
#A  CoKernelOfMultiplicativeGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping.
##  Then `CoKernelOfMultiplicativeGeneralMapping' returns the set of all
##  elements in the range of <mapp> that have the identity of the source in
##  their set of preimages.
##
##  (This is a monoid if <mapp> respects multiplication and one,
##  and if the range of <mapp> is associative.)
##
DeclareAttribute( "CoKernelOfMultiplicativeGeneralMapping",
    IsGeneralMapping );


#############################################################################
##
##  2. properties and attributes of gen. mappings that respect addition
##

#############################################################################
##
#P  RespectsAddition( <mapp> )
##
##  Let <mapp> be a general mapping with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsAddition' returns `true' if
##  $S$ and $R$ are additive magmas such that
##  $(s_1,r_1), (s_2,r_2) \in F$ implies $(s_1 + s_2,r_1 + r_2) \in F$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsAddition' returns `true'
##  if and only if the equation
##  `<s1>^<mapp> + <s2>^<mapp> = (<s1>+<s2>)^<mapp>'
##  holds for all <s1>, <s2> in $S$.
##
DeclareProperty( "RespectsAddition", IsGeneralMapping );


#############################################################################
##
#P  RespectsZero( <mapp> )
##
##  Let <mapp> be a general mapping with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsZero' returns `true' if
##  $S$ and $R$ are additive-magmas-with-zero such that
##  $( `Zero('S'), Zero('R')' ) \in F$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsZero' returns `true'
##  if and only if the equation
##  `Zero( S )^<mapp> = Zero( R )'
##  holds.
##
DeclareProperty( "RespectsZero", IsGeneralMapping );


#############################################################################
##
#P  RespectsAdditiveInverses( <mapp> )
##
##  Let <mapp> be a general mapping with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsAdditiveInverses' returns `true' if
##  $S$ and $R$ are additive-magmas-with-inverses such that
##  $(s,r) \in F$ implies $(-s,-r) \in F$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsAdditiveInverses' returns `true'
##  if and only if the equation
##  `AdditiveInverse( <s> )^<mapp> = AdditiveInverse( <s>^<mapp> )'
##  holds for all <s> in $S$.
##
DeclareProperty( "RespectsAdditiveInverses", IsGeneralMapping );


#############################################################################
##
#M  RespectsZero( <mapp> )
##
InstallTrueMethod( RespectsZero,
    RespectsAddition and RespectsAdditiveInverses );


#############################################################################
##
#P  IsAdditiveGroupGeneralMapping( <mapp> )
#P  IsAdditiveGroupHomomorphism( <mapp> )
##
DeclareSynonymAttr( "IsAdditiveGroupGeneralMapping",
    IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses );

DeclareSynonymAttr( "IsAdditiveGroupHomomorphism",
    IsAdditiveGroupGeneralMapping and IsMapping );


#############################################################################
##
#A  KernelOfAdditiveGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping.
##  Then `KernelOfAdditiveGeneralMapping' returns the set of all
##  elements in the source of <mapp> that have the zero of the range in
##  their set of images.
##
DeclareAttribute( "KernelOfAdditiveGeneralMapping", IsGeneralMapping );


#############################################################################
##
#A  CoKernelOfAdditiveGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping.
##  Then `CoKernelOfAdditiveGeneralMapping' returns the set of all
##  elements in the rqange of <mapp> that have the zero of the source in
##  their set of preimages.
##
DeclareAttribute( "CoKernelOfAdditiveGeneralMapping", IsGeneralMapping );


#############################################################################
##
##  3. properties and attributes of gen. mappings that respect scalar mult.
##

#############################################################################
##
#P  RespectsScalarMultiplication( <mapp> )
##
##  Let <mapp> be a general mapping, with underlying relation
##  $F \subseteq S \times R$,
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then `RespectsScalarMultiplication' returns `true' if
##  $S$ and $R$ are left modules with the left acting domain $D$ of $S$
##  contained in the left acting domain of $R$ and such that
##  $(s,r) \in F$ implies $(c \* s,c \* r) \in F$ for all $c \in D$,
##  and `false' otherwise.
##
##  If <mapp> is single-valued then `RespectsScalarMultiplication' returns
##  `true' if and only if the equation
##  `<c> \* <s>^<mapp> = (<c> \* <s>)^<mapp>'
##  holds for all <c> in $D$ and <s> in $S$.
##
DeclareProperty( "RespectsScalarMultiplication", IsGeneralMapping );

InstallTrueMethod( RespectsAdditiveInverses, RespectsScalarMultiplication );


#############################################################################
##
#P  IsLeftModuleGeneralMapping( <mapp> )
#P  IsLeftModuleHomomorphism( <mapp> )
##
DeclareSynonymAttr( "IsLeftModuleGeneralMapping",
    IsAdditiveGroupGeneralMapping and RespectsScalarMultiplication );

DeclareSynonymAttr( "IsLeftModuleHomomorphism",
    IsLeftModuleGeneralMapping and IsMapping );


#############################################################################
##
#O  IsLinearMapping( <F>, <mapp> )
##
##  is `true' if <mapp> is an <F>-linear general mapping,
##  and `false' otherwise.
##
DeclareOperation( "IsLinearMapping", [ IsDomain, IsGeneralMapping ] );


#############################################################################
##
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##

#############################################################################
##
#P  IsRingGeneralMapping( <mapp> )
#P  IsRingHomomorphism( <mapp> )
##
DeclareSynonymAttr( "IsRingGeneralMapping",
    IsGeneralMapping and RespectsMultiplication
    and IsAdditiveGroupGeneralMapping );

DeclareSynonymAttr( "IsRingHomomorphism",
    IsRingGeneralMapping and IsMapping );


#############################################################################
##
#P  IsRingWithOneGeneralMapping( <mapp> )
#P  IsRingWithOneHomomorphism( <mapp> )
##
DeclareSynonymAttr( "IsRingWithOneGeneralMapping",
    IsRingGeneralMapping and RespectsOne );

DeclareSynonymAttr( "IsRingWithOneHomomorphism",
    IsRingWithOneGeneralMapping and IsMapping );


#############################################################################
##
#P  IsAlgebraGeneralMapping( <mapp> )
#P  IsAlgebraHomomorphism( <mapp> )
##
DeclareSynonymAttr( "IsAlgebraGeneralMapping",
    IsRingGeneralMapping and IsLeftModuleGeneralMapping );

DeclareSynonymAttr( "IsAlgebraHomomorphism",
    IsAlgebraGeneralMapping and IsMapping );


#############################################################################
##
#P  IsAlgebraWithOneGeneralMapping( <mapp> )
#P  IsAlgebraWithOneHomomorphism( <mapp> )
##
DeclareSynonymAttr( "IsAlgebraWithOneGeneralMapping",
    IsAlgebraGeneralMapping and RespectsOne );

DeclareSynonymAttr( "IsAlgebraWithOneHomomorphism",
    IsAlgebraWithOneGeneralMapping and IsMapping );


#############################################################################
##
#P  IsFieldHomomorphism( <mapp> )
##
##  A general mapping is a field homomorphism if and only if it is
##  a ring homomorphism with source a field.
##
DeclareProperty( "IsFieldHomomorphism", IsGeneralMapping );

InstallTrueMethod( IsAlgebraHomomorphism, IsFieldHomomorphism );


#############################################################################
##
#F  InstallEqMethodForMappingsFromGenerators( <IsStruct>,
#F                           <GeneratorsOfStruct>, <respects>, <infostring> )
##
InstallEqMethodForMappingsFromGenerators := function( IsStruct,
    GeneratorsOfStruct, respects, infostring )

    InstallMethod( \=,
        Concatenation( "method for two s.v. gen. mappings", infostring ),
        IsIdenticalObj,
        [ IsGeneralMapping and IsSingleValued and respects,
          IsGeneralMapping and IsSingleValued and respects ],
        0,
        function( map1, map2 )
        local gen;
        if   not IsStruct( Source( map1 ) ) then
          TryNextMethod();
        elif     HasIsInjective( map1 ) and HasIsInjective( map2 )
             and IsInjective( map1 ) <> IsInjective( map2 ) then
          return false;
        elif     HasIsSurjective( map1 ) and HasIsSurjective( map2 )
             and IsSurjective( map1 ) <> IsSurjective( map2 ) then
          return false;
        elif     HasIsTotal( map1 ) and HasIsTotal( map2 )
             and IsTotal( map1 ) <> IsTotal( map2 ) then
          return false;
        elif    Source( map1 ) <> Source( map2 )
             or Range ( map1 ) <> Range ( map2 ) then
          return false;
        fi;

        for gen in GeneratorsOfStruct( PreImagesRange( map1 ) ) do
          if    ImagesRepresentative( map1, gen )
             <> ImagesRepresentative( map2, gen ) then
            return false;
          fi;
        od;
        return true;
        end );
end;


#############################################################################
##
#E

