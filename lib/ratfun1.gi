#############################################################################
##
#W  ratfun1.gi                   GAP Library                      Frank Celler
#W                                                             Andrew Solomon
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file  contains those  methods  for    rational  functions,  laurent
##  polynomials and polynomials and their families which are time critical
##  and will benefit from compilation.
##
Revision.ratfun1_gi :=
    "@(#)$Id$";

# Functions to create objects 

LAUR_POL_BY_EXTREP:=function(rfam,coeff,val,inum)
local f,typ,lc;

# trap code for unreduced coeffs.
# if Length(coeffs[1])>0 
#    and (IsZero(coeffs[1][1]) or IsZero(coeffs[1][Length(coeffs[1])])) then
#   Error("zero coeff!");
# fi;

  # check for constants and zero
  lc:=Length(coeff);
  if 0 = val and 1 = lc  then
    # unshifted and one coefficient - constant
    typ := rfam!.threeLaurentPolynomialTypes[2];
  elif 0 = lc then
    # it is the zero polynomial
    val:=0; # special case: result is 0.
    typ := rfam!.threeLaurentPolynomialTypes[2];
  elif 0 <= val  then
    # possibly shifted left - polynomial
    typ := rfam!.threeLaurentPolynomialTypes[3];
  else
    typ := rfam!.threeLaurentPolynomialTypes[1];
  fi;
  
  # slightly better to do this after the Length id determined 
  if IsFFECollection(coeff) and IS_PLIST_REP(coeff) then
    ConvertToVectorRep(coeff);
  fi;

  
  # objectify. We have to be *fast*. Thus we don't even call
  # `ObjectifyWithAttributes' but `Objectify' itself.

  # note that `IndNum.LaurentPol. is IndnumUnivRatFun !
  f := rec(IndeterminateNumberOfUnivariateRationalFunction:=inum,
           CoefficientsOfLaurentPolynomial:=[coeff,val]);
  Objectify(typ,f);

#  ObjectifyWithAttributes(f,typ,
#    IndeterminateNumberOfLaurentPolynomial, inum,
#    CoefficientsOfLaurentPolynomial, coeffs);

  # and return the polynomial
  return f;
end;

# conversion

EXTREP_POLYNOMIAL_LAURENT:=function(f)
local coefs, ind, extrep, i, shift,fam;
  fam:=FamilyObj(f);
  coefs := CoefficientsOfLaurentPolynomial(f);
  ind := IndeterminateNumberOfLaurentPolynomial(f);
  extrep := [];
  shift := coefs[2];
  for i in [1 .. Length(coefs[1])] do
    if coefs[1][i]<>fam!.zeroCoefficient then
      if 1-i<>shift then
	Append(extrep,[[ind, i + shift -1], coefs[1][i]]);
      else
	Append(extrep,[[], coefs[1][i]]);
      fi;
    fi;
  od;
  return extrep;
  
end;

