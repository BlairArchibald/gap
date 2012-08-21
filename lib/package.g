#############################################################################
##
#W  package.g                   GAP Library                      Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains support for {\GAP} packages.
##
Revision.package_g :=
    "@(#)$Id$";

#############################################################################
##
#F  CompareVersionNumbers(<supplied>,<required>)
##
##  compares two version numbers, given as strings. They are split at
##  non-number characters, the resulting integer lists are compared
##  lexicographically. The routine tests, whether <supplied> is at least as
##  large as <required> and returns `true' or `false' accordingly. A version
##  number ending in `dev' is considered to be infinite.
##  See Section~"ext:Version Numbers" of ``Extending GAP'' for details
##  about version numbers.
BindGlobal("CompareVersionNumbers",function(s,r)
local i,j,a,b;
  # special tratment of a ".dev" version
  if Length(s)>4 and s{[Length(s)-2..Length(s)]}="dev" then
    return true;
  elif Length(r)>4 and r{[Length(r)-2..Length(r)]}="dev" then
    return false;
  fi;

  i:=1;
  j:=1;
  while Length(s)>=i or Length(r)>=j do
    if Length(s)=0 then
      return false;
    elif Length(r)=0 then
      return true;
    fi;

    # read the next numbers
    while i<=Length(s) and IsDigitChar(s[i]) do
      i:=i+1;
    od;
    while j<=Length(r) and IsDigitChar(r[j]) do
      j:=j+1;
    od;
    a:=Int(s{[1..i-1]});
    b:=Int(r{[1..j-1]});
    if a<b then
      return false;
    elif a>b then
      return true;
    fi;
    # read the next nonnumbers
    while i<=Length(s) and not IsDigitChar(s[i]) do
      i:=i+1;
    od;
    s:=s{[i..Length(s)]};
    i:=1;
    while j<=Length(r) and not IsDigitChar(r[j]) do
      j:=j+1;
    od;
    r:=r{[j..Length(r)]};
    j:=1;
  od;
  return true;
end);

#############################################################################
##  
#V  LOADED_PACKAGES
##
##  This is a mutable record, the component names are the packages that are
##  currently loaded.
##  The component for each package is a list of length two,
##  the first entry being the path to the {\GAP} root directory that contains
##  the package, 
##  and the second being a list used by `CreateCompletionFilesPkg'.
##
##  For each package, the component with its first entry get bound in the
##  `RequirePackage' call, and the second entry gets bound in the
##  `ReadOrComplete' call (in `ReadOrCompletePkg').
##
BindGlobal( "LOADED_PACKAGES", rec() );

BindGlobal( "PACKAGES_AVAILABLE_VERSIONS", rec() ); 
BindGlobal( "PACKAGES_VERSIONS", rec() ); # versions of *loaded* packages
BindGlobal( "PACKAGES_NAMES", rec() );    # names of *loaded* packages

# CURRENTLY_TESTED_PACKAGES contains the version numbers of packages
# which are currently tested for availability
CURRENTLY_TESTED_PACKAGES := rec();

#############################################################################
##  
#V  AUTOLOAD_PACKAGES
##  
##  This list contains the names of packages which may not be autoloaded
##  automatically. This permits the user
##  to disable the automatic loading of certain packages which are properly
##  installed by simply removing package names from `AUTOLOAD_PACKAGES'
##  via a line in their `.gaprc' file.
##  
AUTOLOAD_PACKAGES := [];

IS_IN_AUTOLOAD := false;     # indicates whether we are
                             # in the autoload stage
IS_IN_PACKAGE_TEST := false; # indicates whether package
                             # availability is tested.
IS_IN_PACKAGE_LOAD := false; # indicates whether currently
                             # already a package is being
                             # loaded
AUTOLOAD_LOAD_DOCU := false; # set to `true' to enable
                             # `DeclarePackageAutoDocumentation'
                             # during `TestPackageAvailability' of autoload
                             # when the package itself is *not* to be loaded 
                             # (i.e. at the same time disables `Re(re)adPkg') 

