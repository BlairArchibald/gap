#############################################################################
##
#W  cyclotom.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares operations for cyclotomics.
##
Revision.cyclotom_gd :=
    "@(#)$Id$";


#############################################################################
##
#M  IsIntegralRing( <R> ) . . . . . .  Every ring of cyclotomics is integral.
##
InstallTrueMethod( IsIntegralRing,
    IsCyclotomicCollection and IsRing and IsNonTrivial );


#############################################################################
##
#O  RoundCyc( <cyc> )
##
##  is a cyclotomic integer $z$ (see "IsIntegralCyclotomic") near to the
##  cyclotomic <cyc> in the sense that the $i$-th coefficient in the external
##  representation (see~"CoeffsCyc") of $z$ is `Int( c+1/2 )' where `c' is
##  the $i$-th coefficient in the external representation of <cyc>.
##  Expressed in terms of the Zumbroich basis (see~"Integral Bases for
##  Abelian Number Fields"), the coefficients of <cyc> w.r.t.~this basis are
##  rounded.
##
DeclareOperation( "RoundCyc" , [ IsCyclotomic ] );


#############################################################################
##
#F  CoeffsCyc( <cyc>, <N> )
##
##  Let <cyc> be a cyclotomic with conductor $n$.
##  If <N> is not a multiple of $n$ then `CoeffsCyc' returns `fail' because
##  <cyc> cannot be expressed in terms of <N>-th roots of unity.
##  Otherwise `CoeffsCyc' returns a list of length <N> with entry at position
##  $j$ equal to the coefficient of $e^{2 \pi i (j-1)/<N>}$ if this root
##  belongs to the <N>-th Zumbroich basis (see~"Integral Bases for Abelian
##  Number Fields"),
##  and equal to zero otherwise.
##  So we have                                        
##  `<cyc> = CoeffsCyc(<cyc>,<N>) * List( [1..<N>], j -> E(<N>)^(j-1) )'.
##
DeclareGlobalFunction( "CoeffsCyc" );


#############################################################################
##
#F  IsGaussInt( <x> ) . . . . . . . . test if an object is a Gaussian integer
##
##  `IsGaussInt' returns `true' if the  object <x> is  a Gaussian integer and
##  `false' otherwise.  Gaussian integers are of the form  `<a> + <b>\*E(4)',
##  where <a> and <b> are integers.
##
DeclareGlobalFunction( "IsGaussInt" );


#############################################################################
##
#F  IsGaussRat( <x> ) . . . . . . .  test if an object is a Gaussian rational
##
##  `IsGaussRat' returns `true' if the  object <x> is a Gaussian rational and
##  `false' otherwise.  Gaussian rationals are of the form `<a> + <b>\*E(4)',
##  where <a> and <b> are rationals.
##
DeclareGlobalFunction( "IsGaussRat" );


