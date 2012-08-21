#############################################################################
##
#W  ctbl.gi                     GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains generic methods for character tables.
##
##  1. methods for operations that take a group or a table as argument
##  2. method for character tables only
##
Revision.ctbl_gi :=
    "@(#)$Id$";


#T introduce '\=' and '<' for character tables


#############################################################################
##
##  1. methods for operations that take a group or a table as argument
##
##  The table may delegate to the group.
##  The table may compute without the help of the group.
##  The group may call a method for its ordinary table (but must *not* call
##  the operation for its ordinary table).
##
##  For the following ``groupy'' operations, there are methods that allow
##  an ordinary character table instead of a group.
##
##  `CharacterDegreesAttr',
##  `CharacterTable',
##  `ClassMultiplicationCoefficient',
##  `OrdinaryCharacterTable',
##  `Irr',
##  `NrConjugacyClasses',
##  `TableOfMarks',
##  `Size',
##  `SizesConjugacyClasses',
##  `SizesCentralizers',
##  `OrdersClassRepresentatives'
##
##  For the following ``tably'' operations, there are methods that allow
##  a group instead of an ordinary character table.
##  (The reason to treat them the other way around is that we want to store
##  the info in the table and not in the group; the reason for this is that
##  we can use the stored info also if no underlying group is known.)
##
##  'BrauerCharacterTable',
##  'PowerMap',
##  'FusionConjugacyClasses'
##


#############################################################################
##
#F  CharacterDegrees( <G> ) . . . . . . . . . . . . . . . . . . . for a group
#F  CharacterDegrees( <G>, <p> )  . . . . . . . . . . for a group and a prime
#F  CharacterDegrees( <tbl> ) . . . . . . . . . . . . . for a character table
##
InstallGlobalFunction( CharacterDegrees, function( arg )
    if     Length( arg ) = 1
       and ( IsGroup( arg[1] ) or IsCharacterTable( arg[1] ) ) then
      return CharacterDegreesAttr( arg[1] );
    elif Length( arg ) = 2 and IsGroup( arg[1] ) and IsInt( arg[2] ) then
      return CharacterDegreesOp( arg[1], arg[2] );
    fi;
    Error( "usage: CharacterDegrees(<G>[,<p>]) or CharacterDegrees(<tbl>)" );
end );


#############################################################################
##
#M  CharacterDegreesAttr( <G> ) . . . . . . . . . . . . . . . . . for a group
#M  CharacterDegreesOp( <G>, <zero> ) . . . . . . . . .  for a group and zero
##
##  The attribute delegates to the operation.
##  The operation delegates to 'Irr'.
##
InstallMethod( CharacterDegreesAttr,
    "for a group",
    true,
    [ IsGroup ], 0,
    G -> CharacterDegreesOp( G, 0 ) );

InstallOtherMethod( CharacterDegreesOp,
    "for a group, and zero",
    true,
    [ IsGroup, IsZeroCyc ], 0,
    function( G, zero )
    return Collected( List( Irr( G ), DegreeOfCharacter ) );
    end );

InstallOtherMethod( CharacterDegreesOp,
    "for a group, and positive integer",
    true,
    [ IsGroup, IsPosInt ], 0,
    function( G, p )
    if Size( G ) mod p = 0 then
      return CharacterDegreesAttr( CharacterTable( G, p ) );
    else
      return CharacterDegreesAttr( G );
    fi;
    end );


#############################################################################
##
#M  CharacterDegreesAttr( <tbl> ) . . . . . . . . . . . for a character table
##
##  We delegate to 'Irr' for the table.
##  The ordinary table may ask its group.
##
InstallOtherMethod( CharacterDegreesAttr,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> Collected( List( Irr( tbl ), DegreeOfCharacter ) ) );

InstallOtherMethod( CharacterDegreesAttr,
    "for an ordinary character table with group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    tbl -> CharacterDegreesAttr( UnderlyingGroup( tbl ) ) );


#############################################################################
##
#M  CharacterDegreesAttr( <G> ) . . . for group handled via nice monomorphism
##
AttributeMethodByNiceMonomorphism( CharacterDegreesAttr,
    [ IsGroup ] );


#############################################################################
##
#M  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#M  CharacterTable( <ordtbl>, <p> )
#M  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
##
##  We delegate to `OrdinaryCharacterTable' or `BrauerCharacterTable'.
##
InstallMethod( CharacterTable,
    "for a group and a prime",
    true,
    [ IsGroup, IsInt ], 0,
    function( G, p )
    if p = 0 then
      return OrdinaryCharacterTable( G );
    else
      return BrauerCharacterTable( OrdinaryCharacterTable( G ), p );
    fi;
    end );

InstallOtherMethod( CharacterTable,
    "for an ordinary table and a prime",
    true,
    [ IsOrdinaryTable, IsPosInt ], 0,
    BrauerCharacterTable );

InstallOtherMethod( CharacterTable,
    "for a group (delegate to 'OrdinaryCharacterTable')",
    true,
    [ IsGroup ], 0,
    OrdinaryCharacterTable );


#############################################################################
##
#M  ClassMultiplicationCoefficient( <ordtbl>, <c1>, <c2>, <c3> )
##
##  We either delegate to the group or use the irreducibles (if known)
##
InstallOtherMethod( ClassMultiplicationCoefficient,
    "for an ord. table with group, and three pos. integers",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup,
      IsPosInt, IsPosInt, IsPosInt ], 0,
    function( ordtbl, c1 ,c2, c3 )
    return ClassMultiplicationCoefficient( UnderlyingGroup( ordtbl ),
                                           c1, c2, c3 );
    end );

InstallOtherMethod( ClassMultiplicationCoefficient,
    "for an ord. table with irreducibles, and three pos. integers",
    true,
    [ IsOrdinaryTable and HasIrr,
      IsPosInt, IsPosInt, IsPosInt ], 10,
    function( ordtbl, c1 ,c2, c3 )

    local res, chi, char, classes;

    res:= 0;
    for chi in Irr( ordtbl ) do
       char:= ValuesOfClassFunction( chi );
       res:= res + char[c1] * char[c2] * GaloisCyc(char[c3], -1) / char[1];
    od;
    classes:= SizesConjugacyClasses( ordtbl );
    return classes[c1] * classes[c2] * res / Size( ordtbl );
    end );


#############################################################################
##
#F  ClassStructureCharTable(<tbl>,<classes>)  . gener. class mult. coefficent
##
InstallGlobalFunction( ClassStructureCharTable, function( tbl, classes )

    local exp;

    exp:= Length( classes ) - 2;
    if exp < 0 then
      Error( "length of <classes> must be at least 2" );
    fi;

    return Sum( Irr( tbl ),
                chi -> Product( chi{ classes }, 1 ) / ( chi[1] ^ exp ),
                0 )
           * Product( SizesConjugacyClasses( tbl ){ classes }, 1 )
           / Size( tbl );
end );


#############################################################################
##
#F  MatClassMultCoeffsCharTable( <tbl>, <class> )
##
InstallGlobalFunction( MatClassMultCoeffsCharTable, function( tbl, class )
    local nccl;
    nccl:= NrConjugacyClasses( tbl );
    return List( [ 1 .. nccl ],
                 j -> List( [ 1 .. nccl ],
                 k -> ClassMultiplicationCoefficient( tbl, class, j, k ) ) );
end );


#############################################################################
##
#M  OrdinaryCharacterTable( <G> ) . . . . . . . . . . . . . . . . for a group
#M  OrdinaryCharacterTable( <modtbl> )  . . . .  for a Brauer character table
##
##  In the first case, we setup the table object.
##  In the second case, we delegate to 'OrdinaryCharacterTable' for the
##  group.
##
InstallMethod( OrdinaryCharacterTable,
    "for a group",
    true,
    [ IsGroup ], 0,
    function( G )
    local tbl;

    # Make the object.
    tbl:= Objectify( NewType( NearlyCharacterTablesFamily,
                              IsOrdinaryTable and IsAttributeStoringRep ),
                     rec() );

    SetUnderlyingGroup( tbl, G );
    SetUnderlyingCharacteristic( tbl, 0 );

    return tbl;
    end );

InstallOtherMethod( OrdinaryCharacterTable,
    "for a Brauer character table with group",
    true,
    [ IsBrauerTable and HasUnderlyingGroup ], 0,
    modtbl -> OrdinaryCharacterTable( UnderlyingGroup( modtbl ) ) );


#############################################################################
##
#F  BrauerCharacterTable( <ordtbl>, <p> ) . . . . . . . . . <p>-modular table
#F  BrauerCharacterTable( <G>, <p> )
##
##  Note that Brauer tables are stored in the ordinary table and not in the
##  group.
##
InstallGlobalFunction( BrauerCharacterTable, function( ordtbl, p )

    local known;

    # Delegeta to the ordinary table in the case of a group.
    if IsGroup( ordtbl ) then
      ordtbl:= OrdinaryCharacterTable( ordtbl );
    fi;

    if not IsOrdinaryTable( ordtbl ) then
      Error( "<ordtbl> must be an ordinary character table" );
    elif not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedBrauerCharacterTables( ordtbl );

    # Compute the <p>-modular table if necessary.
    if not IsBound( known[p] ) then
      known[p] := BrauerCharacterTableOp( ordtbl, p );
    fi;

    # Return the <p>-modular table.
    return known[p];
end );


#############################################################################
##
#M  BrauerCharacterTableOp( <ordtbl>, <p> ) . . . . . . . . <p>-modular table
##
##  Note that we do not need a method for the first argument a group,
##  since `BrauerCharacterTable' delegates this to the ordinary table.
##
InstallMethod( BrauerCharacterTableOp,
    "for ordinary character table, and positive integer",
    true,
    [ IsOrdinaryTable, IsPosInt ], 0,
    CharacterTableRegular );


#############################################################################
##
#M  ComputedBrauerCharacterTables( <ordtbl> ) . . for an ord. character table
##
InstallMethod( ComputedBrauerCharacterTables,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    ordtbl -> [] );


#############################################################################
##
#M  \mod( <ordtbl>, <p> ) . . . . . . . . . . . . . . . . . <p>-modular table
##
InstallMethod( \mod,
    "for ordinary character table, and positive integer",
    true,
    [ IsOrdinaryTable, IsPosInt ], 0,
    BrauerCharacterTable );


#############################################################################
##
#F  IBr( <G>, <p> )
#F  IBr( <modtbl> )
##
InstallGlobalFunction( IBr, function( arg )
    if Length( arg ) = 1 and IsBrauerTable( arg[1] ) then
      return Irr( arg[1] );
    elif Length( arg ) = 2 and IsGroup( arg[1] ) and IsInt( arg[2] )
                           and IsPrimeInt( arg[2] ) then
      return Irr( BrauerCharacterTable( OrdinaryCharacterTable( arg[1] ),
                                        arg[2] ) );
    else
      Error( "usage: IBr( <G>, <p> ) for group <G> and prime <p>" );
    fi;
end );


#############################################################################
##
#M  Irr( <modtbl> ) . . . . . . . . . . . . . for a <p>-solvable Brauer table
##
##  Compute the modular irreducibles from the ordinary irreducibles
##  using the Fong-Swan Theorem.
##
InstallOtherMethod( Irr,
    "for a <p>-solvable Brauer table (use the Fong-Swan Theorem)",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )

    local p,       # characteristic
          ordtbl,  # ordinary character table
          i,       # loop variable
          rest,    # restriction of characters to 'p'-regular classes
          irr,     # list of Brauer characters
          cd,      # list of ordinary character degrees
          deg,     # one character degree
          chars,   # characters of a given degree
          dec;     # decomposition of ordinary characters
                   # into known Brauer characters

    p:= UnderlyingCharacteristic( modtbl );
    ordtbl:= OrdinaryCharacterTable( modtbl );

    if not IsPSolvableCharacterTable( ordtbl, p ) then
      TryNextMethod();
    fi;

    rest:= RestrictedClassFunctions( Irr( ordtbl ), modtbl );

    if Size( ordtbl ) mod p <> 0 then

      # Catch a trivial case.
      irr:= rest;

    else

      # Start with the linear characters.
      # (Choose the same succession as in the ordinary table,
      # in particular leave the trivial character at first position
      # if this is the case for `ordtbl'.)
      irr:= [];
      for i in rest do
        if DegreeOfCharacter( i ) = 1 and not i in irr then
          Add( irr, i );
        fi;
      od;
      cd:= Set( List( rest, DegreeOfCharacter ) );
      RemoveSet( cd, 1 );
  
      for deg in cd do
        chars:= Set( Filtered( rest, x -> DegreeOfCharacter( x ) = deg ) );
#T improve this!!!
        dec:= Decomposition( irr, chars, "nonnegative" );
        for i in [ 1 .. Length( dec ) ] do
          if dec[i] = fail then
            Add( irr, chars[i] );
          fi;
        od;
      od;

    fi;

    # Return the irreducible Brauer characters.
    return irr;
    end );


#############################################################################
##
#M  Irr( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . . for a group
##


#############################################################################
##
#M  Irr( <ordtbl> ) . . . . . . . . . . . . . for an ordinary character table
##
##  We must delegate this to the underlying group.
##
InstallOtherMethod( Irr,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    ordtbl -> Irr( UnderlyingGroup( ordtbl ) ) );