#############################################################################
##
#F  TestPackageAvailability( <name>, <version> )
##  
##  tests, whether the  {\GAP} package <name> is available for  loading in a
##  version that is at least <version>.  It returns `true' if the package is
##  already loaded, `fail' if it is not available, and the directory path to
##  the package if it is available, but not yet loaded. A test function (the
##  third  parameter  to `DeclarePackage')  should  therefore  test for  the
##  result  of  `TestPackageAvailability' being  not  equal  to `fail'.  The
##  argument <name> is case insensitive.
##  
BindGlobal( "TestPackageAvailability", function(name,ver)
local init,path,isin;
 
  if IS_IN_AUTOLOAD and IS_IN_PACKAGE_TEST then 
                             # necessary because `TestPackageAvailability'
    return false;            # may occur in a package's init.g file
  fi;                        # ... don't return `fail' here as a workaround
                             # for package NQ which may o/wise do Error in
                             # autoloading

  name := LowercaseString(name);
  # Is the package already installed?
  if IsBound(PACKAGES_VERSIONS.(name)) and 
    CompareVersionNumbers(PACKAGES_VERSIONS.(name),ver) 
    and IsBound(LOADED_PACKAGES.(name)) then
      return true;
  fi;
  
  # Is the package already currently tested for availability?
  if IsBound(CURRENTLY_TESTED_PACKAGES.(name)) and 
    CompareVersionNumbers(CURRENTLY_TESTED_PACKAGES.(name),ver) then
      return true; # only to avoid recursion. This response is a
      # conditional `true', provided the other packages will be OK.
  fi;

  # locate the init file
  path := DirectoriesPackageLibrary(name,"");
  if path = fail  then
    Info(InfoWarning,3,"Package `", name, "' does not exist" );
    return fail;
  fi;
  init := Filename( path, "init.g" );
  if init = fail  then
    Info(InfoWarning,1,"Package `",name,
         "': cannot locate `init.g', please check the installation" );
    return fail;
  fi;

  # read the `init' file once, ignoring all but `Declare(Auto)Package'
  isin:=IS_IN_PACKAGE_TEST;
  IS_IN_PACKAGE_TEST:=true;
  Info(InfoWarning, 3, "TestPackageAvailability: reading init.g of package ",
                       name); 
  Read(init);
  IS_IN_PACKAGE_TEST:=isin;

  # on the ``outermost'' level clean the test pool info
  if isin=false then
    CURRENTLY_TESTED_PACKAGES := rec();
  fi;

  if not IsBound(PACKAGES_VERSIONS.(name)) then
    if not AUTOLOAD_LOAD_DOCU then
      # the package requirements were not fulfilled
      Info(InfoWarning,3,"Package ``",name,"'' has unfulfilled requirements");
    fi;
    return fail;
  fi;

  # Make sure the version number we found is high enough -- AS 20/4/99
  if not CompareVersionNumbers(PACKAGES_VERSIONS.(name),ver) then
      return fail;
  fi;

  # Ah, everything worked. Return the path
  return path;
end );

#############################################################################
##
#F  ReadOrCompletePkg( <name> ) 
##
##  Go to package directory <name> and read read.g or read.co - whichever
##  is appropriate. The argument <name> is case insensitive. AS 17/10/98
##
BindGlobal("ReadOrCompletePkg",function( package )
    local   comp,  check, name;

    package := LowercaseString(package);
    name := Concatenation("pkg/",package,"/read.g");
    comp := Concatenation("pkg/",package,"/read.co");
    READED_FILES := [];
    check        := CHECK_INSTALL_METHOD;

    # use completion files
    if CHECK_FOR_COMP_FILES  then

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
            ADD_LIST( LOADED_PACKAGES.(package), 
                      [name, READED_FILES, RANK_FILTER_LIST ] );
                      # name is redundant, but we keep it for consistency 
                      # with the lib case. Also admits the possibility 
                      # of more than 1 read file per package.

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
        ADD_LIST( LOADED_PACKAGES.(package), 
                  [ name, READED_FILES, RANK_FILTER_LIST ] );    
    fi;

    # reset rank and filter functions
    IS_READ_OR_COMPLETE  := false;
    CHECK_INSTALL_METHOD := check;
    RankFilter           := RANK_FILTER;
    Unbind(RANK_FILTER_LIST);
    Unbind(READED_FILES);
end);

#############################################################################
##
#F  InstalledPackageVersion( <name> )
##
##  returns the version number string of the package <name> if it is installed
##  and `fail' otherwise. The <name> argument is case insensitive.
##  
BindGlobal( "InstalledPackageVersion", function(name)
local init;
 
  name := LowercaseString(name);
  # Is the package already installed?
  if IsBound(PACKAGES_VERSIONS.(name)) then
    return PACKAGES_VERSIONS.(name);
  else
    return fail;
  fi;
end);

