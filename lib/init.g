#############################################################################
##
#W  init.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file initializes GAP.
##
Revision.init_g :=
    "@(#)$Id$";

#############################################################################
##
#F  OnBreak( )  . . . . . . . . . function to call at entry to the break loop
##
##
OnBreak := Where;

#############################################################################
##
#F  Ignore( <arg> ) . . . . . . . . . . . . ignore but evaluate the arguments
##
#T  1996/08/07 M.Schoenert 'Ignore' should be in the kernel
#T  1996/09/08 S.Linton    Do we need it at all?
##
Ignore := function ( arg )  end;


#############################################################################
##
##  Define some global variables
##
SetFilterObj := "2b defined";
infinity := "2b defined";


#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  This cannot be inside "kernel.g" because it is needed to read "kernel.g".
##
ReplacedString := function ( string, old, new )
    local  res,  i,  k,  l;
    res := [];
    k := 1;
    l := false;
    for i  in [1..LEN_LIST(string)]  do
        if string{[i..i+LEN_LIST(old)-1]} = old  then
            l := i;
        fi;
        if string[i] = ';'  then
            if l <> false  then
                APPEND_LIST_INTR( res, string{[k..l-1]} );
                APPEND_LIST_INTR( res, new );
                APPEND_LIST_INTR( res, string{[l+LEN_LIST(old)..i]} );
            else
                APPEND_LIST_INTR( res, string{[k..i]} );
            fi;
            k := i + 1;
            l := false;
        fi;
    od;
    if l <> false  then
        APPEND_LIST_INTR( res, string{[k..l-1]} );
        APPEND_LIST_INTR( res, new );
        APPEND_LIST_INTR( res, string{[l+LEN_LIST(old)..LEN_LIST(string)]} );
    else
        APPEND_LIST_INTR( res, string{[k..LEN_LIST(string)]} );
    fi;
    return res;
end;


#############################################################################
##
#V  InfoRead? . . . . . . . . . . . . . . . . . . . . print what file is read
##
if DEBUG_LOADING           then InfoRead1 := Print;   fi;
if not IsBound(InfoRead1)  then InfoRead1 := Ignore;  fi;
if not IsBound(InfoRead2)  then InfoRead2 := Ignore;  fi;


#############################################################################
##
#V  CHECK_INSTALL_METHOD  . . . . . .  check requirements in `INSTALL_METHOD'
##
CHECK_INSTALL_METHOD := true;


#############################################################################
##

#F  ReadGapRoot( <name> ) . . . . . . . . . .  read file from GAP's root area
##
ReadGapRoot := function( name )
    if not READ_GAP_ROOT(name)  then
        Error( "file \"", name, "\" must exist and be readable" );
    fi;
end;


IS_READ_OR_COMPLETE := false;

READED_FILES := [];

RANK_FILTER_LIST         := [];
RANK_FILTER_LIST_CURRENT := fail;
RANK_FILTER_COUNT        := fail;

RANK_FILTER_COMPLETION   := Error;	# defined in "filter.g"
RANK_FILTER_STORE        := Error;	# defined in "filter.g"
RANK_FILTER              := Error;	# defined in "filter.g"
RankFilter               := Error;      # defined in "filter.g"



#############################################################################
##
#F  ReadOrComplete( <name> )  . . . . . . . . . . . . read file or completion
##
COMPLETABLE_FILES := [];
COMPLETED_FILES   := [];