#############################################################################
##
#M  NrConjugacyClasses( <ordtbl> )  . . . . . for an ordinary character table
#M  NrConjugacyClasses( <modtbl> )  . . . . . .  for a Brauer character table
#M  NrConjugacyClasses( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders or class lengths, however, we use them.
##
##  If the argument is a group, we can use the known class lengths of the
##  known ordinary character table.
##
InstallOtherMethod( NrConjugacyClasses,
    "for an ordinary character table with underlying group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    ordtbl -> NrConjugacyClasses( UnderlyingGroup( ordtbl ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    modtbl -> Length( GetFusionMap( modtbl,
                                    OrdinaryCharacterTable( modtbl ) ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "for a character table with known centralizer sizes",
    true,
    [ IsNearlyCharacterTable and HasSizesCentralizers ], 0,
    tbl -> Length( SizesCentralizers( tbl ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "for a character table with known class lengths",
    true,
    [ IsNearlyCharacterTable and HasSizesConjugacyClasses ], 0,
    tbl -> Length( SizesConjugacyClasses( tbl ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasNrConjugacyClasses( tbl ) then
      return NrConjugacyClasses( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Size( <tbl> ) . . . . . . . . . . . . . . . . . . . for a character table
#M  Size( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders, however, we use them.
##
##  If the argument is a group, we can use the known size of the
##  known ordinary character table.
##
InstallOtherMethod( Size,
    "for a character table with underlying group",
    true,
    [ IsCharacterTable and HasUnderlyingGroup ], 0,
    tbl -> Size( UnderlyingGroup( tbl ) ) );


InstallOtherMethod( Size,
    "for a character table with known centralizer sizes",
    true,
    [ IsNearlyCharacterTable and HasSizesCentralizers ], 100,
    tbl -> SizesCentralizers( tbl )[1] );
#T immediate method ?


InstallOtherMethod( Size,
    "for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasSize( tbl ) then
      return Size( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  ConjugacyClasses( <ordtbl> )  . . . . . . for an ordinary character table
##
#T is only preliminary;
#T catch cases where consistency must be guaranteed!
#T better delegate to `CompatibleConjugacyClasses' !!
##
InstallMethod( ConjugacyClasses,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    function( tbl )
    local ccl, bijection, pos, help;

    ccl:= ConjugacyClasses( UnderlyingGroup( tbl ) );
    bijection:= [ 1 .. Length( ccl ) ];

    # We have to make sure that the class of the identity element
    # is the first one.
    pos:= PositionProperty( ccl, c -> Order( Representative( c ) ) = 1 );
    if pos <> 1 then
      ccl:= ShallowCopy( ccl );
      bijection[1]:= pos;
      bijection[ pos ]:= 1;
      help:= ccl[1];
      ccl[1]:= ccl[ pos ];
      ccl[ pos ]:= help;
      MakeImmutable( ccl );
    fi;

    MakeImmutable( bijection );
    SetIdentificationOfConjugacyClasses( tbl, bijection );

    return ccl;
    end );


#############################################################################
##
#M  SizesConjugacyClasses( <ordtbl> ) . . . . for an ordinary character table
#M  SizesConjugacyClasses( <modtbl> ) . . . . .  for a Brauer character table
##
##  If we know the centralizer orders, we use them.
##
InstallMethod( SizesConjugacyClasses,
    "for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return SizesConjugacyClasses( ordtbl ){ GetFusionMap( modtbl,
                                                          ordtbl ) };
    end );

InstallMethod( SizesConjugacyClasses,
    "for a character table with known centralizer sizes",
    true,
    [ IsNearlyCharacterTable and HasSizesCentralizers ], 100,
    function( tbl )
    local centsizes, size;
    centsizes:= SizesCentralizers( tbl );
    size:= centsizes[1];
    return List( centsizes, s -> size / s );
    end );

InstallMethod( SizesConjugacyClasses,
    "for a character table with known group",
    true,
    [ IsNearlyCharacterTable and HasUnderlyingGroup ], 0,
    tbl -> List( ConjugacyClasses( tbl ), Size ) );


#############################################################################
##
#M  SizesCentralizers( <ordtbl> ) . . . . . . for an ordinary character table
#M  SizesCentralizers( <modtbl> ) . . . . . . .  for a Brauer character table
##
##  If we know the class lengths, we use them.
##
InstallMethod( SizesCentralizers,
    "for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return SizesCentralizers( ordtbl ){ GetFusionMap( modtbl, ordtbl ) };
    end );

InstallMethod( SizesCentralizers,
    "for a character table with known class lengths",
    true,
    [ IsNearlyCharacterTable and HasSizesConjugacyClasses ], 100,
    function( tbl )
    local classlengths, size;
    classlengths:= SizesConjugacyClasses( tbl );
    size:= Sum( classlengths, 0 );
    return List( classlengths, s -> size / s );
    end );

InstallMethod( SizesCentralizers,
    "for a character table with known group",
    true,
    [ IsNearlyCharacterTable and HasUnderlyingGroup ], 0,
    function( tbl )
    local size;
    size:= Size( tbl );
    return List( ConjugacyClasses( tbl ), c -> size / Size( c ) );
    end );


#############################################################################
##
#M  OrdersClassRepresentatives( <ordtbl> )  . for an ordinary character table
#M  OrdersClassRepresentatives( <modtbl> )  . .  for a Brauer character table
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the class lengths, however, we use them.
##
InstallMethod( OrdersClassRepresentatives,
    "for a Brauer character table (delegate to the ordinary table)",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return OrdersClassRepresentatives( ordtbl ){ GetFusionMap( modtbl,
                                                               ordtbl ) };
    end );

InstallMethod( OrdersClassRepresentatives,
    "for a character table with known group",
    true,
    [ IsNearlyCharacterTable and HasUnderlyingGroup ], 0,
    tbl -> List( ConjugacyClasses( tbl ),
                 c -> Order( Representative( c ) ) ) );

InstallMethod( OrdersClassRepresentatives,
    "for a character table, use known power maps",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )

    local ord, p;

    # Compute the orders as determined by the known power maps.
    ord:= ElementOrdersPowerMap( ComputedPowerMaps( tbl ) );
    if ForAll( ord, IsInt ) then
      return ord;
    fi;

    # If these maps do not suffice, compute the missing power maps
    # and then try again.
    for p in Set( Factors( Size( tbl ) ) ) do
      PowerMap( tbl, p );
    od;
    ord:= ElementOrdersPowerMap( ComputedPowerMaps( tbl ) );
    Assert( 2, ForAll( ord, IsInt ),
            "computed power maps should determine element orders" );

    return ord;
    end );


#############################################################################
##
#M  BlocksInfo( <modtbl> )
##
InstallMethod( BlocksInfo,
    "generic method for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )

    local ordtbl, prime, modblocks, decinv, i, ilist, ibr, rest, pblocks,
          ordchars, decmat, nccmod, k, modchars;

    ordtbl    := OrdinaryCharacterTable( modtbl );
    prime     := UnderlyingCharacteristic( modtbl );
    modblocks := [];

    if Size( ordtbl ) mod prime <> 0 then

      # If characteristic and group order are coprime then all blocks
      # are trivial.
      # (We do not need the Brauer characters.)
      decinv:= [ [ 1 ] ];
      MakeImmutable( decinv );
      for i in [ 1 .. NrConjugacyClasses( ordtbl ) ] do

        ilist:= [ i ];
        MakeImmutable( ilist );

        modblocks[i]:= rec( defect   := 0,
                            ordchars := ilist,
                            modchars := ilist,
                            basicset := ilist,
                            decinv   := decinv );

      od;

    else

      # We use the irreducible Brauer characters.
      ibr      := Irr( modtbl );
      rest     := RestrictedClassFunctions( Irr( ordtbl ), modtbl );
      pblocks  := PrimeBlocks( ordtbl, prime );
      ordchars := InverseMap( pblocks.block );
      decmat   := Decomposition( ibr, rest, "nonnegative" );
      nccmod   := Length( decmat[1] );
      MakeImmutable( ordchars );

      for k in [ 1 .. Length( pblocks.defect ) ] do

        modchars:= Filtered( [ 1 .. nccmod ],
                             j -> ForAny( ordchars[k],
                                          i -> decmat[i][j] <> 0 ) );
        MakeImmutable( modchars );

        modblocks[i]:= rec( defect   := pblocks.defect[k],
                            ordchars := ordchars[k],
                            modchars := modchars );

      od;

    fi;

    # Return the blocks information.
    return modblocks;
    end );


#############################################################################
##
#F  AddDecMats( <modtbl> )
##
InstallGlobalFunction( AddDecMats, function( modtbl )

    local ordtbl,
          fus,
          block,
          ordchars,
          modchars;

    if not IsBrauerTable( modtbl ) then
      Error( "<modtbl> must be a Brauer table" );
    fi;
    ordtbl:= OrdinaryCharacterTable( modtbl );

    fus:= GetFusionMap( modtbl, ordtbl );
    for block in BlocksInfo( modtbl ) do
      if block.defect = 0 then
        block.decmat:= [ [ 1 ] ];
      else
        ordchars:= List( Irr( ordtbl ){ block.ordchars },
                         chi -> ValuesOfClassFunction( chi ){ fus } );
        modchars:= List( Irr( modtbl ){ block.modchars },
                         ValuesOfClassFunction );
        block.decmat:= Decomposition( modchars, ordchars, "nonnegative" );
      fi;
      MakeImmutable( block.decmat );
    od;
end );


#############################################################################
##
#M  IrredInfo( <tbl> )  . . . . . . . . . method for a nearly character table
##
##  initialize with empty records
##
InstallMethod( IrredInfo,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> List( [ 1 .. NrConjugacyClasses( tbl ) ],
                 i -> rec( indicator:= [], pblock:= [] ) ) );


#############################################################################
##
#M  ComputedClassFusions( <tbl> )
##
##  We do *not* store class fusions in groups,
##  `FusionConjugacyClasses' must store the fusion if the character tables
##  of both groups are known already.
#T !!
##
InstallMethod( ComputedClassFusions,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> [] );


#############################################################################
##
#F  PowerMapByComposition( <tbl>, <n> ) . .  for char. table and pos. integer
##
InstallGlobalFunction( PowerMapByComposition, function( tbl, n )

    local powermap, nth_powermap, i;

    if not IsPosInt( n ) then
      Error( "<n> must be a positive integer" );
    fi;
    powermap:= ComputedPowerMaps( tbl );
    nth_powermap:= [ 1 .. NrConjugacyClasses( tbl ) ];

    for i in Factors( n ) do
      if not IsBound( powermap[i] ) then
        return fail;
      fi;
      nth_powermap:= nth_powermap{ powermap[i] };
    od;

    # Return the map;
    return nth_powermap;
end );


#############################################################################
##
#F  PowerMap( <tbl>, <n> )  . . . . . . . . . for character table and integer
#F  PowerMap( <tbl>, <n>, <class> )
#F  PowerMap( <G>, <n> )  . . . . . . . . . . . . . . . for group and integer
#F  PowerMap( <G>, <n>, <class> )
##
##  We do not store power maps in groups, the group delegates to its ordinary
##  character table.
##
InstallGlobalFunction( PowerMap, function( arg )

    local tbl, n, known;

    if Length( arg ) = 2 and IsInt( arg[2] ) then

      if IsGroup( arg[1] ) then

        return PowerMap( OrdinaryCharacterTable( arg[1] ), arg[2] );

      elif IsNearlyCharacterTable( arg[1] ) then

        tbl := arg[1];
        n   := arg[2];
        known:= ComputedPowerMaps( tbl );

        # compute the <n>-th power map
        if not IsBound( known[n] ) then
          known[n] := PowerMapOp( tbl, n );
        fi;

        # return the <p>-th power map
        return known[n];

      fi;

    elif Length( arg ) = 3 and IsInt( arg[2] ) and IsInt( arg[3] ) then

      if IsGroup( arg[1] ) then

        return PowerMap( OrdinaryCharacterTable( arg[1] ), arg[2], arg[3] );

      elif IsNearlyCharacterTable( arg[1] ) then

        tbl := arg[1];
        n   := arg[2];
        known:= ComputedPowerMaps( tbl );

        if IsBound( known[n] ) then
          return known[n][ arg[3] ];
        else
          return PowerMapOp( tbl, n, arg[3] );
        fi;

      fi;

    else
      Error( "usage: PowerMap( <tbl>, <n>[, <class>] )" );
    fi;

end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n> ) . . . . . .  for ord. table, and pos. integer
##
InstallMethod( PowerMapOp,
    "for ordinary table with group, and positive integer",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup, IsPosInt ], 0,
    function( tbl, n )

    local G, map, p;

    if n = 1 then

      map:= [ 1 .. NrConjugacyClasses( tbl ) ];

    elif IsPrimeInt( n ) then

      G:= UnderlyingGroup( tbl );
      map:= PowerMapOfGroup( G, n, ConjugacyClasses( G ) );

    else

      map:= [ 1 .. NrConjugacyClasses( tbl ) ];
      for p in Factors( n ) do
        map:= map{ PowerMap( tbl, p ) };
      od;

    fi;
    return map;
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n> ) . . . . . .  for ord. table, and pos. integer
##
InstallMethod( PowerMapOp,
    "for ordinary table, and positive integer",
    true,
    [ IsOrdinaryTable, IsPosInt ], 0,
    function( tbl, n )
    local i, powermap, nth_powermap, pmap;

    nth_powermap:= [ 1 .. NrConjugacyClasses( tbl ) ];
    if n = 1 then
      return nth_powermap;
    elif HasUnderlyingGroup( tbl ) then
      TryNextMethod();
    fi;

    powermap:= ComputedPowerMaps( tbl );

    for i in Factors( n ) do
      if not IsBound( powermap[i] ) then

        # Compute the missing power map.
        pmap:= PossiblePowerMaps( tbl, i, rec( quick := true ) );
        if 1 < Length( pmap ) then
          Error( Ordinal( i ), " power map not determined for <tbl>" );
        fi;
        powermap[i]:= pmap[1];

      fi;
      nth_powermap:= nth_powermap{ powermap[i] };
    od;

    # Return the map;
    return nth_powermap;
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n>, <class> )
##
InstallOtherMethod( PowerMapOp,
    "for ordinary table, and two positive integers",
    true,
    [ IsOrdinaryTable, IsPosInt, IsPosInt ], 0,
    function( tbl, n, class )

    local i, powermap, image, range, pmap;

    powermap:= ComputedPowerMaps( tbl );
    if n = 1 then
      return class;
    elif IsBound( powermap[n] ) then
      return powermap[n][ class ];
    fi;

    n:= n mod OrdersClassRepresentatives( tbl )[ class ];
    if n = 0 then
      return 1;
    elif n = 1 then
      return class;
    elif IsBound( powermap[n] ) then
      return powermap[n][ class ];
    fi;

    image:= class;
    for i in FactorsInt( n ) do
      if not IsBound( powermap[i] ) then

        # Compute the missing power map.
        powermap[i]:= PowerMap( tbl, i );
#T if the group is available, better ask it directly?
#T (careful: No maps are stored by the three-argument call,
#T this may slow down the computation if many calls are done ...)

      fi;
      image:= powermap[i][ image ];
    od;
    return image;
    end );


#############################################################################
##
#M  PowerMapOp( <tbl>, <n> )
##
InstallMethod( PowerMapOp,
    "for character table and negative integer",
    true,
    [ IsCharacterTable, IsInt and IsNegRat ], 0,
    function( tbl, n )
    return PowerMap( tbl, -n ){ InverseClasses( tbl ) };
    end );


#############################################################################
##
#M  PowerMapOp( <tbl>, <zero> )
##
InstallMethod( PowerMapOp,
    "for character table and zero",
    true,
    [ IsCharacterTable, IsZeroCyc ], 0,
    function( tbl, zero )
    return ListWithIdenticalEntries( NrConjugacyClasses( tbl ), 1 );
    end );


#############################################################################
##
#M  PowerMapOp( <modtbl>, <n> )
##
InstallMethod( PowerMapOp,
    "for Brauer table and positive integer",
    true,
    [ IsBrauerTable, IsPosInt ], 0,
    function( tbl, n )
    local fus, ordtbl;
    ordtbl:= OrdinaryCharacterTable( tbl );
    fus:= GetFusionMap( tbl, ordtbl );
    return InverseMap( fus ){ PowerMap( ordtbl, n ){ fus } };
    end );


#############################################################################
##
#M  PowerMapOp( <modtbl>, <n>, <class> )
##
InstallOtherMethod( PowerMapOp,
    "for Brauer table and two integers",
    true,
    [ IsBrauerTable, IsPosInt, IsPosInt ], 0,
    function( tbl, n, class )
    local fus, ordtbl;
#T check whether the map is stored already!
    ordtbl:= OrdinaryCharacterTable( tbl );
    fus:= GetFusionMap( tbl, ordtbl );
    return Position( fus, PowerMap( ordtbl, n, fus[ class ] ) );
    end );


#############################################################################
##
#M  ComputedPowerMaps( <tbl> )  . . . . . . . .  for a nearly character table
##
InstallMethod( ComputedPowerMaps,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> [] );


#############################################################################
##
##  2. method for character tables only
##


#############################################################################
##
#M  IsInternallyConsistent( <tbl> ) . . . . . . . . . . for a character table
##
##  Check consistency of information in the head of the character table
##  <tbl>, and check if the first orthogonality relation is satisfied.
##
InstallMethod( IsInternallyConsistent,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    function( tbl )

    local flag,
          centralizers,
          order,
          nccl,
          classes,
          orders,
          i, j, k, x,
          powermap,
          characters, map, row, sum,
          tbl_irredinfo;

    flag:= true;
    centralizers:= SizesCentralizers( tbl );
    order:= centralizers[1];
    if HasSize( tbl ) then
      if Size( tbl ) <> order then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): centralizer of identity not equal to group order" );
        flag:= false;
      fi;
    fi;

    nccl:= Length( centralizers );
    if HasSizesConjugacyClasses( tbl ) then
      classes:= SizesConjugacyClasses( tbl );
      if classes <> List( centralizers, x -> order / x ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): centralizers and class lengths inconsistent" );
        flag:= false;
      fi;
      if Length( classes ) <> nccl then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): number of classes and centralizers inconsistent" );
        flag:= false;
      fi;
    else
      classes:= List( centralizers, x -> order / x );
    fi;

    if Sum( classes, 0 ) <> order then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl,
            "): sum of class lengths not equal to group order" );
      flag:= false;
    fi;

    if HasOrdersClassRepresentatives( tbl ) then
      orders:= OrdersClassRepresentatives( tbl );
      if nccl <> Length( orders ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): number of classes and orders inconsistent" );
        flag:= false;
      else
        for i in [ 1 .. nccl ] do
          if centralizers[i] mod orders[i] <> 0 then
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl,
                  "): not all representative orders divide the\n",
                  "#I   corresponding centralizer order" );
            flag:= false;
          fi;
        od;
      fi;
    fi;

    if HasComputedPowerMaps( tbl ) then
      powermap:= ComputedPowerMaps( tbl );
      for map in Set( powermap ) do
        if nccl <> Length( map ) then
          Info( InfoWarning, 1,
                "IsInternallyConsistent(", tbl,
                "): lengths of power maps and classes inconsistent" );
          flag:= false;
        fi;
      od;

      # If the power maps of all prime divisors of the order are stored,
      # check if they are consistent with the representative orders.
      if     IsBound( orders )
         and ForAll( Set( FactorsInt( order ) ), x -> IsBound(powermap[x]) )
         and orders <> ElementOrdersPowerMap( powermap ) then
        flag:= false;
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): representative orders and power maps inconsistent" );
      fi;
    fi;

    # From here on, we check the irreducible characters.
    if flag = false then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl,
            "): corrupted table, no test of orthogonality" );
      return false;
    fi;

    if HasIrr( tbl ) then
      characters:= List( Irr( tbl ), ValuesOfClassFunction );
      for i in [ 1 .. Length( characters ) ] do
        row:= [];
        for j in [ 1 .. Length( characters[i] ) ] do
          row[j]:= GaloisCyc( characters[i][j], -1 ) * classes[j];
        od;
        for j in [ 1 .. i ] do
          sum:= row * characters[j];
          if ( i = j and sum <> order ) or ( i <> j and sum <> 0 ) then
            flag:= false;
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl,
                  "): Scpr( ., X[", i, "], X[", j, "] ) = ",
                  sum / order );
          fi;
        od;
      od;

      if centralizers <> Sum( characters,
                              x -> List( x, y -> y * GaloisCyc(y,-1) ),
                              0 ) then
        flag:= false;
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): centralizer orders inconsistent with irreducibles" );
      fi;

      if HasIrredInfo( tbl ) then

        tbl_irredinfo:= IrredInfo( tbl );

        if IsBound(tbl_irredinfo[1].indicator) then
          for i in [ 2 .. Length( tbl_irredinfo[1].indicator ) ] do
            if IsBound( tbl_irredinfo[1].indicator[i] ) then
              if List( tbl_irredinfo, x -> x.indicator[i] )
                 <> Indicator( tbl, i ) then
                Info( InfoWarning, 1,
                      "IsInternallyConsistent(", tbl,
                      "): ", Ordinal( i ), " indicator not correct" );
                flag:= false;
              fi;
            fi;
          od;
        fi;

      fi;
    fi;

    return flag;
    end );


#############################################################################
##
#F  InverseMap( <paramap> )  . . . . . . . . .  Inverse of a parametrized map
##
##
InstallGlobalFunction( InverseMap, function( paramap )
    local i, inversemap, im;
    inversemap:= [];
    for i in [ 1 .. Length( paramap ) ] do
      if IsList( paramap[i] ) then
        for im in paramap[i] do
          if IsBound( inversemap[ im ] ) then
            AddSet( inversemap[ im ], i );
          else
            inversemap[ im ]:= [ i ];
          fi;
        od;
      else
        if IsBound( inversemap[ paramap[i] ] ) then
          AddSet( inversemap[ paramap[i] ], i );
        else
          inversemap[ paramap[i] ]:= [ i ];
        fi;
      fi;
    od;
    for i in [ 1 .. Length( inversemap ) ] do
      if IsBound( inversemap[i] ) and Length( inversemap[i] ) = 1 then
        inversemap[i]:= inversemap[i][1];
      fi;
    od;
    return inversemap;
end );


#############################################################################
##
#F  NrPolyhedralSubgroups( <tbl>, <c1>, <c2>, <c3>)  . # polyhedral subgroups
##
InstallGlobalFunction( NrPolyhedralSubgroups, function(tbl, c1, c2, c3)
    local orders, res, ord;

    orders:= OrdersClassRepresentatives( tbl );

    if orders[c1] = 2 then
       res:= ClassMultiplicationCoefficient(tbl, c1, c2, c3)
             * SizesConjugacyClasses( tbl )[c3];
       if orders[c2] = 2 then
          if orders[c3] = 2 then   # V4
             ord:= Length(Set([c1, c2, c3]));
             if ord = 2 then
                res:= res * 3;
             elif ord = 3 then
                res:= res * 6;
             fi;
             res:= res / 6;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "V4");
          elif orders[c3] > 2 then   # D2n
             ord:= orders[c3];
             if c1 <> c2 then
                res:= res * 2;
             fi;
             res:= res * Length(ClassOrbitCharTable(tbl,c3))/(ord*Phi(ord));
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res,
                        type:= Concatenation("D" ,String(2*ord)));
          fi;
       elif orders[c2] = 3 then
          if orders[c3] = 3 then   # A4
             res:= res * Length(ClassOrbitCharTable(tbl, c3)) / 24;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "A4");
          elif orders[c3] = 4 then   # S4
             res:= res / 24;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "S4");
          elif orders[c3] = 5 then   # A5
             res:= res * Length(ClassOrbitCharTable(tbl, c3)) / 120;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "A5");
          fi;
       fi;
    fi;
end );


#############################################################################
##
#M  ClassParameters( <tbl> )  . . . . . . . . .  for a nearly character table
##
InstallMethod( ClassParameters,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )
    Error( "no default method to compute class parameters" );
    end );