#############################################################################
##
#F  TestIfPackageCurrent(<name>,<forauto>)
##
##  This function tests, whether the package <name> might require an update
##  for loading. It returns `true' if the package should still be loaded and
##  `false' otherwise.
##  The <forauto> flag indicates whether we are in an autoload
##  situation.
##  This function uses the variable `UPDATED_PACKAGES' which is defined in
##  `version.g'.
BindGlobal("TestIfPackageCurrent",function(name,forauto)
local pkg;
  if name = "anupq" and TestPackageAvailability(name, "1.5") = fail and
	TestPackageAvailability(name, "1.4") <> fail then
	Print("\n","  This version (1.4) of the ANUPQ package contains ",
	"known, dandgerous bugs\n     in the PqDescendants function\n",
        "    Please upgrade to version 1.5 if it is avaiable yet. In the meantime\n",
	"    please do not trust results from PqDescendants\n\n");		
    return true;		
  fi;			
  if IsBound( UPDATED_PACKAGES.(name) ) then
    pkg := UPDATED_PACKAGES.(name);
    if TestPackageAvailability(name, pkg.safeversion) = fail then
      if IsBound(pkg.quietAutoload) and pkg.quietAutoload=true
	and IS_IN_AUTOLOAD then
	Info(InfoWarning,3,"Package ",name, " ignoring test");
	return true;
      elif not IsBound( PACKAGES_AVAILABLE_VERSIONS.(name) ) then
        # package is either not installed in any version or 
        # its installation is incomplete
        return false;
      fi;

      Print("\n",
            "  The package `",name,"' is installed in a ",
                "version older than ", pkg.safeversion, ".\n",
            "  ", pkg.message, "\n",
            "  It is strongly recommended to update to the ",
                "most recent version which can\n",
            "  be found at URL:\n",
            "      ", pkg.urlForUpdate, "\n");
      if pkg.refuseLoad then
	  Print(
            "  The non-upgraded package cannot be loaded.\n",
            "\n");
          return false;
      elif forauto then
        if pkg.refuseAutoload then
	  Print(
            "  The package will not autoload in this ",
                "non-upgraded version.\n",
            "  It is still possible to load it by hand by issuing ",
                "the command:\n",
            "      RequirePackage(\"",name,"\");\n",
            "\n");
	  return false;
	else
	  Print(
            "  The package is still autoloaded, but you ",
                "might encounter problems when\n",
	    "  using package functionality.\n");
	fi;
      fi;
      Print("\n");
    fi;
  fi;
  return true;
end);