UNIVARTEST_RATFUN:=function(f)
local fam,notuniv,cannot,num,den,hasden,indn,col,val,i,j,nud,pos;
  fam:=FamilyObj(f);

  notuniv:=[false,fail,false,fail];  # answer if know to be not univariate
  cannot:=[fail,fail,fail,fail];     # answer if the test fails because
                                     # there is no multivariate GCD.

  # try to become a polynomial if possible. In particular we know the
  # denominator to be cancelled out if possible.
  if IsPolynomial(f) then
    num := ExtRepPolynomialRatFun(f);
    den:=[[],fam!.oneCoefficient];
  else
    num := ExtRepNumeratorRatFun(f);
    den := ExtRepDenominatorRatFun(f);
  fi;

  if Length(den[1])> 0 then
    # try a GCD cancellation
    i:=TryGcdCancelExtRepPolynomials(fam,num,den);
    if i<>fail then
      num:=i[1];
      den:=i[2];
    fi;

    #T: must do multivariate GCD (otherwise a `false' answer is not guaranteed)
  fi;
  hasden:=true;

  indn:=false; # the indeterminate number we want to get
  if Length(den)=2 and Length(den[1])=0 then
    if not IsOne(den[2]) then
      # take care of denominator so that we can throw it away afterwards.
      den:=den[2];
      num:=ShallowCopy(num);
      for i in [2,4..Length(num)] do
        num[i]:=num[i]/den;
      od;
    fi;
    hasden:=false;
    val:=0;

  elif Length(den)=2 then
    # this is the only case in which we can spot a laurent polynomial

    # We assume that the cancellation test will have dealt properly with
    # denominators which are monomials. So what we need here is only one
    # indeterminate, otherwise we must fail
    if Length(den[1])>2 then
      return notuniv;
    fi;

    indn:=den[1][1]; # this is the indeterminate number we need to have
    val:=-den[1][2];
    if not IsOne(den[2]) then
      # take care of denominator so that we can throw it away afterwards.
      den:=den[2];
      num:=ShallowCopy(num);
      for i in [2,4..Length(num)] do
        num[i]:=num[i]/den;
      od;
    fi;
    hasden:=false;
  fi;

  col:=[];
  nud:=1; # last position isto which we can assign without holes
  # now process the numerator
  for i in [2,4..Length(num)] do

    if Length(num[i-1])>0 then
      if indn=false then
	#set the indeterminate
	indn:=num[i-1][1];
      elif indn<>num[i-1][1] then
	# inconsistency:
	if hasden then
	  return cannot;
	else
	  return notuniv;
	fi;
      fi;
    fi;

    if Length(num[i-1])>2 then
      if hasden then
        return cannot;
      else
        return notuniv;
      fi;
    fi;

    # now we know the monomial to be [indn,exp]

    # set the coefficient
    if Length(num[i-1])=0 then
      # exp=0
      pos:=1;
    else
      pos:=num[i-1][2]+1;
    fi;

    # fill zeroes in the coefficient list
    for j in [nud..pos-1] do
      col[j]:=fam!.zeroCoefficient;
    od;

    col[pos]:=num[i];
    nud:=pos+1;
    

  od;

  if hasden then
    # because we have a special hook above for laurent polynomials, we
    # cannot be a laurent polynomial any longer.

    # now process the denominator
    for i in [2,4..Length(den)] do

      if Length(den[i-1])>0 then
	if indn=false then
	  #set the indeterminate
	  indn:=den[i-1][1];
	elif indn<>den[i-1][1] then
	  # inconsistency:
	  return cannot;
	fi;
      fi;

      if Length(den[i-1])>2 then
	return cannot;
      fi;

    od;

    # the indeterminate number must be set, we have a nonvanishing
    # denominator
    return [true,indn,false,fail];

  else
    # no denominator to deal with: We are univariate laurent

    # shift properly
    val:=val+RemoveOuterCoeffs(col,fam!.zeroCoefficient);

    if indn=false then
      indn:=1; #default value
    fi;

    return [true,indn,true,[col,val]];
  fi;

end;

EXTREP_NUMERATOR_LAURENT:=function( obj )
    local   zero,  cofs,  val,  ind,  ext,  i,  j;

    zero := FamilyObj(obj)!.zeroCoefficient;
    cofs := CoefficientsOfLaurentPolynomial(obj);
    if Length(cofs) = 0 then
      return [];
    fi;
    val  := Maximum(0,cofs[2]); # negagive will go into denominator
    cofs := cofs[1];

    ind  := IndeterminateNumberOfUnivariateRationalFunction(obj);

    ext := [];
    for i  in [ 0 .. Length(cofs)-1 ]  do
        if cofs[i+1] <> zero  then
            j := val + i;
            if j <> 0  then
                Add( ext, [ ind, j ] );
                Add( ext, cofs[i+1] );
            else
                Add( ext, [] );
                Add( ext, cofs[i+1] );
            fi; 
        fi; 
    od; 
    
    return ext;
    
end;

#############################################################################
# 
# Functions for dealing with monomials 
# The monomials are represented as Zipped Lists. 
# i.e. sorted lists [i1,e1,i2, e2,...] where i1<i2<...are the indeterminates
# from smallest to largest
#
#############################################################################

#############################################################################
##
#F  MonomialRevLexicoLess(mon1,mon2) . . . .  reverse lexicographic ordering
##
MONOM_REV_LEX:=function(m,n)
local x,y;
  # assume m and n are lexicographically sorted (otherwise we have to do
  # further work)
  x:=Length(m)-1;
  y:=Length(n)-1;

  while x>0 and y>0 do
    if m[x]>n[y] then
      return false;
    elif m[x]<n[y] then
      return true;
    # now m[x]=n[y]
    elif m[x+1]>n[y+1] then
      return false;
    elif m[x+1]<n[y+1] then
      return true;
    fi;
    # thus same coeffs, step down
    x:=x-2;
    y:=y-2;
  od;
  if x<=0 and y>0 then
    return true;
  else
    return false;
  fi;