#############################################################################
##
#M  ClassNames( <tbl> )  . . . . . . . . . . class names of a character table
##
##  'ClassNames' computes names for the classes of the character table <tbl>.
##  Each class name is a string consisting of the order of elements of the
##  class and and least one distinguishing letter.
##
InstallMethod( ClassNames,
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )

    local i,        # loop variable
          alpha,    # alphabet
          lalpha,   # length of the alphabet
          number,   # at position <i> the current number of
                    # classes of order <i>
          unknown,  # number of next unknown element order
          names,    # list of classnames, result
          name,     # local function returning right combination of letters
          orders;   # list of representative orders

    alpha:= [ "a","b","c","d","e","f","g","h","i","j","k","l","m",
              "n","o","p","q","r","s","t","u","v","w","x","y","z" ];
    lalpha:= Length( alpha );

    name:= function(n)
       local name;
       name:= "";
       while 0 < n do
          name:= Concatenation( alpha[ (n-1) mod lalpha + 1 ], name );
          n:= QuoInt( n-1, lalpha );
       od;
       return name;
    end;

    names:= [];

    if HasUnderlyingGroup( tbl ) or HasOrdersClassRepresentatives( tbl ) then

      orders:= OrdersClassRepresentatives( tbl );
      number:= [];
      unknown:= 1;
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        if IsInt( orders[i] ) then
          if not IsBound( number[ orders[i] ] ) then
            number[ orders[i] ]:= 1;
          fi;
          names[i]:= Concatenation( String( orders[i] ),
                                    name( number[ orders[i] ] ) );
          number[ orders[i] ]:= number[ orders[i] ] + 1;
        else
          names[i]:= Concatenation( "?", name( unknown ) );
          unknown:= unknown + 1;
        fi;
      od;

    else

      names[1]:= Concatenation( "1", alpha[1] );
      for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
        names[i]:= Concatenation( "?", name( i-1 ) );
      od;

    fi;

    # return the list of classnames
    return names;
    end );


#############################################################################
##
#M  \.( <tbl>, <name> ) . . . . . . . . . position of a class with given name
##
##  If <name> is a class name of the character table <tbl> as computed by
##  'ClassNames', '<tbl>.<name>' is the position of the class with this name.
##
InstallMethod( \.,
    "for class names of a nearly character table",
    true,
    [ IsNearlyCharacterTable, IsString ], 0,
    function( tbl, name )
    local pos;
    name:= NameRNam( name );
    pos:= Position( ClassNames( tbl ), name );
    if pos = fail then
      TryNextMethod();
    else
      return pos;
    fi;
    end );


#############################################################################
##
#M  DisplayOptions( <tbl> ) . . . . . . . . . .  for a nearly character table
##
InstallMethod( DisplayOptions,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> rec() );


#############################################################################
##
#M  Identifier( <tbl> ) . . . . . . . . . . . .  for a nearly character table
##
InstallMethod( Identifier,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )
    tbl:= Concatenation( "CT#", String( LARGEST_IDENTIFIER_NUMBER ) );
    ConvertToStringRep( tbl );
    MakeReadWriteGlobal( "LARGEST_IDENTIFIER_NUMBER" );
    LARGEST_IDENTIFIER_NUMBER:= LARGEST_IDENTIFIER_NUMBER + 1;
    MakeReadOnlyGlobal( "LARGEST_IDENTIFIER_NUMBER" );
    return tbl;
    end );


#############################################################################
##
#M  InfoText( <tbl> ) . . . . . . . . . . . . .  for a nearly character table
##
InstallMethod( InfoText,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> "" );


#############################################################################
##
#M  InverseClasses( <tbl> ) . . .  method for an ord. table with irreducibles
##
InstallMethod( InverseClasses,
    "for a character table with known irreducibles",
    true,
    [ IsCharacterTable and HasIrr ], 0,
    function( tbl )

    local nccl,
          irreds,
          inv,
          isinverse,
          chi,
          remain,
          i, j;

    nccl:= NrConjugacyClasses( tbl );
    irreds:= Irr( tbl );
    inv:= [ 1 ];

    isinverse:= function( i, j )         # is 'j' the inverse of 'i' ?
    for chi in irreds do
      if not IsRat( chi[i] ) and chi[i] <> GaloisCyc( chi[j], -1 ) then
        return false;
      fi;
    od;
    return true;
    end;

    remain:= [ 2 .. nccl ];
    for i in [ 2 .. nccl ] do
      if i in remain then
        for j in remain do
          if isinverse( i, j ) then
            inv[i]:= j;
            inv[j]:= i;
            SubtractSet( remain, Set( [ i, j ] ) );
            break;
          fi;
        od;
      fi;
    od;
    return inv;
    end );


#############################################################################
##
#M  InverseClasses( <tbl> ) . . . . . . . . . .  method for a character table
##
InstallMethod( InverseClasses,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> PowerMap( tbl, -1 ) );


#############################################################################
##
#M  NamesOfFusionSources( <tbl> ) . . . . . . .  for a nearly character table
##
InstallMethod( NamesOfFusionSources,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> [] );


#############################################################################
##
#M  CharacterTableDirectProduct( <ordtbl1>, <ordtbl2> )
##
InstallMethod( CharacterTableDirectProduct,
    IsIdenticalObj,
    [ IsOrdinaryTable, IsOrdinaryTable ], 0,
    function( tbl1, tbl2 )

    local direct,        # table of the direct product, result
          ncc1,          # no. of classes in 'tbl1'
          ncc2,          # no. of classes in 'tbl2'
          i, j, k,       # loop variables
          vals1,         # list of 'tbl1'
          vals2,         # list of 'tbl2'
          vals_direct,   # corresponding list of the result
          powermap_k,    # 'k'-th power map
          ncc2_i,        #
          fus;           # projection/embedding map

    direct:= ConvertToLibraryCharacterTableNC(
                 rec( UnderlyingCharacteristic := 0 ) );
    SetSize( direct, Size( tbl1 ) * Size( tbl2 ) );
    SetIdentifier( direct, Concatenation( Identifier( tbl1 ), "x",
                                          Identifier( tbl2 ) ) );
    SetSizesCentralizers( direct,
                      KroneckerProduct( [ SizesCentralizers( tbl1 ) ],
                                        [ SizesCentralizers( tbl2 ) ] )[1] );

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Compute class parameters, if present in both tables.
    if HasClassParameters( tbl1 ) and HasClassParameters( tbl2 ) then

      vals1:= ClassParameters( tbl1 );
      vals2:= ClassParameters( tbl2 );
      vals_direct:= [];
      for i in [ 1 .. ncc1 ] do
        for j in [ 1 .. ncc2 ] do
          vals_direct[ j + ncc2 * ( i - 1 ) ]:= [ vals1[i], vals2[j] ];
        od;
      od;
      SetClassParameters( direct, vals_direct );

    fi;

    # Compute element orders.
    vals1:= OrdersClassRepresentatives( tbl1 );
    vals2:= OrdersClassRepresentatives( tbl2 );
    vals_direct:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do
        vals_direct[ j + ncc2 * ( i - 1 ) ]:= Lcm( vals1[i], vals2[j] );
      od;
    od;
    SetOrdersClassRepresentatives( direct, vals_direct );

    # Compute power maps for all prime divisors of the result order.
    vals_direct:= ComputedPowerMaps( direct );
    for k in Union( FactorsInt( Size( tbl1 ) ),
                    FactorsInt( Size( tbl2 ) ) ) do
      powermap_k:= [];
      vals1:= PowerMap( tbl1, k );
      vals2:= PowerMap( tbl2, k );
      for i in [ 1 .. ncc1 ] do
        ncc2_i:= ncc2 * (i-1);
        for j in [ 1 .. ncc2 ] do
          powermap_k[ j + ncc2_i ]:= vals2[j] + ncc2 * ( vals1[i] - 1 );
        od;
      od;
      vals_direct[k]:= powermap_k;
    od;

    # Compute the irreducibles.
    SetIrr( direct, List( KroneckerProduct(
                                List( Irr( tbl1 ), ValuesOfClassFunction ),
                                List( Irr( tbl2 ), ValuesOfClassFunction ) ),
                          vals -> CharacterByValues( direct, vals ) ) );

    # Form character parameters if they exist for the irreducibles
    # in both tables.
    if HasIrredInfo( tbl1 ) and HasIrredInfo( tbl2 ) then
      vals1:= IrredInfo( tbl1 );
      vals2:= IrredInfo( tbl2 );
      if     IsBound( vals1[1].charparam )
         and IsBound( vals2[1].charparam ) then
        vals_direct:= IrredInfo( direct );
        for i in [ 1 .. ncc1 ] do
          for j in [ 1 .. ncc2 ] do
            vals_direct[ j + ncc2 * ( i - 1 ) ].charparam:=
                                [ vals1[i].charparam, vals2[j].charparam ];
          od;
        od;
      fi;
    fi;

    # Store projections.
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( direct,
                 rec( map := fus, specification := "1" ),
                 tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( direct,
                 rec( map := fus, specification := "2" ),
                 tbl2 );

    # Store embeddings.
    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 direct );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 direct );

    # Return the table of the direct product.
    return direct;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <modtbl>, <ordtbl> )
##
InstallMethod( CharacterTableDirectProduct,
    "for one Brauer and one ordinary character table",
    IsIdenticalObj,
    [ IsBrauerTable, IsOrdinaryTable ], 0,
    function( tbl1, tbl2 )

    local ncc1,     # no. of classes in 'tbl1'
          ncc2,     # no. of classes in 'tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if Size( tbl2 ) mod UnderlyingCharacteristic( tbl1 ) <> 0 then
      Error( "no direct product of Brauer table and p-singular ordinary" );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( OrdinaryCharacterTable(tbl1), tbl2 );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl1 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> CharacterByValues( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, fus, tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, fus, tbl2 );

    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 reg );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 reg );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <ordtbl>, <modtbl> )
##
InstallMethod( CharacterTableDirectProduct,
    "for one ordinary and one Brauer character table",
    IsIdenticalObj,
    [ IsOrdinaryTable, IsBrauerTable ], 0,
    function( tbl1, tbl2 )

    local ncc1,     # no. of classes in 'tbl1'
          ncc2,     # no. of classes in 'tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if Size( tbl1 ) mod UnderlyingCharacteristic( tbl2 ) <> 0 then
      Error( "no direct product of Brauer table and p-singular ordinary" );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( tbl1, OrdinaryCharacterTable(tbl2) );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl2 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> CharacterByValues( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, fus, tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, fus, tbl2 );

    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 reg );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 reg );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <modtbl1>, <modtbl2> )
##
InstallMethod( CharacterTableDirectProduct,
    "for two Brauer character tables",
    IsIdenticalObj,
    [ IsBrauerTable, IsBrauerTable ], 0,
    function( tbl1, tbl2 )

    local ncc1,     # no. of classes in 'tbl1'
          ncc2,     # no. of classes in 'tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if    UnderlyingCharacteristic( tbl1 )
       <> UnderlyingCharacteristic( tbl2 ) then
      Error( "no direct product of Brauer tables in different char." );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( OrdinaryCharacterTable( tbl1 ),
                                       OrdinaryCharacterTable( tbl2 ) );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl1 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> CharacterByValues( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, fus, tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, fus, tbl2 );

    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 reg );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 reg );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  \*( <tbl1>, <tbl2> )  . . . . . . . . . . . . .  direct product of tables
##
InstallOtherMethod( \*,
    "for two nearly character tables",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ], 0,
    CharacterTableDirectProduct );


#############################################################################
##
#M  CharacterTableFactorGroup( <tbl>, <classes> )
##
InstallMethod( CharacterTableFactorGroup,
    "for an ordinary table, and a list of class positions",
    true,
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection ], 0,
    function( tbl, classes )

    local F,              # table of the factor group, result
          N,              # classes of the normal subgroup
          chi,            # loop over irreducibles
          ker,            # kernel of a 'chi'
          size,           # size of 'tbl'
          tclasses,       # class lengths of 'tbl'
          suborder,       # order of the normal subgroup
          factirr,        # irreducibles of 'F'
          factorfusion,   # fusion from 'tbl' to 'F'
          nccf,           # no. of classes of 'F'
          cents,          # centralizer orders of 'F'
          i,              # loop over the classes
          inverse,        # inverse of 'factorfusion'
          p;              # loop over prime divisors

    factirr:= [];
    N:= [ 1 .. NrConjugacyClasses( tbl ) ];
    for chi in Irr( tbl ) do
      ker:= KernelChar( chi );
      if IsEmpty( Difference( classes, ker ) ) then
        IntersectSet( N, ker );
        Add( factirr, ValuesOfClassFunction( chi ) );
      fi;
    od;

    # Compute the order of the normal subgroup corresponding to `N'.
    size:= Size( tbl );
    tclasses:= SizesConjugacyClasses( tbl );
    suborder:= Sum( tclasses{ N }, 0 );
    if size mod suborder <> 0 then
      Error( "intersection of kernels of irreducibles containing\n",
             "<classes> has an order not dividing the size of <tbl>" );
    fi;

    # Compute the irreducibles of the factor.
    factirr:= CollapsedMat( factirr, [] );
    factorfusion := factirr.fusion;
    factirr      := factirr.mat;

    # Compute the centralizer orders of the factor group.
    # \[ |C_{G/N}(gN)\| = \frac{|G|/|N|}{|Cl_{G/N}(gN)|}
    #    = \frac{|G|:|N|}{\frac{1}{|N|}\sum_{x fus gN} |Cl_G(x)|}
    #    = \frac{|G|}{\sum_{x fus gN} |Cl_G(x)| \]
    nccf:= Length( factirr[1] );
    cents:= [];
    for i in [ 1 .. nccf ] do
      cents[i]:= 0;
    od;
    for i in [ 1 .. Length( factorfusion ) ] do
      cents[ factorfusion[i] ]:= cents[ factorfusion[i] ] + tclasses[i];
    od;
    for i in [ 1 .. nccf ] do
      cents[i]:= size / cents[i];
    od;
    if not ForAll( cents, IsInt ) then
      Error( "not all centralizer orders of the factor are well-defined" );
    fi;

    F:= Concatenation( Identifier( tbl ), "/", String( N ) );
    ConvertToStringRep( F );
    F:= rec(
             UnderlyingCharacteristic := 0,
             Size                     := size / suborder,
             Identifier               := F,
             Irr                      := factirr,
             SizesCentralizers        := cents
            );

    # Transfer necessary power maps of `tbl' to `F'.
    inverse:= ProjectionMap( factorfusion );
    F.ComputedPowerMaps:= [];
    for p in Set( Factors( F.Size ) ) do
      F.ComputedPowerMaps[p]:= factorfusion{ PowerMap( tbl, p ){ inverse } };
    od;

    # Convert the record into a library table.
    ConvertToLibraryCharacterTableNC( F );

    # Store the factor fusion on `tbl'.
    StoreFusion( tbl, rec( map:= factorfusion, type:= "factor" ), F );

    # Return the result.
    return F;
    end );


#############################################################################
##
#M  \/( <tbl>, <list> )  . . . . . . . . .  character table of a factor group
##
InstallOtherMethod( \/,
    "for character table and list of class positions",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection ], 0,
    CharacterTableFactorGroup );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl> ) . . . . . . . . for an ordinary table
##
InstallMethod( CharacterTableIsoclinic,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )
    local classes, half, kernel;

    # Identify the unique normal subgroup of index 2.
    half:= Size( tbl ) / 2;
    classes:= SizesConjugacyClasses( tbl );
    kernel:= Filtered( List( Filtered( Irr( tbl ),
                                       chi -> DegreeOfCharacter( chi ) = 1 ),
                             KernelChar ),
                       ker -> Sum( classes{ ker }, 0 ) = half );
    if IsEmpty( kernel ) or 1 < Length( kernel ) then
      Error( "normal subgroup of index 2 not uniquely determined,\n",
             "use CharTableIsoclinic( <tbl>, <classes_of_nsg> )" );
    fi;

    # Delegate to the two-argument version.
    return CharacterTableIsoclinic( tbl, kernel[1] );
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl>, <nsg> )
##
InstallMethod( CharacterTableIsoclinic,
    "for an ordinary character table, and a list of classes",
    true,
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection ], 0,
    function( tbl, nsg )

    local classes, orders, centre;

    # Get the unique central subgroup of order 2 in the normal subgroup.
    classes:= SizesConjugacyClasses( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    centre:= Filtered( nsg, x -> classes[x] = 1 and orders[x] = 2 );
    if Length( centre ) <> 1 then
      Error( "central subgroup of order 2 must be unique" );
    fi;

    # Delegate to the three-argument version.
    return CharacterTableIsoclinic( tbl, nsg, centre[1] );
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl>, <nsg>, <centerpos> )
##
InstallMethod( CharacterTableIsoclinic,
    "for an ordinary character table, a list of classes, and a class pos.",
    true,
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection, IsPosInt ], 0,
    function( tbl, nsg, center )
    local centralizers,    # attribute of 'tbl'
          classes,         # attribute of 'tbl'
          orders,          # attribute of 'tbl'
          size,            # attribute of 'tbl'
          i,               # 'E(4)'
          j,               # loop variable
          chi,             # one character
          values,          # values of 'chi'
          class,
          map,
          linear,          # linear characters of 'tbl'
          isoclinic,       # the isoclinic table, result
          outer,           # classes outside the index 2 subgroup
          nonfaith,        # characters of the factor group modulo 'center'
          irreds,          # characters of 'isoclinic'
          images,
          factorfusion,    # fusion onto factor modulo the central inv.
          p,               # loop over prime divisors of the size of 'tbl'
          reg;             # restriction to regular classes

    centralizers:= SizesCentralizers( tbl );
    classes:= SizesConjugacyClasses( tbl );
    orders:= ShallowCopy( OrdersClassRepresentatives( tbl ) );
    size:= Size( tbl );

    # Check `nsg'.
    if Sum( classes{ nsg }, 0 ) <> size / 2 then
      Error( "normal subgroup described by <nsg> must have index 2" );
    fi;

    # Check `center'.
    if not center in nsg then
      Error( "<center> must lie in <nsg>" );
    fi;

    # Make the isoclinic table.
    isoclinic:= Concatenation( "Isoclinic(", Identifier( tbl ), ")" );
    ConvertToStringRep( isoclinic );

    isoclinic:= rec(
        UnderlyingCharacteristic   := 0,
        Identifier                 := isoclinic,
        Size                       := size,
        SizesCentralizers          := centralizers,
        SizesConjugacyClasses      := classes,
        OrdersClassRepresentatives := orders,
        ComputedPowerMaps          := []             );

    # classes outside the normal subgroup
    outer:= Difference( [ 1 .. Length( classes ) ], nsg );

    # Adjust faithful characters in outer classes.
    nonfaith:= [];
    irreds:= [];
    i:= E(4);
    for chi in Irr( tbl ) do
      values:= ValuesOfClassFunction( chi );
      if values[ center ] = values[1] then
        Add( nonfaith, values );
      else
        values:= ShallowCopy( values );
        for class in outer do
          values[ class ]:= i * values[ class ];
        od;
      fi;
      Add( irreds, values );
    od;
    isoclinic.Irr:= irreds;

    # Get the fusion map onto the factor group modulo '[ 1, center ]'.
    factorfusion:= CollapsedMat( nonfaith, [] ).fusion;

    # Adjust the power maps.
    for p in Set( Factors( isoclinic.Size ) ) do

      map:= PowerMap( tbl, p );

      # For p mod 4 in $\{ 0, 1 \}$, the map remains unchanged,
      # since $g^p = h$ and $(gi)^p = hi^p = hi$ then.
      if p mod 4 = 2 then

        # The squares lie in 'nsg'; for $g^2 = h$,
        # we have $(gi)^2 = hz$, so we must take the other
        # preimage under the factorfusion, if exists.
        map:= ShallowCopy( map );
        for class in outer do
          images:= Filtered( Difference( nsg, [ map[class] ] ),
              x -> factorfusion[x] = factorfusion[ map[ class ] ] );
          if Length( images ) = 1 then
            map[ class ]:= images[1];
            orders[ class ]:= 2 * orders[ images[1] ];
          fi;
        od;

      elif p mod 4 = 3 then

        # For $g^p = h$, we have $(gi)^p = hi^p = hiz$, so again
        # we must choose the other preimage under the
        # factorfusion, if exists; the 'p'-th powers lie outside
        # 'nsg' in this case.
        map:= ShallowCopy( map );
        for class in outer do
          images:= Filtered( Difference( outer, [ map[ class ] ] ),
              x -> factorfusion[x] = factorfusion[ map[ class ] ] );
          if Length( images ) = 1 then
            map[ class ]:= images[1];
          fi;
        od;

      fi;

      isoclinic.ComputedPowerMaps[p]:= map;

    od;

    # Convert the record into a library table.
    ConvertToLibraryCharacterTableNC( isoclinic );

    # Return the result.
    return isoclinic;
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <modtbl> ) . . . . . . . . .  for a Brauer table
##
##  For the isoclinic table of a Brauer table,
##  we transfer the normal subgroup information to the regular classes,
##  and adjust the irreducibles.
##
InstallMethod( CharacterTableIsoclinic,
    "for a Brauer table",
    true,
    [ IsBrauerTable ], 0,
    function( tbl )

    local isoclinic,
          reg,
          factorfusion,
          center,
          outer,
          irreducibles,
          i,
          chi,
          values,
          class;

    isoclinic:= CharacterTableIsoclinic( OrdinaryCharacterTable( tbl ) );
    reg:= CharacterTableRegular( isoclinic, Characteristic( tbl ) );
    factorfusion:= GetFusionMap( reg, isoclinic );
    center:= Position( factorfusion, center );
    outer:= Filtered( [ 1 .. NrConjugacyClasses( reg ) ],
                      x -> factorfusion[x] in outer );

    # Compute the irreducibles as for the ordinary isoclinic table.
    irreducibles:= [];
    i:= E(4);
    for chi in Irr( tbl ) do
      values:= ValuesOfClassFunction( chi );
      if values[ center ] <> values[1] then
        values:= ShallowCopy( values );
        for class in outer do
          values[ class ]:= i * values[ class ];
        od;
      fi;
      Add( irreducibles, values );
    od;
    SetIrr( reg, List( irreducibles,
                       vals -> CharacterByValues( reg, vals ) ) );

    # Return the result.
    return reg;
    end );