#############################################################################
##
#F  RequirePackage( <name>, [<version>] )
##  
##  loads  the  {\GAP}  package  <name>.  If  the  optional  version  string
##  <version> is given, the package will  only be loaded in a version number
##  at least as large as <version> (see~"ext:Version Numbers" in ``Extending
##  GAP''). The argument <name> is case insensitive.
##  
##  `RequirePackage' will return `true' if the package has been successfully
##  loaded and  will return `fail' if  the package could not  be loaded. The
##  latter may  be the case  if the package  is not installed,  if necessary
##  binaries  have not  been compiled  or if  the available  version is  too
##  small. If the package <name> has already been loaded in a version number
##  at  least  <version>,  `RequirePackage'  returns  `true'  without  doing
##  anything.
##  
DELAYED_PACKAGE_LOAD := [];
# if package is not autoloading.
BindGlobal( "RequirePackage", function(arg)
local name,ver,init,path,isin, package, isauto;

  Info(InfoWarning, 3, "testing? ", IS_IN_PACKAGE_TEST, " autoload? ",
                       IS_IN_AUTOLOAD);
  if IS_IN_PACKAGE_TEST=true then
    # if we are testing the availability of another package, a
    # `RequirePackage' in its `init.g' file will be ignored.
    return true;
  fi;

  name:= LowercaseString( arg[1] );


  if Length(arg)>1 then
    ver:=arg[2];
  else
    ver:="";
  fi;

  if not IS_IN_AUTOLOAD then
    # issue warning, and possibly fail, if old version
    if not TestIfPackageCurrent(name,false) then
      return fail;
    fi;
  fi;

  # test whether the package is available for requiring
  path:=TestPackageAvailability(name,ver);

  if path=fail then
    return fail; # package not available
  elif path=true and IsBound(LOADED_PACKAGES.(name)) then
    return true; # package already loaded
  fi;

  
  # Store the directory containing the `init.g' file as the first entry.
  LOADED_PACKAGES.( name ):= [ path ];

  init:= Filename( path, "init.g" );

  isin:=IS_IN_PACKAGE_LOAD;
  IS_IN_PACKAGE_LOAD:=true;

  LOADED_PACKAGES.(name) := path;

  # in case of autoloading we switch off the IS_IN_AUTOLOAD flag here
  # to handle explicit RequirePackage calls in init.g
  isauto := IS_IN_AUTOLOAD;
  IS_IN_AUTOLOAD := false;
  
  # and finally read it
  Read(init);

  # test whether there is also a `read.g' file?
  init := Filename( path, "read.g" );
  if init<>fail  then
    Add(DELAYED_PACKAGE_LOAD,name);#changed init to name of package
  fi;

  # reset original values
  IS_IN_PACKAGE_LOAD:=isin;
  IS_IN_AUTOLOAD:=isauto;
  
  # if this is the ``outermost'' `Require', we finally load all the
  # potentially delayed `read.g' files that contain the actual
  # implementation.
  if isin=false then
    for package in DELAYED_PACKAGE_LOAD do
        ReadOrCompletePkg(package); 
        #AS 17/10/99  This will become ReadOrCompletePkg
    od;
    DELAYED_PACKAGE_LOAD:=[];
  fi;

  return true; #package loaded

end );

#############################################################################
##
#F  DeclarePackage( <name>, <version>, <tester> )
#F  DeclareAutoPackage( <name>, <version>, <tester> )
##  
##  This function  may only  occur within  the `init.g'  file of  the {\GAP}
##  package  <name>. It  prepares the  installation of  the package  <name>,
##  which  will  be  installed  in version  <version>.  The  third  argument
##  <tester>  is a  function which  tests for  necessary conditions  for the
##  package  to  be  loadable,  like  the  availability  of  other  packages
##  (using `TestPackageAvailability',  see "TestPackageAvailability")  or --
##  if necessary  -- the  existence of compiled  binaries. It  should return
##  `true'  only if  all conditions  are  fulfilled (and  `false' or  `fail'
##  otherwise).  If it  does  not return  `true', the  package  will not  be
##  loaded, and the documentation will  not be available. The second version
##  `DeclareAutoPackage' declares the package  and enables automatic loading
##  when {\GAP} is started. (Because  potentially all installed packages are
##  automatically loaded, the <tester> function should take little time.)
##  
##  The argument <name> is case   sensitive.  But note that the package name
##  is internally  converted to  a lower  case string;  so, there  cannot be
##  different packages with names which are only distinguished by case.
##  
# 
# The difference between the `Auto' and the other version is that in case of
# IS_IN_AUTOLOAD the component PACKAGES_VERSIONS.(lname) is bound only with
# the `Auto' version. This leads to different behaviour in `RequirePackage'
# when it asks for package availability.
# 
BindGlobal( "DeclareAutoPackage", function( name, version, tester )
  local lname;

  # normalize name to lowercase
  lname := LowercaseString(name);
  Info(InfoWarning, 3, "Declared package `", name, "' version: ", version);

  AUTOLOAD_LOAD_DOCU:=false;
  CURRENTLY_TESTED_PACKAGES.(lname):=version;
  # test availability
  if IS_IN_PACKAGE_TEST=false then
    # we have tested the availability already before
    tester:=true;
  elif tester<>true then
    # test availability
    tester:=tester();
  fi;
  if tester=true then
    PACKAGES_AVAILABLE_VERSIONS.(lname):=version;
    if not (IsBound(UPDATED_PACKAGES.(lname)) and
            not CompareVersionNumbers(
                    version, UPDATED_PACKAGES.(lname).safeversion) and
            (UPDATED_PACKAGES.(lname).refuseLoad or
             IS_IN_AUTOLOAD and UPDATED_PACKAGES.(lname).refuseAutoload)) then
      PACKAGES_VERSIONS.(lname):=Immutable(version);
      PACKAGES_NAMES.(lname):=Immutable(name);
    fi;
  else
    AUTOLOAD_LOAD_DOCU:=true;
  fi;
end );