end;

##  Low level workhorse for operations with monomials in Zipped form
##  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
ZIPPED_SUM_LISTS:= function( z1, z2, zero, f )
    local   sum,  i1,  i2,  i;

    sum := [];
    i1  := 1;
    i2  := 1;
    while i1 <= Length(z1) and i2 <= Length(z2)  do
        ##  are the two monomials equal ?
        if z1[i1] = z2[i2]  then
            ##  compute the sum of the coefficients
            i := f[2]( z1[i1+1], z2[i2+1] );
            if i <> zero  then
                ##  Add the term to the sum if the coefficient is not zero
                Add( sum, z1[i1] );
                Add( sum, i );
            fi;
            i1 := i1+2;
            i2 := i2+2;
        elif f[1]( z1[i1], z2[i2] )  then  ##  z1[i1] < z2[i2] ?
            ##  z1[i1] is the smaller of the two monomials and gets added to
            ##  the sum.  We have to apply the sum function to the
            ##  coefficient and zero.
            if z1[i1+1] <> zero  then
                Add( sum, z1[i1] );
                Add( sum, f[2]( z1[i1+1], zero ) );
            fi;
            i1 := i1+2;
        else
            ##  z1[i1] is the smaller of the two monomials
            if z2[i2+1] <> zero  then
                Add( sum, z2[i2] );
                Add( sum, f[2]( zero, z2[i2+1] ) );
            fi;
            i2 := i2+2;
        fi;
    od;
    ##  Now append the rest of the longer polynomial to the sum.  Note that
    ##  only one of the following loops is executed.
    for i  in [ i1, i1+2 .. Length(z1)-1 ]  do
        if z1[i+1] <> zero  then
            Add( sum, z1[i] );
            Add( sum, f[2]( z1[i+1], zero ) );
        fi;
    od;
    for i  in [ i2, i2+2 .. Length(z2)-1 ]  do
        if z2[i+1] <> zero  then
            Add( sum, z2[i] );
            Add( sum, f[2]( zero, z2[i+1] ) );
        fi;
    od;
    return sum;
end;


##  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
ZIPPED_PRODUCT_LISTS:=function( z1, z2, zero, f )
    local   mons,  cofs,  i,  j,  c,  prd;

    # fold the product
    mons := [];
    cofs := [];
    for i  in [ 1, 3 .. Length(z1)-1 ]  do
        for j  in [ 1, 3 .. Length(z2)-1 ]  do
            ## product of the coefficients.
            c := f[4]( z1[i+1], z2[j+1] );
            if c <> zero  then
                ##  add the product of the monomials
                Add( mons, f[1]( z1[i], z2[j] ) );
                ##  and the coefficient
                Add( cofs, c );
            fi;
        od;
    od;

    # sort monomials
    SortParallel( mons, cofs, f[2] );

    # sum coeffs
    prd := [];
    i   := 1;
    while i <= Length(mons)  do
        c := cofs[i];
        while i < Length(mons) and mons[i] = mons[i+1]  do
            i := i+1;
            c := f[3]( c, cofs[i] );    ##  add coefficients
        od;
        if c <> zero  then
            ## add the term to the product
            Add( prd, mons[i] );
            Add( prd, c );
        fi;
        i := i+1;
    od;

    # and return the product
    return prd;

end;

#############################################################################
##
#F  ZippedListQuotient  . . . . . . . . . . . .  divide a monomial by another
##
ZippedListQuotient := function( l, r )
  return ZippedSum( l, r, 0, [ \<, \- ] );
end;

# Arithmetic 

ADDITIVE_INV_RATFUN:=function( obj )
    local   fam,  i, newnum;

    fam := FamilyObj(obj);
    newnum := ShallowCopy(ExtRepNumeratorRatFun(obj));
    for i  in [ 2, 4 .. Length(newnum) ]  do
        newnum[i] := -newnum[i];
    od;
    return RationalFunctionByExtRep(fam,newnum,ExtRepDenominatorRatFun(obj));