ReadOrComplete := function( name )
    local   comp,  check;

    READED_FILES := [];
    check        := CHECK_INSTALL_METHOD;

    # use completion files
    if CHECK_FOR_COMP_FILES  then
        comp := ReplacedString( name, ".g", ".co" );

        # do not check installation and use cached ranks
        CHECK_INSTALL_METHOD := false;
        RankFilter           := RANK_FILTER_COMPLETION;

        # check for the completion file
        if not READ_GAP_ROOT(comp)  then

            # set filter functions to store
            IS_READ_OR_COMPLETE  := true;
            CHECK_INSTALL_METHOD := check;
            RankFilter           := RANK_FILTER_STORE;
            RANK_FILTER_LIST     := [];

            # read the original file
            InfoRead1( "#I  reading ", name, "\n" );
            if not READ_GAP_ROOT(name)  then
                Error( "cannot read or complete file ", name );
            fi;
            ADD_LIST( COMPLETABLE_FILES, 
                      [ name, READED_FILES, RANK_FILTER_LIST ] );

        # file completed
        else
            ADD_LIST( COMPLETED_FILES, name );
            InfoRead1( "#I  completed ", name, "\n" );
        fi;

    else

        # set `RankFilter' to hash the ranks
        IS_READ_OR_COMPLETE := true;
        RankFilter          := RANK_FILTER_STORE;
        RANK_FILTER_LIST    := [];

        # read the file
        if not READ_GAP_ROOT(name)  then
            Error( "cannot read file ", name );
        fi;
        ADD_LIST( COMPLETABLE_FILES,
                  [ name, READED_FILES, RANK_FILTER_LIST ] );    
    fi;

    # reset rank and filter functions
    IS_READ_OR_COMPLETE  := false;
    CHECK_INSTALL_METHOD := check;
    RankFilter           := RANK_FILTER;
    Unbind(RANK_FILTER_LIST);
    Unbind(READED_FILES);
end;


#############################################################################
##
#F  READ_CHANGED_GAP_ROOT( <name> ) . . . . . .  completion file is out-dated
##
READ_CHANGED_GAP_ROOT := function( name )
    local   rankFilter;

    rankFilter := RankFilter;
    RankFilter := RANK_FILTER;
    Print( "#W  inconsistent completion for \"", name, "\"\n" );
    if not READ_GAP_ROOT(name)  then
        Error( "cannot read file ", name );
    fi;
    RankFilter := rankFilter;
end;


#############################################################################
##
##  We will need this stuff to be able to bind global variables. Thus it
##  must be done first.
##
ReadGapRoot( "lib/kernel.g" );
ReadGapRoot( "lib/global.g" );
ReadGapRoot( "lib/system.g" );

#############################################################################
##
## print the banner (but not on the Macintosh version)
##
ReadGapRoot( "lib/version.g" );
if not QUIET and BANNER and not ARCH_IS_MAC() then
  P := function(a) Print("   ", a, "\n" );  end;
  ReadGapRoot( "lib/banner.g" );
  Print("   Loading the library. Please be patient, this may take a while.\n");
fi;

#############################################################################
##
#F  ReadAndCheckFunc( <path>[,<libname>] )
##
##  'ReadAndCheckFunc' creates a function that  reads in a file named <name>,
##  this  name  must   include an extension.     The file  must  also  define
##  'Revision.<name_ext>'.
##  If a second argument 'libname' is given, GAP just prints a warning that 
##  the library <libname> was not found when the file cannot be read and
##  returns 'true' or 'false' according to the read status.
##  This can be used for partial reading of the library.
##
BIND_GLOBAL("ReadAndCheckFunc",function( arg )
  local  path,  prefix;

    path := IMMUTABLE_COPY_OBJ(arg[1]);

    if LEN_LIST(arg) = 1  then
        prefix := IMMUTABLE_COPY_OBJ("");
    else
        prefix := IMMUTABLE_COPY_OBJ(arg[2]);
    fi;

    return function( arg )
        local  name,  ext,  libname, error;

	error:=false;
	name:=arg[1];
        # create a filename from <path> and <name>
        libname := SHALLOW_COPY_OBJ(path);
        APPEND_LIST_INTR( libname, "/" );
        APPEND_LIST_INTR( libname, name );

        # we are completing, store the filename and filter ranks
        if IS_READ_OR_COMPLETE  then
            ADD_LIST( READED_FILES, libname );
            RANK_FILTER_LIST_CURRENT := [];
            RANK_FILTER_COUNT := 0;
            ADD_LIST( RANK_FILTER_LIST, RANK_FILTER_LIST_CURRENT );
            error:=not READ_GAP_ROOT(libname);
            Unbind(RANK_FILTER_LIST_CURRENT);
            Unbind(RANK_FILTER_COUNT);
        else
            error:=not READ_GAP_ROOT(libname);
        fi;

	if error then
	  if LEN_LIST( arg )=1 then
	    Error( "the library file '", name, "' must exist and ",
		   "be readable");
	  else
# we don't print a warning here but instead list the components at the end
#	    Print("#W  The library file '",name,"' was not available\n",
#	          "#W  The library of ",arg[2]," is not installed!\n");
	    return false;
	  fi;
	elif path<>"pkg" then
	  # check the revision entry
          ext := SHALLOW_COPY_OBJ(prefix);
	  APPEND_LIST_INTR(ext,ReplacedString( name, ".", "_" ));
	  if not IsBound(Revision.(ext))  then
	      Print( "#W  revision entry missing in \"", name, "\"\n" );
	  fi;
        fi;

      if LEN_LIST(arg)>1 then
	return true;
      fi;

    end;
end);