BindGlobal( "DeclarePackage", function( name, version, tester )
  if IS_IN_AUTOLOAD=false then
    DeclareAutoPackage( name, version, tester );
    AUTOLOAD_LOAD_DOCU:=false;
  else
    # the package is not intended for autoloading. So at least we give the
    # documentation a chance
    AUTOLOAD_LOAD_DOCU:=true;
  fi;
end );

#############################################################################
##
#F  DeclarePackageDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  DeclarePackageAutoDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
##
##  This  function indicates  that the  documentation of  the {\GAP} package
##  <name> can  be found in its  <doc> subdirectory. The second  version will
##  enable  that  the  documentation  is loaded  automatically  when  {\GAP}
##  starts, even if the package itself will not be loaded.
##  
##  Both  functions may  only  occur within  the `init.g'  file  of a {\GAP}
##  package.
##  
##  The string <name> is case insensitive (but internally  converted to lower
##  case, e.g., for the directory name of the package). 
##  
##  There are  two optional arguments:  <short> is  a short string  which is
##  used as identifying name of the book in {\GAP}'s online help. And <long>
##  is a  short description  of the  book. This is  shown with  the `?books'
##  query, so <short> and <long> together should easily fit on a line.
##  
##  If <short> and <long> are not given, the default values <name> for
##  <short> and `GAP Package `<name>'' for <long> are used.
##  
BindGlobal( "DeclarePackageAutoDocumentation", function( arg )
  local pkg, doc, short, long, file;

  if IS_IN_PACKAGE_TEST and not AUTOLOAD_LOAD_DOCU then 
    # `DeclarePackage(Auto)Documentation' is a noop during
    # `TestPackageAvailability' but not during a `RequirePackage'
    return;
  fi;

  pkg := arg[1];
  doc := arg[2];
  if Length(arg) > 2 then
    short := arg[3];
  else
    short := pkg;
  fi;
  if Length(arg) > 3 then
    long := arg[4];
  else
    long := Concatenation("GAP Package `", pkg, "'" );
  fi;

  Info(InfoWarning, 3, "(auto)loading documentation for: ", pkg);
  
  # test for the existence of a `manual.six' file
  file := Filename(DirectoriesPackageLibrary(LowercaseString(pkg),doc),
                   "manual.six");
  if file = fail then
    # if we are not autoloading print a warning that the documentation
    # is not available.
    Info(InfoWarning,1,"Package `",pkg,
         "': cannot load documentation, no manual index file `",doc,
         "/manual.six'" );
  else
    # declare the location
    doc := Directory(file{[1..Length(file)-10]});
    if not IsBound(LOADED_PACKAGES.(LowercaseString(pkg))) then
      # indicate that the package still needs requiring
      short := Concatenation(short," (not loaded)");
    fi;
    HELP_ADD_BOOK(short, long, doc);
  fi;

end );

BindGlobal( "DeclarePackageDocumentation", function( arg )
  if IS_IN_AUTOLOAD=false then
    CallFuncList(DeclarePackageAutoDocumentation, arg);
  fi;
end );

# now come some technical functions to support autoloading

##  a helper, get records from a file
##  First removes everything in each line which starts with a `#', then
##  splits remaining content at whitespace.
BindGlobal("RECORDS_FILE", function(name)
  local str, rows, recs, pos, r;
  str := StringFile(name);
  if str = fail then
    return [];
  fi;
  rows := SplitString(str,"","\n");
  recs := [];
  for r in rows do
    # remove comments starting with `#'
    pos := Position(r, '#');
    if pos <> fail then
      r := r{[1..pos-1]};
    fi;
    Append(recs, SplitString(r, "", " \n\t\r"));
  od;
  return recs;
end);

