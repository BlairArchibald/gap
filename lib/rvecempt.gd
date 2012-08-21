#############################################################################
##
#W  rvecempt.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation of immutable empty row vectors.
##  An empty row vector is an immutable empty list whose family is
##  a collections family.
##  Empty row vectors are different if their families are different,
##  especially the ordinary empty list `[]' is different from every empty
##  row vector.
##
##  The first case where empty row vectors turned out to be necessary was
##  in the representation of elements of a zero dimensional s.c. algebra.
##
Revision.rvecempt_gd :=
    "@(#)$Id$";


#############################################################################
##
#A  EmptyRowVector( <F> )
##
##  is an empty row vector whose family is the collections family of <F>.
##
DeclareAttribute( "EmptyRowVector", IsFamily );


#############################################################################
##
#E

