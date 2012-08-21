#############################################################################
##
#W  partitio.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This    file contains the  functions that    construct and modify ordered
##  partitions. These  functions  are used in  the backtrack  algorithms  for
##  permutation groups.
##
##  A *partition* is a mutable record with the following components.
##  \beginitems                             
##  `points':  &
##       a list of all points contained in the partition, such that
##       points from the same cell are neighboured
##
##  `cellno': &
##       a list whose <i>th entry is the number of the cell which
##       contains the point <i>
##
##  `firsts': &
##       a list such that <points[firsts[j]]> is the first point in
##       <points> which is in cell <j>
##
##  `lengths': &
##       a list of the cell lengths
##  \enditems                             
##
Revision.partitio_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  Partition( <list> ) . . . . . . . . . . . . . . . . partition constructor
##
BindGlobal( "Partition", function( list )
    local   P,  i,  c;
    
    P := rec( points := Concatenation( list ),
              firsts := [  ],
             lengths := [  ] );

    if Length(list)>0 then
      P.cellno := ListWithIdenticalEntries( Maximum( P.points ), 0 );
    else
      Info(InfoWarning,2,"empty partition created!");
      P.cellno:=[];
    fi;
    i := 1;
    for c  in [ 1 .. Length( list ) ]  do
        if Length( list[ c ] ) = 0  then
            Error( "Partition: cells must not be empty" );
        fi;
        Add( P.firsts, i );
        Add( P.lengths, Length( list[ c ] ) );
        i := i + Length( list[ c ] );
        P.cellno{ list[ c ] } := c + 0 * list[ c ];
    od;
    return P;
end );


#############################################################################
##
#F  IsEqualPartition( <P>, <Q> )  . . . . . . . . . . . . . . . equality test
##
BindGlobal( "IsEqualPartition", function( P, Q )
    return P.cellno = Q.cellno;
end );


#############################################################################
##
#F  OnPartitions( <P>, <g> )  . . . . . . . permutations acting on partitions
##
BindGlobal( "OnPartitions", function( P, g )
    local   Q,  i;
    
    Q := StructuralCopy( P );
    Q.points := OnTuples( P.points, g );
    Q.cellno := [  ];
    for i  in [ 1 .. Length( P.cellno ) ]  do
        if IsBound( P.cellno[ i ] )  then
            Q.cellno[ i ^ g ] := P.cellno[ i ];
        fi;
    od;
    return Q;
end );

      
#############################################################################
##
#F  IsPartition( <P> )  . . . . . . . . . . . . test if object is a partition
##
BindGlobal( "IsPartition", P -> IsRecord( P ) and IsBound( P.cellno ) );
#T state this in the definition of a partition!


#############################################################################
##
#F  PointsPartition( <P> )  . . . . . . . . .  points involved in a partition
##
BindGlobal( "PointsPartition", P -> Set( P.points ) );


#############################################################################
##
#F  NumberCells( <P> )  . . . . . . . . . . . . . . . . . . . number of cells
##
BindGlobal( "NumberCells", P -> Length( P.firsts ) );


#############################################################################
##
#F  Cell( <P>, <m> )  . . . . . . . . . . . . . . . . . . . . .  cell as list
##
BindGlobal( "Cell", function( P, m )
    return P.points{ [ P.firsts[m] .. P.firsts[m] + P.lengths[m] - 1 ] };
end );


#############################################################################
##
#F  Fixcells( <P> ) . . . . . . . . . . . . . . . . . . . .  fixcells as list
##
##  Returns a list of the points along in their  cell, ordered as these cells
##  are ordered
##
BindGlobal( "Fixcells", function( P )
    local   fix,  i;
    
    fix := [  ];
    for i  in [ 1 .. Length( P.lengths ) ]  do
        if P.lengths[ i ] = 1  then
            Add( fix, P.points[ P.firsts[ i ] ] );
        fi;
    od;
    return fix;
end );