#############################################################################
##
#F  CharacterTableOfNormalSubgroup( <tbl>, <classes> )
##
InstallGlobalFunction( CharacterTableOfNormalSubgroup, function( tbl, classes )

    local sizesclasses,   # class lengths of the result
          size,           # size of the result
          nccl,           # no. of classes
          orders,         # repr. orders of the result
          centralizers,   # centralizer orders of the result
          result,         # result table
          err,            # list of classes that must split
          inverse,        # inverse map of `classes'
          p,              # loop over primes
          irreducibles,   # list of irred. characters
          chi,            # loop over irreducibles of `tbl'
          char;           # one character values list for `result'

    if not IsOrdinaryTable( tbl ) then
      Error( "<tbl> must be an ordinary character table" );
    fi;

    sizesclasses:= SizesConjugacyClasses( tbl ){ classes };
    size:= Sum( sizesclasses );

    if Size( tbl ) mod size <> 0 then
      Error( "<classes> is not a normal subgroup" );
    fi;

    nccl:= Length( classes );
    orders:= OrdersClassRepresentatives( tbl ){ classes };
    centralizers:= List( sizesclasses, x -> size / x );

    result:= Concatenation( "Rest(", Identifier( tbl ), ",",
                            String( classes ), ")" );
    ConvertToStringRep( result );

    result:= rec(
        UnderlyingCharacteristic   := 0,
        Identifier                 := result,
        Size                       := size,
        SizesCentralizers          := centralizers,
        SizesConjugacyClasses      := sizesclasses,
        OrdersClassRepresentatives := orders,
        ComputedPowerMaps          := []             );

    err:= Filtered( [ 1 .. nccl ],
                    x-> centralizers[x] mod orders[x] <> 0 );
    if not IsEmpty( err ) then
      Info( InfoCharacterTable, 2,
            "CharacterTableOfNormalSubgroup: classes in " , err,
            " necessarily split" );
    fi;
    inverse:= InverseMap( classes );

    for p in [ 1 .. Length( ComputedPowerMaps( tbl ) ) ] do
      if IsBound( ComputedPowerMaps( tbl )[p] ) then
        result.ComputedPowerMaps[p]:=
            CompositionMaps( inverse,
                CompositionMaps( ComputedPowerMaps( tbl )[p], classes ) );
      fi;
    od;

    # Compute the irreducibles if known.
    irreducibles:= [];
    if HasIrr( tbl ) then

      for chi in Irr( tbl ) do
        char:= ValuesOfClassFunction( chi ){ classes };
        if     Sum( [ 1 .. nccl ],
                  i -> sizesclasses[i] * char[i] * GaloisCyc(char[i],-1), 0 )
               = size
           and not char in irreducibles then
          Add( irreducibles, char );
        fi;
      od;

    fi;

    if Length( irreducibles ) = nccl then

      result.Irr:= irreducibles;

      # Convert the record into a library table.
      ConvertToLibraryCharacterTableNC( result );

    else

      p:= Size( tbl ) / size;
      if IsPrimeInt( p ) and not IsEmpty( irreducibles ) then
        Info( InfoCharacterTable, 2,
              "CharacterTableOfNormalSubgroup: The table must have ",
              p * NrConjugacyClasses( tbl ) -
              ( p^2 - 1 ) * Length( irreducibles ), " classes\n",
              "#I   (now ", Length( classes ), ", after nec. splitting ",
              Length( classes ) + (p-1) * Length( err ), ")" );
      fi;

      Error( "tables in progress not yet supported" );
#T !!

    fi;

    # Store the fusion into 'tbl'.
    StoreFusion( result, classes, tbl );

    # Return the result.
    return result;
end );


#############################################################################
##
#F  CharacterTableQuaternionic( <4n> )
##
InstallGlobalFunction( CharacterTableQuaternionic, function( 4n )

    local quaternionic;

    if 4n mod 4 <> 0 then
      Error( "argument must be a multiple of 4" );
    elif 4n = 4 then
      quaternionic:= CharacterTable( "Cyclic", 4 );
    else
      quaternionic:= CharacterTableIsoclinic(
                         CharacterTable( "Dihedral", 4n ),
                         [ 1 .. 4n / 4 + 1 ] );
    fi;
    SetIdentifier( quaternionic, Concatenation( "Q", String( 4n ) ) );
#T not allowed ...
    return quaternionic;
end );


#############################################################################
##
#F  CharacterTableRegular( <ordtbl>, <p> )  . restriction to <p>-reg. classes
##
InstallGlobalFunction( CharacterTableRegular,
    function( ordtbl, prime )

    local fusion,
          inverse,
          orders,
          i,
          regular,
          power;

    if not IsPrimeInt( prime ) then
      Error( "<prime> must be a prime" );
    elif IsBrauerTable( ordtbl ) then
      Error( "<ordtbl> is already a Brauer table" );
    fi;

    fusion:= [];
    inverse:= [];
    orders:= OrdersClassRepresentatives( ordtbl );
    for i in [ 1 .. Length( orders ) ] do
      if orders[i] mod prime <> 0 then
        Add( fusion, i );
        inverse[i]:= Length( fusion );
      fi;
    od;

    regular:= rec(
       Identifier                 := Concatenation( Identifier( ordtbl ),
                                         "mod", String( prime ) ),
       UnderlyingCharacteristic   := prime,
       Size                       := Size( ordtbl ),
       OrdersClassRepresentatives := orders{ fusion },
       SizesCentralizers          := SizesCentralizers( ordtbl ){ fusion },
       ComputedPowerMaps          := [],
       OrdinaryCharacterTable     := ordtbl
      );

    power:= ComputedPowerMaps( ordtbl );
    for i in [ 1 .. Length( power ) ] do
      if IsBound( power[i] ) then
        regular.ComputedPowerMaps[i]:= inverse{ power[i]{ fusion } };
      fi;
    od;

    regular:= ConvertToBrauerTableNC( regular );
    StoreFusion( regular, rec( map:= fusion, type:= "choice" ), ordtbl );

    return regular;
    end );


#############################################################################
##
#M  PrintObj( <tbl> ) . . . . . . . . . . . . . . . . . for a character table
##
InstallMethod( PrintObj,
    "for an ordinary table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )
    if HasUnderlyingGroup( tbl ) then
      Print( "CharacterTable( ", UnderlyingGroup( tbl ), " )" );
    else
      Print( "CharacterTable( \"", Identifier( tbl ), "\" )" );
    fi;
    end );

InstallMethod( PrintObj,
    "for a Brauer table",
    true,
    [ IsBrauerTable ], 0,
    function( tbl )
    if HasUnderlyingGroup( tbl ) then
      Print( "BrauerTable( ", UnderlyingGroup( tbl ), ", ",
             UnderlyingCharacteristic( tbl ), " )" );
    else
      Print( "BrauerTable( \"", Identifier( OrdinaryCharacterTable( tbl ) ),
             "\", ", UnderlyingCharacteristic( tbl ), " )" );
    fi;
    end );


#############################################################################
##
#M  ViewObj( <tbl> )  . . . . . . . . . . . . . . . . . for a character table
##
InstallMethod( ViewObj,
    "for an ordinary table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )
    Print( "CharacterTable( " );
    if HasUnderlyingGroup( tbl ) then
      View( UnderlyingGroup( tbl ) );
    else
      View( Identifier( tbl ) );
    fi;
    Print(  " )" );
    end );

InstallMethod( ViewObj,
    "for a Brauer table",
    true,
    [ IsBrauerTable ], 0,
    function( tbl )
    Print( "BrauerTable( " );
    if HasUnderlyingGroup( tbl ) then
      View( UnderlyingGroup( tbl ) );
    else
      View( Identifier( OrdinaryCharacterTable( tbl ) ) );
    fi;
    Print( ", ", UnderlyingCharacteristic( tbl ), " )" );
    end );


#############################################################################
##
#M  AutomorphismsOfTable( <tbl> ) . . . . . . . . . . . for a character table
##
InstallMethod( AutomorphismsOfTable,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> TableAutomorphisms( tbl, Irr( tbl ) ) );


#############################################################################
##
#M  AutomorphismsOfTable( <modtbl> )  . . . for Brauer table & good reduction
##
InstallMethod( AutomorphismsOfTable,
    "for a Brauer table in the case of good reduction",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    if Size( modtbl ) mod UnderlyingCharacteristic( modtbl ) = 0 then
      TryNextMethod();
    else
      return AutomorphismsOfTable( OrdinaryCharacterTable( modtbl ) );
    fi;
    end );


#############################################################################
##
#M  Indicator( <tbl>, <n> )
#M  Indicator( <tbl>, <characters>, <n> )
#M  Indicator( <modtbl>, 2 )
##
InstallMethod( Indicator,
    "for an ordinary character table and a positive integer",
    true,
    [ IsOrdinaryTable, IsPosInt ], 0,
    function( tbl, n )

    local indicator,
          irredinfo,
          i;

    # Compute the indicator.
    indicator:= Indicator( tbl, Irr( tbl ), n );

    # Write the indicator to the table.
    irredinfo:= IrredInfo( tbl );
    for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
      irredinfo[i].indicator[n]:= indicator[i];
    od;
    Info( InfoCharacterTable, 2,
          "Indicator: ", Ordinal( n ), " indicator written to the table" );

    # Return the indicator.
    return indicator;
    end );

InstallOtherMethod( Indicator,
    "for an ord. character table, a hom. list, and a pos. integer",
    true,
    [ IsOrdinaryTable, IsHomogeneousList, IsPosInt ], 0,
    function( tbl, characters, n )

    local principal, map;

    principal:= List( [ 1 .. NrConjugacyClasses( tbl ) ], x -> 1 );
    map:= PowerMap( tbl, n );
    return List( characters,
                 chi -> ScalarProduct( tbl, chi{ map }, principal ) );
    end );

InstallMethod( Indicator,
    "for a Brauer character table and <n> = 2",
    true,
    [ IsBrauerTable, IsPosInt ], 0,
    function( modtbl, n )

    local ordtbl,
          irr,
          ibr,
          ordindicator,
          fus,
          indicator,
          i,
          j,
          odd;

    if n <> 2 then
      Error( "for Brauer table <modtbl> only for <n> = 2" );
    elif Characteristic( modtbl ) = 2 then
      Error( "for Brauer table <modtbl> only in odd characteristic" );
    fi;

    ordtbl:= OrdinaryCharacterTable( modtbl );
    irr:= Irr( ordtbl );
    ibr:= Irr( modtbl );
    ordindicator:= Indicator( ordtbl, irr, 2 );
    fus:= GetFusionMap( modtbl, ordtbl );

    # compute indicators block by block
    indicator:= [];

    for i in BlocksInfo( modtbl ) do
      if not IsBound( i.decmat ) then
        i.decmat:= Decomposition( ibr{ i.modchars },
                         List( irr{ i.ordchars },
                               x -> x{ fus } ), "nonnegative" );
      fi;
      for j in [ 1 .. Length( i.modchars ) ] do
        if ForAny( ibr[ i.modchars[j] ],
                   x -> not IsInt(x) and GaloisCyc(x,-1) <> x ) then

          # indicator of a Brauer character is 0 iff it has
          # at least one nonreal value
          indicator[ i.modchars[j] ]:= 0;

        else

          # indicator is equal to the indicator of any real ordinary
          # character containing it as constituent, with odd multiplicity
          odd:= Filtered( [ 1 .. Length( i.decmat ) ],
                          x -> i.decmat[x][j] mod 2 <> 0 );
          odd:= List( odd, x -> ordindicator[ i.ordchars[x] ] );
          indicator[ i.modchars[j] ]:= First( odd, x -> x <> 0 );

        fi;
      od;
    od;

    return indicator;
    end );


#############################################################################
##
#M  InducedCyclic( <tbl> )
#M  InducedCyclic( <tbl>, \"all\" )
#M  InducedCyclic( <tbl>, <classes> )
#M  InducedCyclic( <tbl>, <classes>, \"all\" )
##
InstallMethod( InducedCyclic,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl ->InducedCyclic( tbl, [ 1 .. NrConjugacyClasses( tbl ) ] ) );

InstallOtherMethod( InducedCyclic,
    "for a character table and a string",
    true,
    [ IsCharacterTable, IsString ],
    # The `string' should overrule over the `homogeneous list' installed in
    # the next method
    1,
    function( tbl, all )
    return InducedCyclic( tbl, [ 1 .. NrConjugacyClasses( tbl ) ], all );
    end );