#############################################################################
##
#F  EB( <n> ) . . . . . . . . . . . . . . . . . .  some ATLAS irrationalities
#F  EC( <n> ) 
#F  ED( <n> ) 
#F  EE( <n> ) 
#F  EF( <n> ) 
#F  EG( <n> ) 
#F  EH( <n> )
##
##  For $N$ a positive integer, let $z = `E(<N>)' = e^{2 \pi i / N}$.
##  The following so-called *atomic irrationalities*
##  (see Chapter~7, Section~10 of~\cite{CCN85}) can be entered by functions.
##  (Note that the values are not necessary irrational.)
##
##  $$
##  \matrix{
##  `EB(<N>)' & = & b_N & = & \frac{1}{2}\sum_{j=1}^{N-1}z^{j^{2}} &
##   (N\equiv 1\bmod 2)\cr
##  `EC(<N>)' & = & c_N & = & \frac{1}{3}\sum_{j=1}^{N-1}z^{j^{3}} &
##   (N\equiv 1\bmod 3)\cr
##  `ED(<N>)' & = & d_N & = & \frac{1}{4}\sum_{j=1}^{N-1}z^{j^{4}} &
##   (N\equiv 1\bmod 4)\cr
##  `EE(<N>)' & = & e_N & = & \frac{1}{5}\sum_{j=1}^{N-1}z^{j^{5}} &
##   (N\equiv 1\bmod 5)\cr
##  `EF(<N>)' & = & f_N & = & \frac{1}{6}\sum_{j=1}^{N-1}z^{j^{6}} &
##   (N\equiv 1\bmod 6)\cr
##  `EG(<N>)' & = & g_N & = & \frac{1}{7}\sum_{j=1}^{N-1}z^{j^{7}} &
##   (N\equiv 1\bmod 7)\cr
##  `EH(<N>)' & = & h_N & = & \frac{1}{8}\sum_{j=1}^{N-1}z^{j^{8}} &
##   (N\equiv 1\bmod 8)\cr
##  }
##  $$
##
##  (Note that in $c_N, \ldots, h_N$, <N> must be a prime.)
##
DeclareGlobalFunction( "EB" );
DeclareGlobalFunction( "EC" );
DeclareGlobalFunction( "ED" );
DeclareGlobalFunction( "EE" );
DeclareGlobalFunction( "EF" );
DeclareGlobalFunction( "EG" );
DeclareGlobalFunction( "EH" );


#############################################################################
##
#F  EI( <n> ) . . . . ATLAS irrationality $i_{<n>}$ (the square root of -<n>)
#F  ER( <n> ) . . . . ATLAS irrationality $r_{<n>}$ (pos. square root of <n>)
#F  Sqrt( <rat> )
##
##  $$
##  \matrix{
##  `ER(<N>)' & = & \sqrt{N}   &   & \cr
##  `EI(<N>)' & = & i \sqrt{N} & = & \sqrt{-N}\cr
##  }
##  $$
##
##  A probably more usual name for `ER' is `Sqrt',
##  it can be used to compute the positive square root of any rational number
##  <rat>.
##  
##  From a theorem of Gauss we know that
##  $$
##  b_N = \left\{
##  \matrix{
##  \frac{1}{2}(-1+\sqrt{N}) & {\rm if} & N\equiv 1 & \bmod 4\cr
##  \frac{1}{2}(-1+i\sqrt{N}) & {\rm if} & N\equiv -1 & \bmod 4\cr
##  }\right. ,
##  $$
##  so $\sqrt{N}$ can be computed from $b_N$.
##  If <N> is a negative integer then `ER(<N>) = EI(-<N>)'.
##  
DeclareGlobalFunction( "EI" );
DeclareGlobalFunction( "ER" );
DeclareSynonym( "Sqrt", ER );


#############################################################################
##
#F  EY( <n>[, <d>] )
#F  EX( <n>[, <d>] )
#F  EW( <n>[, <d>] )
#F  EV( <n>[, <d>] )
#F  EU( <n>[, <d>] )
#F  ET( <n>[, <d>] )
#F  ES( <n>[, <d>] )
##
##  For given <N>, let $n_k = n_k(N)$ be the first integer with
##  multiplicative order exactly <k> modulo <N>,
##  chosen in the order of preference
##  $$
##  1, -1, 2, -2, 3, -3, 4, -4, \ldots .
##  $$
##  
##  We define
##  $$
##  \matrix{
##  `EY(<N>)' & = & y_n & = & z+z^n &(n = n_2)\cr
##  `EX(<N>)' & = & x_n & = & z+z^n+z^{n^2} &(n=n_3)\cr
##  `EW(<N>)' & = & w_n & = & z+z^n+z^{n^2}+z^{n^3} &(n=n_4)\cr
##  `EV(<N>)' & = & v_n & = & z+z^n+z^{n^2}+z^{n^3}+z^{n^4} &(n=n_5)\cr
##  `EU(<N>)' & = & u_n & = & z+z^n+z^{n^2}+\ldots +z^{n^5} &(n=n_6)\cr
##  `ET(<N>)' & = & t_n & = & z+z^n+z^{n^2}+\ldots +z^{n^6} &(n=n_7)\cr
##  `ES(<N>)' & = & s_n & = & z+z^n+z^{n^2}+\ldots +z^{n^7} &(n=n_8)\cr
##  }
##  $$              
##
DeclareGlobalFunction( "EY" );
DeclareGlobalFunction( "EX" );
DeclareGlobalFunction( "EW" );
DeclareGlobalFunction( "EV" );
DeclareGlobalFunction( "EU" );
DeclareGlobalFunction( "ET" );
DeclareGlobalFunction( "ES" );


