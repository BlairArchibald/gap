#############################################################################
##
#W  ctblpope.tst               GAP Library                      Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  The examples in this file show some typical examples how to compute
##  permutation characters, mainly by using the {\ATLAS} information together
##  with the {\GAP} implementation of the algorithms to compute
##  possible permutation characters that are described in~\cite{BP98}.
##
#T missing:
#T more examples for the combin. and ineq. algorithm,
#T the use of tables of marks,
#T and the example concerning the character of Ly mentioned in [BP98].
#T also the examples in ~/Saxl/M12.2, ~/Saxl/Suz !!

gap> START_TEST("$Id$");


#############################################################################
#
# Example 1. (all possible permutation characters of $M_{11}$)
# 
# We compute all possible permutation characters of the Mathieu group
# $M_{11}$, using the three different strategies available in {\GAP}.
# First we try the algorithm that enumerates all candidates via solving
# a system of inequalities, which is described in Section~3.2 of~\cite{BP98}.

gap> m11:= CharacterTable( "M11" );;
gap> SetName( m11, "m11" );
gap> perms:= PermChars( m11 );
[ Character( m11, [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ), 
  Character( m11, [ 11, 3, 2, 3, 1, 0, 1, 1, 0, 0 ] ), 
  Character( m11, [ 12, 4, 3, 0, 2, 1, 0, 0, 1, 1 ] ), 
  Character( m11, [ 22, 6, 4, 2, 2, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 55, 7, 1, 3, 0, 1, 1, 1, 0, 0 ] ), 
  Character( m11, [ 66, 10, 3, 2, 1, 1, 0, 0, 0, 0 ] ), 
  Character( m11, [ 110, 6, 2, 2, 0, 0, 2, 2, 0, 0 ] ), 
  Character( m11, [ 110, 6, 2, 6, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 110, 14, 2, 2, 0, 2, 0, 0, 0, 0 ] ), 
  Character( m11, [ 132, 12, 6, 0, 2, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 144, 0, 0, 0, 4, 0, 0, 0, 1, 1 ] ), 
  Character( m11, [ 165, 13, 3, 1, 0, 1, 1, 1, 0, 0 ] ), 
  Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ), 
  Character( m11, [ 220, 12, 4, 4, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ), 
  Character( m11, [ 330, 2, 6, 2, 0, 2, 0, 0, 0, 0 ] ), 
  Character( m11, [ 330, 18, 6, 2, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 396, 12, 0, 4, 1, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 440, 8, 8, 0, 0, 2, 0, 0, 0, 0 ] ), 
  Character( m11, [ 440, 24, 8, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 495, 15, 0, 3, 0, 0, 1, 1, 0, 0 ] ), 
  Character( m11, [ 660, 4, 3, 4, 0, 1, 0, 0, 0, 0 ] ), 
  Character( m11, [ 660, 12, 3, 0, 0, 3, 0, 0, 0, 0 ] ), 
  Character( m11, [ 660, 12, 12, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 660, 28, 3, 0, 0, 1, 0, 0, 0, 0 ] ), 
  Character( m11, [ 720, 0, 0, 0, 0, 0, 0, 0, 5, 5 ] ), 
  Character( m11, [ 792, 24, 0, 0, 2, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 880, 0, 16, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 990, 6, 0, 2, 0, 0, 2, 2, 0, 0 ] ), 
  Character( m11, [ 990, 6, 0, 6, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 990, 30, 0, 2, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 1320, 8, 6, 0, 0, 2, 0, 0, 0, 0 ] ), 
  Character( m11, [ 1320, 24, 6, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 1584, 0, 0, 0, 4, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 1980, 12, 0, 4, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 1980, 36, 0, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 2640, 0, 12, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 3960, 24, 0, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( m11, [ 7920, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]

# This algorithm admits a second search strategy, which uses the inequalities
# for a sort of previewing.
#T But this does not work correctly,
#T already the GAP 3 version did not do what was promised.
#T (Apparently, the additional options were used rarely.)

# Next we try the improved combinatorial approach that is sketched at the
# end of Section~3.2 in~\cite{BP98}.

gap> degrees:= DivisorsInt( Size( m11 ) );;
gap> perms2:= [];;      
gap> for d in degrees do 
>      Append( perms2, PermChars( m11, d ) ); 
>    od;
gap> Set( perms ) = Set( perms2 );
true

# Finally, we try the algorithm that is based on Gaussian elimination
# and that is described in Section~3.3 of~\cite{BP98}.
gap> perms3:= [];;                                                 
gap> for d in degrees do
>      Append( perms3, PermChars( m11, rec( torso:= [ d ] ) ) );
>    od;
gap> Set( perms ) = Set( perms3 );
true


#############################################################################
#
# Example 2. (explicit induction in the case of known character tables)
# 
# We are interested in the permutation character of $U_6(2)$
# that corresponds to the action on the cosets of a $M_{22}$ subgroup.
# The character tables of both the group and the point stabilizer
# are available in the {\GAP} character table library,
# so we can compute (class fusion and) permutation character directly;
# note that if the class fusion is not stored on the table of the subgroup,
# in general one will not get a unique fusion but only a list of candidates
# for the fusion.

gap> u62:= CharacterTable( "U6(2)" );;
gap> m22:= CharacterTable( "M22" );;
gap> fus:= PossibleClassFusions( m22, u62 );
[ [ 1, 3, 7, 10, 14, 15, 22, 24, 24, 26, 33, 34 ], 
  [ 1, 3, 7, 10, 14, 15, 22, 24, 24, 26, 34, 33 ], 
  [ 1, 3, 7, 11, 14, 15, 22, 24, 24, 27, 33, 34 ], 
  [ 1, 3, 7, 11, 14, 15, 22, 24, 24, 27, 34, 33 ], 
  [ 1, 3, 7, 12, 14, 15, 22, 24, 24, 28, 33, 34 ], 
  [ 1, 3, 7, 12, 14, 15, 22, 24, 24, 28, 34, 33 ] ]
gap> cand:= Set( List( fus, x -> Induced( m22, u62,
>                                    [ TrivialCharacter( m22 ) ], x )[1] ) );
[ Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 0, 48, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 4, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( u62, cand ).ATLAS;
[ "1a+22a+252a+616a+1155c+1386a+8064a+9240c", 
  "1a+22a+252a+616a+1155b+1386a+8064a+9240b", 
  "1a+22a+252a+616a+1155a+1386a+8064a+9240a" ]

# We see that there are six possible class fusions that induce three
# different permutation characters.
# They belong to the three classes of maximal subgroups of type $M_{22}$
# in $U_6(2)$, which are permuted by an outer automorphism of order 3.

# Now we want to compute the extension of the above permutation character
# to the group $U_6(2).2$,
# which corresponds to the action of this group on the cosets of a $M_{22}.2$
# subgroup.

gap> u622:= CharacterTable( "U6(2).2" );;
gap> m222:= CharacterTable( "M22.2" );;
gap> GetFusionMap( m222, u622 );
fail
gap> fus:= PossibleClassFusions( m222, u622 );
[ [ 1, 3, 7, 10, 13, 14, 20, 22, 22, 24, 29, 38, 39, 42, 41, 46, 50, 53, 58, 
      59, 59 ] ]
gap> cand:= Induced( m222, u622, [ TrivialCharacter( m222 ) ], fus[1] );
[ Character( CharacterTable( "U6(2).2" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0,
      0, 0, 0, 0, 0, 1080, 72, 0, 48, 8, 0, 0, 0, 18, 0, 0, 0, 8, 0, 0, 2, 0,
      0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( u622, cand ).ATLAS;
[ "1a+22a+252a+616a+1155a+1386a+8064a+9240a" ]

# We see that for the embedding of $M_{22}.2$ into $U_6(2).2$,
# the class fusion is unique,
# so we get a unique extension of one of the above permutation characters.
# (Exactly one class of maximal subgroups of type $M_{22}$ extends to
# $M_{22}.2$ in a given group $U_6(2).2$.)


#############################################################################
#
# Example 3.
# 
# Alternatively, or if only the character table of the supergroup is
# available, one can compute all those characters that have certain
# properties of permutation characters.
# (Of course this may take much longer than the above computations,
# which needed only a few seconds.)
# First let us look at the same problem as in Example 2 above.
# (These calculations may need several hours,
# depending on the computer used.)

gap> cand:= PermChars( u62, rec( torso := [ 20736 ] ) );
[ Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 0, 48, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 4, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]

# For the computation of the extension of the permutation character
# to $U_6(2).2$, we may use the above information,
# since the values on the inner classes are prescribed.
# (The question which of the three candidates for $U_6(2)$ extends to
# $U_6(2).2$ depends on the choice of the class fusion of $U_6(2)$ into
# $U_6(2).2$; with respect to the class fusion that is stored,
# the third candidate extends.)
   
gap> u622:= CharacterTable( "U6(2).2" );;
gap> inv:= InverseMap( GetFusionMap( u62, u622 ) );
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, [ 11, 12 ], 13, 14, 15, [ 16, 17 ], 18, 19, 
  20, 21, 22, 23, 24, 25, 26, [ 27, 28 ], [ 29, 30 ], 31, 32, [ 33, 34 ], 
  [ 35, 36 ], 37, [ 38, 39 ], 40, [ 41, 42 ], 43, 44, [ 45, 46 ] ]
gap> ext:= List( cand, x -> CompositionMaps( x, inv ) );
[ [ 20736, 0, 384, 0, 0, 0, 54, 0, 0, 0, [ 0, 48 ], 0, 16, 6, 0, 0, 0, 0, 0, 
      6, 0, 2, 0, 0, [ 0, 4 ], 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 20736, 0, 384, 0, 0, 0, 54, 0, 0, 0, [ 0, 48 ], 0, 16, 6, 0, 0, 0, 0, 0, 
      6, 0, 2, 0, 0, [ 0, 4 ], 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 20736, 0, 384, 0, 0, 0, 54, 0, 0, 48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 6, 0, 
      2, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> cand:= PermChars( u622, rec( torso:= ext[3] ) );
[ Character( CharacterTable( "U6(2).2" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0,
      0, 0, 0, 0, 0, 1080, 72, 0, 48, 8, 0, 0, 0, 18, 0, 0, 0, 8, 0, 0, 2, 0,
      0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0 ] ) ]


#############################################################################
#
# Example 4.
# 
# The group $O_8^+(3)$ contains a subgroup of type $2^{3+6}.L_3(2)$,
# which extends to a maximal subgroup in $O_8^+(3).3$.
# For the computation of the permutation character,
# we have to take the second approach since the table of the subgroup
# is not available in the {\GAP} table library.
# Since the $2^{3+6}.L_3(2)$ group is contained in a $O_8^+(2)$ subgroup
# of $O_8^+(3)$, we can try to find the permutation character in $O_8^+(2)$
# and then induce this character to $O_8^+(3)$.
# (In general the problem becomes more difficult with increasing degree.)
# In fact, the $2^{3+6}.L_3(2)$ group is contained in a $2^6:A_8$ subgroup
# of $O_8^+(2)$, in which the index is only $15$ and the unique
# possible permutation character of this degree can be read off immediately.
# Induction to $O_8^+(3)$ through the chain of subgroups is possible
# provided the class fusions are available.
# (There are $24$ possible fusions from $O_8^+(2)$ into $O_8^+(3)$,
# which are all equivalent w.r.t.~table automorphisms of $O_8^+(3)$.
# If we later want to consider the extension of the permutation character
# in question to $O_8^+(3).3$ then we have to choose a fusion of an
# $O_8^+(2)$ subgroup that does {\em not} extend to $O_8^+(2).3$.
# But if for example our question is just whether the resulting permutation
# character is multiplicity-free then this can be decided already from the
# permutation character of $O_8^+(3)$.)

gap> o8p3:= CharacterTable("O8+(3)");;
gap> Size( o8p3 ) / (2^9*168);
57572775
gap> o8p2:= CharacterTable( "O8+(2)" );;
gap> fus:= GetFusionMap( o8p2, o8p3 );
fail
gap> fus:= PossibleClassFusions( o8p2, o8p3 );;
gap> Length( fus );
24
gap> rep:= RepresentativesFusions( o8p2, fus, o8p3 );
[ [ 1, 5, 2, 3, 4, 5, 7, 8, 12, 16, 17, 19, 23, 20, 21, 22, 23, 24, 25, 26, 
      37, 38, 42, 31, 32, 36, 49, 52, 51, 50, 43, 44, 45, 53, 55, 56, 57, 71, 
      71, 71, 72, 73, 74, 78, 79, 83, 88, 89, 90, 94, 100, 101, 105 ] ]
gap> fus:= rep[1];;
gap> Size( o8p2 ) / (2^9*168);                                      
2025
gap> sub:= CharacterTable( "2^6:A8" );;
gap> subfus:= GetFusionMap( sub, o8p2 );
[ 1, 3, 2, 2, 4, 5, 6, 13, 3, 6, 12, 13, 14, 7, 21, 24, 11, 30, 29, 31, 13, 
  17, 15, 16, 14, 17, 36, 37, 18, 41, 24, 44, 48, 28, 33, 32, 34, 35, 35, 51, 
  51 ]
gap> fus:= CompositionMaps( fus, subfus );
[ 1, 2, 5, 5, 3, 4, 5, 23, 2, 5, 19, 23, 20, 7, 37, 31, 17, 50, 51, 43, 23, 
  23, 21, 22, 20, 23, 56, 57, 24, 72, 31, 78, 89, 52, 45, 44, 53, 55, 55, 
  100, 100 ]
gap> Size( sub ) / (2^9*168); 
15
gap> List( Irr( sub ), Degree );
[ 1, 7, 14, 20, 21, 21, 21, 28, 35, 45, 45, 56, 64, 70, 28, 28, 35, 35, 35, 
  35, 70, 70, 70, 70, 140, 140, 140, 140, 140, 210, 210, 252, 252, 280, 280, 
  315, 315, 315, 315, 420, 448 ]
gap> cand:= PermChars( sub, 15 );
[ Character( CharacterTable( "2^6:A8" ), [ 15, 15, 15, 7, 7, 7, 7, 7, 3, 3, 
      3, 3, 3, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 
      1, 1, 1, 1, 1, 0, 0 ] ) ]
gap> ind:= Induced( sub, o8p3, cand, fus );
[ Character( CharacterTable( "O8+(3)" ), [ 57572775, 59535, 59535, 59535, 
      3591, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2187, 0, 27, 135, 135, 135, 243, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 27, 0, 
      0, 0, 0, 27, 27, 27, 27, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> o8p33:= CharacterTable( "O8+(3).3" );;
gap> inv:= InverseMap( GetFusionMap( o8p3, o8p33 ) );
[ 1, [ 2, 3, 4 ], 5, 6, [ 7, 8, 9 ], [ 10, 11, 12 ], 13, [ 14, 15, 16 ], 17, 
  18, 19, [ 20, 21, 22 ], 23, [ 24, 25, 26 ], [ 27, 28, 29 ], 30, 
  [ 31, 32, 33 ], [ 34, 35, 36 ], [ 37, 38, 39 ], [ 40, 41, 42 ], 
  [ 43, 44, 45 ], 46, [ 47, 48, 49 ], 50, [ 51, 52, 53 ], 54, 55, 56, 57, 
  [ 58, 59, 60 ], [ 61, 62, 63 ], 64, [ 65, 66, 67 ], 68, [ 69, 70, 71 ], 
  [ 72, 73, 74 ], [ 75, 76, 77 ], [ 78, 79, 80 ], [ 81, 82, 83 ], 84, 85, 
  [ 86, 87, 88 ], [ 89, 90, 91 ], [ 92, 93, 94 ], 95, 96, [ 97, 98, 99 ], 
  [ 100, 101, 102 ], [ 103, 104, 105 ], [ 106, 107, 108 ], [ 109, 110, 111 ], 
  [ 112, 113, 114 ] ]
gap> ext:= CompositionMaps( ind[1], inv );
[ 57572775, 59535, 3591, 0, 0, 0, 0, 0, 2187, 0, 27, 135, 243, 0, 0, 0, 0, 0, 
  0, 0, 27, 0, 0, 27, 27, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> perms:= PermChars( o8p33, rec( torso:= ext ) );
[ Character( CharacterTable( "O8+(3).3" ), [ 57572775, 59535, 3591, 0, 0, 0, 
      0, 0, 2187, 0, 27, 135, 243, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 27, 27, 0, 
      8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 3159, 3159, 243, 243, 39, 39, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 
      3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 
     ] ) ]
gap> PermCharInfo( o8p33, perms ).ATLAS;                          
[ "1a+780aabb+2457a+2808abc+9450aaabbcc+18200abcdddef+24192a+54600a^{5}b+70200\
aabb+87360ab+139776a^{5}+147420a^{4}b^{4}+163800ab+184275aabc+199017aa+218700a\
+245700a+291200aef+332800a^{4}b^{5}c^{5}+491400aaabcd+531441a^{5}b^{4}c^{4}+55\
2825a^{4}+568620aabb+698880a^{4}b^{4}+716800aaabbccdddeeff+786240aabb+873600aa\
+998400aa+1257984a^{6}+1397760aa" ]

# Remark.
# Alternatively, if the table of marks of the group is available
# then one can extract the permutation characters from it.
# The table of marks of $O_8^+(2)$ is in fact available,
# but it requires some time to read the data into {\GAP},
# since the file is about $25$ MB large.


#############################################################################
#
# Example 5.
#
# We want to know whether the permutation character of $O_7(3).2$ on the
# cosets of its maximal subgroup of type $2^7.S_7$ is multiplicity-free.
# As usual, we first compute the permutation character of the simple group.
# It turns out that the computation from the degree is too time consuming.
# But we can use for example the additional information provided by the fact
# that the subgroup contains an $A_7$ subgroup.
# We compute the possible class fusions.

gap> o73:= CharacterTable( "O7(3)" );;
gap> a7:= CharacterTable( "A7" );;
gap> fus:= PossibleClassFusions( a7, o73 );
[ [ 1, 3, 6, 10, 15, 16, 24, 33, 33 ], [ 1, 3, 7, 10, 15, 16, 22, 33, 33 ] ]

# We cannot decide easily which fusion is the right one,
# but already the fact that no other fusions are possible
# gives us some information about impossible constituents of the
# permutation character we want to compute.

gap> ind:= List( fus, x -> Induced( a7, o73,
>                              [ TrivialCharacter( a7 ) ], x )[1] );;
gap> mat:= MatScalarProducts( o73, Irr( o73 ), ind );;
gap> sum:= Sum( mat );
[ 2, 6, 2, 0, 8, 6, 2, 4, 4, 8, 3, 0, 4, 4, 9, 3, 5, 0, 0, 9, 0, 10, 5, 6,
  15, 1, 12, 1, 15, 7, 2, 4, 14, 16, 0, 12, 12, 7, 8, 8, 14, 12, 12, 14, 6,
  6, 20, 16, 12, 12, 12, 10, 10, 12, 12, 8, 12, 6 ]
gap> const:= Filtered( [ 1 .. Length( sum ) ], x -> sum[x] <> 0 );
[ 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 20, 22, 23, 24, 25, 26,
  27, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46,
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58 ]
gap> Length( const );
52
gap> const:= Irr( o73 ){ const };;
gap> rat:= RationalizedMat( const );;

# But much more restrictions can be deduced from the fact that certain
# zeros of the permutation character can be predicted.

gap> names:= ClassNames( o73 );
[ "1a", "2a", "2b", "2c", "3a", "3b", "3c", "3d", "3e", "3f", "3g", "4a",
  "4b", "4c", "4d", "5a", "6a", "6b", "6c", "6d", "6e", "6f", "6g", "6h",
  "6i", "6j", "6k", "6l", "6m", "6n", "6o", "6p", "7a", "8a", "8b", "9a",
  "9b", "9c", "9d", "10a", "10b", "12a", "12b", "12c", "12d", "12e", "12f",
  "12g", "12h", "13a", "13b", "14a", "15a", "18a", "18b", "18c", "18d", "20a"
 ]
gap> List( fus, x -> names{ x } );
[ [ "1a", "2b", "3b", "3f", "4d", "5a", "6h", "7a", "7a" ], 
  [ "1a", "2b", "3c", "3f", "4d", "5a", "6f", "7a", "7a" ] ]
gap> torso:= [ 28431 ];;
gap> zeros:= [ 5, 8, 9, 11, 17, 20, 23, 28, 29, 32, 36, 37, 38,
>              43, 46, 47, 48, 53, 54, 55, 56, 57, 58 ];;
gap> for i in zeros do
>      Print( names[i], " " );
>    od; Print( "\n" );
3a 3d 3e 3g 6a 6d 6g 6l 6m 6p 9a 9b 9c 12b 12e 12f 12g 15a 18a 18b 18c 18d 20a\

# Every order 3 element lies in an $A_7$ subgroup,
# so at most the classes `3B', `3C', and `3F' can have nonzero permutation
# character values.
# The excluded classes of element order 6 are the squere roots of the
# excluded order 3 elements, likewise the given classes of element orders 9,
# 12, and 18 are excluded.
# The character value on `20A' must be zero because the subgroup does not
# contain elements of this order.
# So we enter the additional information about these zeros.

gap> for  i in zeros do
>      torso[i]:= 0;
>    od;
gap> torso;
[ 28431,,,, 0,,, 0, 0,, 0,,,,,, 0,,, 0,,, 0,,,,, 0, 0,,, 0,,,, 0, 0, 0,,,,, 0,
  ,, 0, 0, 0,,,,, 0, 0, 0, 0, 0, 0 ]
gap> perms:= PermChars( o73, rec( torso:= torso, chars:= rat ) );
[ Character( CharacterTable( "O7(3)" ), [ 28431, 567, 567, 111, 0, 0, 243, 0,
      0, 81, 0, 15, 3, 27, 15, 6, 0, 0, 27, 0, 3, 27, 0, 0, 0, 3, 9, 0, 0, 3,
      3, 0, 4, 1, 1, 0, 0, 0, 0, 2, 2, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0 ] ) ]
gap> PermCharInfo( o73, perms ).ATLAS;
[ "1a+78a+168a+182a+260ab+1092a+2457a+2730a+4095b+5460a+11648a" ]

# This character is already multiplicity free, so must be the extension
# to $O_7(3).2$, which also could be computed in the same way as in the
# examples above.


#############################################################################
#
# Example 6.
# 
# We are interested in the permutation character of $O_8^+(3).2_1$
# that corresponds to the action on the cosets of a subgroup of type
# $2^7.A_8$.
# The intersection of the point stabilizer with the simple group $O_8^+(3)$
# is of type $2^6.A_8$,
# first we compute the class fusion of these groups,
# modulo problems with ambiguities due to table automorphisms.

gap> o8p3:= CharacterTable( "O8+(3)" );;
gap> o8p2:= CharacterTable( "O8+(2)" );;
gap> GetFusionMap( o8p2, o8p3 );
fail
gap> fus:= PossibleClassFusions( o8p2, o8p3 );;
gap> NamesOfFusionSources( o8p2 );
[ "2^8:O8+(2)", "2^6:A8", "2.O8+(2)", "S6(2)" ]
gap> sub:= CharacterTable( "2^6:A8" );;
gap> subfus:= GetFusionMap( sub, o8p2 );
[ 1, 3, 2, 2, 4, 5, 6, 13, 3, 6, 12, 13, 14, 7, 21, 24, 11, 30, 29, 31, 13,
  17, 15, 16, 14, 17, 36, 37, 18, 41, 24, 44, 48, 28, 33, 32, 34, 35, 35, 51,
  51 ]
gap> fus:= List( fus, x -> CompositionMaps( x, subfus ) );;
gap> fus:= Set( fus );;
gap> Length( fus );
24

# The ambiguities due to Galois automorphisms disappear when we are
# looking for the permutation characters induced by the fusions.

gap> ind:= List( fus, x -> Induced( sub, o8p3,
>                              [ TrivialCharacter( sub ) ], x )[1] );;
gap> ind:= Set( ind );;
gap> Length( ind );
6

# Now we try to extend the candidates to $O_8^+(3).2_1$;
# the choice of the fusion of $O_8^+(3)$ into $O_8^+(3).2_1$ determines
# which of the candidates (may) extend.

gap> o8p32:= CharacterTable( "O8+(3).2_1" );;
gap> fus:= GetFusionMap( o8p3, o8p32 );;
gap> ext:= List( ind, x -> CompositionMaps( x, InverseMap( fus ) ) );;
gap> ext:= Filtered( ext, x -> ForAll( x, IsInt ) );
[ [ 3838185, 17577, 8505, 8505, 873, 0, 0, 0, 0, 6561, 0, 0, 729, 0, 9, 105,
      45, 45, 105, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 189, 0, 0, 0, 9, 9, 27, 27,
      0, 0, 27, 9, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,
      0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0,
      0, 0 ], [ 3838185, 17577, 8505, 8505, 873, 0, 6561, 0, 0, 0, 0, 0, 729,
      0, 9, 105, 45, 45, 105, 30, 0, 0, 0, 0, 0, 0, 189, 0, 0, 0, 9, 0, 0, 0,
      9, 27, 27, 0, 0, 9, 27, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0,
      0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0 ] ]

# We compute the extensions of the first one;
# the other belongs to another class of subgroups, which is the image under
# an outer automorphism.
# (These calculations may need about one hour,
# depending on the computer used.)

gap> perms:= PermChars( o8p32, rec( torso:= ext[1] ) );
[ Character( CharacterTable( "O8+(3).2_1" ),
    [ 3838185, 17577, 8505, 8505, 873, 0, 0, 0, 0, 6561, 0, 0, 729, 0, 9,
      105, 45, 45, 105, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 189, 0, 0, 0, 9, 9,
      27, 27, 0, 0, 27, 9, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
      0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0,
      0, 0, 0, 0, 3159, 1575, 567, 63, 87, 15, 0, 0, 45, 0, 81, 9, 27, 0, 0,
      3, 3, 3, 3, 5, 5, 0, 0, 0, 4, 0, 0, 27, 0, 9, 0, 0, 15, 0, 3, 0, 0, 2,
      0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( o8p32, perms ).ATLAS;
[ "1a+260abc+520ab+819a+2808b+9450aab+18200a+23400ac+29120b+36400aab+46592abce\
+49140d+66339a+98280ab+163800a+189540d+232960d+332800ab+368550a+419328a+531441\
ab" ]

# Now we may repeat the calculations for $O_8^+(3).2_2$ instead of
# $O_8^+(3).2_1$.

gap> o8p32:= CharacterTable( "O8+(3).2_2" );;
gap> fus:= GetFusionMap( o8p3, o8p32 );;
gap> ext:= List( ind, x -> CompositionMaps( x, InverseMap( fus ) ) );;
gap> ext:= Filtered( ext, x -> ForAll( x, IsInt ) );;
gap> perms:= PermChars( o8p32, rec( torso:= ext[1] ) );
[ Character( CharacterTable( "O8+(3).2_2" ), [ 3838185, 17577, 8505, 873, 0,
      0, 0, 6561, 0, 0, 0, 0, 729, 0, 9, 105, 45, 105, 30, 0, 0, 0, 0, 0, 0,
      189, 0, 0, 0, 9, 0, 9, 27, 0, 0, 0, 27, 27, 9, 0, 8, 1, 1, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0,
      0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 199017, 2025, 297, 441, 73, 9, 0,
      1215, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 27, 27, 0, 1, 9, 12, 0, 0, 45, 0,
      0, 1, 0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0
     ] ) ]
gap> PermCharInfo( o8p32, perms ).ATLAS;
[ "1a+260aac+520ab+819a+2808a+9450aaa+18200accee+23400ac+29120a+36400a+46592aa\
+49140c+66339a+93184a+98280ab+163800a+184275ac+189540c+232960c+332800aa+419328\
a+531441aa" ]

# Remark:
# If we are now interested in the extension to $O_8^+(3).(2^2)_{122}$
# then the table library does not help, since this table is not (yet)
# contained in it.
# But the extension cannot be multiplicity free because of the multiplicity
# `9450aaa' in the character of $O_8^+(3).2_2$.


#############################################################################
#
# Example 7.
# 
# We want to know whether the permutation character corresponding to the
# action of $S_4(4).4$ on the cosets of its maximal subgroup of type
# $5^2:[2^5]$ is multiplicity free.
# 
# The known class fusions from subgroups are stored as value of the
# attribute `NamesOfFusionSources', and for groups that are not determined
# by their names this is the only safe way to find out whether the table
# of the subgroup is contained in the {\GAP} library and known to belong
# to this group.
# It might be that a table with such a name is contained in the
# library but belongs to another group,
# and it may be that the table of the group is contained in the library
# (with any name) but it is not known that the group is isomorphic to a
# subgroup of $S_4(4).4$.

gap> s444:= CharacterTable( "S4(4).4" );;
gap> NamesOfFusionSources( s444 );
[ "S4(4)", "S4(4).2" ]

# So we cannot simply fetch the table.
# As in the previous examples, we compute the possible permutation
# characters.

gap> perms:= PermChars( s444, rec( torso:= [ Size( s444 ) / ( 5^2*2^5 ) ] ) );
[ Character( CharacterTable( "S4(4).4" ), [ 4896, 384, 96, 0, 16, 32, 36, 16, 
      0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ), 
  Character( CharacterTable( "S4(4).4" ), [ 4896, 192, 32, 0, 0, 8, 6, 1, 0, 
      2, 0, 0, 36, 0, 12, 0, 0, 0, 1, 0, 6, 6, 2, 2, 0, 0, 0, 0, 1, 1 ] ), 
  Character( CharacterTable( "S4(4).4" ), [ 4896, 240, 64, 0, 8, 8, 36, 16, 
      0, 0, 0, 0, 0, 12, 8, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]

# So there are three candidates.
# None of them is multiplicity free,
# so we need not decide which of the candidates actually belongs
# to the group $5^2:[2^5]$ we have in mind.

gap> PermCharInfo( s444, perms ).ATLAS;
[ "1abcd+50abcd+153abcd+170a^{4}b^{4}+680aabb", 
  "1a+50ac+153a+170aab+256a+680abb+816a+1020a", 
  "1ac+50ac+68a+153abcd+170aabbb+204a+680abb+1020a" ]

# (If we would be interested which candidate is the right one,
# we could for example look at the intersection with $S_4(4)$,
# and hope for a contradiction to the fact that the group must lie
# in a $(A_5 \times A_5):2$ subgroup.)


#############################################################################
#
# Example 8.
# 
# We compute the permutation characters of the sporadic simple Conway group
# $G = Co_1$ corresponding to the actions on the cosets of involution
# centralizers
# (equivalently, the action on conjugacy classes of involutions).
# 
# These characters can be computed as follows.

# 1. Get the table of $G$.

gap> t:= CharacterTable( "Co1" );
CharacterTable( "Co1" )

# 2. The centralizer of a {\tt 2A} element is a maximal subgroup of $G$.
#    This group is also contained in the table library.
#    So we can compute the permutation character by explicit induction,
#    and the decomposition in irreducibles is computed with the command
#    `PermCharInfo'.

gap> s:= CharacterTable( Maxes( t )[5] );
CharacterTable( "2^(1+8)+.O8+(2)" )
gap> ind:= Induced( s, t, [ TrivialCharacter( s ) ] );;
gap> PermCharInfo( t, ind ).ATLAS;
[ "1a+299a+17250a+27300a+80730a+313950a+644644a+2816856a+5494125a+12432420a+24\
794000a" ]

# 3. The centralizer of a {\tt 2B} element is not maximal.
#    First we compute which maximal subgroup can contain it.
#    The character tables of all maximal subgroups of $G$ are contained
#    in {\GAP}'s table library,
#    so we may take these tables and look at the group orders.

gap> centorder:= SizesCentralizers( t )[3];;
gap> maxes:= List( Maxes( t ), CharacterTable );;
gap> cand:= Filtered( maxes, x -> Size( x ) mod centorder = 0 );
[ CharacterTable( "(A4xG2(4)):2" ) ]
gap> u:= cand[1];;
gap> index:= Size( u ) / centorder;
3

#    There is a unique class of maximal subgroups containing the centralizer
#    of a {\tt 2B} element, as a subgroup of index $3$.
#    We compute the unique permutation character of degree $3$ of this group,
#    and induce this character to $G$.
#
#    In fact `PermCandidates' computes all those characters that have
#    certain properties of permutation characters.
#    In our situation, this is sufficient.
#
#    For a very small degree, the algorithm that needs the `torso' component
#    of the options record is a good choice.
#    If one wants to use the combinatorial algorithm for a small degree and
#    a not very small number of conjugacy classes, one should suppress the
#    computation of bounds by setting the `bounds' component to `false'.

gap> subperm:= PermChars( u, rec( degree := index, bounds := false ) );
[ Character( CharacterTable( "(A4xG2(4)):2" ),
    [ 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3,
      3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ) ]
gap> subperm = PermChars( u, rec( torso := [ 3 ] ) );
true
gap> ind:= Induced( u, t, subperm );
[ Character( CharacterTable( "Co1" ), [ 2065694400, 181440, 119408, 38016,
      2779920, 0, 0, 378, 30240, 864, 0, 720, 316, 80, 2520, 30, 0, 6480,
      1508, 0, 0, 0, 0, 0, 38, 18, 105, 0, 600, 120, 56, 24, 0, 12, 0, 0, 0,
      120, 48, 18, 0, 0, 6, 0, 360, 144, 108, 0, 0, 10, 0, 0, 0, 0, 0, 4, 2,
      3, 9, 0, 0, 15, 3, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 12,
      8, 0, 6, 0, 0, 3, 0, 1, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0 ] ) ]
gap> PermCharInfo( t, ind ).ATLAS;
[ "1a+1771a+8855a+27300aa+313950a+345345a+644644aa+871884aaa+1771000a+2055625a\
+4100096a+7628985a+9669660a+12432420aa+21528000aa+23244375a+24174150aa+2479400\
0a+31574400aa+40370176a+60435375a+85250880aa+100725625a+106142400a+150732800a+\
184184000a+185912496a+207491625a+299710125a+302176875a" ]

# 3. We try the same for the centralizer of a 2C element.

gap> centorder:= SizesCentralizers( t )[4];;
gap> cand:= Filtered( maxes, x -> Size( x ) mod centorder = 0 );
[ CharacterTable( "Co2" ), CharacterTable( "2^11:M24" ) ]

#  The group order excludes all except two classes of maximal subgroups.
#  But the {\tt 2C} centralizer cannot lie in $Co_2$ because the involution
#  centralizers in $Co_2$ are too small.

gap> u:= cand[1];;
gap> GetFusionMap( u, t );
[ 1, 2, 2, 4, 7, 6, 9, 11, 11, 10, 11, 12, 14, 17, 16, 21, 23, 20, 22, 22,
  24, 28, 30, 33, 31, 32, 33, 33, 37, 42, 41, 43, 44, 48, 52, 49, 53, 55, 53,
  52, 54, 60, 60, 60, 64, 65, 65, 67, 66, 70, 73, 72, 78, 79, 84, 85, 87, 92,
  93, 93 ]
gap> centorder;
389283840
gap> SizesCentralizers( u )[4];
1474560

#  So we try the second candidate.

gap> u:= cand[2];
CharacterTable( "2^11:M24" )
gap> index:= Size( u ) / centorder;
1288
gap> subperm:= PermChars( u, rec( torso := [ index ] ) );
[ Character( CharacterTable( "2^11:M24" ), [ 1288, 1288, 1288, 56, 56, 56,
      56, 56, 56, 48, 48, 48, 48, 48, 10, 10, 10, 10, 7, 7, 8, 8, 8, 8, 8, 8,
      4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 3, 3, 3, 0,
      0, 0, 0, 2, 2, 2, 2, 3, 3, 3, 1, 1, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0 ] ) ]
gap> subperm = PermChars( u, rec( degree:= index, bounds := false ) );
true
gap> ind:= Induced( u, t, subperm );
[ Character( CharacterTable( "Co1" ), [ 10680579000, 1988280, 196560, 94744,
      0, 17010, 0, 945, 7560, 3432, 2280, 1728, 252, 308, 0, 225, 0, 0, 0,
      270, 0, 306, 0, 46, 45, 25, 0, 0, 120, 32, 12, 52, 36, 36, 0, 0, 0, 0,
      0, 45, 15, 0, 9, 3, 0, 0, 0, 0, 18, 0, 30, 0, 6, 18, 0, 3, 5, 0, 0, 0,
      0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 6, 0, 2,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( t, last ).ATLAS;
[ "1a+17250aa+27300a+80730aa+644644aaa+871884a+1821600a+2055625aaa+2816856a+54\
94125a^{4}+12432420aa+16347825aa+23244375a+24174150aa+24667500aa+24794000aaa+3\
1574400a+40370176a+55255200a+66602250a^{4}+83720000aa+85250880aaa+91547820aa+1\
06142400a+150732800a+184184000aaa+185912496aaa+185955000aaa+207491625aaa+21554\
7904aa+241741500aaa+247235625a+257857600aa+259008750a+280280000a+302176875a+32\
6956500a+387317700a+402902500a+464257024a+469945476b+502078500a+503513010a+504\
627200a+522161640a" ]


#############################################################################
#
# Example 9.
# 
# We compute the multiplicity free possible permutation characters of
# $G = G_2(3)$.
# For each divisor $d$ of $|G|$, we compute all those possible permutation
# characters of degree $d$ of $G$ for which each irreducible constituent
# occurs with multiplicity at most $1$;
# this is done by prescribing the `maxmult' component of the second argument
# of `PermChars' to be the list with $1$ at each position.

gap> t:= CharacterTable( "G2(3)" );
CharacterTable( "G2(3)" )
gap> t:= CharacterTable( "G2(3)" );;
gap> n:= Length( RationalizedMat( Irr( t ) ) );;
gap> perms:= [];;
gap> divs:= DivisorsInt( Size( t ) );;
gap> for d in divs do
>      Append( perms,
>              PermChars( t, rec( bounds  := false,
>                                 degree  := d,
>                                 maxmult := List( [1..n], i->1 ) ) ) );
>    od;
gap> Length( perms );
42
gap> List( perms, Degree );
[ 1, 351, 351, 364, 364, 378, 378, 546, 546, 546, 546, 546, 702, 702, 728, 
  728, 1092, 1092, 1092, 1092, 1092, 1092, 1092, 1092, 1456, 1456, 1638, 
  1638, 2184, 2184, 2457, 2457, 2457, 2457, 3159, 3276, 3276, 3276, 3276, 
  4368, 6552, 6552 ]


gap> STOP_TEST( "ctblpope.tst", 612923095 );


#############################################################################
##
#E
##