#############################################################################
##
#F  SplitCell( <P>, <i>, <Q>, <j>, <g>, <out> ) . . . . . . . .  split a cell
##
##  Splits <P>[ <i> ],  by taking out all  the points that are also contained
##  in <Q>[ <j> ]  ^ g. The  new cell is appended to  <P> unless it would  be
##  empty. If the old cell would remain empty, nothing is changed either.
##
##  Returns the length of the new cell, or `false' if nothing was changed.
##
##  Shortcuts of  the  splitting algorithm:  If  the last  argument  <out> is
##  `true', at least one point will  move out. If <out> is  a number, at most
##  <out> points will move out.
##
BindGlobal( "SplitCell", function( P, i, Q, j, g, out )
    local   a,  b,  l,  B,  tmp,  m,  x;

    a := P.firsts[ i ];
    b := a + P.lengths[ i ];
    l := b - 1;
    
    # If none or  all  points are  moved out,  do  not change <P>  and return
    # 'false'.
    if out <> true  then
        x := Q{ OnTuples( P.points{ [ a .. l ] }, g ) };
        if x = j + 0 * x  or  ForAll( x, i -> i <> j )  then
            return false;
        fi;
    fi;

    # Collect  the points to  be moved out of  the <i>th  cell  of <P> at the
    # right.
    a := a - 1;
    if out <> true  then  B := l - out;
                    else  B := 0;        fi;
    if B > 0  then

        # Points left of <a>  remain in the cell,   points right of  <b> move
        # out.
        while a < b  do

            # Decrease <b> until a point remains in the cell.
            repeat
                b := b - 1;
                
                # $b < B$ means that more than <out> points move out.
                if b < B  then
                    return false;
                fi;
                
            until Q[ P.points[ b ] ^ g ] <> j;

            # Increase <a> until a point moved out.
            repeat
                a := a + 1;
            until Q[ P.points[ a ] ^ g ] =  j;

            # Swap the points.
            if a < b  then
                tmp := P.points[ a ];
                P.points[ a ] := P.points[ b ];
                P.points[ b ] := tmp;
            fi;
            
        od;
        
    else  # Same as above, but without $b < B$ check.
        while a < b  do
            repeat
                b := b - 1;
            until Q[ P.points[ b ] ^ g ] <> j;
            repeat
                a := a + 1;
            until Q[ P.points[ a ] ^ g ] =  j;
            if a < b  then
                tmp := P.points[ a ];
                P.points[ a ] := P.points[ b ];
                P.points[ b ] := tmp;
            fi;
        od;
    fi;

    # Split the cell and introduce a new cell into <P>.
    m := Length( P.firsts ) + 1;
    P.cellno{ P.points{ [ a .. l ] } } := m + 0 * [ a .. l ];
    P.firsts[ m ] := a;
    P.lengths[ m ] := l - a + 1;
    P.lengths[ i ] := P.lengths[ i ] - P.lengths[ m ];
    
    return P.lengths[ m ];
end );


#############################################################################
##
#F  IsolatePoint( <P>, <a> )  . . . . . . . . . . . . . . . . isolate a point
##
##  Takes point <a> out of its cell in <P>, putting it into a new cell, which
##  is appended to <P>. However, does nothing, if <a> was already isolated.
##
##  Returns the  number of the cell   from <a> was  taken out,  or `false' if
##  nothing was changed.
##
BindGlobal( "IsolatePoint", function( P, a )
    local   i,  pos,  l,  m;
    
    i := P.cellno[ a ];
    if P.lengths[ i ] = 1  then
        return false;
    fi;
    
    pos := Position( P.points, a, P.firsts[ i ] - 1 );
    l := P.firsts[ i ] + P.lengths[ i ] - 1;
    P.points[ pos ] := P.points[ l ];
    P.points[ l ] := a;
    
    m := Length( P.firsts ) + 1;
    P.cellno[ a ] := m;
    P.firsts[ m ] := l;
    P.lengths[ m ] := 1;
    P.lengths[ i ] := P.lengths[ i ] - 1;
    return i;
end );


#############################################################################
##
#F  UndoRefinement( <P> ) . . . . . . . . . . . . . . . . . undo a refinement
##
##  Undoes the  effect of   the  last  cell-splitting actually performed   by
##  `SplitCell' or `IsolatePoint'. (This means that  if the last call of such
##  a function had no effect, `UndoRefinement' looks at the second-last etc.)
##  This fuses the last cell of <P> with an earlier cell.
##
##  Returns  the number of the  cell with which  the  last cell was fused, or
##  `false'   if the last  cell starts   at  `<P>.points[1]', because then it
##  cannot have been split off.
##
##  May behave undefined if there was no splitting before.
##
BindGlobal( "UndoRefinement", function( P )
    local   M,  m;
    
    M := Length( P.firsts );
    if P.firsts[ M ] = 1  then
        return false;
    fi;
    
    # Fuse the last cell with the one stored before it in `<P>.points'.
    m := P.cellno[ P.points[ P.firsts[ M ] - 1 ] ];
    P.lengths[ m ] := P.lengths[ m ] + P.lengths[ M ];
    P.cellno{ P.points
            { [ P.firsts[ M ] .. P.firsts[ M ] + P.lengths[ M ] - 1 ] } }
      := m + 0 * [ 1 .. P.lengths[ M ] ];
    Unbind( P.firsts[ M ] );
    Unbind( P.lengths[ M ] );
    
    return m;
end );


#############################################################################