InstallOtherMethod( InducedCyclic,
    "for a character table and a hom. list",
    true,
    [ IsCharacterTable, IsHomogeneousList ], 0,
    function( tbl, classes )

    local centralizers,
          orders,
          independent,
          inducedcyclic,
          i,
          fusion,
          j,
          single;

    centralizers:= SizesCentralizers( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    independent:= List( orders, x -> true );
    inducedcyclic:= [];
    for i in classes do                         # induce from i-th class
      if independent[i] then
        fusion:= [ i ];
        for j in [ 2 .. orders[i] ] do
          fusion[j]:= PowerMap( tbl, j, i );    # j-th powermap at class i
        od;
	single:= ListWithIdenticalEntries(Length(orders),0);
        for j in fusion do
          if orders[j] = orders[i] then
            # position is Galois conjugate to 'i'
            independent[j]:= false;
          fi;
          single[j]:= single[j] + 1;
        od;
        for j in [ 1 .. Length( orders ) ] do
          single[j]:= single[j] * centralizers[j] / orders[i];
          if not IsInt( single[j] ) then
            single[j]:= Unknown();
            Info( InfoCharacterTable, 1,
                  "InducedCyclic: subgroup order not dividing sum",
                  " (induce from class ", i, ")" );
          fi;
        od;
        AddSet( inducedcyclic, single );
      fi;
    od;
    return inducedcyclic;
    end );

InstallOtherMethod( InducedCyclic,
    "for a character table, a hom. list, and a string",
    true,
    [ IsCharacterTable, IsHomogeneousList, IsString ], 0,
    function( tbl, classes, all )

    local centralizers,
          orders,
          independent,
          inducedcyclic,
          i,
          fusion,
          j,
          k,
          single;

    if all <> "all" then
      Error( "<all> must be the string \"all\"" );
    fi;

    centralizers:= SizesCentralizers( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    independent:= List( orders, x -> true );
    inducedcyclic:= [];
    for i in classes do                         # induce from i-th class
      if independent[i] then
        fusion:= [ i ];
        for j in [ 2 .. orders[i] ] do
          fusion[j]:= PowerMap( tbl, j, i );    # j-th powermap at class i
        od;

        for k in [ 0 .. orders[i] - 1 ] do      # induce k-th character
	  single:= ListWithIdenticalEntries(Length(orders),0);
          single[i]:= E( orders[i] ) ^ ( k );
          for j in [ 2 .. orders[i] ] do
            if orders[ fusion[j] ] = orders[i] then

              # position is Galois conjugate
              independent[ fusion[j] ]:= false;
            fi;
            single[ fusion[j] ]:=
                single[ fusion[j] ] + E( orders[i] )^( k*j mod orders[i] );
          od;
          for j in [ 1 .. Length( orders ) ] do
            single[j]:= single[j] * centralizers[j] / orders[i];
            if not IsCycInt( single[j] ) then
              single[j]:= Unknown();
              Info( InfoCharacterTable, 1,
                    "InducedCyclic: subgroup order not dividing sum",
                    " (induce from class ", i, ")" );
            fi;
          od;
          AddSet( inducedcyclic, single );
        od;
      fi;
    od;
    return inducedcyclic;
    end );
#T missing: methods for 'IsCharacterTableInProgress'!!
#T (and for Brauer tables)


#############################################################################
##
#F  GetFusionMap( <source>, <destin> )
#F  GetFusionMap( <source>, <destin>, <specification> )
##
InstallGlobalFunction( GetFusionMap, function( arg )

    local source,
          destin,
          specification,
          name,
          fus,
          ordsource,
          orddestin;

    # Check the arguments.
    if not ( 2 <= Length( arg ) and IsNearlyCharacterTable( arg[1] )
                                and IsNearlyCharacterTable( arg[2] ) ) then
      Error( "first two arguments must be nearly character tables" );
    elif 3 < Length( arg ) then
      Error( "usage: GetFusionMap( <source>, <destin>[, <specification>" );
    fi;

    source := arg[1];
    destin := arg[2];

    if Length( arg ) = 3 then
      specification:= arg[3];
    fi;

    # First check whether 'source' knows a fusion to 'destin' .
    name:= Identifier( destin );
    for fus in ComputedClassFusions( source ) do
      if fus.name = name then
        if IsBound( specification ) then
          if     IsBound( fus.specification )
             and fus.specification = specification then
            if HasClassPermutation( destin ) then
              return OnTuples( fus.map, ClassPermutation( destin ) );
            else
              return ShallowCopy( fus.map );
            fi;
          fi;
        else
          if IsBound( fus.specification ) then
            Info( InfoCharacterTable, 1,
                  "GetFusionMap: Used fusion has specification ",
                  fus.specification );
          fi;
          if HasClassPermutation( destin ) then
            return OnTuples( fus.map, ClassPermutation( destin ) );
          else
            return ShallowCopy( fus.map );
          fi;
        fi;
      fi;
    od;

    # Now check whether the tables are Brauer tables
    # whose ordinary tables know more.
    # (If 'destin' is the ordinary table of 'source' then
    # the fusion has been found already.)
    # Note that 'specification' makes no sense here.
    if IsBrauerTable( source ) and IsBrauerTable( destin ) then
      ordsource:= OrdinaryCharacterTable( source );
      orddestin:= OrdinaryCharacterTable( destin );
      fus:= GetFusionMap( ordsource, orddestin );
      if fus <> fail then
        fus:= InverseMap( GetFusionMap( destin, orddestin ) ){ fus{
                              GetFusionMap( source, ordsource ) } };
        StoreFusion( source, fus, destin );
        return fus;
      fi;
    fi;

    # No fusion map was found.
    return fail;
end );


#############################################################################
##
#F  StoreFusion( <source>, <fusion>, <destination> )
#F  StoreFusion( <source>, <fusionmap>, <destination> )
##
InstallGlobalFunction( StoreFusion, function( source, fusion, destination )

    local fus;

    # (compatibility with {\GAP}~3)
    if IsList( destination ) or IsRecord( destination ) then
      StoreFusion( source, destination, fusion );
      return;
    fi;

    # Check the arguments.
    if not ( IsList(fusion) or ( IsRecord(fusion) and IsBound(fusion.map) ) )
       then
      Error( "<fusion> must be a list or a record containing at least",
             " <fusion>.map" );
    elif   IsRecord( fusion ) and IsBound( fusion.name )
       and fusion.name <> Identifier( destination ) then
      Error( "identifier of <destination> must be equal to <fusion>.name" );
    fi;

    if IsList( fusion ) then
      fusion:= rec( name := Identifier( destination ),
                    map  := Immutable( fusion ) );
    else
      fusion      := ShallowCopy( fusion );
      fusion.map  := Immutable( fusion.map );
      fusion.name := Identifier( destination );
    fi;

    # Adjust the map to the stored permutation.
    if HasClassPermutation( destination ) then
      fusion.map:= OnTuples( fusion.map,
                             Inverse( ClassPermutation( destination ) ) );
      MakeImmutable( fusion.map );
    fi;

    # Check that different stored fusions into the same table
    # have different specifications.
    for fus in ComputedClassFusions( source ) do
      if fus.name = fusion.name then

        # Do nothing if a known fusion is to be stored.
        if fus.map = fusion.map then
          return;
        fi;

        # Signal an error if two different fusions to the same
        # destination are to be stored, without distinguishing them.
        if    not IsBound( fusion.specification )
           or (     IsBound( fus.specification )
                and fusion.specification = fus.specification ) then

          Error( "fusion to <destination> already stored on <source>;\n",
             " to store another one, assign different specifications",
             " to both fusions" );

        fi;

      fi;
    od;

    # The fusion is new, add it.
    Add( ComputedClassFusions( source ), Immutable( fusion ) );
    Add( NamesOfFusionSources( destination ), Identifier( source ) );
end );


#############################################################################
##
#F  FusionConjugacyClasses( <tbl1>, <tbl2> )  . . . . .  for character tables
#F  FusionConjugacyClasses( <H>, <G> )  . . . . . . . . . . . . .  for groups
#F  FusionConjugacyClasses( <hom> ) . . . . . . . .  for a group homomorphism
##
##  We do not store class fusions in groups,
##  the groups delegate to their ordinary character tables.
##
InstallGlobalFunction( FusionConjugacyClasses, function( arg )

    local tbl1, tbl2, hom, fus;

    if Length( arg ) = 1 then

      # The argument is (expected to be) a group homomorphism.
      return FusionConjugacyClassesOp( arg[1] );

    elif Length( arg ) = 2 then

      # Groups delegate to their ordinary tables.
      if IsGroup( arg[1] ) and IsGroup( arg[2] ) then
        tbl1:= OrdinaryCharacterTable( arg[1] );
        tbl2:= OrdinaryCharacterTable( arg[2] );
      elif     IsNearlyCharacterTable( arg[1] )
           and IsNearlyCharacterTable( arg[2] ) then
        tbl1:= arg[1];
        tbl2:= arg[2];
      else
        Error( "usage: FusionConjugacyClasses( <tbl1>, <tbl2> )" );
      fi;

    else
      Error( "usage: FusionConjugacyClasses( <tbl1>, <tbl2> )" );
    fi;

    # Check whether the fusion map is stored already.
    fus:= GetFusionMap( tbl1, tbl2 );

    # If not then call the operation.
    if fus = fail then
      fus:= FusionConjugacyClassesOp( tbl1, tbl2 );
      if fus <> fail then
        StoreFusion( tbl1, fus, tbl2 );
      fi;
    fi;

    # In the case of groups, redirect the fusion.
    if IsGroup( arg[1] ) and IsGroup( arg[2] ) then
      fus:= IdentificationOfConjugacyClasses( tbl2 ){
                fus{ InverseMap( IdentificationOfConjugacyClasses(
                    tbl1 ) ) } };
    fi;

    # Return the fusion map.
    return fus;
end );


#############################################################################
##
#M  FusionConjugacyClassesOp( <hom> )
##
InstallMethod( FusionConjugacyClassesOp,
    "for a group homomorphism",
    true,
    [ IsGroupHomomorphism ], 0,
    hom -> FusionConjugacyClasses( Source( hom ), Range( hom ) ) );


#############################################################################
##
#M  FusionConjugacyClassesOp( <tbl1>, <tbl2> )
##
InstallMethod( FusionConjugacyClassesOp,
    "for two ordinary tables with groups",
    IsIdenticalObj,
    [ IsOrdinaryTable and HasUnderlyingGroup,
      IsOrdinaryTable and HasUnderlyingGroup ], 0,
    function( tbl1, tbl2 )

    local i, k, t, p,  # loop and help variables
          Sclasses,    # conjugacy classes of S
          Rclasses,    # conjugacy classes of R
          fusion,      # the fusion map
          orders;      # list of orders of representatives

    Sclasses:= ConjugacyClasses( tbl1 );
    Rclasses:= ConjugacyClasses( tbl2 );

    # Check that no factor fusion is tried.
    if FamilyObj( Sclasses ) <> FamilyObj( Rclasses ) then
      Error( "group of <tbl1> must be a subgroup of that of <tbl2>" );
    fi;

    fusion:= [];
    orders:= OrdersClassRepresentatives( tbl2 );
#T use more invariants/class identification!
    for i in [ 1 .. Length( Sclasses ) ] do
      k:= Representative( Sclasses[i] );
      t:= Order( k );
      for p in [ 1 .. Length( orders ) ] do
        if t = orders[p] and k in Rclasses[p] then
          fusion[i]:= p;
          break;
        fi;
      od;
    od;

    if Number( fusion ) <> Length( Sclasses ) then
      Error( "class fusion must be defined for all in `Sclasses'" );
    fi;

    return fusion;
    end );

InstallMethod( FusionConjugacyClassesOp,
    "for two ordinary tables",
    IsIdenticalObj,
    [ IsOrdinaryTable, IsOrdinaryTable ], 0,
    function( tbl1, tbl2 )

    local fusion;

    if   Size( tbl2 ) < Size( tbl1 ) then

      Error( "cannot compute factor fusion from tables" );
#T (at least try, sometimes it is unique ...)

    elif Size( tbl2 ) = Size( tbl1 ) then

      # find a transforming permutation
      fusion:= TransformingPermutationsCharacterTables( tbl1, tbl2 );
      if   fusion = fail then
        return fail;
      elif 1 < Size( fusion.group ) then
        Error( "fusion is not unique" );
      fi;
      if fusion.columns = () then
        fusion:= [];
      else
        fusion:= OnTuples( [ 1 .. LargestMovedPointPerm( fusion.columns ) ],
                           fusion.columns );
      fi;

      Append( fusion,
              [ Length( fusion ) + 1 .. NrConjugacyClasses( tbl1 ) ] );

    else

      # find a subgroup fusion
      fusion:= PossibleClassFusions( tbl1, tbl2 );
      if   IsEmpty( fusion ) then
        return fail;
      elif 1 < Length( fusion ) then

        # If both tables know a group then we should use them.
        if HasUnderlyingGroup( tbl1 ) and HasUnderlyingGroup( tbl2 ) then
          TryNextMethod();
        else
          Error( "fusion is not stored and not uniquely determined" );
        fi;

      fi;
      fusion:= fusion[1];

    fi;

    Assert( 2, Number( fusion ) = NrConjugacyClasses( tbl1 ),
            "fusion must be defined for all positions in `Sclasses'" );

    return fusion;
    end );

InstallMethod( FusionConjugacyClassesOp,
    "for two Brauer tables",
    IsIdenticalObj,
    [ IsBrauerTable, IsBrauerTable ], 0,
    function( tbl1, tbl2 )
    local fus, ord1, ord2;

    ord1:= OrdinaryCharacterTable( tbl1 );
    ord2:= OrdinaryCharacterTable( tbl2 );

    if HasUnderlyingGroup( ord1 ) and HasUnderlyingGroup( ord2 ) then

      # If the tables know their groups then compute the unique fusion.
      fus:= FusionConjugacyClasses( ord1, ord2 );
      if fus = fail then
        return fail;
      else
        return InverseMap( GetFusionMap( tbl2, ord2 ) ){
                   fus{ GetFusionMap( tbl1, ord1 ) } };
      fi;

    else

      # Try to find a unique restriction of the possible class fusions.
      fus:= PossibleClassFusions( ord1, ord2 );
      if IsEmpty( fus ) then
        return fail;
      else

        fus:= Set( List( fus, map -> InverseMap(
                                         GetFusionMap( tbl2, ord2 ) ){
                                     map{ GetFusionMap( tbl1, ord1 ) } } ) );
        if 1 < Length( fus ) then
          Error( "fusion is not uniquely determined" );
        fi;
        return fus[1];

      fi;

    fi;
    end );


#############################################################################
##
#M  Display( <tbl> )  . . . . . . . . . . . . .  for a nearly character table
#M  Display( <tbl>, <record> )
##
InstallMethod( Display,
    "for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )
    Display( tbl, rec() );
    end );

InstallMethod( Display,
    "for a nearly character table with display options",
    true,
    [ IsNearlyCharacterTable and HasDisplayOptions ], 0,
    function( tbl )
    Display( tbl, DisplayOptions( tbl ) );
    end );

InstallOtherMethod( Display,
    "for a nearly character table and a list",
    true,
    [ IsNearlyCharacterTable, IsList ], 0,
    function( tbl, list )
    Display( tbl, rec( chars:= list ) );
    end );

InstallOtherMethod( Display,
    "for a nearly character table and a record",
    true,
    [ IsNearlyCharacterTable, IsRecord ], 0,
    function( tbl, options )

    local i, j,              # loop variables
          chars,             # list of characters
          cnr,               # list of character numbers
          cletter,           # character name
          classes,           # list of classes
          powermap,          # list of primes
          centralizers,      # boolean
          cen,               # factorized centralizers
          fak,               # factorization
          prime,             # loop over primes
          primes,            # prime factors of order
          prin,              # column widths
          nam,               # classnames
          col,               # number of columns already printed
          acol,              # nuber of columns on next page
          len,               # width of next page
          ncols,             # total number of columns
          linelen,           # line length
          q,                 # quadratic cyc / powermap entry
          indicator,         # list of primes
          indic,             # indicators
          iw,                # width of indicator column
          letters,           # the alphabet
          ll,                # cardinality of the alphabet
          irrstack,          # list of known cycs
          irrnames,          # list of names for cycs
          colWidth,          # local function
          irrName,           # local function
          stringEntry,       # local function
          cc,                # column number
          charnames,         # list of character names
          charvals,          # matrix of strings of character values
          tbl_powermap,
          tbl_centralizers,
          tbl_irredinfo;

    # compute the width of column 'col'
    colWidth:= function( col )
       local len, width;

       # the class name should fit into the column
       width:= Length( nam[col] );

       # the class names of power classes should fit into the column
       for i in powermap do
         len:= tbl_powermap[i][ col ];
         if IsInt( len ) then
           len:= Length( nam[ len ] );
           if len > width then
             width:= len;
           fi;
         fi;
       od;

       # each character value should fit into the column
       for i in [ 1 .. Length( cnr ) ] do
         len:= Length( charvals[i][ col ] );
         if len > width then
           width:= len;
         fi;
       od;

       # at least one blank should separate the column entries
       return width + 1;

    end;

    # names of irrationalities
    irrName:= function( n )
       local i, name;

       name:= "";
       while 0 < n do
          name:= Concatenation(letters[(n-1) mod ll + 1], name);
          n:= QuoInt(n-1, ll);
       od;
       return name;
    end;

    # function (in one variable) to display a single entry
    if   IsBound( options.StringEntry ) then
      stringEntry:= options.StringEntry;
    else

      # string function as known
      stringEntry:= function( entry )
         local i, val;

         if entry = 0 then
            return ".";
         elif IsCyc( entry ) and not IsInt( entry ) then
            # find shorthand for cyclo
            for i in [ 1 .. Length(irrstack) ] do
               if entry = irrstack[i] then
                  return irrName(i);
               elif entry = -irrstack[i] then
                  return Concatenation("-", irrName(i));
               fi;
               val:= GaloisCyc(irrstack[i], -1);
               if entry = val then
                  return Concatenation("/", irrName(i));
               elif entry = -val then
                  return Concatenation("-/", irrName(i));
               fi;
               val:= StarCyc(irrstack[i]);
               if entry = val then
                  return Concatenation("*", irrName(i));
               elif -entry = val then
                  return Concatenation("-*", irrName(i));
               fi;
               i:= i+1;
            od;
            Add( irrstack, entry );
            Add( irrnames, irrName( Length( irrstack ) ) );
            return irrnames[ Length( irrnames ) ];

         elif ( IsList( entry ) and not IsString( entry ) )
              or IsUnknown( entry ) then
            return "?";
         else
            return String( entry );
         fi;
      end;

    fi;

    irrstack:= [];
    irrnames:= [];
    letters:= [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ];
    ll:= Length( letters );

    # default:
    # options
    cletter:= "X";

    # choice of characters
    if IsBound( options.chars ) then
       if IsCyclotomicCollection( options.chars ) then
          cnr:= options.chars;
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsInt( options.chars ) then
          cnr:= [ options.chars ];
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsHomogeneousList( options.chars ) then
          chars:= options.chars;
          cletter:= "Y";
          cnr:= [ 1 .. Length( chars ) ];
       else
          chars:= [];
       fi;
    else
      chars:= List( Irr( tbl ), ValuesOfClassFunction );
      cnr:= [ 1 .. Length( chars ) ];
    fi;

    if IsBound( options.letter ) and options.letter in letters then
       cletter:= options.letter;
    fi;

    # choice of classes
    if IsBound( options.classes ) then
      if IsInt( options.classes ) then
        classes:= [ options.classes ];
      else
        classes:= options.classes;
      fi;
    else
      classes:= [ 1 .. NrConjugacyClasses( tbl ) ];
    fi;

    # choice of power maps
    tbl_powermap:= ComputedPowerMaps( tbl );
    powermap:= Filtered( [ 1 .. Length( tbl_powermap ) ],
                         x -> IsBound( tbl_powermap[x] ) );
    if IsBound( options.powermap ) then
       if IsInt( options.powermap ) then
          IntersectSet( powermap, [ options.powermap ] );
       elif IsList( options.powermap ) then
          IntersectSet( powermap, options.powermap );
       elif options.powermap = false then
          powermap:= [];
       fi;
    fi;

    # print factorized centralizer orders?
    centralizers:=    not IsBound( options.centralizers )
                   or options.centralizers;

    # print Frobenius-Schur indicators?
    indicator:= [];
    if     IsBound( options.indicator )
       and not ( IsBound( options.chars ) and IsMatrix( options.chars ) ) then
       if options.indicator = true then
          indicator:= [2];
       elif IsRowVector( options.indicator ) then
          indicator:= Set( Filtered( options.indicator, IsPosInt ) );
       fi;
    fi;

    # (end of options handling)

    # line length
    linelen:= SizeScreen()[1] - 1;

    # A character table has a name.
    Print( Identifier( tbl ), "\n\n" );

    # prepare centralizers
    if centralizers then
       fak:= FactorsInt( Size( tbl ) );
       primes:= Set( fak );
       cen:= [];
       for prime in primes do
          cen[prime]:= [ Number( fak, x -> x = prime ) ];
       od;
    fi;

    # prepare classnames
    nam:= ClassNames( tbl );

    # prepare character names
    charnames:= [];
    if HasIrredInfo( tbl ) then
      tbl_irredinfo:= IrredInfo( tbl );
    fi;
    if HasIrredInfo( tbl ) and not IsBound( options.chars ) then
      for i in [ 1 .. Length( cnr ) ] do
        if IsBound( tbl_irredinfo[ cnr[i] ].charname ) then
          charnames[i]:= tbl_irredinfo[ cnr[i] ].charname;
        else
          charnames[i]:= Concatenation( cletter, ".", String( cnr[i] ) );
        fi;
      od;
    else
      for i in [ 1 .. Length( cnr ) ] do
        charnames[i]:= Concatenation( cletter, ".", String( cnr[i] ) );
      od;
    fi;

    # prepare indicator
    iw:= [0];
    if indicator <> [] and not HasIrredInfo( tbl ) then
       indicator:= [];
    fi;
    if indicator <> [] then
       indic:= [];
       for i in indicator do
          indic[i]:= [];
          for j in cnr do
             if IsBound( tbl_irredinfo[j] ) and
                IsBound( tbl_irredinfo[j].indicator ) and
                IsBound( tbl_irredinfo[j].indicator[i] ) then
                indic[i][j]:= tbl_irredinfo[j].indicator[i];
             fi;
          od;
          if indic[i] = [] then
             Unbind(indic[i]);
          else
             if i = 2 then
                iw[i]:= 2;
             else
                iw[i]:= Maximum( Length(String(Maximum(Set(indic[i])))),
                                 Length(String(Minimum(Set(indic[i])))),
                                 Length(String(i)) )+1;
             fi;
             iw[1]:= iw[1] + iw[i];
          fi;
       od;
       iw[1]:= iw[1] + 1;
       indicator:= Filtered( indicator, x-> IsBound( indic[x] ) );
    fi;

    if Length( cnr ) = 0 then
      prin:= [ 3 ];
    else
      prin:= [ Maximum( List( charnames, Length ) ) + 3 ];
    fi;

    # prepare list for strings of character values
    charvals:= List( chars, x -> [] );

    # Number Of Columns
    ncols:= Length(classes) + 1;

    # Anzahl bereits gedruckter Spalten
    col:= 1;

    while col < ncols do

       # determine number of cols for next page
       acol:= 0;
       if indicator <> [] then
          prin[1]:= prin[1] + iw[1];
       fi;
       len:= prin[1];
       while col+acol < ncols and len < linelen do
          acol:= acol + 1;
          if Length(prin) < col + acol then
             cc:= classes[ col + acol - 1 ];
             for i in [ 1 .. Length( cnr ) ] do
               charvals[i][ cc ]:= stringEntry( chars[i][ cc ] );
             od;
             prin[col + acol]:= colWidth( classes[col + acol - 1] );
          fi;
          len:= len + prin[col+acol];
       od;
       if len >= linelen then
          acol:= acol-1;
       fi;

       # Check whether we are able to print at least one column.
       if acol = 0 then
         Error( "line length too small (perhaps resize with 'SizeScreen')" );
       fi;

       # centralizers
       if centralizers then
          tbl_centralizers:= SizesCentralizers( tbl );
          for i in [col..col+acol-1] do
             fak:= FactorsInt( tbl_centralizers[classes[i]] );
             for prime in Set( fak ) do
                cen[prime][i]:= Number( fak, x -> x = prime );
             od;
          od;
          for j in [1..Length(cen)] do
             if IsBound(cen[j]) then
                for i in [col..col+acol-1] do
                   if not IsBound(cen[j][i]) then
                      cen[j][i]:= ".";
                   fi;
                od;
             fi;
          od;

          for prime in primes do
             Print( FormattedString( prime, prin[1] ) );
             for j in [1..acol] do
               Print( FormattedString( cen[prime][col+j-1], prin[col+j] ) );
             od;
             Print("\n");
          od;
          Print("\n");
       fi;

       # class names
       Print( FormattedString( "", prin[1] ) );
       for i in [ 1 .. acol ] do
         Print( FormattedString( nam[classes[col+i-1]], prin[col+i] ) );
       od;
       Print("\n");

       # power maps
       if powermap <> [] then
          for i in powermap do
             Print( FormattedString( Concatenation( String(i), "P" ),
                                     prin[1] ) );
             for j in [1..acol] do
                q:= tbl_powermap[i][classes[col+j-1]];
                if IsInt(q) then
                   Print( FormattedString( nam[q], prin[col+j] ) );
                else
                   Print( FormattedString( "?", prin[col+j] ) );
                fi;
             od;
             Print("\n");
          od;
       fi;

       # empty column resp. indicators
       if indicator <> [] then
          prin[1]:= prin[1] - iw[1];
          Print( FormattedString( "", prin[1] ) );
          for i in indicator do
             Print( FormattedString( i, iw[i] ) );
          od;
       fi;
       Print("\n");

       # the characters
       for i in [1..Length(chars)] do

          # character name
          Print( FormattedString( charnames[i], -prin[1] ) );

          # indicators
          for j in indicator do
             if IsBound(indic[j][cnr[i]]) then
                if j = 2 then
                   if indic[j][cnr[i]] = 0 then
                      Print( FormattedString( "o", iw[j] ) );
                   elif indic[j][cnr[i]] = 1 then
                      Print( FormattedString( "+", iw[j] ) );
                   elif indic[j][cnr[i]] = -1 then
                      Print( FormattedString( "-", iw[j] ) );
                   fi;
                else
                   if indic[j][cnr[i]] = 0 then
                      Print( FormattedString( "0", iw[j] ) );
                   else
                      Print( FormattedString( stringEntry(indic[j][cnr[i]]),
                                              iw[j]) );
                   fi;
                fi;
             else
                Print( FormattedString( "", iw[j] ) );
             fi;
          od;
          if indicator <> [] then
            Print(" ");
          fi;
          for j in [ 1 .. acol ] do
            Print( FormattedString( charvals[i][ classes[col+j-1] ],
                                    prin[ col+j ] ) );
          od;
          Print("\n");
       od;
       col:= col + acol;
       Print("\n");
       indicator:= [];
    od;

    # print legend for cyclos
    for i in [1..Length(irrstack)] do
       Print( irrName(i), " = ", irrstack[i], "\n" );
       q:= Quadratic( irrstack[i] );
       if q <> fail then
          Print( "  = ", q.display, " = ", q.ATLAS, "\n");
       fi;
    od;
    end );


#T support Cambridge format!
#T (for that, make the legend printing a separate function,
#T and also the handling of the irrats;
#T probably also the 'stringEntry' default function should become a
#T global variable)


#############################################################################
##
#F  ConvertToOrdinaryTable( <record> )  . . . . create character table object
#F  ConvertToOrdinaryTableNC( <record> )  . . . create character table object
##
InstallGlobalFunction( ConvertToOrdinaryTableNC, function( record )

    local names,    # list of component names
          i;        # loop over 'SupportedOrdinaryTableInfo'

    names:= RecNames( record );

    # Make the object.
    if     IsBound( record.UnderlyingCharacteristic )
       and record.UnderlyingCharacteristic <> 0 then
      ConvertToBrauerTableNC( record );
    else

      record.UnderlyingCharacteristic:= 0;
      Objectify( NewType( NearlyCharacterTablesFamily,
                          IsCharacterTable and IsAttributeStoringRep ),
                 record );

      # Enter the properties and attributes.
      for i in [ 1, 3 .. Length( SupportedOrdinaryTableInfo ) - 1 ] do
        if     SupportedOrdinaryTableInfo[ i+1 ] in names
           and SupportedOrdinaryTableInfo[ i+1 ] <> "Irr" then
          Setter( SupportedOrdinaryTableInfo[i] )( record,
              record!.( SupportedOrdinaryTableInfo[ i+1 ] ) );
        fi;
      od;

      # Make the lists of character values into character objects.
      if "Irr" in names then
        SetIrr( record, List( record!.Irr,
                              chi -> CharacterByValues( record, chi ) ) );
      fi;

    fi;

    # Return the object.
    return record;
end );

InstallGlobalFunction( ConvertToOrdinaryTable, function( record )
    Error( "not yet implemented!" );
end );


#############################################################################
##
#F  ConvertToBrauerTable( <record> ) . . . . . . . create Brauer table object
#F  ConvertToBrauerTableNC( <record> ) . . . . . . create Brauer table object
##
InstallGlobalFunction( ConvertToBrauerTableNC, function( record )

    local names,    # list of component names
          i;        # loop over 'SupportedBrauerTableInfo'

    names:= RecNames( record );

    # Make the object.
    Objectify( NewType( NearlyCharacterTablesFamily,
                        IsBrauerTable and IsAttributeStoringRep ),
               record );

    # Enter the properties and attributes.
    for i in [ 1, 3 .. Length( SupportedBrauerTableInfo ) - 1 ] do
      if     SupportedBrauerTableInfo[ i+1 ] in names
         and SupportedBrauerTableInfo[ i+1 ] <> "Irr" then
        Setter( SupportedBrauerTableInfo[i] )( record,
            record!.( SupportedBrauerTableInfo[ i+1 ] ) );
      fi;
    od;

    # Make the lists of character values into character objects.
    if "Irr" in names then
      SetIrr( record, List( record!.Irr,
                            chi -> CharacterByValues( record, chi ) ) );
    fi;

    # Return the object.
    return record;
end );

InstallGlobalFunction( ConvertToBrauerTable, function( record )
    Error( "not yet implemented!" );
end );


#############################################################################
##
#F  ConvertToLibraryCharacterTableNC( <record> )
##
InstallGlobalFunction( ConvertToLibraryCharacterTableNC, function( record )

    local names,    # list of component names
          i;        # loop over 'SupportedOrdinaryTableInfo'

    names:= RecNames( record );

    # Make the object.
    if IsBound( record.isGenericTable ) and record.isGenericTable then
      Objectify( NewType( NearlyCharacterTablesFamily,
                          IsGenericCharacterTableRep ),
                 record );
    elif not IsBound( record.UnderlyingCharacteristic ) then
      Error( "<record> must have one of 'isGenericTable' or ",
             "'UnderlyingCharacteristic'" );
    elif record.UnderlyingCharacteristic = 0 then
      Objectify( NewType( NearlyCharacterTablesFamily,
                              IsOrdinaryTable
                          and IsLibraryCharacterTableRep ),
                 record );
    else
      Objectify( NewType( NearlyCharacterTablesFamily,
                              IsBrauerTable
                          and IsLibraryCharacterTableRep ),
                 record );
    fi;

    # Enter the properties and attributes.
    for i in [ 2, 4 .. Length( SupportedOrdinaryTableInfo ) ] do
      if     SupportedOrdinaryTableInfo[i] in names
         and SupportedOrdinaryTableInfo[i] <> "Irr" then
        Setter( SupportedOrdinaryTableInfo[ i-1 ] )( record,
                            record!.( SupportedOrdinaryTableInfo[i] ) );
      fi;
    od;

    # Make the lists of character values into character objects.
    if "Irr" in names then
      SetIrr( record, List( record!.Irr,
                            chi -> CharacterByValues( record, chi ) ) );
    fi;

    # Return the object.
    return record;
end );


#############################################################################
##
#F  PrintCharacterTable( <tbl>, <varname> )
##
InstallGlobalFunction( PrintCharacterTable, function( tbl, varname )

    local i, info, comp;

    # Check the arguments.
    if not IsNearlyCharacterTable( tbl ) then
      Error( "<tbl> must be a nearly character table" );
    elif not IsString( varname ) then
      Error( "<varname> must be a string" );
    fi;

    # Print the preamble.
    Print( varname, ":= function()\n" );
    Print( "local tbl;\n" );
    Print( "tbl:=rec();\n" );

    # Print the values of supported attributes.
    for i in [ 2, 4 .. Length( SupportedOrdinaryTableInfo ) ] do
      if Tester( SupportedOrdinaryTableInfo[i-1] )( tbl ) then
        info:= SupportedOrdinaryTableInfo[i-1]( tbl );
        if SupportedOrdinaryTableInfo[i] = "Irr" then
          info:= List( info, ValuesOfClassFunction );
        fi;
        Print( "tbl.", SupportedOrdinaryTableInfo[i], ":=\n" );
        if IsString( info ) and not IsEmptyString( info ) then
          Print( "\"", info, "\";\n" );
        else
          Print( info, ";\n" );
        fi;
      fi;
    od;

    # Print the values of supported components if available.
    if IsLibraryCharacterTableRep( tbl ) then
      for comp in SupportedLibraryTableComponents do
        if IsBound( tbl!.( comp ) ) then
#T           if   comp = "cliffordTable" then
#T             Print( "tbl.", comp, ":=\n\"",
#T                    PrintCliffordTable( tbl ), "\";\n" );
#T           elif     IsString( tbl!.( comp ) )
#T                and not IsEmptyString( tbl!.( comp ) ) then
          if     IsString( tbl!.( comp ) )
             and not IsEmptyString( tbl!.( comp ) ) then
            Print( "tbl.", comp, ":=\n\"",
                   tbl!.( comp ), "\";\n" );
          else
            Print( "tbl.", comp, ":=\n",
                   tbl!.( comp ), ";\n" );
          fi;
        fi;
      od;
      Print( "ConvertToLibraryCharacterTableNC(tbl);\n" );
    else
      Print( "ConvertToOrdinaryTableNC(tbl);\n" );
    fi;

    # Print the rest of the construction.
    Print( "return tbl;\n" );
    Print( "end;\n" );
    Print( varname, ":= ", varname, "();\n" );
end );


PrintCharTable := function( tbl )
    PrintCharacterTable( tbl, "t" );
end;
#T compat3 ?


#############################################################################
##
#M  IsCommutative( <tbl> )  . . . . . . . . . for an ordinary character table
##
InstallOtherMethod( IsCommutative,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    tbl -> NrConjugacyClasses( tbl ) = Size( tbl ) );


#############################################################################
##
#M  IsCyclic( <tbl> ) . . . . . . . . . . . . for an ordinary character table
##
InstallOtherMethod( IsCyclic,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    tbl -> Size( tbl ) in OrdersClassRepresentatives( tbl ) );


#############################################################################
##
#M  IsSimpleCharacterTable( <tbl> ) . . . . . for an ordinary character table
##
InstallOtherMethod( IsSimpleCharacterTable,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    tbl -> Length( ClassPositionsOfNormalSubgroups( tbl ) ) = 2 );


#############################################################################
##
#M  IsPSolvableCharacterTableOp( <tbl>, <p> )
##
InstallMethod( IsPSolvableCharacterTableOp,
    "for an ordinary character table, an a positive integer",
    true,
    [ IsOrdinaryTable, IsPosInt ], 0,
    function( tbl, p )

    local nsg,       # list of all normal subgroups
          i,         # loop variable, position in 'nsg'
          n,         # one normal subgroup
          posn,      # position of 'n' in 'nsg'
          size,      # size of 'n'
          nextsize,  # size of smallest normal subgroup containing 'n'
          classes,   # class lengths
          facts;     # set of prime factors of a chief factor

    nsg:= ClassPositionsOfNormalSubgroups( tbl );

    # Go up a chief series, starting with the trivial subgroup
    i:= 1;
    nextsize:= 1;
    classes:= SizesConjugacyClasses( tbl );

    while i < Length( nsg ) do

      posn:= i;
      n:= nsg[ posn ];
      size:= nextsize;

      # Get the smallest normal subgroup containing 'n' \ldots
      i:= posn + 1;
      while not IsSubsetSet( nsg[ i ], n ) do i:= i+1; od;

      # \ldots and its size.
      nextsize:= Sum( classes{ nsg[i] }, 0 );

      facts:= Set( FactorsInt( nextsize / size ) );
      if 1 < Length( facts ) and ( p = 0 or p in facts ) then

        # The chief factor 'nsg[i] / n' is not a prime power,
        # and our 'p' divides its order.
        return false;

      fi;

    od;
    return true;
    end );


#############################################################################
##
#M  IsSolvableCharacterTable( <tbl> ) . . . . for an ordinary character table
##
InstallOtherMethod( IsSolvableCharacterTable,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    tbl -> IsPSolvableCharacterTable( tbl, 0 ) );


#T #############################################################################
#T ##
#T #M  IsSupersolvable( <tbl> )
#T ##
#T InstallOtherMethod( IsSupersolvable, true, [ IsOrdinaryTable ], 0,
#T     tbl -> Size( SupersolvableResiduum( tbl ) ) = 1 );
#T 
#T 
#T #############################################################################
#T ##
#T #M  SupersolvableResiduum( <tbl> )
#T ##
#T InstallOtherMethod( SupersolvableResiduum, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local nsg,       # list of all normal subgroups
#T           i,         # loop variable, position in 'nsg'
#T           N,         # one normal subgroup
#T           posN,      # position of 'N' in 'nsg'
#T           size,      # size of 'N'
#T           nextsize,  # size of largest normal subgroup contained in 'N'
#T           classes;   # class lengths
#T 
#T     nsg:= ClassPositionsOfNormalSubgroups( tbl );
#T 
#T     # Go down a chief series, starting with the whole group,
#T     # until there is no step of prime order.
#T     i:= Length( nsg );
#T     nextsize:= Size( tbl );
#T     classes:= SizesConjugacyClasses( tbl );
#T 
#T     while i > 1 do
#T 
#T       posN:= i;
#T       N:= nsg[ posN ];
#T       size:= nextsize;
#T 
#T       # Get the largest normal subgroup contained in 'N' \ldots
#T       i:= posN - 1;
#T       while not IsSubsetSet( N, nsg[ i ] ) do i:= i-1; od;
#T 
#T       # \ldots and its size.
#T       nextsize:= Sum( classes{ nsg[i] }, 0 );
#T 
#T       if not IsPrimeInt( size / nextsize ) then
#T 
#T         # The chief factor 'N / nsg[i]' is not of prime order,
#T         # i.e., 'N' is the supersolvable residuum.
#T         return N;
#T 
#T       fi;
#T 
#T     od;
#T     return [ 1 ];
#T     end );


#############################################################################
##
#F  CharacterTable_UpperCentralSeriesFactor( <tbl>, <N> )
##
##  Let <tbl> the character table of the group $G$, and <N> the list of
##  classes contained in the normal subgroup $N$ of $G$.
##  The upper central series $[ Z_1, Z_2, \ldots, Z_n ]$ of $G/N$ is defined
##  by $Z_1 = Z(G/N)$, and $Z_{i+1} / Z_i = Z( G / Z_i )$.
##  'UpperCentralSeriesFactor( <tbl>, <N> )' is a list
##  $[ C_1, C_2, \ldots, C_n ]$ where $C_i$ is the set of positions of
##  $G$-conjugacy classes contained in $Z_i$.
##
##  A simpleminded version of the algorithm can be stated as follows.
##
##  $M_0:= Irr(G);$|
##  |$Z_1:= Z(G);$|
##  |$i:= 0;$|
##  repeat
##    |$i:= i+1;$|
##    |$M_i:= \{ \chi\in M_{i-1} ; Z_i \leq \ker(\chi) \};$|
##    |$Z_{i+1}:= \bigcap_{\chi\in M_i}} Z(\chi);$|
##  until |$Z_i = Z_{i+1};$
##
CharacterTable_UpperCentralSeriesFactor := function( tbl, N )

    local Z,      # result list
          n,      # number of conjugacy classes
          M,      # actual list of pairs kernel/centre of characters
          nextM,  # list of pairs in next iteration
          kernel, # kernel of a character
          centre, # centre of a character
          i,      # loop variable
          chi;    # loop variable

    n:= NrConjugacyClasses( tbl );
    N:= Set( N );

    # instead of the irreducibles store pairs $[ \ker(\chi), Z(\chi) ]$.
    # 'Z' will be the list of classes forming $Z_1 = Z(G/N)$.
    M:= [];
    Z:= [ 1 .. n ];
    for chi in Irr( tbl ) do
      kernel:= KernelChar( chi );
      if IsSubsetSet( kernel, N ) then
        centre:= CentreChar( chi );
        AddSet( M, [ kernel, centre ] );
        IntersectSet( Z, centre );
      fi;
    od;

    Z:= [ Z ];
    i:= 0;

    repeat
      i:= i+1;
      nextM:= [];
      Z[i+1]:= [ 1 .. n ];
      for chi in M do
        if IsSubsetSet( chi[1], Z[i] ) then
          Add( nextM, chi );
          IntersectSet( Z[i+1], chi[2] );
        fi;
      od;
      M:= nextM;
    until Z[i+1] = Z[i];
    Unbind( Z[i+1] );

    return Z;
end;


#T #############################################################################
#T ##
#T #M  UpperCentralSeries( <tbl> )
#T ##
#T InstallOtherMethod( UpperCentralSeries, true, [ IsOrdinaryTable ], 0,
#T     tbl -> CharacterTable_UpperCentralSeriesFactor( tbl, [1] ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  LowerCentralSeries( <tbl> )
#T ##
#T ##  Let <tbl> the character table of the group $G$.
#T ##  The lower central series $[ K_1, K_2, \ldots, K_n ]$ of $G$ is defined
#T ##  by $K_1 = G$, and $K_{i+1} = [ K_i, G ]$.
#T ##  'LowerCentralSeries( <tbl> )' is a list
#T ##  $[ C_1, C_2, \ldots, C_n ]$ where $C_i$ is the set of positions of
#T ##  $G$-conjugacy classes contained in $K_i$.
#T ##
#T ##  Given an element $x$ of $G$, then $g\in G$ is conjugate to $[x,y]$ for
#T ##  an element $y\in G$ if and only if
#T ##  $\sum_{\chi\in Irr(G)} \frac{|\chi(x)|^2 \overline{\chi(g)}}{\chi(1)}
#T ##  \not= 0$, or equivalently, if the structure constant
#T ##  $a_{x,\overline{x},g}$ is nonzero..
#T ##
#T ##  Thus $K_{i+1}$ consists of all classes $Cl(g)$ in $K_i$ for that there
#T ##  is an $x\in K_i$ such that $a_{x,\overline{x},g}$ is nonzero.
#T ##
#T InstallOtherMethod( LowerCentralSeries, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local series,     # list of normal subgroups, result
#T           K,          # actual last element of 'series'
#T           inv,        # list of inverses of classes of 'tbl'
#T           mat,        # matrix of structure constants
#T           i, j,       # loop over 'mat'
#T           running,    # loop not yet terminated
#T           new;        # next element in 'series'
#T 
#T     series:= [];
#T     series[1]:= [ 1 .. NrConjugacyClasses( tbl ) ];
#T     K:= ClassesOfDerivedSubgroup( tbl );
#T     if K = series[1] then
#T       return series;
#T     fi;
#T     series[2]:= K;
#T 
#T     # Compute the structure constants $a_{x,\overline{x},g}$ with $g$ and $x$
#T     # in $K_2$.
#T     # Put them into a matrix, the rows indexed by $g$, the columns by $x$.
#T     inv:= PowerMap( tbl, -1 );
#T     mat:= List( K, x -> [] );
#T     for i in [ 2 .. Length( K ) ] do
#T       for j in K do
#T         mat[i][j]:= ClassMultiplicationCoefficient( tbl, K[i], j, inv[j] );
#T       od;
#T     od;
#T 
#T     running:= true;
#T 
#T     while running do
#T 
#T       new:= [ 1 ];
#T       for i in [ 2 .. Length( mat ) ] do
#T         if ForAny( K, x -> mat[i][x] <> 0 ) then
#T           Add( new, i );
#T         fi;
#T       od;
#T 
#T       if Length( new ) = Length( K ) then
#T         running:= false;
#T       else
#T         mat:= mat{ new };
#T         K:= K{ new };
#T         Add( series, new );
#T       fi;
#T 
#T     od;
#T 
#T     return series;
#T     end );


#############################################################################
##
#F  CharacterTable_IsNilpotentFactor( <tbl>, <N> )
##
BindGlobal( "CharacterTable_IsNilpotentFactor", function( tbl, N )
    local series;
    series:= CharacterTable_UpperCentralSeriesFactor( tbl, N );
    return Length( series[ Length( series ) ] ) = NrConjugacyClasses( tbl );
end );


#T #############################################################################
#T ##
#T #M  IsNilpotent( <tbl> )
#T ##
#T InstallOtherMethod( IsNilpotent, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T     local series;
#T     series:= UpperCentralSeries( tbl );
#T     return Length( series[ Length( series ) ] ) = NrConjugacyClasses( tbl );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #F  CharacterTable_IsNilpotentNormalSubgroup( <tbl>, <N> )
#T ##
#T ##  returns whether the normal subgroup described by the classes in <N> is
#T ##  nilpotent.
#T ##
#T CharacterTable_IsNilpotentNormalSubgroup := function( tbl, N )
#T 
#T     local classlengths,  # class lengths
#T           orders,        # orders of class representatives
#T           ppow,          # list of classes of prime power order
#T           part,          # one pair '[ prime, exponent ]'
#T           classes;       # classes of p power order for a prime p
#T 
#T     # Take the classes of prime power order.
#T     classlengths:= SizesConjugacyClasses( tbl );
#T     orders:= OrdersClassRepresentatives( tbl );
#T     ppow:= Filtered( N, i -> IsPrimePowerInt( orders[i] ) );
#T 
#T     for part in Collected( FactorsInt( Sum( classlengths{ N }, 0 ) ) ) do
#T 
#T       # Check whether the Sylow p subgroup of 'N' is normal in 'N',
#T       # i.e., whether the number of elements of p-power is equal to
#T       # the size of a Sylow p subgroup.
#T       classes:= Filtered( ppow, i -> orders[i] mod part[1] = 0 );
#T       if part[1] ^ part[2] <> Sum( classlengths{ classes }, 0 ) + 1 then
#T         return false;
#T       fi;
#T 
#T     od;
#T     return true;
#T end;
#T 
#T 
##############################################################################
##
#M  AbelianInvariants( <tbl> )
##
##  For all Sylow p subgroups of '<tbl> / ClassesOfDerivedSubgroup( <tbl> )'
##  compute the abelian invariants by repeated factoring by a cyclic group
##  of maximal order.
#T for a table with group, is it better to delegate to the group?
#T when is it better to delegate from the group to the table?
#T (at least orders & power maps should be known)
##
InstallOtherMethod( AbelianInvariants,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )

    local kernel,  # cyclic group to be factored out
          inv,     # list of invariants, result
          primes,  # list of prime divisors of actual size
          max,     # list of actual maximal orders, for 'primes'
          pos,     # list of positions of maximal orders
          orders,  # list of representative orders
          i,       # loop over classes
          j;       # loop over primes

    # Do all computations modulo the derived subgroup.
    kernel:= ClassesOfDerivedSubgroup( tbl );
    if 1 < Length( kernel ) then
      tbl:= tbl / kernel;
    fi;
#T cheaper to use only orders and power maps,
#T and to avoid computing several tables!
#T (especially avoid to compute the irreducibles of the original
#T table if they are not known!)

    inv:= [];

    while 1 < Size( tbl ) do

      # For all prime divisors $p$ of the size,
      # compute the element of maximal $p$ power order.
      primes:= Set( FactorsInt( Size( tbl ) ) );
      max:= List( primes, x -> 1 );
      pos:= [];
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 2 .. Length( orders ) ] do
        if IsPrimePowerInt( orders[i] ) then
          j:= 1;
          while orders[i] mod primes[j] <> 0 do
            j:= j+1;
          od;
          if orders[i] > max[j] then
            max[j]:= orders[i];
            pos[j]:= i;
          fi;
        fi;
      od;

      # Update the list of invariants.
      Append( inv, max );

      # Factor out the cyclic subgroup.
      tbl:= tbl / ClassesOfNormalClosure( tbl, pos );

    od;

    return AbelianInvariantsOfList( inv );
#T if we call this function anyhow, we can also take factors by the largest
#T cyclic subgroup of the commutator factor group!
    end );


