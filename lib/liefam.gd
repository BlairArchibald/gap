#############################################################################
##
#W  liefam.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the definition of the family of Lie elements of a
##  family of ring elements.

#1
##  Given a family $F$ of ring elements, we can form its Lie family $L$.
##  The elements of $F$ and $L$ are in bijection, only the multiplications
##  via `\*' differ for both families.
##  More exactly, if $l_1$ and $l_2$ are the Lie elements corresponding to
##  the elements $f_1$ and $f_2$ in $F$, we have $l_1 * l_2$ equal to the
##  Lie element corresponding to $f_1 * f_2 - f_2 * f_2$.
##
##  The main reason to distinguish elements and Lie elements on the family
##  level is that this helps to avoid forming domains that contain
##  elements of both types.
##  For example, if we could form vector spaces of matrices then at first
##  glance it would be no problem to have both ordinary and Lie matrices
##  in it, but as soon as we find out that the space is in fact an algebra
##  (e.g., because its dimension is that of the full matrix algebra),
##  we would run into strange problems.
##
##  Note that the family situation with Lie families may be not familiar.
##
##  \beginlist
##  \item{-}
##    An element is *not* equal to its Lie element.
##
##  \item{-}
##    If we take the Lie object of an ordinary (associative) matrix
##    then this is again a matrix;
##    it is therefore a collection (of its rows) and a list.
##    But it is *not* a collection of collections of its entries,
##    and its family is *not* a collections family.
##
##  \item{-}
##    We have to be careful when installing methods for certain types
##    of domains that may involve Lie elements.
##    For example, the zero element of a matrix space is either an ordinary
##    matrix or its Lie element, depending on the space.
##    So either the method must be aware of both cases, or the method
##    selection must distinguish the two cases.
##    In the latter situation, only one method may be applicable to each
##    case; this means that it is not sufficient to treat the Lie case
##    with the additional requirement `IsLieObjectCollection' but that
##    we must explicitly require non-Lie elements for the non-Lie case.
##
##  \item{-}
##    Being a full matrix space is a property that may hold for a space
##    of ordinary matrices or a space of Lie matrices.
##    So methods for full matrix spaces must also be aware of Lie matrices.
##  \endlist
##
Revision.liefam_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsLieObject( <obj> )
#C  IsLieObjectCollection( <obj> )
##
##  An object lies in `IsLieObject' if and only if it lies in a family
##  constructed by `LieFamily'.
##
DeclareCategory( "IsLieObject",
        IsRingElement
    and IsZeroSquaredElement
    and IsJacobianElement );

DeclareCategoryCollections( "IsLieObject" );


#############################################################################
##
#A  LieFamily( <Fam> )
##
##  is a family $F$ in bijection with the family <Fam>,
##  but with the Lie bracket as infix multiplication.
##  That is, for $x$, $y$ in <Fam>, the product of the images in $F$ will be
##  the image of $x \* y - y \* x$.
##
##  The standard type of objects in a Lie family <F> is `<F>!.packedType'.
##
##  The bijection from <Fam> to $F$ is given by `Embedding( <Fam>, $F$ )';
##  this bijection respects addition and additive inverses.
##
DeclareAttribute( "LieFamily", IsFamily );


#############################################################################
##
#A  UnderlyingFamily( <Fam> )
##
##  If <Fam> is a Lie family then `UnderlyingFamily( <Fam> )'
##  is a family $F$ such that `<Fam> = LieFamily( $F$ )'.
##
DeclareAttribute( "UnderlyingFamily", IsObject );


#############################################################################
##
#A  LieObject( <obj> )
##
##  Let <obj> be a ring element in the family $F$.
##  Then `LieObject( <obj> )' is the corresponding object in the family
##  `LieFamily( $F$ )', see~"LieFamily".
##
DeclareAttribute( "LieObject", IsRingElement );


#############################################################################
##
#E