#############################################################################
##
#F  ReadLib( <name> ) . . . . . . . . . . . . . . . . . . . . . library files
#F  ReadGrp( <name> ) . . . . . . . . . . . . . . . . . . group library files
#F  ReadTbl( <name> ) . . . . . . . . . . . . . . . .  character tables files
#F  ReadTom( <name> ) . . . . . . . . . . . . . . . . .  table of marks files
#F  ReadSmall( <name> ) . . . . . . . . . . . . .  small groups library files
#F  ReadTrans( <name> ) . . . . . . . .  transitive perm groups library files
#F  ReadPrim( <name> )  . . . . . . . . . primitive perm groups library files
#F  DoReadPkg( <name> )  . . . . . . . . . read a package AS17/10/98
##
##  ReadPkg has to be a wrapper because it may not be executed while reading
##  `init.g' the first time. AH
##
BIND_GLOBAL("ReadLib",ReadAndCheckFunc("lib"));
BIND_GLOBAL("ReadGrp",ReadAndCheckFunc("grp"));
BIND_GLOBAL("ReadTbl",ReadAndCheckFunc("tbl"));
BIND_GLOBAL("ReadTom",ReadAndCheckFunc("tom"));
BIND_GLOBAL("ReadSmall",ReadAndCheckFunc("small"));
BIND_GLOBAL("ReadTrans",ReadAndCheckFunc("trans"));
BIND_GLOBAL("ReadPrim",ReadAndCheckFunc("prim"));
BIND_GLOBAL("DoReadPkg",ReadAndCheckFunc("pkg"));


#############################################################################
##
##  Define functions which may not be available to avoid syntax errors
##
NONAVAILABLE_FUNC:=function(arg)
  Error("this function is not available");
end;
IdGroup:=NONAVAILABLE_FUNC; # will be overwritten if loaded
SmallGroup:=NONAVAILABLE_FUNC; # will be overwritten if loaded
NumberSmallGroups:=NONAVAILABLE_FUNC; # will be overwritten if loaded
AllGroups:=NONAVAILABLE_FUNC; # will be overwritten if loaded
OneGroup:=NONAVAILABLE_FUNC; # will be overwritten if loaded
IdsOfAllGroups:=NONAVAILABLE_FUNC; # will be overwritten if loaded      
Gap3CatalogueIdGroup:=NONAVAILABLE_FUNC; # will be overwritten if loaded
PrimitiveGroup:=NONAVAILABLE_FUNC; # will be overwritten if loaded           
NrAffinePrimitiveGroups:=NONAVAILABLE_FUNC; # will be overwritten if loaded
NrSolvableAffinePrimitiveGroups:=NONAVAILABLE_FUNC;

#############################################################################
##  
##  Initialize functions for the source of small group lib and id library
##
SMALL_AVAILABLE := x -> fail;
ID_AVAILABLE := x -> fail;                                  
  