#############################################################################
##
#F  AutoloadablePackagesList()
##
##  this function returns a list of all existing packages which are
##  permissible for automatic loading.
##  As there is no kernel functionality yet for getting a list of
##  subdirectories, we use the file `pkg/ALLPKG'.
BindGlobal("AutoloadablePackagesList",function()
    local paks, pkgdirs, nopaks, f, test, pkgdir;
    paks:=[];
    
    if DO_AUTOLOAD_PACKAGES = false then
        return paks;
    fi;
    
    pkgdirs:=DirectoriesLibrary("pkg");
    if pkgdirs=fail then
        return paks;
    fi;

    for pkgdir in pkgdirs do 
      nopaks:=[];
      # note the names of packages which are deliberately set in `pkg/NOAUTO'
      f:=Filename([pkgdir],"NOAUTO");
      if f<>fail then
          nopaks := List(RECORDS_FILE(f), LowercaseString);
      fi;

      # get the lines from `ALLPKG' and test whether they are subdirectories
      # which contain an `init' file.
      f:=Filename([pkgdir],"ALLPKG");
      if f<>fail then
          test := function(name)
            local pkg;
            pkg := Filename([pkgdir], name);
            return (not name in nopaks) and
                   pkg <> fail and
                   Filename([Directory(pkg)],"init.g") <> fail;
          end;
          Append(paks, Filtered(List(RECORDS_FILE(f), LowercaseString), test));
      fi;
    od;
    return Set( paks );

end);

#############################################################################
##
#F  ReadPkg(<name>,<file>)
##
##  reads the file <file> of the {\GAP} package <name>, where <file> is given
##  as a relative path to the directory of <name>. The <name> argument is
##  case insensitive.
##
BindGlobal( "ReadPkg", function( arg )
# This must be a wrapper to be skipped when `init.g' is read the first
# time. It must also be skipped if Declare(Auto)Package returns fail
# (in this case, AUTOLOAD_LOAD_DOCU is true).
local path;
  if IS_IN_PACKAGE_TEST=false and AUTOLOAD_LOAD_DOCU=false then
    # normalize package name to lower case
    arg[1] := LowercaseString(arg[1]);
    if Length(arg)=1 then
      path:=arg[1];
    else
      path:=Concatenation(arg[1],"/",arg[2]);
    fi;
    DoReadPkg(path);
  fi;
end);


#############################################################################
##
#F  RereadPkg( <name>, <file> )
#F  RereadPkg( <pkg-file> )
##
##  In the first form, `RereadPkg' rereads  the  file  <file>  of  the {\GAP}
##  package <name>, where <file> is given as a relative path to the  directory
##  of <name>. In the second form where only one argument <pkg-file> is given,
##  <pkg-file> should be the complete path of a  file  relative  to  a  `pkg'
##  subdirectory of a {\GAP} root path (see~"ref:GAP root directory"  in  the
##  Reference Manual). Each of <name>,  <file>  and  <pkg-file>  should  be  a
##  string. The <name> is case insensitive.
##
BindGlobal( "RereadPkg", function( arg )
    if IS_IN_PACKAGE_TEST = false and AUTOLOAD_LOAD_DOCU = false then
      # normalize package name to lower case
      arg[1] := LowercaseString(arg[1]);
      if Length( arg ) = 1 then
        DoRereadPkg( arg[1] );
      elif Length( arg ) = 2 then
        DoRereadPkg( Concatenation( arg[1], "/", arg[2] ) );
      else
        Error("expected 1 or 2 arguments\n");
      fi;
    fi;
end );


#############################################################################
##
#M  CreateCompletionFilesPkg( <name> )  . . create "pkg/<name>/read.co" files
##
## AS: minor modification of  CreateCompletionFiles

