#############################################################################
##
#W  ghomperm.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.ghomperm_gd :=
    "@(#)$Id$";


#############################################################################
##
#R  IsPermGroupGeneralMappingByImages(<map>)
#R  IsPermGroupHomomorphismByImages(<map>)
##
##  is the representation for mappings that map from a perm group
DeclareRepresentation( "IsPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
DeclareSynonym( "IsPermGroupHomomorphismByImages",
    IsPermGroupGeneralMappingByImages and IsMapping );

#############################################################################
##
#R  IsToPermGroupGeneralMappingByImages(<map>)
#R  IsToPermGroupHomomorphismByImages(<map>)
##
##  is the representation for mappings that map to a perm group
DeclareRepresentation( "IsToPermGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
DeclareSynonym( "IsToPermGroupHomomorphismByImages",
    IsToPermGroupGeneralMappingByImages and IsMapping );

DeclareGlobalFunction( "AddGeneratorsGenimagesExtendSchreierTree" );
DeclareGlobalFunction( "ImageSiftedBaseImage" );
DeclareGlobalFunction( "CoKernelGensIterator" );
DeclareGlobalFunction( "CoKernelGensPermHom" );
DeclareGlobalFunction( "StabChainPermGroupToPermGroupGeneralMappingByImages" );
DeclareGlobalFunction( "MakeStabChainLong" );
DeclareGlobalFunction( "ImageKernelBlocksHomomorphism" );
DeclareGlobalFunction( "PreImageSetStabBlocksHomomorphism" );


#############################################################################
##
#E

