#############################################################################
##
#W  pcgspcg.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations  for polycylic generating systems of pc
##  groups.
##
Revision.pcgspcg_gd :=
    "@(#)$Id$";

#############################################################################
##
#P  IsFamilyPcgs( <pcgs> )
##
DeclareProperty( "IsFamilyPcgs", IsPcgs,
  30 #familyPcgs is stronger than prime orders and some other properties
     # (cf. rank for `IsParentPcgsFamilyPcgs' in pcgsind.gd)
  );
InstallTrueMethod(IsCanonicalPcgs,IsFamilyPcgs);
InstallTrueMethod(IsParentPcgsFamilyPcgs,IsFamilyPcgs);

#############################################################################
##
#E  pcgspcg.gd	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
