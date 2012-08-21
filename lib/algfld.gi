#############################################################################
##
#W  algfld.gi                   GAP Library                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for algebraic elements and their families
##
Revision.algfld_gi:=
  "@(#)$Id$";

#############################################################################
##
#R  IsAlgebraicExtensionDefaultRep    Representation of algebraic extensions
##
DeclareRepresentation(
  "IsAlgebraicExtensionDefaultRep", IsAlgebraicExtension and
  IsComponentObjectRep and IsAttributeStoringRep,
  ["extFam"]);

#############################################################################
##
#R  IsAlgBFRep        Representation for embedded base field
##
DeclareRepresentation("IsAlgBFRep",
  IsPositionalObjectRep and IsAlgebraicElement,[]);

#############################################################################
##
#R  IsAlgExtRep       Representation for true extension elements
##
DeclareRepresentation("IsAlgExtRep",
  IsPositionalObjectRep and IsAlgebraicElement,[]);

#############################################################################
##
#M  AlgebraicElementsFamilies       Initializing method
##
InstallMethod(AlgebraicElementsFamilies,true,[IsUnivariatePolynomial],0,
              f -> []);

#############################################################################
##
#F  StoreAlgExtFam(<pol>,<field>,<fam>)  store fam as Alg.Ext.Fam. for p
##                                       over field
##
StoreAlgExtFam := function(p,f,fam)
local   aef;
  aef:=AlgebraicElementsFamilies(p);
  if not ForAny(aef,i->i[1]=f) then
    Add(aef,[f,fam]);
  fi;
end;

#############################################################################
##
#M  AlgebraicElementsFamily      generic method
##
InstallMethod(AlgebraicElementsFamily,"generic",true,
  [IsField,IsUnivariatePolynomial],0,
function(f,p)
local fam,i;
  if not
  IsIrreducibleRingElement(PolynomialRing(f,
             [IndeterminateNumberOfLaurentPolynomial(p)]),p) then
    Error("<p> must be irreducible over f");
  fi;
  fam:=AlgebraicElementsFamilies(p);
  i:=PositionProperty(fam,i->i[1]=f);
  if i<>fail then
    return fam[i][2];
  fi;

  fam:=NewFamily("AlgebraicElementsFamily(...)",IsAlgebraicElement,
         IsAlgebraicElement and CanEasilySortElements,
	 IsAlgebraicElementFamily and CanEasilySortElements);

  # The two types
  fam!.baseType := NewType(fam,IsAlgBFRep);
  fam!.extType := NewType(fam,IsAlgExtRep);

  # Important trivia
  fam!.baseField:=f;
  fam!.baseZero:=Zero(f);
  fam!.baseOne:=One(f);
  fam!.poly:=p;
  fam!.polCoeffs:=CoefficientsOfUnivariatePolynomial(p);
  fam!.deg:=DegreeOfLaurentPolynomial(p);
  i:=List([1..DegreeOfLaurentPolynomial(p)],i->fam!.baseZero);
  i[2]:=fam!.baseOne;
  fam!.primitiveElm:=ObjByExtRep(fam,i);

  SetIsUFDFamily(fam,true);
  SetCoefficientsFamily(fam,FamilyObj(One(f)));

  # and set one and zero
  SetZero(fam,ObjByExtRep(fam,Zero(f)));
  SetOne(fam,ObjByExtRep(fam,One(f)));

  StoreAlgExtFam(p,f,fam);

  return fam;
end);