#############################################################################
##
#F  EM( <n>[, <d>] )
#F  EL( <n>[, <d>] )
#F  EK( <n>[, <d>] )
#F  EJ( <n>[, <d>] )
##
##  $$
##  \matrix{
##  `EM(<N>)' & = & m_n & = & z-z^n &(n=n_2)\cr
##  `EL(<N>)' & = & l_n & = & z-z^n+z^{n^2}-z^{n^3} &(n=n_4)\cr
##  `EK(<N>)' & = & k_n & = & z-z^n+\ldots -z^{n^5} &(n=n_6)\cr
##  `EJ(<N>)' & = & j_n & = & z-z^n+\ldots -z^{n^7} &(n=n_8)\cr
##  }
##  $$
##
DeclareGlobalFunction( "EM" );
DeclareGlobalFunction( "EL" );
DeclareGlobalFunction( "EK" );
DeclareGlobalFunction( "EJ" );


#############################################################################
##
#F  NK( <n>, <k>, <d> ) . . . . . . . . . . utility for ATLAS irrationalities
##
##  Let $n_k^{(d)} = n_k^{(d)}(N)$ be the $d+1$-th integer with
##  multiplicative order exactly <k> modulo <N>, chosen in the order of
##  preference defined above; we write
##  $n_k=n_k^{(0)},n_k^{\prime}=n_k^{(1)}, n_k^{\prime\prime} = n_k^{(2)}$
##  and so on.
##  These values can be computed as`NK(<N>,<k>,<d>)'$ = n_k^{(d)}(N)$;
##  if there is no integer with the required multiplicative order,
##  `NK' returns `fail'.
##  
##  The algebraic numbers
##  $$
##  y_N^{\prime}=y_N^{(1)},y_N^{\prime\prime}=y_N^{(2)},\ldots,
##  x_N^{\prime},x_N^{\prime\prime},\ldots,
##  j_N^{\prime},j_N^{\prime\prime},\ldots
##  $$
##  are obtained on replacing $n_k$ in the above
##  definitions by $n_k^{\prime},n_k^{\prime\prime},\ldots$;
##  they can be entered as
##  
##  $$
##  \matrix{
##  `EY(<N>,<d>)' & = & y_N^{(d)}\cr
##  `EX(<N>,<d>)' & = & x_N^{(d)}\cr
##   & \vdots &\cr
##  `EJ(<N>,<d>)' & = & j_n^{(d)}\cr
##  }
##  $$
##
DeclareGlobalFunction( "NK" );


#############################################################################
##
#F  StarCyc( <cyc> )  . . . . the unique nontrivial Galois conjugate of <cyc>
##
##  If the cyclotomic <cyc> is an irrational element of a quadratic
##  extension of the rationals then `StarCyc' returns the unique Galois
##  conjugate of <cyc> that is different from <cyc>,
##  otherwise `fail' is returned.
##  In the first case, the return value is often called $<cyc>\ast$
##  (see~"DisplayCharacterTable").
##
DeclareGlobalFunction( "StarCyc" );