#############################################################################
##                              
#V  PRIM_AVAILABLE   variables for data libraries. Will be set during loading
#V  TRANS_AVAILABLE
#V  TBL_AVAILABLE                                                            
#V  TOM_AVAILABLE
PRIM_AVAILABLE:=false;
TRANS_AVAILABLE:=false;
TBL_AVAILABLE:=false;
TOM_AVAILABLE:=false;

#############################################################################
##
#F  DeclareComponent(<componentname>,<versionstring>)
#V  LOADED_COMPONENTS
##
LOADED_COMPONENTS:=rec();
BIND_GLOBAL("DeclareComponent",function(name,version)
  LOADED_COMPONENTS.(name):=version;
end);

#############################################################################
##
#X  read in the files
##

# inner functions, needed in the kernel
ReadGapRoot( "lib/read1.g" );
ExportToKernelFinished();

ReadOrComplete( "lib/read2.g" );
ReadOrComplete( "lib/read3.g" );

# help system, profiling
ReadOrComplete( "lib/read4.g" );

#T  1996/09/01 M.Schoenert this helps performance
IMPLICATIONS:=IMPLICATIONS{[Length(IMPLICATIONS),Length(IMPLICATIONS)-1..1]};
HIDDEN_IMPS:=HIDDEN_IMPS{[Length(HIDDEN_IMPS),Length(HIDDEN_IMPS)-1..1]};

# we cannot complete the following command because printing may mess up the
# backslash-masked characters!
BIND_GLOBAL("VIEW_STRING_SPECIAL_CHARACTERS",
  # The first list is sorted an contains special characters. The second list
  # contains characters that should instead be printed after a `\'.
  Immutable([ "\c\b\n\r\"\\", "cbnr\"\\" ]));

ReadOrComplete( "lib/read5.g" );

ReadOrComplete( "lib/read6.g" );

# character theory stuff
ReadOrComplete( "lib/read7.g" );

# overloaded operations
ReadOrComplete( "lib/read8.g" );


#############################################################################
##
##  Load data libraries
##  The data libraries which may be absent cannot be completed, therefore
##  they must be read in here!

#############################################################################
##
#X  Read library of groups of small order
#X  Read identification routine
##
ReadSmall( "readsml.g","small groups" );

#############################################################################
##
#X  Read transitive groups library
##
TRANS_AVAILABLE:=ReadTrans( "trans.gd","transitive groups" );
TRANS_AVAILABLE:= TRANS_AVAILABLE and ReadTrans( "trans.grp",
                                        "transitive groups" );

#############################################################################
##
#X  Read primitive groups library
##
PRIM_AVAILABLE:=ReadPrim( "primitiv.gd","primitive groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.grp",
                                     "irreducible solvable groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "primitiv.gi",
                                     "primitive groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "primitiv.grp",
                                     "primitive groups" );

#############################################################################
##
#X  character table library
##
TBL_AVAILABLE:=ReadTbl( "ctadmin.tbd","character tables");
TBL_AVAILABLE:=TBL_AVAILABLE and ReadTbl( "ctadmin.tbi","character tables");


#############################################################################
##
#X  table of marks library
##
TOM_AVAILABLE:=ReadTom( "tmadmin.tmd","tables of marks");
TOM_AVAILABLE:=TOM_AVAILABLE and ReadTom( "tmadmin.tmi","tables of marks");


#############################################################################
##
##  Display version, loaded components and packages
##
if not QUIET and BANNER then
#  # erase the `wait' line
#  for P in [1..77] do
#    Print("\b\c");
#  od;
  Print("GAP4, Version: ",VERSION," of ",DATE,", ", GAP_ARCHITECTURE, "\n" );
  if LOADED_COMPONENTS<>rec() then
    Print("Components:  ");
    PL:=11;
    P:=false;
    for COMPONENTNAME in RecNames(LOADED_COMPONENTS) do
      if P<>false then
        Print(", ");
      fi;
      if PL>60 then
	Print("\n             ");
	PL:=11;
      fi;
      Print(COMPONENTNAME,"\c");
      PL:=PL+Length(COMPONENTNAME)+2;
      P:=true;
    od;
    Print("  installed.\n");
  fi;