end;

ADDITIVE_INV_POLYNOMIAL:=function( obj )
    local   fam,  i, newnum;

    fam := FamilyObj(obj);
    newnum := ShallowCopy(ExtRepNumeratorRatFun(obj));
    for i  in [ 2, 4 .. Length(newnum) ]  do
        newnum[i] := -newnum[i];
    od;
    return PolynomialByExtRep(fam,newnum);
end;

SMALLER_RATFUN:=function(left,right)
local a,b,fam,i, j;
  if HasIsPolynomial(left) and IsPolynomial(left)
     and HasIsPolynomial(right) and IsPolynomial(right) then
    a:=ExtRepPolynomialRatFun(left);
    b:=ExtRepPolynomialRatFun(right);
  else
    fam:=FamilyObj(left);
    a := ZippedProduct(ExtRepNumeratorRatFun(left),
			ExtRepDenominatorRatFun(right),
			fam!.zeroCoefficient,fam!.zippedProduct);

    b := ZippedProduct(ExtRepNumeratorRatFun(right),
			ExtRepDenominatorRatFun(left),
			fam!.zeroCoefficient,fam!.zippedProduct);
  fi;

  i:=Length(a)-1;
  j:=Length(b)-1;
  while i>0 and j>0 do
    # compare the last monomials
    if a[i]=b[j] then
      # the monomials are the same, compare the coefficients
      if a[i+1]=b[j+1] then
        # the coefficients are also the same. Must continue
        i:=i-2;
        j:=j-2;
      else
        # let the coefficients decide
        return a[i+1]<b[j+1];
      fi;
    elif MonomialTotalDegreeLess(a[i],b[j]) then
      # a is strictly smaller
      return true;
    else
      # a is strictly larger
      return false;
    fi;
  od;
  # is there an a-remainder (then a is larger)
  # or are both polynomials equal?
  if i>0 or i=j then
    return false;
  else
    return true;
  fi;
end;

#############################################################################
##
#M  <polynomial>     + <coeff>
##
SUM_COEF_POLYNOMIAL:=function( cf, rf )
local   fam,  extrf;

  if IsZero(cf) then
    return rf;
  fi;

  fam   := FamilyObj(rf);
  extrf  := ExtRepPolynomialRatFun(rf);
  # assume the constant term is in the first position
  if Length(extrf)>0 and Length(extrf[1])=0 then
    if extrf[2]=-cf then
      extrf:=extrf{[3..Length(extrf)]};
    else
      extrf:=ShallowCopy(extrf);
      extrf[2]:=extrf[2]+cf;
    fi;
  else
    extrf:=Concatenation([[],cf],extrf);
  fi;

  return PolynomialByExtRep(fam,extrf);

end;

QUOTIENT_POLYNOMIALS_EXT:=function(fam, p, q )
local   quot, lcq,  lmq,  mon,  i, coeff;

  if Length(q)=0 then
    return fail; #safeguard
  fi;

  quot := [];

  lcq := q[Length(q)];
  lmq := q[Length(q)-1];

  p:=ShallowCopy(p);
  while Length(p)>0 do
    ##  divide the leading monomial of q by the leading monomial of p
    mon  := ZippedListQuotient( p[Length(p)-1], lmq );

      ##  check if mon has negative exponents
      for i in [2,4..Length(mon)] do
	  if mon[i] < 0 then return fail; fi;
      od;

      ##  now add the quotient of the coefficients
      coeff := p[Length(p)] / lcq;

      ##  Add coeff, mon to quot, the result is sorted in reversed order.
      Add( quot,  coeff );
      Add( quot,  mon );

      ## p := p - mon * q;
      #  compute -q*mon;
      mon  := ZippedProduct(q,[mon,-coeff],
        fam!.zeroCoefficient,fam!.zippedProduct);
  
      # add it to p
      p:=ZippedSum(p,mon,fam!.zeroCoefficient,fam!.zippedSum);
  od;

  quot := Reversed(quot);
  return quot;
end;