#############################################################################
##
#F  Quadratic( <cyc> ) . . . . .  information about quadratic irrationalities
##
##  Let <cyc> be a cyclotomic that lies in a quadratic extension field of the
##  rationals.
##  In this case, `Quadratic' calculates the representation
##  $<cyc> = ( \hbox{`a'} + \hbox{`b'} \sqrt{ \hbox{`root'} } ) / \hbox{`d'}$
##  and a (not necessarily shortest) representation `ATLAS' in terms of
##  a combination of the {\ATLAS} irrationalities $b_{\hbox{`root'}}$,
##  $i_{\hbox{`root'}}$, and $r_{\hbox{`root'}}$,
##  and returns a record with the components `a', `b', `root', `d', `ATLAS',
##  and `display', the latter being a string that expresses the <cyc> in
##  {\GAP} notation, corresponding to the `ATLAS' component.
##
##  If <cyc> does not lie in a quadratic extension of the rationals
##  then `fail' is returned.
##
##  If the denominator `d' is 2, necessarily `root' is congruent 1 mod 4,
##  and $r_n$, $i_n$ are not possible;
##  `<cyc> = x + y * EB( root )' with `y = b', `x = ( a + b ) / 2'.
##
##  If the denominator `d' is 1, we have the possibilities
##  $i_n$ for $`root' \< -1$, `a + b * i' for `root' = -1, $a + b * r_n$
##  for $`root' > 0$. Furthermore if `root' is congruent 1 modulo 4, also
##  `<cyc> = (a+b) + 2 * b * EB( root )' is possible; the shortest string
##  of these is taken as value for the component `ATLAS'.
##
DeclareGlobalFunction( "Quadratic" );


#############################################################################
##
#A  GaloisMat( <mat> )
##
##  Let <mat> be a matrix of cyclotomics.
##  `GaloisMat' calculates the completions of orbits under the operation of
##  the Galois group of the (irrational) entries of <mat>,
##  and the permutations of rows corresponding to the generators of the
##  Galois group.
##
##  If some rows of <mat> are identical, only the first one is considered
##  for the permutations, and a warning will be printed.
##  
##  `GaloisMat' returns a record with components `mat', `galoisfams',
##  and `generators'
##  
##  \beginitems
##  `mat':& 
##     a list with initial segment the rows of <mat>
##     (*not* shallow copies of these rows);
##     the list consists of full orbits under the action of the Galois
##     group of the entries of <mat> defined above.
##     The last rows in the list are those not contained in <mat> but
##     must be added in order to complete the orbits;
##     so if the orbits were already complete, <mat> and `mat' have
##     identical rows.
##
##  `galoisfams':&
##     a list that has the same length as the `mat' component,
##     its entries are either 1, 0, -1, or lists.
##     `galoisfams[i]  = 1' means that `mat[i]' consists of rationals,
##     i.e. `[ mat[i] ]' forms an orbit;
##     `galoisfams[i] = -1' means that `mat[i]' contains unknowns
##     (see chapter~"Unknowns");
##     in this case `[ mat[i] ]' is regarded as an orbit, too,
##     even if `mat[i]' contains irrational entries;
##     if $`galoisfams[i]' = [ l_1, l_2 ]$ is a list then
##     `mat[i]' is the first element of its orbit in `mat',
##     $l_1$ is the list of positions of rows that form the orbit,
##     and $l_2$ is the list of corresponding Galois automorphisms
##     (as exponents, not as functions),
##     so we have $`mat'[ l_1[j] ][k] = `GaloisCyc'( `mat'[i][k], l_2[j] )$;
##     `galoisfams[i] = 0' means that `mat[i]' is an element of a
##     nontrivial orbit but not the first element of it.
## 
##  `generators':&
##     a list of permutations generating the permutation group
##     corresponding to the action of the Galois group on the rows of
##     `mat'.
##  \enditems
##
DeclareAttribute( "GaloisMat", IsMatrix );


#############################################################################
##
#A  RationalizedMat( <mat> )  . . . . . .  list of rationalized rows of <mat>
##
##  returns the list of rationalized rows of <mat>,
##  which must be a matrix of cyclotomics.
##  This is the set of sums over orbits under the action of the Galois group
##  of the entries of <mat> (see "GaloisMat"),
##  so the operation may be viewed as a kind of trace on the rows.
##
##  Note that no two rows of <mat> should be equal.
##
DeclareAttribute( "RationalizedMat", IsMatrix );


#############################################################################
##
#E  cyclotom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