fi;


#############################################################################
##
##  Deal with compatibility mode via command line option `-O'.
##
if false = fail then ReadLib( "compat3d.g" ); fi;

# determine which packages to load
AUTOLOAD_PACKAGES:= AutoloadablePackagesList();

#############################################################################
##
##  Read the .gaprc file
##
READ(GAP_RC_FILE);

#############################################################################
##
##  Autoload packages
##
IS_IN_AUTOLOAD:=true;
for COMPONENTNAME in AUTOLOAD_PACKAGES do
  Info(InfoWarning,2,"autoloading:",COMPONENTNAME,"\n");
  RequirePackage(COMPONENTNAME);
od;
IS_IN_AUTOLOAD:=false;

#############################################################################
##
##  Display version, loaded components and packages
##
if not QUIET and BANNER and LOADED_PACKAGES<>rec() then
  Print("Packages:    ");
  PL:=11;
  P:=false;
  for COMPONENTNAME in RecNames(LOADED_PACKAGES) do
    if P<>false then
      Print(", ");
    fi;
    if PL>60 then
      Print("\n             ");
      PL:=11;
    fi;
    Print(COMPONENTNAME,"\c");
    PL:=PL+Length(COMPONENTNAME)+2;
    P:=true;
  od;
  Print("  installed.\n");
fi;


#############################################################################
##
##  Finally, deal with the lists of global variables.
##  This must be done at the end of this file,
##  since the variables defined in packages are regarded as system variables.
##  (But also the variables defined in the file `GAP_RC_FILE' are regarded as
##  system variables this way; is this inconvenient?)
##

#############################################################################
##
#F  NamesGVars()  . . . . . . . . . . . list of names of all global variables
##
##  This function returns an immutable (see~"Mutability and Copyability")
##  sorted (see~"Sorted Lists and Sets") list of all the global                
##  variable names known to the system.  This includes names of variables
##  which were bound but have now been unbound and some other names which
##  have never been bound but have become known to the system by various
##  routes.                                                           
##
BindGlobal( "NamesGVars", function()
    local names;
    names:= Set( IDENTS_GVAR() );
    MakeImmutable( names );
    return names;
end );


#############################################################################
##
#F  NamesSystemGVars()  . . . . . .  list of names of system global variables
##
##  This function returns an immutable sorted list of all the global        
##  variable names created by the {\GAP} library when {\GAP} was started.
##
NAMES_SYSTEM_GVARS := Filtered( IDENTS_GVAR(), ISB_GVAR );
Add( NAMES_SYSTEM_GVARS, "NamesUserGVars" );
Add( NAMES_SYSTEM_GVARS, "NamesSystemGVars" );
Add( NAMES_SYSTEM_GVARS, "NAMES_SYSTEM_GVARS" );
Add( NAMES_SYSTEM_GVARS, "last" );
Add( NAMES_SYSTEM_GVARS, "last2" );
Add( NAMES_SYSTEM_GVARS, "last3" );
Add( NAMES_SYSTEM_GVARS, "time" );
NAMES_SYSTEM_GVARS := Set( NAMES_SYSTEM_GVARS );
MakeImmutable( NAMES_SYSTEM_GVARS );
MakeReadOnlyGlobal( "NAMES_SYSTEM_GVARS" );

BIND_GLOBAL( "NamesSystemGVars", function()
    return NAMES_SYSTEM_GVARS;
end);


#############################################################################
##
#F  NamesUserGVars()  . . . . . . . .  list of names of user global variables
##
##  This function returns an immutable sorted list of the global variable
##  names created since the library was read, to which a value is
##  currently bound.                                                         
##
BIND_GLOBAL( "NamesUserGVars", function()
    local names;
    names:= Filtered( Difference( NamesGVars(), NamesSystemGVars() ),
                      ISB_GVAR );
    MakeImmutable( names );
    return names;
end);


#############################################################################
##
#E
##