#############################################################################
##
#M  AlgebraicExtension      generic method
##
InstallMethod(AlgebraicExtension,"generic",true,
  [IsField,IsUnivariatePolynomial],0,
function(f,p)
local e,fam;

  if DegreeOfLaurentPolynomial(p)<=1 then
    return f;
  fi;

  fam:=AlgebraicElementsFamily(f,p);
  e:=Objectify(NewType(CollectionsFamily(fam),IsAlgebraicExtensionDefaultRep),
               rec());

  fam!.wholeField:=e;
  e!.extFam:=fam;
  SetCharacteristic(e,Characteristic(f));
  SetDegreeOverPrimeField(e,DegreeOfLaurentPolynomial(p)*DegreeOverPrimeField(f));
  SetIsFiniteDimensional(e,true);
  SetLeftActingDomain(e,f);
  SetGeneratorsOfField(e,[fam!.primitiveElm]);
  SetIsPrimeField(e,false);
  SetPrimitiveElement(e,fam!.primitiveElm);
  SetDefiningPolynomial(e,p);
  SetRootOfDefiningPolynomial(e,fam!.primitiveElm);

  if HasIsFinite(f) then
    if IsFinite(f) then
      SetIsFinite(e,true);
      if HasSize(f) then
	SetSize(e,Size(f)^fam!.deg);
      fi;
    else
      SetIsFinite(e,false);
      SetSize(e,infinity);
    fi;
  fi;

  # AH: Noch VR-Eigenschaften!
  SetDimension( e, DegreeOverPrimeField( e ) );

  SetOne(e,One(fam));
  SetZero(e,Zero(fam));

  return e;
end);

# this method is wrong
#InstallOtherMethod(FieldByGenerators,"algebraic elements",true,
#  [IsAlgebraicElementCollection],0,
#function(l)
#  return FamilyObj(l[1])!.wholeField;
#end);

#############################################################################
##
#M  FieldExtension     generically default on `AlgebraicExtension'.
##
InstallMethod(FieldExtension,"generic",true,
  [IsField,IsUnivariatePolynomial],0,AlgebraicExtension);

#############################################################################
##
#M  ExtRepOfObj     
##
##  The external representation of an algebraic element is a coefficient
##  list (in the primitive element)
##
InstallMethod(ExtRepOfObj,"baseFieldElm",true,
  [IsAlgebraicElement and IsAlgBFRep],0,
function(e)
local f,l;
  f:=FamilyObj(e);
  l:=[e![1]];
  while Length(l)<f!.deg do
    Add(l,f!.baseZero);
  od;
  return l;
end);

InstallMethod(ExtRepOfObj,"ExtElm",true,
  [IsAlgebraicElement and IsAlgExtRep],0,
function(e)
  return e![1];
end);

#############################################################################
##
#M  ObjByExtRep          embedding of elements of base field
##
InstallMethod(ObjByExtRep,"baseFieldElm",true,
  [IsAlgebraicElementFamily,IsRingElement],0,
function(fam,e)
  #AH: Immutable
  e:=[e];
  Objectify(fam!.baseType,e);
  return e;
end);

#############################################################################
##
#M  ObjByExtRep          extension elements
##
InstallMethod(ObjByExtRep,"ExtElm",true,
  [IsAlgebraicElementFamily,IsList],0,
function(fam,e)
  #AH: Immutable
  e:=[e];
  Objectify(fam!.extType,e);
  return e;
end);

#############################################################################
##
#F  AlgExtElm      A `nicer' ObjByExtRep, that shrinks/grows a list to the 
##                 correct length and tries to get to the BaseField
##                 representation
##
AlgExtElm := function(fam,e)
  if IsList(e) then
    if Length(e)<fam!.deg then
      e:=ShallowCopy(e);
      while Length(e)<fam!.deg do
        Add(e,fam!.baseZero);
      od;
    fi;
    # try to get into small rep
    if ForAll(e{[2..fam!.deg]},i->i=fam!.baseZero) then
      e:=e[1];
    elif Length(e)>fam!.deg then
      e:=e{[1..fam!.deg]};
    fi;
  fi;
  return ObjByExtRep(fam,e);
end;

#############################################################################
##
#M  PrintObj
##
InstallMethod(PrintObj,"BFElm",true,[IsAlgBFRep],0,
function(a)
  Print("!",String(a![1]));
end);

InstallMethod(PrintObj,"AlgElm",true,[IsAlgExtRep],0,
function(a)
local fam,i,p;
  fam:=FamilyObj(a);
  Print("(");
  p:=false;
  for i in [1..fam!.deg] do
    if a![1][i]<>fam!.baseZero then
      if p and (not IsRationals(fam!.baseField) or a![1][i]>0) then
	Print("+");
      fi;
      p:=true;
      if i=1 or a![1][i]<>fam!.baseOne then
	Print(a![1][i]);
	if i>1 then
	  Print("*");
	fi;
      fi;
      if i>1 then
        Print("a");
	if i>2 then
	  Print("^",i-1);
        fi;
      fi;
    fi;
  od;
  Print(")");
end);