#F  Cells( <Pi> ) . . . . . . . . . . . . . . . . . partition as list of sets
##
BindGlobal( "Cells", function( Pi )
    local  cells,  i;
    
    cells := [  ];
    for i  in Reversed( [ 1 .. NumberCells( Pi ) ] )  do
        cells[ i ] := Cell( Pi, i );
    od;
    return cells;
end );


#############################################################################
##
#F  FixpointCellNo( <P>, <i> )  . . . . . . . . .  fixpoint from cell no. <i>
##
##  Returns the first point of <P>[ <i> ] (should be a one-point cell).
##
BindGlobal( "FixpointCellNo", function( P, i )
    return P.points[ P.firsts[ i ] ];
end );


#############################################################################
##
#F  FixcellPoint( <P>, <old> )  . . . . . . . . . . . . . . . . . . . . local
##
##  Returns a random cell number which is not yet contained  in <old> and has
##  length 1.
##
##  Adds this cell number to <old>.
##
BindGlobal( "FixcellPoint", function( P, old )
    local   lens,  poss,  p;
    
    lens := P.lengths;
    poss := Filtered( [ 1 .. Length( lens ) ], i ->
                    not i in old  and  lens[ i ] = 1 );
    if Length( poss ) = 0  then
        return false;
    else
        p := Random( poss );
        AddSet( old, p );
        return p;
    fi;
end );


#############################################################################
##
#F  FixcellsCell( <P>, <cellno>, <conj>, <old> )  . . . . . . . . . . . local
##
##  Returns [ <K>, <I>  ] such that  for j=1,...|K|=|I|,  all points  in cell
##  <P>[  <I>[j] ], mapped  with <conj> have value  <K>[j] in <cellno> (i.e.,
##  lie   in cell <K>[j]  of a  partition whose `cellno'  entry is <cellno>).
##  Returns `false' if <K> and <I> are empty.
##
BindGlobal( "FixcellsCell", function( P, cellno, conj, old )
    local   K,  I,  i,  k,  start;
    
    K := [  ];  I := [  ];
    for i  in [ 1 .. NumberCells( P ) ]  do
        start := P.firsts[ i ];
        k := cellno[ P.points[ start ] ^ conj ];
        if     not k in old
           and ForAll( start + [ 1 .. P.lengths[ i ] - 1 ], j ->
                       cellno[ P.points[ j ] ^ conj ] = k ) then
            AddSet( old, k );
            Add( K, k );  Add( I, i );
        fi;
    od;
    if Length( K ) = 0  then  return false;
                        else  return [ K, I ];  fi;
end );


#############################################################################
##

#F  TrivialPartition( <Omega> ) . . . . . . . . . one-cell partition of a set
##
BindGlobal( "TrivialPartition", function( Omega )
    return Partition( [ Omega ] );
end );


#############################################################################
##
#F  OrbitsPartition( <G>, <Omega> ) partition determined by the orbits of <G>
##
BindGlobal( "OrbitsPartition", function( G, Omega )
    if IsGroup( G )  then
        return Partition( Orbits( G, Omega ) );
    else
        return Partition( OrbitsPerms( G.generators, Omega ) );
    fi;
end );


#############################################################################
##
#F  SmallestPrimeDivisor( <size> )  . . . . . . . . .  smallest prime divisor
##
BindGlobal( "SmallestPrimeDivisor", function( size )
    local   i;
    
    i := 0;
    if size = 1  then
        return 1;
    else
        repeat
            i := i + 1;
        until i > Length( Primes )  or  size mod Primes[ i ] = 0;
        if i > Length( Primes )  then  return FactorsInt( size )[ 1 ];
                                 else  return Primes[ i ];              fi;
    fi;
end );


#############################################################################
##
#F  CollectedPartition( <P>, <size> ) . orbits on cells under group of <size>
##
##  Returns a  partition into unions of cells  of <P> of equal length, sorted
##  by  this length. However,  if there are $n$ cells  of equal length, which
##  cannot be fused under the action of a group of  order <size> (because $n$
##  < SmallestPrimeDivisor(  <size>  )), leaves   these $n$  cells   unfused.
##  (<size> = 1 suppresses this extra feature.)
##
BindGlobal( "CollectedPartition", function( P, size )
    local   lens,  C,  div,  typ,  p,  i;

    lens := P.lengths;
    C    := [  ];
    div  := SmallestPrimeDivisor( size );
    for typ  in Collected( lens )  do
        p := [  ];
        for i  in [ 1 .. Length( lens ) ]  do
            if lens[ i ] = typ[ 1 ]  then
                Add( p, Cell( P, i ) );
            fi;
        od;
        if typ[ 2 ] < div  then
            Append( C, p );
        else
            Add( C, Concatenation( p ) );
        fi;
    od;
    return Partition( C );
end );


#############################################################################
##
#E