#T #############################################################################
#T ##
#T #M  Agemo( <tbl>, <p> )
#T ##
#T InstallOtherMethod( Agemo, true, [ IsOrdinaryTable, IsPosInt ], 0,
#T     function( tbl, p )
#T     return ClassesOfNormalClosure( tbl, Set( PowerMap( tbl, p ) ) );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Centre( <tbl> )
#T ##
#T InstallOtherMethod( Centre, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T     local size, centralizers;
#T     size:= Size( tbl );
#T     centralizers:= SizesCentralizers( tbl );
#T     return Filtered( [ 1 .. NrConjugacyClasses( tbl ) ],
#T                      x -> centralizers[x] = size );
#T     end );
#T #T CentreClasses!


#############################################################################
##
#M  ClassesOfDerivedSubgroup( <tbl> )
##
InstallMethod( ClassesOfDerivedSubgroup,
    "for an ordinary table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )

    local der,   # derived subgroup, result
          chi;   # one irreducible character

    der:= [ 1 .. NrConjugacyClasses( tbl ) ];
    for chi in Irr( tbl ) do
#T support `Lin' ?
      if DegreeOfCharacter( chi ) = 1 then
        IntersectSet( der, KernelChar( chi ) );
      fi;
    od;
    return der;
    end );


#T #############################################################################
#T ##
#T #M  ElementaryAbelianSeries( <tbl> )
#T ##
#T InstallOtherMethod( ElementaryAbelianSeries, true,
#T                     [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local elab,         # el. ab. series, result
#T           nsg,          # list of normal subgroups of 'tbl'
#T           actsize,      # size of actual normal subgroup
#T           classes,      # conjugacy class lengths
#T           next,         # next smaller normal subgroup
#T           nextsize;     # size of next smaller normal subgroup
#T 
#T     # Sort normal subgroups according to decreasing number of classes.
#T     nsg:= ShallowCopy( ClassPositionsOfNormalSubgroups( tbl ) );
#T 
#T     elab:= [ [ 1 .. NrConjugacyClasses( tbl ) ] ];
#T     Unbind( nsg[ Length( nsg ) ] );
#T 
#T     actsize:= Size( tbl );
#T     classes:= SizesConjugacyClasses( tbl );
#T 
#T     repeat
#T 
#T       next:= nsg[ Length( nsg ) ];
#T       nextsize:= Sum( classes{ next }, 0 );
#T       Add( elab, next );
#T       Unbind( nsg[ Length( nsg ) ] );
#T       nsg:= Filtered( nsg, x -> IsSubset( next, x ) );
#T 
#T       if not IsPrimePowerInt( actsize / nextsize ) then
#T         Error( "<tbl> must be table of a solvable group" );
#T       fi;
#T 
#T       actsize:= nextsize;
#T 
#T     until Length( nsg ) = 0;
#T 
#T     return elab;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Exponent( <tbl> )
#T ##
#T InstallOtherMethod( Exponent, true, [ IsOrdinaryTable ], 0,
#T     tbl -> Lcm( OrdersClassRepresentatives( tbl ) ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  FittingSubgroup( <tbl> )
#T ##
#T ##  The Fitting subgroup is the maximal nilpotent normal subgroup, that is,
#T ##  the product of all normal subgroups of prime power order.
#T ##
#T InstallOtherMethod( FittingSubgroup, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local nsg,      # all normal subgroups of 'tbl'
#T           classes,  # class lengths
#T           ppord,    # classes in normal subgroups of prime power order
#T           n;        # one normal subgroup of 'tbl'
#T 
#T     # Compute all normal subgroups.
#T     nsg:= ClassPositionsOfNormalSubgroups( tbl );
#T 
#T     # Take the union of classes in all normal subgroups of prime power order.
#T     classes:= SizesConjugacyClasses( tbl );
#T     ppord:= [];
#T     for n in nsg do
#T       if IsPrimePowerInt( Sum( classes{n}, 0 ) ) then
#T         UniteSet( ppord, n );
#T       fi;
#T     od;
#T 
#T     # Return the normal closure.
#T     return ClassesOfNormalClosure( tbl, ppord );
#T     end );