#############################################################################
##
#M  \+  for all combinations of A.E.Elms and base field elms.
##
InstallMethod(\+,"AlgElm+AlgElm",IsIdenticalObj,[IsAlgExtRep,IsAlgExtRep],0,
function(a,b)
  return AlgExtElm(FamilyObj(a),a![1]+b![1]);
end);

InstallMethod(\+,"AlgElm+BFElm",IsIdenticalObj,[IsAlgExtRep,IsAlgBFRep],0,
function(a,b)
  a:=ShallowCopy(a![1]);
  a[1]:=a[1]+b![1];
  return ObjByExtRep(FamilyObj(b),a);
end);

InstallMethod(\+,"BFElm+AlgElm",IsIdenticalObj,[IsAlgBFRep,IsAlgExtRep],0,
function(a,b)
  b:=ShallowCopy(b![1]);
  b[1]:=b[1]+a![1];
  return ObjByExtRep(FamilyObj(a),b);
end);

InstallMethod(\+,"BFElm+BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return ObjByExtRep(FamilyObj(a),a![1]+b![1]);
end);

InstallMethod(\+,"AlgElm+FElm",IsElmsCoeffs,[IsAlgExtRep,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  a:=ShallowCopy(a![1]);
  a[1]:=a[1]+(b*fam!.baseOne);
  return ObjByExtRep(fam,a);
end);

InstallMethod(\+,"FElm+AlgElm",IsCoeffsElms,[IsRingElement,IsAlgExtRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  b:=ShallowCopy(b![1]);
  b[1]:=b[1]+(a*fam!.baseOne);
  return ObjByExtRep(fam,b);
end);

InstallMethod(\+,"BFElm+FElm",IsElmsCoeffs,[IsAlgBFRep,IsRingElement],0,
function(a,b)
  b:=a![1]+b;
  return AlgExtElm(FamilyObj(a),b);
end);

InstallMethod(\+,"FElm+BFElm",IsCoeffsElms,[IsRingElement,IsAlgBFRep],0,
function(a,b)
  a:=b![1]+a;
  return AlgExtElm(FamilyObj(b),a);
end);

#############################################################################
##
#M  AdditiveInverseOp
##
InstallMethod( AdditiveInverseOp, "AlgElm",true,[IsAlgExtRep],0,
function(a)
  return ObjByExtRep(FamilyObj(a),-a![1]);
end);

InstallMethod( AdditiveInverseOp, "BFElm",true,[IsAlgBFRep],0,
function(a)
  return ObjByExtRep(FamilyObj(a),-a![1]);
end);

#############################################################################
##
#M  \*  for all combinations of A.E.Elms and base field elms.
##
InstallMethod(\*,"AlgElm*AlgElm",IsIdenticalObj,[IsAlgExtRep,IsAlgExtRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  b:=ProductCoeffs(a![1],b![1]);
  ReduceCoeffs(b,fam!.polCoeffs);
  return AlgExtElm(fam,b);
end);

InstallMethod(\*,"AlgElm*BFElm",IsIdenticalObj,[IsAlgExtRep,IsAlgBFRep],0,
function(a,b)
  a:=a![1]*b![1];
  return AlgExtElm(FamilyObj(b),a);
end);

InstallMethod(\*,"BFElm*AlgElm",IsIdenticalObj,[IsAlgBFRep,IsAlgExtRep],0,
function(a,b)
  b:=b![1]*a![1];
  return AlgExtElm(FamilyObj(a),b);
end);

InstallMethod(\*,"BFElm*BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return ObjByExtRep(FamilyObj(a),a![1]*b![1]);
end);

InstallMethod(\*,"Alg*FElm",IsElmsCoeffs,[IsAlgebraicElement,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  b:=a![1]*(b*fam!.baseOne);
  return AlgExtElm(fam,b);
end);

InstallMethod(\*,"FElm*Alg",IsCoeffsElms,[IsRingElement,IsAlgebraicElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  a:=b![1]*(a*fam!.baseOne);
  return AlgExtElm(fam,a);
end);

InstallMethod(\*,"Alg*List",true,[IsAlgebraicElement,IsVector],0,
function(a,b)
  return List(b,i->a*i);
end);

InstallMethod(\*,"List*Alg",true,[IsVector,IsAlgebraicElement],0,
function(a,b)
  return List(a,i->i*b);
end);

#############################################################################
##
#M  InverseOp
##
InstallMethod( InverseOp, "AlgElm",true,[IsAlgExtRep],0,
function(a)
local i,fam,f,g,t,h,rf,rg,rh,z;
  fam:=FamilyObj(a);
  f:=a![1];
  g:=ShallowCopy(fam!.polCoeffs);
  rf:=[fam!.baseOne];
  z:=fam!.baseZero;
  rg:=[];
  while g<>[] do
    t:=QuotRemPolList(f,g);
    h:=g;
    rh:=rg;
    g:=t[2];
    if Length(t[1])=0 then
      rg:=[];
    else
      rg:=ShallowCopy(-ProductCoeffs(t[1],rg));
    fi;
    for i in [1..Length(rf)] do
      if IsBound(rg[i]) then
        rg[i]:=rg[i]+rf[i];
      else
        rg[i]:=rf[i];
      fi;
    od;
    f:=h;
    rf:=rh;
    ShrinkCoeffs(g);
    #t:=Length(g);
    #while t>0 and g[t]=z do
    #  Unbind(g[t]);
    #  t:=t-1;
    #od;
  od;
  rf:=1/f[Length(f)]*rf;
  return AlgExtElm(fam,rf);
end);

InstallMethod( InverseOp, "BFElm",true,[IsAlgBFRep],0,
function(a)
  return ObjByExtRep(FamilyObj(a),Inverse(a![1]));
end);


#############################################################################
##
#M  \<  for all combinations of A.E.Elms and base field elms.
##      Comparison is by the coefficient lists of the External
##      representation. The base field is naturally embedded
##
InstallMethod(\<,"AlgElm<AlgElm",IsIdenticalObj,[IsAlgExtRep,IsAlgExtRep],0,
function(a,b)
  return a![1]<b![1];
end);

InstallMethod(\<,"AlgElm<BFElm",IsIdenticalObj,[IsAlgExtRep,IsAlgBFRep],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b![1] then
    i:=2;
    while i<=fam!.deg and a![1][i]=fam!.baseZero do
      i:=i+1;
    od;
    if i<=fam!.deg and a![1][i]<fam!.baseZero then
      return true;
    fi;
    return false;
  else
    return a![1][1]<b![1];
  fi;
end);

InstallMethod(\<,"BFElm<AlgElm",IsIdenticalObj,[IsAlgBFRep,IsAlgExtRep],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a![1] then
    i:=2;
    while i<=fam!.deg and b![1][i]=fam!.baseZero do
      i:=i+1;
    od;
    if i<=fam!.deg and b![1][i]<fam!.baseZero then
      return false;
    fi;
    return true;
  else
    return a![1]<b![1][1];
  fi;
end);

InstallMethod(\<,"BFElm<BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return a![1]<b![1];
end);

InstallMethod(\<,"AlgElm<FElm",true,[IsAlgExtRep,IsRingElement],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b then
    i:=2;
    while i<=fam!.deg and a![1][i]=fam!.baseZero do
      i:=i+1;
    od;
    if i<=fam!.deg and a![1][i]<fam!.baseZero then
      return true;
    fi;
    return false;
  else
    return a![1][1]<b;
  fi;
end);

InstallMethod(\<,"FElm<AlgElm",true,[IsRingElement,IsAlgExtRep],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a then
    i:=2;
    while i<=fam!.deg and b![1][i]=fam!.baseZero do
      i:=i+1;
    od;
    if i<=fam!.deg and b![1][i]<fam!.baseZero then
      return false;
    fi;
    return true;
  else
    return a<b![1][1];
  fi;
end);

InstallMethod(\<,"BFElm<FElm",true,[IsAlgBFRep,IsRingElement],0,
function(a,b)
  return a![1]<b;
end);

InstallMethod(\<,"FElm<BFElm",true,[IsRingElement,IsAlgBFRep],0,
function(a,b)
  return a<b![1];
end);

#############################################################################
##
#M  \=  for all combinations of A.E.Elms and base field elms.
##      Comparison is by the coefficient lists of the External
##      representation. The base field is naturally embedded
##
InstallMethod(\=,"AlgElm=AlgElm",IsIdenticalObj,[IsAlgExtRep,IsAlgExtRep],0,
function(a,b)
  return a![1]=b![1];
end);

InstallMethod(\=,"AlgElm=BFElm",IsIdenticalObj,[IsAlgExtRep,IsAlgBFRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b![1] then
    return ForAll([2..fam!.deg],i->a![1][i]=fam!.baseZero);
  else
    return false;
  fi;
end);

InstallMethod(\=,"BFElm<AlgElm",IsIdenticalObj,[IsAlgBFRep,IsAlgExtRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a![1] then
    return ForAll([2..fam!.deg],i->b![1][i]=fam!.baseZero);
  else
    return false;
  fi;
end);

InstallMethod(\=,"BFElm=BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return a![1]=b![1];
end);

InstallMethod(\=,"AlgElm=FElm",true,[IsAlgExtRep,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b then
    return ForAll([2..fam!.deg],i->a![1][i]=fam!.baseZero);
  else
    return false;
  fi;
end);

InstallMethod(\=,"FElm=AlgElm",true,[IsRingElement,IsAlgExtRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a then
    return ForAll([2..fam!.deg],i->b![1][i]=fam!.baseZero);
  else
    return false;
  fi;
end);

InstallMethod(\=,"BFElm=FElm",true,[IsAlgBFRep,IsRingElement],0,
function(a,b)
  return a![1]=b;
end);

InstallMethod(\=,"FElm=BFElm",true,[IsRingElement,IsAlgBFRep],0,
function(a,b)
  return a=b![1];
end);

#############################################################################
##
#M  \in      base field elements are considered to lie in the algebraic
##           extension
##
InstallMethod(\in,"Alg in Ext",true,[IsAlgebraicElement,IsAlgebraicExtension],
  0,
function(a,b)
  return FamilyObj(a)=b!.extFam;
end);

InstallMethod(\in,"FElm in Ext",true,[IsRingElement,IsAlgebraicExtension],
  0,
function(a,b)
  return a in b!.extFam!.baseField;
end);

#############################################################################
##
#M  MinimalPolynomial
##
#InstallMethod(MinimalPolynomial,"AlgElm",true,
#  [IsAlgebraicExtension,IsAlgExtRep,IsPosInt],0,
#function(f,e,inum)
#local fam,c,m;
#  fam:=FamilyObj(e);
#  c:=One(e);
#  m:=[];
#  repeat
#    Add(m,ShallowCopy(ExtRepOfObj(c)));
#    c:=c*e;
#  until RankMat(m)<Length(m);
#  m:=NullspaceMat(m)[1];
#  # make monic
#  m:=m/m[Length(m)];
#  return UnivariatePolynomialByCoefficients(FamilyObj(fam!.baseZero),m,inum);
#end);
#T  The method might be installed since it avoids the computations with
#T  a basis (used in the generic method).
#T  But note:
#T  In GAP 4, `MinimalPolynomial( <F>, <z> )' is a polynomial with
#T  coefficients in <F>, *not* the min. pol. of an element <z> in <F>
#T  with coefficients in `LeftActingDomain( <F> )'.
#T  So the first argument will in general be `Rationals'!


#############################################################################
##
#M  CharacteristicPolynomial
##
#InstallMethod(CharacteristicPolynomial,"Alg",true,
#  [IsAlgebraicExtension,IsScalar],0,
#function(f,e)
#local fam,p;
#  fam:=FamilyObj(One(f));
#  p:=MinimalPolynomial(f,e);
#  return p^(fam!.deg/DegreeOfLaurentPolynomial(p));
#end);
#T  See the comment about `MinimalPolynomial' above!


# #############################################################################
# ##
# #M  Trace
# ##
# InstallMethod(Trace,"Alg",true,
#   [IsAlgebraicExtension,IsScalar],0,
# function(f,e)
# local   p;
#   p:=CharacteristicPolynomial(f,e);
#   p:=CoefficientsOfUnivariatePolynomial(p);
#   return -p[Length(p)-1];
# end);
# 
# #############################################################################
# ##
# #M  Norm
# ##
# InstallMethod(Norm,"Alg",true,
#   [IsAlgebraicExtension,IsScalar],0,
# function(f,e)
# local   p;
#   p:=CharacteristicPolynomial(f,e);
#   p:=CoefficientsOfUnivariatePolynomial(p);
#   return p[1]*(-1)^(Length(p)-1);
# end);
#T The above two installations are obsolete since now the default methods
#T for `Trace' and `Norm' use `TracePolynomial';
#T the ``old'' default to use `Conjugates' is now restricted to the special
#T case that the field has `IsFieldControlledByGaloisGroup'.


#############################################################################
##
#M  Random
##
InstallMethod(Random,"Alg",true,
  [IsAlgebraicExtension],0,
function(e)
local fam,l;
  fam:=e!.extFam;
  l:=List([1..fam!.deg],i->Random(fam!.baseField));
  return AlgExtElm(fam,l);
end);

#############################################################################
##
#F  MaxNumeratorCoeffAlgElm(<a>)
##
InstallMethod(MaxNumeratorCoeffAlgElm,"rational",true,[IsRat],0,
function(e)
  return AbsInt(NumeratorRat(e));
end);

InstallMethod(MaxNumeratorCoeffAlgElm,"algebraic element",true,
  [IsAlgebraicElement and IsAlgBFRep],0,
function(e)
  return MaxNumeratorCoeffAlgElm(e![1]);
end);

InstallMethod(MaxNumeratorCoeffAlgElm,"algebraic element",true,
  [IsAlgebraicElement and IsAlgExtRep],0,
function(e)
  return Maximum(List(e![1],MaxNumeratorCoeffAlgElm));
end);


#############################################################################
##
##  Supply a canonical basis for algebraic extensions.
##  (Subspaces of algebraic extensions could be easily handled via
##  the nice/ugly vectors mechanism.)
##


#############################################################################
##
#M  Basis( <algext> )
##
InstallMethod( Basis,
    "for an algebraic extension (delegate to `CanonicalBasis')",
    [ IsAlgebraicExtension ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#R  IsCanonicalBasisAlgebraicExtension( <algext> )
##
DeclareRepresentation( "IsCanonicalBasisAlgebraicExtension",
    IsBasis and IsCanonicalBasis and IsAttributeStoringRep, [] );


#############################################################################
##
#M  CanonicalBasis( <algext> )  . . . . . . . . . . . for algebraic extension
##
##  The basis vectors are the first powers of the primitive element.
##
InstallMethod( CanonicalBasis,
    "for an algebraic extension",
    true,
    [ IsAlgebraicExtension ], 0,
    function( F )
    local B;
    B:= Objectify( NewType( FamilyObj( F ),
                            IsCanonicalBasisAlgebraicExtension ),
                   rec() );
    SetUnderlyingLeftModule( B, F );
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . . . . . . . . . for canon. basis of alg. ext.
##
InstallMethod( BasisVectors,
    "for canon. basis of an algebraic extension",
    true,
    [ IsCanonicalBasisAlgebraicExtension ], 0,
    F -> List( [ 0 .. Dimension( F ) - 1 ], i -> PrimitiveElement( F )^i ) );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . . . . for canon. basis of alg. ext.
##
InstallMethod( Coefficients,
    "for canon. basis of an algebraic extension, and alg. element",
    IsCollsElms,
    [ IsCanonicalBasisAlgebraicExtension, IsAlgebraicElement ], 0,
    function( B, v )
    return ExtRepOfObj( v );
    end );

InstallMethod( Coefficients,
    "for canon. basis of an algebraic extension, and scalar",
    true,
    [ IsCanonicalBasisAlgebraicExtension, IsScalar ], 0,
    function( B, v )
    B:= UnderlyingLeftModule( B );
    if v in LeftActingDomain( B ) then
      return Concatenation( [ v ], Zero( v ) * [ 1 .. Dimension( B )-1 ] );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#E