BindGlobal( "CreateCompletionFilesPkg", function( name )
local   path,  input,   com,  read,  j,  crc, filesandfilts;
  # normalize name to lower case
  name := LowercaseString(name);
  if not IsBound(LOADED_PACKAGES.(name))  then
    Error("Can't create read.co for package ", name, " - package not loaded.");
    return false;
  fi;
  if not IsBound(LOADED_PACKAGES.(name)[2]) then
    Error("Completion file was loaded. Delete read.co and try again.");
    return false;
  fi;

  # get the path to the output
  path := LOADED_PACKAGES.(name)[1];
  input := DirectoriesLibrary(""); #The gap home where packages live

  #filesandfilts[1] = "pkg/<name>/read.g"
  #filesandfilts[2]= The files which read.g reads with ReadPkg.
  #filesandfilts[3]= For each file in filesandfilts[2] a list of filters
  filesandfilts := LOADED_PACKAGES.(name)[2];



  # com := the completion filename
  com := Filename( path, "read.co");
  if com = fail  then
		  Error( "cannot create output file" );
  fi;
  Print( "#I  converting \"","read.g", "\" to \"", com, "\"\n" );

  # now find the input file
  read := List( [1 .. Length(filesandfilts[2]) ], x 
	    -> [ filesandfilts[2][x], Filename( input, filesandfilts[2][x] ), filesandfilts[3][x] ] );
  if ForAny( read, x -> x[2] = fail )  then
		  Error( "cannot locate all input files" );
  fi;

  # create the completion files
  PRINT_TO( com, "#I  file=\"", filesandfilts[1], "\"\n\n" );
  for j  in read  do

    # create a crc value
    Print( "#I    parsing \"", j[1], "\"\n" );
    crc := GAP_CRC(j[2]);

    # create ranking list
    APPEND_TO( com, "#F  file=\"", j[1], "\" crc=", crc, "\n" );
    APPEND_TO( com, "RANK_FILTER_LIST  := ", j[3], ";\n",
		  "RANK_FILTER_COUNT := 1;\n\n" );

    # create `COM_FILE' header and `if' start
    APPEND_TO( com, "#C  load module, file, or complete\n" );
    APPEND_TO( com, 
      "COM_RESULT := COM_FILE( \"", j[1], "\", ", crc, " );\n",
      "if COM_RESULT = fail  then\n",
      "Error(\"cannot locate file \\\"", j[1], "\\\"\");\n",
      "elif COM_RESULT = 1  then\n",
      ";\n",
      "elif COM_RESULT = 2  then\n",
      ";\n",
      "elif COM_RESULT = 4  then\n",
      "READ_CHANGED_GAP_ROOT(\"",j[1],"\");\n",
      "elif COM_RESULT = 3  then\n"
      );

    # create completion
    MAKE_INIT( com, j[2] );

    APPEND_TO( com,
    "else\n",
    "Error(\"unknown result code \", COM_RESULT );\n",
    "fi;\n\n",
    "#U  unbind temporary variables\n",
    "Unbind(RANK_FILTER_LIST);\n",
    "Unbind(RANK_FILTER_COUNT);\n",
    "Unbind(COM_RESULT);\n",
    "#E  file=\"", j[1], "\"\n\n"
    );

  od;

end );

#############################################################################
##  
#F  GapDocManualLab(<pkgname>) . create manual.lab for package w/ GapDoc docs
##  
##  For a package <pkgname> with {\GapDoc}  documentation,  `GapDocManualLab'
##  builds a `manual.lab' file from the {\GapDoc}-produced `manual.six'  file
##  so that the currently-default `gapmacro.tex'-compiled manuals can  access
##  the labels of package <pkgname>.
##
BindGlobal( "GapDocManualLab", function(pkgname)
local dirs, file, stream, entries, SecNumber;
  if not IsString(pkgname) then
    Error("argument <pkgname> should be a string\n");
  fi;
  pkgname := LowercaseString(pkgname);
  if RequirePackage("gapdoc") <> true then
    Error("package `GapDoc' not installed. Please install `GapDoc'\n" );
  fi;
  dirs := DirectoriesPackageLibrary(pkgname, "doc");
  if dirs = fail then
    Error("could not open `doc' directory of package `", pkgname, "'.\n",
          "Perhaps the package is not installed\n");
  fi;
  file := Filename(dirs, "manual.six");
  if file = fail or not IsReadableFile(file) then
    Error("could not open `manual.six' file of package `", pkgname, "'.\n",
          "Please compile its documentation\n");
  fi;
  stream := InputTextFile(file);
  entries := HELP_BOOK_HANDLER.GapDocGAP.ReadSix(stream).entries;

  SecNumber := function(list)
    if IsEmpty(list) or list[1] = 0 then
      return "";
    fi;
    while list[ Length(list) ] = 0 do
      Unbind( list[ Length(list) ] );
    od;
    return JoinStringsWithSeparator( List(list, String), "." );
  end;

  entries := List( entries, 
                   entry -> Concatenation( "\\makelabel{", pkgname, ":",
                                           entry[1], "}{",
                                           SecNumber( entry[3] ), "}\n" ) );
  file := Filename(dirs[1], "manual.lab");
  FileString( file, Concatenation(entries) );
  Info(InfoWarning, 1, "File: ", file, " written.");
end );
        
#############################################################################
##
#E  package.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