#############################################################################
##
#M  ClassPositionsOfMaximalNormalSubgroups( <tbl> )
##
##  *Note* that the maximal normal subgroups of a group <G> can be computed
##  easily if the character table of <G> is known.  So if you need the table
##  anyhow, you should compute it before computing the maximal normal
##  subgroups of the group.
##
InstallMethod( ClassPositionsOfMaximalNormalSubgroups,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )

    local normal,    # list of all kernels
          maximal,   # list of maximal kernels
          k;         # one kernel

    # Every normal subgroup is an intersection of kernels of characters,
    # so maximal normal subgroups are kernels of irreducible characters.
    normal:= Set( List( Irr( tbl ), KernelChar ) );

    # Remove non-maximal kernels
    RemoveSet( normal, [ 1 .. NrConjugacyClasses( tbl ) ] );
    Sort( normal, function(x,y) return Length(x) > Length(y); end );
    maximal:= [];
    for k in normal do
      if ForAll( maximal, x -> not IsSubsetSet( x, k ) ) then

        # new maximal element found
        Add( maximal, k );

      fi;
    od;

    return maximal;
    end );


#############################################################################
##
#M  ClassesOfNormalClosure( <tbl>, <classes> )
##
InstallMethod( ClassesOfNormalClosure,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable, IsHomogeneousList and IsCyclotomicCollection ], 0,
    function( tbl, classes )

    local closure,   # classes forming the normal closure, result
          chi,       # one irreducible character of 'tbl'
          ker;       # classes forming the kernel of 'chi'

    closure:= [ 1 .. NrConjugacyClasses( tbl ) ];
    for chi in Irr( tbl ) do
      ker:= KernelChar( chi );
      if IsSubset( ker, classes ) then
        IntersectSet( closure, ker );
      fi;
    od;

    return closure;
    end );


#############################################################################
##
#M  ClassPositionsOfNormalSubgroups( <tbl> )
##
InstallOtherMethod( ClassPositionsOfNormalSubgroups,
    "for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )

    local kernels,  # list of kernels of irreducible characters
          ker1,     # loop variable
          ker2,     # loop variable
          normal,   # list of normal subgroups, result
          inter;    # intersection of two kernels

    # get the kernels of irreducible characters
    kernels:= Set( List( Irr( tbl ), KernelChar ) );

    # form all possible intersections of the kernels
    normal:= ShallowCopy( kernels );
    for ker1 in normal do
      for ker2 in kernels do
        inter:= Intersection( ker1, ker2 );
        if not inter in normal then
          Add( normal, inter );
        fi;
      od;
    od;

    # return the list of normal subgroups
    normal:= SSortedList( normal );
    Sort( normal, function( x, y ) return Length(x) < Length(y); end );
    return normal;
    end );


#T ############################################################################
#T ##
#T #V  PreliminaryLatticeOps . . operations record for normal subgroup lattices
#T ##
#T PreliminaryLatticeOps := OperationsRecord( "PreliminaryLatticeOps" );
#T 
#T PreliminaryLatticeOps.Print := function( obj )
#T     Print( "Lattice( ", obj.domain, " )" );
#T     end;
#T 
#T ############################################################################
#T ##
#T #F  Lattice( <tbl> ) . .  lattice of normal subgroups of a c.t.
#T ##
#T Lattice := function( tbl )
#T 
#T     local i, j,       # loop variables
#T           nsg,        # list of normal subgroups
#T           len,        # length of 'nsg'
#T           sizes,      # sizes of normal subgroups
#T           max,        # one maximal subgroup
#T           maxes,      # list of maximal contained normal subgroups
#T           actsize,    # actuel size of normal subgroups
#T           actmaxes,
#T           latt;       # the lattice record
#T 
#T     # Compute normal subgroups and their sizes
#T     nsg:= ClassPositionsOfNormalSubgroups( tbl );
#T     len:= Length( nsg );
#T     sizes:= List( nsg, x -> Sum( tbl.classes{ x }, 0 ) );
#T     SortParallel( sizes, nsg );
#T 
#T     # For each normal subgroup, compute the maximal contained ones.
#T     maxes:= [];
#T     i:= 1;
#T     while i <= len do
#T       actsize:= sizes[i];
#T       actmaxes:= Filtered( [ 1 .. i-1 ], x -> actsize mod sizes[x] = 0 );
#T       while i <= len and sizes[i] = actsize do
#T         max:= Filtered( actmaxes, x -> IsSubset( nsg[i], nsg[x] ) );
#T         for j in Reversed( max ) do
#T           SubtractSet( max, maxes[j] );
#T         od;
#T         Add( maxes, max );
#T         i:= i+1;
#T       od;
#T     od;
#T 
#T     # construct the lattice record
#T     latt:= rec( domain          := tbl,
#T                 normalSubgroups := nsg,
#T                 sizes           := sizes,
#T                 maxes           := maxes,
#T                 XGAP            := rec( vertices := [ 1 .. len ],
#T                                         sizes    := sizes,
#T                                         maximals := maxes ),
#T                 operations      := PreliminaryLatticeOps );
#T 
#T     # return the lattice record
#T     return latt;
#T end;


#############################################################################
##
#F  PermutationToSortCharacters( <tbl>, <chars>, <degree>, <norm> )
##
PermutationToSortCharacters := function( tbl, chars, degree, norm )

    local rational, listtosort, i, len;

    if IsEmpty( chars ) then
      return ();
    fi;

    # Rational characters shall precede irrational ones of same degree,
    # and the trivial character shall be the first one.
    rational := function( chi )
      chi:= ValuesOfClassFunction( chi );
      if ForAll( chi, IsRat ) then
        if ForAll( chi, x -> x = 1 ) then
          return -1;
        else
          return 0;
        fi;
      else
        return 1;
      fi;
    end;

    # Compute the permutation.
    listtosort:= [];
    if degree and norm then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ ScalarProduct( chars[i], chars[i] ),
                          DegreeOfCharacter( chars[i] ),
                          rational( chars[i] ), i ];
      od;
    elif degree then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ DegreeOfCharacter( chars[i] ),
                          rational( chars[i] ), i ];
      od;
    elif norm then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ ScalarProduct( chars[i], chars[i] ),
                          rational( chars[i] ), i ];
      od;
    else
      Error( "at least one of <degree> or <norm> must be `true'" );
    fi;
    Sort( listtosort );
    len:= Length( listtosort[1] );
    for i in [ 1 .. Length( chars ) ] do
      listtosort[i]:= listtosort[i][ len ];
    od;
    return Inverse( PermList( listtosort ) );
end;


#############################################################################
##
#F  RealClassesCharTable( <tbl> ) . . . .  the real-valued classes of a table
##
InstallGlobalFunction( RealClassesCharTable, function( tbl )
    local inv;
    inv:= PowerMap( tbl, -1 );
    return Filtered( [ 1 .. NrConjugacyClasses( tbl ) ], i -> inv[i] = i );
end );


#############################################################################
##
#M  CharacterTableWithSortedCharacters( <tbl> )
##
InstallMethod( CharacterTableWithSortedCharacters,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> CharacterTableWithSortedCharacters( tbl,
             PermutationToSortCharacters( tbl, Irr( tbl ), true, false ) ) );