SUM_LAURPOLS:=function( left, right )
local   indn,  fam,  zero,  l,  r,  val,  sum;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfLaurentPolynomial(left) and
    HasIndeterminateNumberOfLaurentPolynomial(right) then
    indn:=IndeterminateNumberOfLaurentPolynomial(left);
    if indn<>IndeterminateNumberOfLaurentPolynomial(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then 
      TryNextMethod();
    fi;
  fi;

  # get the coefficients
  fam  := FamilyObj(left);
  zero := fam!.zeroCoefficient;
  l    := CoefficientsOfLaurentPolynomial(left);
  r    := CoefficientsOfLaurentPolynomial(right);

  # catch zero cases
  if Length(l[1])=0 then
    return right;
  elif Length(r[1])=0 then
    return left;
  fi;

  if l[2]=r[2] then
    sum:=ShallowCopy(l[1]);
    AddCoeffs(sum,r[1]);
    # only in this case the initial coefficient might be cancelled out
    # (assuming that f and g are proper)
    val:=l[2]+RemoveOuterCoeffs(sum,fam!.zeroCoefficient);
  elif l[2]<r[2] then
    sum:=ShallowCopy(r[1]);
    RightShiftRowVector(sum,r[2]-l[2],fam!.zeroCoefficient);
    AddCoeffs(sum,l[1]);
    ShrinkCoeffs(sum);
    val:=l[2];
  else #l[2]>r[2]
    sum:=ShallowCopy(l[1]);
    RightShiftRowVector(sum,l[2]-r[2],fam!.zeroCoefficient);
    AddCoeffs(sum,r[1]);
    ShrinkCoeffs(sum);
    val:=r[2];
  fi;

  # and return the polynomial (we might get a new valuation!)
  return LaurentPolynomialByExtRep(fam, sum, val, indn );

end;

DIFF_LAURPOLS:=
function( left, right )
local   indn,  fam,  zero,  l,  r,  val,  sum;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfLaurentPolynomial(left) and
    HasIndeterminateNumberOfLaurentPolynomial(right) then
    indn:=IndeterminateNumberOfLaurentPolynomial(left);
    if indn<>IndeterminateNumberOfLaurentPolynomial(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then 
      TryNextMethod();
    fi;
  fi;

  # get the coefficients
  fam  := FamilyObj(left);
  zero := fam!.zeroCoefficient;
  l    := CoefficientsOfLaurentPolynomial(left);
  r    := CoefficientsOfLaurentPolynomial(right);

  # catch zero cases
  if Length(l[1])=0 then
    return AdditiveInverseOp(right);
  elif Length(r[1])=0 then
    return left;
  fi;

  if l[2]=r[2] then
    sum:=ShallowCopy(l[1]);
    AddCoeffs(sum,r[1],-fam!.oneCoefficient);
    # only in this case the initial coefficient might be cancelled out
    # (assuming that f and g are proper)
    val:=l[2]+RemoveOuterCoeffs(sum,fam!.zeroCoefficient);
  elif l[2]<r[2] then
    sum:=AdditiveInverseOp(r[1]);
    RightShiftRowVector(sum,r[2]-l[2],fam!.zeroCoefficient);
    AddCoeffs(sum,l[1]);
    ShrinkCoeffs(sum);
    val:=l[2];
  else #l[2]>r[2]
    sum:=ShallowCopy(l[1]);
    RightShiftRowVector(sum,l[2]-r[2],fam!.zeroCoefficient);
    AddCoeffs(sum,AdditiveInverseOp(r[1]));
    ShrinkCoeffs(sum);
    val:=r[2];
  fi;

  # and return the polynomial (we might get a new valuation!)
  return LaurentPolynomialByExtRep(fam, sum, val, indn );

end;

PRODUCT_LAURPOLS:= function( left, right )
local   indn,  fam,  prd,  l,  r,  m,  n, val;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfLaurentPolynomial(left) and
    HasIndeterminateNumberOfLaurentPolynomial(right) then
    indn:=IndeterminateNumberOfLaurentPolynomial(left);
    if indn<>IndeterminateNumberOfLaurentPolynomial(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then 
      TryNextMethod();
    fi;
  fi;

  fam := FamilyObj(left);

  # special treatment of zero
  l   := CoefficientsOfLaurentPolynomial(left);
  m   := Length(l[1]);
  if m=0 then
    return left;
  fi;

  r   := CoefficientsOfLaurentPolynomial(right);
  n   := Length(r[1]);
  if n=0 then
    return right;
  fi;

  # fold the coefficients
  prd:=ProductCoeffs(l[1],m,r[1],n);
  val := l[2] + r[2];
  val:=val+RemoveOuterCoeffs(prd,fam!.zeroCoefficient);

  # return the polynomial
  return LaurentPolynomialByExtRep(fam,prd, val, indn );
end;

QUOTREM_LAURPOLS_LISTS:=function(fc,gc)
local q,m,n,i,c,k;
  # try to divide
  q:=[];
  n:=Length(gc);
  m:=Length(fc)-n;
  for i in [0..m] do
    c:=fc[m-i+n]/gc[n];
    k:=[1..n]+m-i;
    fc{k}:=fc{k}-c*gc;
    q[m-i+1]:=c;
  od;
  return [q,fc];
end;

ADDCOEFFS_GENERIC_3:=function( l1, l2, m )
local   a1,a2, zero,  n1;
  a1:=Length(l1);a2:=Length(l2);
  if a1>=a2 then
    n1:=[1..a2];
    l1{n1}:=l1{n1}+m*l2;
  else
    n1:=[1..a1];
    l1{n1}:=l1+m*l2{n1};
    Append(l1,m*l2{[a1+1..a2]});
  fi;

  if 0 < Length(l1)  then
      zero := Zero(l1[1]);
      n1   := Length(l1);
      while 0 < n1 and l1[n1] = zero  do
	  n1 := n1 - 1;
      od;
  else
      n1 := 0;
  fi;
  return n1;
end;

PRODUCT_COEFFS_GENERIC_LISTS:=
function( l1,m,l2,n )
local i,j,p,z,s,u,o;
  if m=0 or n=0 then
    return [];
  fi;

  z:=Zero(l1[1]);

  p:=[];
  for i  in [ 1 .. m+n-1 ]  do
    s := z;
    if m<i then
      o:=m;
    else
      o:=i;
    fi;
    if i<n then
      u:=1;
    else
      u:=i+1-n;
    fi;
    for j  in [ u .. o ]  do
      s := s + l1[j] * l2[i+1-j];
    od;
    p[i] := s;
  od;
  return p;
end;

##  RemoveOuterCoeffs( <list>, <coef> )
REMOVE_OUTER_COEFFS_GENERIC:=function( l, c )
local   n,  m,  i;

  if 0 = Length(l)  then
      return 0;
  fi;
  n := Length(l);
  while 0 < n and l[n] = c  do
      Unbind(l[n]);
      n := n-1;
  od;
  if n = 0  then
      return 0;
  fi;
  m := 0;
  while m < n and l[m+1] = c  do
      m := m+1;
  od;
  if 0 = m  then
      return 0;
  fi;
  for i  in [ m+1 .. n ]  do
      l[i-m] := l[i];
  od;
  for i  in [ 1 .. m ]  do
      Unbind(l[n-i+1]);
  od;
  return m;
end;

REMOVE_OUTER_COEFFS_GENERIC:=function( l, c )
local   n,  m,  i;

  if 0 = Length(l)  then
      return 0;
  fi;
  n := Length(l);
  while 0 < n and l[n] = c  do
      Unbind(l[n]);
      n := n-1;
  od;
  if n = 0  then
      return 0;
  fi;
  m := 0;
  while m < n and l[m+1] = c  do
      m := m+1;
  od;
  if 0 = m  then
      return 0;
  fi;
  for i  in [ m+1 .. n ]  do
      l[i-m] := l[i];
  od;
  for i  in [ 1 .. m ]  do
      Unbind(l[n-i+1]);
  od;
  return m;
end;

REMOVE_OUTER_COEFFS_GENERIC:=function( l, c )
local   n,  m,  i;

  if 0 = Length(l)  then
      return 0;
  fi;
  n := Length(l);
  while 0 < n and l[n] = c  do
      Unbind(l[n]);
      n := n-1;
  od;
  if n = 0  then
      return 0;
  fi;
  m := 0;
  while m < n and l[m+1] = c  do
      m := m+1;
  od;
  if 0 = m  then
      return 0;
  fi;
  for i  in [ m+1 .. n ]  do
      l[i-m] := l[i];
  od;
  for i  in [ 1 .. m ]  do
      Unbind(l[n-i+1]);
  od;
  return m;
end;

REMOVE_OUTER_COEFFS_GENERIC:=function( l, c )
local   n,  m,  i;

  if 0 = Length(l)  then
      return 0;
  fi;
  n := Length(l);
  while 0 < n and l[n] = c  do
      Unbind(l[n]);
      n := n-1;
  od;
  if n = 0  then
      return 0;
  fi;
  m := 0;
  while m < n and l[m+1] = c  do
      m := m+1;
  od;
  if 0 = m  then
      return 0;
  fi;
  for i  in [ m+1 .. n ]  do
      l[i-m] := l[i];
  od;
  for i  in [ 1 .. m ]  do
      Unbind(l[n-i+1]);
  od;
  return m;
end;

#############################################################################
##
#F  SpecializedExtRepPol(<fam>,<ext>,<ind>,<val>)
##
SPECIALIZED_EXTREP_POL:= function(fam,ext,ind,val)
local e,i,p,m,c;
  e:=[];
  for i in [1,3..Length(ext)-1] do
    # is the indeterminate used in the monomial
    p:=PositionProperty([1,3..Length(ext[i])-1],j->ext[i][j]=ind);
    if p=fail then
      m:=ext[i];
      c:=ext[i+1];
    else
      # yes, compute changed monomial and coefficient
      p:=2*p-1; #actual position 1,3..
      m:=ext[i]{Concatenation([1..p-1],[p+2..Length(ext[i])])};
      c:=ext[i+1]*val^ext[i][p+1];
    fi;
    e:=ZippedSum(e,[m,c],fam!.zeroCoefficient,fam!.zippedSum);
  od;
  return e;
end;

TRY_GCD_CANCEL_EXTREP_POL:=
function(fam,num,den)
local q,p,e,i,j,cnt;
  q:=QuotientPolynomialsExtRep(fam,num,den);
  if q<>fail then
    # true quotient
    return [q,[[],fam!.oneCoefficient]];
  fi;
  
  q:=HeuristicCancelPolynomialsExtRep(fam,num,den);
  if IsList(q) then
    # we got something
    num:=q[1];
    den:=q[2];
  fi;

  # special treatment if the denominator is a monomial
  if Length(den)=2 then
    # is the denominator a constant?
    if Length(den[1])>0 then
      q:=den[1];
      e:=q{[2,4..Length(q)]}; # the indeterminants exponents
      q:=q{[1,3..Length(q)-1]}; # the indeterminant occuring
      IsSSortedList(q);
      i:=1;
      while i<Length(num) and ForAny(e,j->j>0) do
	cnt:=0; # how many indeterminants did we find
	for j in [1,3..Length(num[i])-1] do
	  p:=Position(q,num[i][j]); # uses PositionSorted
	  if p<>fail then
	    cnt:=cnt+1; # found one
	    e[p]:=Minimum(e[p],num[i][j+1]); # gcd via exponents
	  fi;
	od;
	if cnt<Length(e) then
	  e:=[0,0]; # not all indets found: cannot cancel!
	fi;
        i:=i+2;
      od;
      if ForAny(e,j->j>0) then
        # found a common monomial
	num:=ShallowCopy(num);
	for i in [1,3..Length(num)-1] do
	  num[i]:=ShallowCopy(num[i]);
	  for j in [1,3..Length(num[i])-1] do
	    p:=Position(q,num[i][j]); # uses PositionSorted
	    num[i][j+1]:=num[i][j+1]-e[p]; #reduce
	  od;
	od;

	p:=ShallowCopy(den[1]);
	i:=[2,4..Length(p)];
	p{i}:=p{i}-e; # reduce exponents
	den:=[p,den[2]]; #new denominator
      fi;
    fi;
    # remove the denominator coefficient
    if not IsOne(den[2]) then
      num:=ShallowCopy(num);
      for i in [2,4..Length(num)] do
	num[i]:=num[i]/den[2];
      od;
      den:=[den[1],fam!.oneCoefficient];
    fi;
  fi;

  return [num,den];
end;

DEGREE_INDET_EXTREP_POL:=function(e,ind)
local d,i,j;
  e:=Filtered(e,IsList);
  d:=0; #the maximum degree so far
  for i in e do
    j:=1;
    while j<Length(i) do # searching the monomial
      if i[j]=ind then
        if i[j+1]>d then
          d:=i[j+1];
        fi;
        j:=Length(i);
      fi;
      j:=j+2;
    od;
  od;
  return d;
end;

#  LeadingCoefficient( pol, ind )
LEAD_COEF_POL_IND_EXTREP:=function(e,ind)
local c,d,i,p;
  d:=0;
  c:=[];
  for i in [1,3..Length(e)-1] do
    # test whether the indeterminate does occur
    p:=PositionProperty([1,3..Length(e[i])-1],j->e[i][j]=ind);
    if p<>fail then
      p:=p*2-1; # from indext in [1,3..] to number
      if e[i][p+1]>d then
	d:=e[i][p+1]; # new, higher degree
	c:=[]; # start anew
      fi;
      if e[i][p+1]=d then
	# remaining monomial with coefficient
	Append(c,[e[i]{Difference([1..Length(e[i])],[p,p+1])},e[i+1]]);
      fi;
    fi;
  od;
  return c;
end;

#  PolynomialCoefficientsOfPolynomial(<pol>,<ind>)
POL_COEFFS_POL_EXTREP:=function(e,ind)
local c,i,j,m,ex;
  c:=[];
  for i in [1,3..Length(e)-1] do
    m:=e[i];
    j:=1;
    while j<=Length(m) and m[j]<>ind do
      j:=j+2;
    od;
    if j<Length(m) then
      ex:=m[j+1]+1;
      m:=m{Concatenation([1..j-1],[j+2..Length(m)])};
    else
      ex:=1;
    fi;
    if not IsBound(c[ex]) then
      c[ex]:=[];
    fi;
    Add(c[ex],m);
    Add(c[ex],e[i+1]);
  od;
  return c;
end;



#############################################################################
##
#F  PolynomialReduction(poly,plist,order)
##
POLYNOMIAL_REDUCTION:=function(poly,plist,order)
local fam,quot,elist,lmp,lmo,lmc,x,y,z,mon,mon2,qmon,noreduce,
      ep,pos,di,opoly;
  opoly:=poly;
  fam:=FamilyObj(poly);
  quot:=List(plist,i->Zero(poly));
  elist:=List(plist,ExtRepPolynomialRatFun);
  lmp:=List(elist,i->LeadingMonomialPosExtRep(fam,i,order));
  lmo:=List([1..Length(lmp)],i->elist[i][lmp[i]]);
  lmc:=List([1..Length(lmp)],i->elist[i][lmp[i]+1]);

  repeat
    ep:=ExtRepPolynomialRatFun(poly);
    # now try whether we can reduce anywhere.

    x:=Length(ep)-1;
    noreduce:=true;
    while x>0 and noreduce do
      mon:=ep[x];
      y:=1;
      while y<=Length(plist) and noreduce do
	mon2:=lmo[y];
	#check whether the monomial at position x is a multiple of the
	#y-th leading monomial
        z:=1;
	pos:=1;
	qmon:=[]; # potential quotient
	noreduce:=false;
	while noreduce=false and z<=Length(mon2) and pos<=Length(mon) do
	  if mon[pos]>mon2[z] then
	    noreduce:=true; # indet in mon2 does not occur in mon -> does not
	                   # divide
	  elif mon[pos]<mon2[z] then
	    Append(qmon,mon{[pos,pos+1]}); # indet only in mon
	    pos:=pos+2;
	  else
	    # the indets are the same
	    di:=mon[pos+1]-mon2[z+1];
	    if di>0 then
	      #divides and there is remainder
	      Append(qmon,[mon[pos],di]);
	    elif di<0 then
	      noreduce:=true; # exponent to small
	    fi;
	    pos:=pos+2;
	    z:=z+2;
	  fi;
	od;

	# if there is a tail in mon2 left, cannot divide
	if z<=Length(mon2) then
	  noreduce:=true;
	fi;
        y:=y+1;
      od;
      x:=x-2;
    od;
    if noreduce=false then
      x:=x+2;y:=y-1; # re-correct incremented numbers

      # is there a tail in mon? if yes we need to append it
      if pos<Length(mon) then
        Append(qmon,mon{[pos..Length(mon)]});
      fi;

      # reduce!
      qmon:=PolynomialByExtRep(fam,[qmon,ep[x+1]/lmc[y]]); #quotient monomial

      quot[y]:=quot[y]+qmon;
      poly:=poly-qmon*plist[y]; # reduce
    fi;
  until noreduce;
  return [poly,quot];
end;