#############################################################################
##
#M  CharacterTableWithSortedCharacters( <tbl>, <perm> )
##
InstallOtherMethod( CharacterTableWithSortedCharacters,
    "for an ordinary character table, and a permutation",
    true,
    [ IsOrdinaryTable, IsPerm ], 0,
    function( tbl, perm )

    local new, i;

    # Create the new table.
    new:= ConvertToLibraryCharacterTableNC(
                 rec( UnderlyingCharacteristic := 0 ) );

    # Set the permuted attribute values.
    SetIrr( new, Permuted( Irr( tbl ), perm ) );
    SetIrredInfo( new, Permuted( IrredInfo( tbl ), perm ) );

    # Set the other supported values.
    for i in [ 2, 4 .. Length( SupportedOrdinaryTableInfo ) ] do
      if Tester( SupportedOrdinaryTableInfo[ i-1 ] )( tbl )
         and not ( SupportedOrdinaryTableInfo[i]
                     in [ "Irr", "IrredInfo", "UnderlyingGroup" ] ) then
        Setter( SupportedOrdinaryTableInfo[ i-1 ] )( new,
            SupportedOrdinaryTableInfo[ i-1 ]( tbl ) );
      fi;
    od;

    # Return the table.
    return new;
    end );


#############################################################################
##
#M  SortedCharacters( <tbl>, <chars> )
##
InstallMethod( SortedCharacters,
    "for a character table, and a homogeneous list",
    true,
    [ IsNearlyCharacterTable, IsHomogeneousList ], 0,
    function( tbl, chars )
    return Permuted( chars,
               PermutationToSortCharacters( tbl, chars, true, true ) );
    end );


#############################################################################
##
#M  SortedCharacters( <tbl>, <chars>, \"norm\" )
#M  SortedCharacters( <tbl>, <chars>, \"degree\" )
##
InstallOtherMethod( SortedCharacters,
    "for a character table, a homogeneous list, and a string",
    true,
    [ IsNearlyCharacterTable, IsHomogeneousList, IsString ], 0,
    function( tbl, chars, string )
    if string = "norm" then
      return Permuted( chars,
                 PermutationToSortCharacters( tbl, chars, false, true ) );
    elif string = "degree" then
      return Permuted( chars,
                 PermutationToSortCharacters( tbl, chars, true, false ) );
    else
      Error( "<string> must be \"norm\" or \"degree\"" );
    fi;
    end );


#############################################################################
##
#F  PermutationToSortClasses( <tbl>, <classes>, <orders> )
##
PermutationToSortClasses := function( tbl, classes, orders )

    local listtosort, i, len;

    # Compute the permutation.
    listtosort:= [];
    if classes and orders then
      classes:= SizesConjugacyClasses( tbl );
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ orders[i], classes[i], i ];
      od;
    elif classes then
      classes:= SizesConjugacyClasses( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ classes[i], i ];
      od;
    elif orders then
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ orders[i], i ];
      od;
    else
      Error( "<classes> or <orders> must be 'true'" );
    fi;
    Sort( listtosort );
    len:= Length( listtosort[1] );
    for i in [ 1 .. Length( listtosort ) ] do
      listtosort[i]:= listtosort[i][ len ];
    od;
    return Inverse( PermList( listtosort ) );
end;


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl> )
##
InstallMethod( CharacterTableWithSortedClasses,
    "for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> CharacterTableWithSortedClasses( tbl,
               PermutationToSortClasses( tbl, true, true ) ) );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl>, \"centralizers\" )
#M  CharacterTableWithSortedClasses( <tbl>, \"representatives\" )
##
InstallOtherMethod( CharacterTableWithSortedClasses,
    "for a character table, and string",
    true,
    [ IsCharacterTable, IsString ], 0,
    function( tbl, string )
    if   string = "centralizers" then
      return CharacterTableWithSortedClasses( tbl,
                 PermutationToSortClasses( tbl, true, false ) );
    elif string = "representatives" then
      return CharacterTableWithSortedClasses( tbl,
                 PermutationToSortClasses( tbl, false, true ) );
    else
      Error( "<string> must be \"centralizers\" or \"representatives\"" );
    fi;
    end );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl>, <permutation> )
##
InstallOtherMethod( CharacterTableWithSortedClasses,
    "for an ordinary character table, and a permutation",
    true,
    [ IsOrdinaryTable, IsPerm ], 0,
    function( tbl, perm )

    local new, attr, fus, tblmaps, permmap, inverse, k;

    # Create the new table.
    new:= ConvertToLibraryCharacterTableNC(
                 rec( UnderlyingCharacteristic := 0 ) );

    # Set the permuted attribute values.
    if 1^perm <> 1 then
      Error( "<perm> must fix the first class" );
    elif Order( perm ) = 1 then
      return tbl;
    fi;

    # Set supported attributes that do not need adjustion.
    for attr in [ Identifier, InfoText, IrredInfo, IsSimpleCharacterTable,
                  Maxes, NamesOfFusionSources, UnderlyingCharacteristic ] do
      if Tester( attr )( tbl ) then
        Setter( attr )( new, attr( tbl ) );
      fi;
    od;

    # Set known attributes that must be adjusted.
    if HasClassParameters( tbl ) then
      SetClassParameters( new,
          Permuted( ClassParameters( tbl ), perm ) );
    fi;
    if HasIrr( tbl ) then
      SetIrr( new,
          List( Irr( tbl ), chi -> CharacterByValues( new,
                Permuted( ValuesOfClassFunction( chi ), perm ) ) ) );
    fi;
    if HasOrdersClassRepresentatives( tbl ) then
      SetOrdersClassRepresentatives( new,
          Permuted( OrdersClassRepresentatives( tbl ), perm ) );
    fi;
    if HasSizesCentralizers( tbl ) then
      SetSizesCentralizers( new,
          Permuted( SizesCentralizers( tbl ), perm ) );
    fi;
    for fus in ComputedClassFusions( tbl ) do
      Add( ComputedClassFusions( new ),
           rec( name:= fus.name, map:= Permuted( fus.map, perm ) ) );
    od;

    if HasComputedPowerMaps( tbl ) then

      tblmaps:= ComputedPowerMaps( tbl );
      permmap:= ListPerm( perm );
      inverse:= ListPerm( perm^(-1) );
      for k in [ Length( permmap ) + 1 .. NrConjugacyClasses( tbl ) ] do
        permmap[k]:= k;
        inverse[k]:= k;
      od;
      for k in [ 1 .. Length( tblmaps ) ] do
        if IsBound( tblmaps[k] ) then
          ComputedPowerMaps( new )[k]:= CompositionMaps( permmap,
              CompositionMaps( tblmaps[k], inverse ) );
        fi;
      od;

    fi;

    # The automorphisms of the sorted table are obtained on conjugation.
    if HasAutomorphismsOfTable( tbl ) then
      SetAutomorphismsOfTable( new, GroupByGenerators(
          List( GeneratorsOfGroup( AutomorphismsOfTable( tbl ) ),
                x -> x^perm ), () ) );
    fi;

    # Set the class permutation (important for fusions).
    if HasClassPermutation( tbl ) then
      SetClassPermutation( new, ClassPermutation( tbl ) * perm );
    else
      SetClassPermutation( new, perm );
    fi;

    # Return the new table.
    return new;
    end );


#############################################################################
##
#F  SortedCharacterTable( <tbl>, <kernel> )
#F  SortedCharacterTable( <tbl>, <normalseries> )
#F  SortedCharacterTable( <tbl>, <facttbl>, <kernel> )
##
InstallGlobalFunction( SortedCharacterTable, function( arg )

    local i, j, tbl, kernels, list, columns, rows, chi, F, facttbl, kernel,
          trans, ker, fus, new;

    # Check the arguments.
    if not ( Length( arg ) in [ 2, 3 ] and IsOrdinaryTable( arg[1] ) and
             IsList( arg[ Length( arg ) ] ) and
             ( Length( arg ) = 2 or IsOrdinaryTable( arg[2] ) ) ) then
      Error( "usage: SortedCharacterTable( <tbl>, <kernel> ) resp.\n",
             "       SortedCharacterTable( <tbl>, <normalseries> ) resp.\n",
             "       SortedCharacterTable( <tbl>, <facttbl>, <kernel> )" );
    fi;

    tbl:= arg[1];

    if Length( arg ) = 2 then

      # sort w.r. to kernel or series of kernels
      kernels:= arg[2];
      if IsEmpty( kernels ) then
        return tbl;
      fi;

      # regard single kernel as special case of normal series
      if IsInt( kernels[1] ) then
        kernels:= [ kernels ];
      fi;

      # permutation of classes\:
      # 'list[i] = k' if 'i' is contained in 'kernels[k]' but not
      # in 'kernels[k-1]'; only the first position contains a zero
      # to ensure that the identity is not moved.
      # If class 'i' is not contained in any of the kernels we have
      # 'list[i] = ""'.
      list:= [ 0 ];
      for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
        list[i]:= "";
      od;
      for i in [ 1 .. Length( kernels ) ] do
        for j in kernels[i] do
          if not IsInt( list[j] ) then
            list[j]:= i;
          fi;
        od;
      od;
      columns:= Sortex( list );

      # permutation of characters
      # 'list[i] = -(k+1)' if '<tbl>.irreducibles[i]' has 'kernels[k]'
      # in its kernel but not 'kernels[k+1]'; if the 'i'--th irreducible
      # contains none of 'kernels' in its kernel we have 'list[i] = -1',
      # for an irreducible with kernel containing 'kernels[ Length( kernels ) ]
      # the value is '-(Length( kernels ) + 1)'.
      list:= [];
      if HasIrr( tbl ) then
        for chi in Irr( tbl ) do
          i:= 1;
          while     i <= Length( kernels )
                and ForAll( kernels[i], x -> chi[x] = chi[1] ) do
            i:= i+1;
          od;
          Add( list, -i );
        od;
        rows:= Sortex( list );
      else
        rows:= ();
      fi;

    else

      # sort w.r. to table of factor group
      facttbl:= arg[2];
      kernel:= arg[3];
      F:= CharacterTableFactorGroup( tbl, kernel );
      trans:= TransformingPermutationsCharacterTables( F, facttbl );
      if trans = fail then
        Info( InfoCharacterTable, 2,
              "SortedCharacterTable: tables of factors not compatible" );
        return fail;
      fi;

      # permutation of classes\:
      # 'list[i] = k' if 'i' maps to the 'j'--th class of <F>, and
      # 'trans.columns[j] = i'
      list:= OnTuples( GetFusionMap( tbl, F ), trans.columns );
      columns:= Sortex( list );

      # permutation of characters\:
      # divide 'Irr( <tbl> )' into two parts, those containing
      # the kernel of the factor fusion in their kernel (value 0),
      # and the others (value 1); do not forget to permute characters
      # of the factor group with 'trans.rows'.
      if HasIrr( tbl ) then
        ker:= KernelChar( GetFusionMap( tbl, F ) );
        list:= [];
        for chi in Irr( tbl ) do
          if ForAll( ker, x -> chi[x] = chi[1] ) then
            Add( list, 0 );
          else
            Add( list, 1 );
          fi;
        od;
        rows:= Sortex( list ) * trans.rows;
      else
        rows:= ();
      fi;

      # delete the fusion to 'F' on 'tbl'
      fus:= ComputedClassFusions( tbl );
      Unbind( fus[ Length( fus ) ] );
#T better ?

    fi;

    # Sort and return.
    new:= CharacterTableWithSortedClasses( tbl, columns );
    new:= CharacterTableWithSortedCharacters( new, rows );
    return new;
end );


#############################################################################
##
#F  CASString( <tbl> )
##
InstallGlobalFunction( CASString, function( tbl )

    local ll,                 # line length
          CAS,                # the string, result
          i, j,               # loop variables
          convertcyclotom,    # local function, string of cyclotomic
          convertrow,         # local function, convert a whole list
          column,
          param,              # list of class parameters
          fus,                # loop over fusions
          tbl_irredinfo;

    ll:= SizeScreen()[1];

    if HasIdentifier( tbl ) then                        # name
      CAS:= Concatenation( "'", Identifier( tbl ), "'\n" );
    else
      CAS:= "'NN'\n";
    fi;
    Append( CAS, "00/00/00. 00.00.00.\n" );             # date
    if HasSizesCentralizers( tbl ) then                 # nccl, cvw, ctw
      Append( CAS, "(" );
      Append( CAS, String( Length( SizesCentralizers( tbl ) ) ) );
      Append( CAS, "," );
      Append( CAS, String( Length( SizesCentralizers( tbl ) ) ) );
      Append( CAS, ",0," );
    else
      Append( CAS, "(0,0,0," );
    fi;

    if HasIrr( tbl ) then
      Append( CAS, String( Length( Irr( tbl ) ) ) );    # max
      Append( CAS, "," );
      if Length( Irr( tbl ) ) = Length( Set( Irr( tbl ) ) ) then
        Append( CAS, "-1," );                           # link
      else
        Append( CAS, "0," );                            # link
      fi;
    fi;
    Append( CAS, "0)\n" );                              # tilt
    if HasInfoText( tbl ) then                          # text
      Append( CAS, "text:\n(#" );
      Append( CAS, InfoText( tbl ) );
      Append( CAS, "#),\n" );
    fi;

    convertcyclotom:= function( cyc )
    local i, str, coeffs;
    coeffs:= COEFFS_CYC( cyc );
    str:= Concatenation( "\n<w", String( Length( coeffs ) ), "," );
    if coeffs[1] <> 0 then
      Append( str, String( coeffs[1] ) );
    fi;
    i:= 2;
    while i <= Length( coeffs ) do
      if Length( str ) + Length( String( coeffs[i] ) )
                       + Length( String( i-1 ) ) + 4 >= ll then
        Append( CAS, str );
        Append( CAS, "\n" );
        str:= "";
      fi;
      if coeffs[i] < 0 then
        Append( str, "-" );
        if coeffs[i] <> -1 then
          Append( str, String( -coeffs[i] ) );
        fi;
        Append( str, "w" );
        Append( str, String( i-1 ) );
      elif coeffs[i] > 0 then
        Append( str, "+" );
        if coeffs[i] <> 1 then
          Append( str, String( coeffs[i] ) );
        fi;
        Append( str, "w" );
        Append( str, String( i-1 ) );
      fi;
      i:= i+1;
    od;
    Append( CAS, str );
    Append( CAS, "\n>\n" );
    end;

    convertrow:= function( list )
    local i, str;
    if IsCycInt( list[1] ) and not IsInt( list[1] ) then
      convertcyclotom( list[1] );
      str:= "";
    elif IsUnknown( list[1] ) or IsList( list[1] ) then
      str:= "?";
    else
      str:= ShallowCopy( String( list[1] ) );
    fi;
    i:= 2;
    while i <= Length( list ) do
      if IsCycInt( list[i] ) and not IsInt( list[i] ) then
        Append( CAS, str );
        Append( CAS, "," );
        convertcyclotom( list[i] );
        str:= "";
      elif IsUnknown( list[i] ) or IsList( list[i] ) then
        if Length( str ) + 4 < ll then
          Append( str, ",?" );
        else
          Append( CAS, str );
          Append( CAS, ",?\n" );
          str:= "";
        fi;
      else
        if Length(str) + Length( String(list[i]) ) + 5 < ll then
          Append( str, "," );
          Append( str, String( list[i] ) );
        else
          Append( CAS, str );
          Append( CAS, ",\n" );
          str:= String( list[i] );
        fi;
      fi;
      i:= i+1;
    od;
    Append( CAS, str );
    Append( CAS, "\n" );
    end;

    Append( CAS, "order=" );                            # order
    Append( CAS, String( Size( tbl ) ) );
    if HasSizesCentralizers( tbl ) then                 # centralizers
      Append( CAS, ",\ncentralizers:(\n" );
      convertrow( SizesCentralizers( tbl ) );
      Append( CAS, ")" );
    fi;
    if HasOrdersClassRepresentatives( tbl ) then        # orders
      Append( CAS, ",\nreps:(\n" );
      convertrow( OrdersClassRepresentatives( tbl ) );
      Append( CAS, ")" );
    fi;
    if HasComputedPowerMaps( tbl ) then                 # power maps
      for i in [ 1 .. Length( ComputedPowerMaps( tbl ) ) ] do
        if IsBound( ComputedPowerMaps( tbl )[i] ) then
          Append( CAS, ",\npowermap:" );
          Append( CAS, String(i) );
          Append( CAS, "(\n" );
          convertrow( ComputedPowerMaps( tbl )[i] );
          Append( CAS, ")" );
        fi;
      od;
    fi;
    if HasClassParameters( tbl )                        # classtext
       and ForAll( ClassParameters( tbl ),              # (partitions only)
                   x ->     IsList( x ) and Length( x ) = 2
                        and x[1] = 1 and IsList( x[2] )
                        and ForAll( x[2], IsPosInt ) ) then
      Append( CAS, ",\nclasstext:'part'\n($[" );
      param:= ClassParameters( tbl );
      convertrow( param[1][2] );
      Append( CAS, "]$" );
      for i in [ 2 .. Length( param ) ] do
        Append( CAS, "\n,$[" );
        convertrow( param[i][2] );
        Append( CAS, "]$" );
      od;
      Append( CAS, ")" );
    fi;
    if HasComputedClassFusions( tbl ) then              # fusions
      for fus in ComputedClassFusions( tbl ) do
        if IsBound( fus.type ) then
          if fus.type = "normal" then
            Append( CAS, ",\nnormal subgroup " );
          elif fus.type = "factor" then
            Append( CAS, ",\nfactor " );
          else
            Append( CAS, ",\n" );
          fi;
        else
          Append( CAS, ",\n" );
        fi;
        Append( CAS, "fusion:'" );
        Append( CAS, fus.name );
        Append( CAS, "'(\n" );
        convertrow( fus.map );
        Append( CAS, ")" );
      od;
    fi;
    if HasIrr( tbl ) then                              # irreducibles
      Append( CAS, ",\ncharacters:" );
      for i in Irr( tbl ) do
        Append( CAS, "\n(" );
        convertrow( i );
        Append( CAS, ",0:0)" );
      od;
    fi;
    if HasIrredInfo( tbl ) then                        # indicators, blocks
      tbl_irredinfo:= IrredInfo( tbl );
      if IsBound( tbl_irredinfo[1].block ) then
        for i in [ 2 .. Length( tbl_irredinfo[1].block ) ] do
          if IsBound( tbl_irredinfo[1].block[i] ) then
            column:= [];
            for j in [ 1 .. NrConjugacyClasses( tbl ) ] do
              column[j]:= tbl_irredinfo[j].block[i];
            od;
            Append( CAS, ",\nblocks:" );
            Append( CAS, String( i ) );
            Append( CAS, "(\n" );
            convertrow( column );
            Append( CAS, ")" );
          fi;
        od;
      fi;
      if IsBound( tbl_irredinfo[1].indicator ) then
        for i in [ 2 .. Length( tbl_irredinfo[1].indicator ) ] do
          if IsBound( tbl_irredinfo[1].indicator[i] ) then
            column:= [];
            for j in [ 1 .. Length( Irr( tbl ) ) ] do
              column[j]:= tbl_irredinfo[j].indicator[i];
            od;
            Append( CAS, ",\nindicator:" );
            Append( CAS, String( i ) );
            Append( CAS, "(\n" );
            convertrow( column );
            Append( CAS, ")" );
          fi;
        od;
      fi;
    fi;
    if 27 < ll then
      Append( CAS, ";\n/// converted from GAP" );
    else
      Append( CAS, ";\n///" );
    fi;
    return CAS;
end );


#############################################################################
##
#E

