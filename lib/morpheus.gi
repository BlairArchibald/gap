#############################################################################
##
#W  morpheus.gi                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This  file  contains declarations for Morpheus
##
Revision.morpheus_gi:=
  "@(#)$Id$";

#############################################################################
##
#V  MORPHEUSELMS . . . .  limit up to which size to store element lists
##
MORPHEUSELMS := 50000;

#############################################################################
##
#M  AutomorphismDomain(<G>)
##
##  If <G> consists of automorphisms of <H>, this attribute returns <H>.
InstallMethod( AutomorphismDomain, "use source of one",true,
  [IsGroupOfAutomorphisms],0,
function(G)
  return Source(One(G));
end);

DeclareRepresentation("IsOperationHomomorphismAutomGroup",
  IsOperationHomomorphismByBase,["basepos"]);

#############################################################################
##
#M  IsGroupOfAutomorphisms(<G>)
##
InstallMethod( IsGroupOfAutomorphisms, "test generators and one",true,
  [IsGroup and HasGeneratorsOfGroup],0,
function(G)
local s;
  if IsGeneralMapping(One(G)) then
    s:=Source(One(G));
    if Range(One(G))=s and ForAll(GeneratorsOfGroup(G),
      g->IsGroupGeneralMapping(g) and IsSPGeneralMapping(g) and IsMapping(g)
         and IsInjective(g) and IsSurjective(g) and Source(g)=s
	 and Range(g)=s) then
      SetAutomorphismDomain(G,s);
      return true;
    fi;
  fi;
  return false;
end);

#############################################################################
##
#F  StoreNiceMonomorphismAutomGroup
##
InstallGlobalFunction(StoreNiceMonomorphismAutomGroup,
function(aut,elms,elmsgens)
local xset,fam,hom,G,i,ran;
  One(aut); # to avoid infinite recursion once the niceo is set

  # short cut 1: If the group has a trivial centre and no outer automorphisms,
  # take the group itself
  G:=Source(One(aut)); # we don't yet know that aut is a group of automorphisms
  if Size(Centre(G))=1 
     and ForAll(GeneratorsOfGroup(aut),IsConjugatorAutomorphism) then
    ran:=Group(List(GeneratorsOfGroup(aut),ConjugatorInnerAutomorphism),One(G));
    IsFinite(ran); # Hack for 4b5f2
    hom:=GroupHomomorphismByFunction(aut,ran,
      function(auto)
	if not IsConjugatorAutomorphism(auto) then
	  return fail;
	fi;
        return ConjugatorInnerAutomorphism(auto);
      end,
      function(elm)
        return ConjugatorAutomorphism(G,elm);
      end);
    SetIsGroupHomomorphism(hom,true);
    SetIsBijective(hom,true);
    SetRange( hom, G);
  else

    if elms=false then
      # fuse orbits of generators by their conjugacy classes
      elms:=[];
      for i in SmallGeneratingSet(G) do
	if not i in elms then
	  elms:=Union(elms,Orbit(aut,i));
	fi;
      od;
    fi;

    elmsgens:=Filtered(elmsgens,i->i in elms);
    xset:=ExternalSet(aut,elms);
    SetBaseOfGroup(xset,elmsgens);
    fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( aut ) ),
				  PermutationsFamily );
    hom := rec(  );
    hom:=Objectify(NewType(fam,
		  IsOperationHomomorphismAutomGroup and IsSurjective ),hom);
    SetUnderlyingExternalSet( hom, xset );
    hom!.basepos:=List(elmsgens,i->Position(elms,i));
    SetRange( hom, Image( hom ) );
    SetIsInjective(hom,true);
    Setter(SurjectiveOperationHomomorphismAttr)(xset,hom);
    Setter(IsomorphismPermGroup)(aut,OperationHomomorphism(xset,"surjective"));
    hom:=OperationHomomorphism(xset,"surjective");
  fi;

  SetIsFinite(aut,true);
  SetNiceMonomorphism(aut,hom);
  SetIsHandledByNiceMonomorphism(aut,true);
end);

#############################################################################
##
#M  PreImagesRepresentative   for OpHomAutomGrp
##
InstallMethod(PreImagesRepresentative,"AutomGroup Niceomorphism",
  FamRangeEqFamElm,[IsOperationHomomorphismAutomGroup,IsPerm],0,
function(hom,elm)
local xset,g,imgs;
  xset:= UnderlyingExternalSet( hom );
  g:=Source(One(ActingDomain(xset)));
  imgs:=OnTuples(hom!.basepos,elm);
  imgs:=Enumerator(xset){imgs};
  elm:=GroupHomomorphismByImagesNC(g,g,BaseOfGroup(xset),imgs);
  SetIsBijective(elm,true);
  return elm;
end);


#############################################################################
##
#F  MorFroWords(<gens>) . . . . . . create some pseudo-random words in <gens>
##                                                featuring the MeatAxe's FRO
InstallGlobalFunction(MorFroWords,function(gens)
local list,a,b,ab,i;
  list:=[];
  ab:=gens[1];
  for i in [2..Length(gens)] do
    a:=ab;
    b:=gens[i];
    ab:=a*b;
    list:=Concatenation(list,
	 [ab,ab^2*b,ab^3*b,ab^4*b,ab^2*b*ab^3*b,ab^5*b,ab^2*b*ab^3*b*ab*b,
	 ab*(ab*b)^2*ab^3*b]);
  od;
  return list;
end);


#############################################################################
##
#F  MorRatClasses(<G>) . . . . . . . . . . . local rationalization of classes
##
InstallGlobalFunction(MorRatClasses,function(GR)
local r,c,u,j,i,flag;
  Info(InfoMorph,2,"RationalizeClasses");
  r:=[];
  for c in RationalClasses(GR) do
    u:=Subgroup(GR,[Representative(c)]);
    j:=DecomposedRationalClass(c);
    Add(r,rec(representative:=u,
		class:=j[1],
		classes:=j,
		size:=Size(c)));
  od;

  for i in r do
    i.size:=Sum(i.classes,Size);
  od;
  return r;
end);

#############################################################################
##
#F  MorMaxFusClasses(<l>) . .  maximal possible morphism fusion of classlists
##
InstallGlobalFunction(MorMaxFusClasses,function(r)
local i,j,flag,cl;
  # cl is the maximal fusion among the rational classes.
  cl:=[]; 
  for i in r do
    j:=0;
    flag:=true;
    while flag and j<Length(cl) do
      j:=j+1;
      flag:=not(Size(i.class)=Size(cl[j][1].class) and
		  i.size=cl[j][1].size and
		  Size(i.representative)=Size(cl[j][1].representative));
    od;
    if flag then
      Add(cl,[i]);
    else
      Add(cl[j],i);
    fi;
  od;

  # sort classes by size
  Sort(cl,function(a,b) return
    Sum(a,i->i.size)
      <Sum(b,i->i.size);end);
  return cl;
end);

#############################################################################
##
#F  MorClassLoop(<range>,<classes>,<params>,<action>)  loop over classes list
##     to find generating sets or Iso/Automorphisms up to inner automorphisms
##  
##  classes is a list of records like the ones returned from
##  MorMaxFusClasses.
##
##  params is a record containing optional components:
##  gens  generators that are to be mapped
##  from  preimage group (that contains gens)
##  to    image group (as it might be smaller than 'range')
##  free  free generators
##  rels  some relations that hold in from, given as list [word,order]
##  dom   a set of elements on which automorphisms act faithful
##  aut   Subgroup of already known automorphisms
##
##  action is a number whose bit-representation indicates the action to be
##  taken:
##  1     homomorphism
##  2     injective
##  4     surjective
##  8     find all (in contrast to one)
##
InstallGlobalFunction(MorClassLoop,function(range,clali,params,action)
local id,result,rig,dom,tall,tsur,tinj,thom,gens,free,rels,len,el,ind,cla,m,
      mp,cen,i,imgs,ok,size,l;

  id:=One(range);
  if IsBound(params.aut) then
    result:=params.aut;
    rig:=true;
    if IsBound(params.dom) then
      dom:=params.dom;
    else
      dom:=false;
    fi;
  else
    result:=[];
    rig:=false;
  fi;

  tall:=action>7; # try all
  if tall then
    action:=action-8;
  fi;
  tsur:=action>3; # test surjective
  if tsur then
    size:=Size(params.to);
    action:=action-4;
  fi;
  tinj:=action>1; # test injective
  if tinj then
    action:=action-2;
  fi;
  thom:=action>0; # test homomorphism

  if IsBound(params.gens) then
    gens:=params.gens;
  fi;

  if IsBound(params.rels) then
    free:=params.free;
    rels:=params.rels;
  else
    rels:=false;
  fi;

  len:=Length(clali);
  # backtrack over all classes in clali
  l:=ListWithIdenticalEntries(len,1);
  ind:=len;
  while ind>0 do
    ind:=len;
    # test class combination indicated by l:
    cla:=List([1..len],i->clali[i][l[i]]); 
    # test, whether a gen.sys. can be taken from the classes in <cla>
    # candidates.  This is another backtrack
    m:=[];
    m[len]:=[Representative(cla[len])];
    # positions
    mp:=[];
    mp[len]:=1;
    mp[len+1]:=-1;
    # centralizers
    cen:=[];
    cen[len]:=Intersection(range,Centralizer(cla[len]));
    cen[len+1]:=range; # just for the recursion
    i:=len-1;

    # set up the lists
    while i>0 do
      m[i]:=List(DoubleCosets(range,Intersection(range,Centralizer(cla[i])),
                 cen[i+1]),j->Representative(cla[i])^Representative(j));
      mp[i]:=1;
      if i>1 then
	cen[i]:=Centralizer(cen[i+1],m[i][1]);
      fi;
      i:=i-1;
    od;
    i:=1; 

    while i<len do
      imgs:=List([1..len],i->m[i][mp[i]]);

      # computing the size can be nasty. Thus try given relations first.
      ok:=true;
      if rels<>false then
        ok:=ForAll(rels,i->Order(MappedWord(i[1],free,imgs))=i[2]);
      fi;

      # check surjectivity
      if tsur and ok then
        ok:= Size( GroupByGenerators( imgs, id ) ) = size;
      fi;

      if ok and thom then
        imgs:=GroupGeneralMappingByImages(params.from,range,gens,imgs);
	SetIsTotal(imgs,true);
	Info(InfoMorph,3,"testing");
	ok:=IsSingleValued(imgs);
	if ok and tinj then
	  ok:=IsInjective(imgs);
	fi;
      fi;
      
      if ok then
	Info(InfoMorph,2,"found");
	# do we want one or all?
	if tall then
	  if rig then
	    if not imgs in result then
	      result:= GroupByGenerators( Concatenation(
                           GeneratorsOfGroup( result ), [ imgs ] ),
			   One( result ) );
	      StoreNiceMonomorphismAutomGroup(result,dom,gens);
	      Size(result);
	      Info(InfoMorph,2,"new ",Size(result));
	    fi;
	  else
	    Add(result,imgs);
	  fi;
	else
	  return imgs;
        fi;
      fi;

      mp[i]:=mp[i]+1;
      while i<=len and mp[i]>Length(m[i]) do
	mp[i]:=1;
	i:=i+1;
	mp[i]:=mp[i]+1;
      od;
      if i<=len then
	while i>1 do
	  cen[i]:=Centralizer(cen[i+1],m[i][mp[i]]);
	  i:=i-1;
	  m[i]:=List(DoubleCosets(range,Intersection(range,
	                                             Centralizer(cla[i])),
                 cen[i+1]),j->Representative(cla[i])^Representative(j));
	  mp[i]:=1;
	od;
      fi;
    od;

    # 'free for increment'
    l[ind]:=l[ind]+1;
    while ind>0 and l[ind]>Length(clali[ind]) do
      l[ind]:=1;
      ind:=ind-1;
      if ind>0 then
	l[ind]:=l[ind]+1;
      fi;
    od;
  od;

  return result;
end);


#############################################################################
##
#F  MorFindGeneratingSystem(<G>,<cl>) . .  find generating system with an few 
##                      as possible generators from the first classes in <cl>
##
InstallGlobalFunction(MorFindGeneratingSystem,function(G,cl)
local lcl,len,comb,combc,com,a;
  Info(InfoMorph,1,"FindGenerators");
  # throw out the 1-Class
  cl:=Filtered(cl,i->Length(i)>1 or Size(i[1].representative)>1);

  #create just a list of ordinary classes.
  lcl:=List(cl,i->Concatenation(List(i,j->j.classes)));
  len:=1;
  len:=Maximum(1,Length(MinimalGeneratingSet(
		    Image(IsomorphismPcGroup((G/DerivedSubgroup(G))))))-1);
  while true do
    len:=len+1;
    Info(InfoMorph,2,"Trying length ",len);
    # now search for <len>-generating systems
    comb:=UnorderedTuples([1..Length(lcl)],len); 
    combc:=List(comb,i->List(i,j->lcl[j]));

    # test all <comb>inations
    com:=0;
    while com<Length(comb) do
      com:=com+1;
      a:=MorClassLoop(G,combc[com],rec(to:=G),4);
      if Length(a)>0 then
        return a;
      fi;
    od;
  od;
end);

#############################################################################
##
#F  Morphium(<G>,<H>,<DoAuto>) . . . . . . . .Find isomorphisms between G and H
##       modulo inner automorphisms. DoAuto indicates whetehra all
## 	 automorphism are to be found
##       This function thus does the main combinatoric work for creating 
##       Iso- and Automorphisms.
##       It needs, that both groups are not cyclic.
##
InstallGlobalFunction(Morphium,function(G,H,DoAuto)
local 
      len,comb,combc,com,combi,l,m,mp,cen,Gr,Gcl,Ggc,Hr,Hcl,
      ind,gens,i,j,c,cla,u,lcl,hom,isom,free,elms,price,result,rels,inns;

  gens:=SmallGeneratingSet(G);
  len:=Length(gens);
  Gr:=MorRatClasses(G);
  Gcl:=MorMaxFusClasses(Gr);

  Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
  combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
  price:=Product(combi,i->Sum(i,Size));
  Info(InfoMorph,1,"generating system of price:",price,"");

  if not HasMinimalGeneratingSet(G) and price/Size(G)>10000  then

    if IsSolvableGroup(G) then
      gens:=IsomorphismPcGroup(G);
      gens:=List(MinimalGeneratingSet(Image(gens)),
                 i->PreImagesRepresentative(gens,i));
    else
      gens:=MorFindGeneratingSystem(G,Gcl);
    fi;

    Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
    combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
    price:=Product(combi,i->Sum(i,Size));
    Info(InfoMorph,1,"generating system of price:",price,"");
  fi;

  if not DoAuto then
    Hr:=MorRatClasses(H);
    Hcl:=MorMaxFusClasses(Hr);
  fi;

  # now test, whether it is worth, to compute a finer congruence
  # then ALSO COMPUTE NEW GEN SYST!
  # [...]

  if not DoAuto then
    combi:=[];
    for i in Ggc do
      c:=Filtered(Hcl,
	   j->Set(List(j,k->k.size))=Set(List(i,k->k.size))
		and Length(j[1].classes)=Length(i[1].classes) 
		and Size(j[1].class)=Size(i[1].class)
		and Size(j[1].representative)=Size(i[1].representative)
      # This test assumes maximal fusion among the rat.classes. If better
      # congruences are used, they MUST be checked here also!
	);
      if Length(c)<>1 then
	# Both groups cannot be isomorphic, since they lead to different 
	# congruences!
	Info(InfoMorph,2,"different congruences");
	return fail;
      else
	Add(combi,c[1]);
      fi;
    od;
    combi:=List(combi,i->Concatenation(List(i,i->i.classes)));
  fi;

  # combi contains the classes, from which the
  # generators are taken.

  free:=GeneratorsOfGroup(FreeGroup(Length(gens)));
  rels:=MorFroWords(free);
  rels:=List(rels,i->[i,Order(MappedWord(i,free,gens))]);
  result:=rec(gens:=gens,from:=G,to:=H,free:=free,rels:=rels);

  if DoAuto then

    inns:=List(GeneratorsOfGroup(G),i->InnerAutomorphism(G,i));
    if Sum(Flat(combi),Size)<=MORPHEUSELMS then
      elms:=[];
      for i in Flat(combi) do
        if not ForAny(elms,j->Representative(i)=Representative(j)) then
	  # avoid duplicate classes
	  Add(elms,i);
	fi;
      od;
      elms:=Union(List(elms,AsList));

      Assert(2,ForAll(GeneratorsOfGroup(G),i->ForAll(elms,j->j^i in elms)));
      result.dom:=elms;
      inns:= GroupByGenerators( inns, IdentityMapping( G ) );
      StoreNiceMonomorphismAutomGroup(inns,elms,gens);
      result.aut:=inns;
    else
      elms:=false;
    fi;

    result:=rec(aut:=MorClassLoop(H,combi,result,15));

    if elms<>false then
      result.elms:=elms;
      result.elmsgens:=Filtered(gens,i->i<>One(G));
      inns:=SubgroupNC(result.aut,GeneratorsOfGroup(inns));
    fi;
    result.inner:=inns;
  else
    result:=MorClassLoop(H,combi,result,7);
  fi;

  return result;

end);

#############################################################################
##
#F  AutomorphismGroupAbelianGroup(<G>)
##
InstallGlobalFunction(AutomorphismGroupAbelianGroup,function(G)
local i,j,k,l,m,o,nl,nj,max,r,e,au,p,gens,offs;

  # trivial case
  if Size(G)=1 then
    au:= GroupByGenerators( [], IdentityMapping( G ) );
    StoreNiceMonomorphismAutomGroup(au,[One(G)],[One(G)]);
    SetIsAutomorphismGroup( au, true );
    SetIsFinite(au,true);
    return au;
  fi;

  # get standard generating system
  if not IsPermGroup(G) then
    p:=IsomorphismPermGroup(G);
    gens:=IndependentGeneratorsOfAbelianGroup(Image(p));
    gens:=List(gens,i->PreImagesRepresentative(p,i));
  else
    gens:=IndependentGeneratorsOfAbelianGroup(G);
  fi;

  au:=[];
  # run by primes
  p:=Set(Factors(Size(G)));
  for i in p do
    l:=Filtered(gens,j->IsInt(Order(j)/i));
    nl:=Filtered(gens,i->not i in l);

    #sort by exponents
    o:=List(l,j->LogInt(Order(j),i));
    e:=[];
    for j in Set(o) do
      Add(e,[j,l{Filtered([1..Length(o)],k->o[k]=j)}]);
    od;

    # construct automorphisms by components
    for j in e do
      nj:=Concatenation(List(Filtered(e,i->i[1]<>j[1]),i->i[2]));
      r:=Length(j[2]);

      # the permutations and addition
      if r>1 then
	Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
	    #(1,2)
	    Concatenation(nl,nj,j[2]{[2]},j[2]{[1]},j[2]{[3..Length(j[2])]})));
	Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
	    #(1,..,n)
	    Concatenation(nl,nj,j[2]{[2..Length(j[2])]},j[2]{[1]})));
	#for k in [0..j[1]-1] do
        k:=0;
	  Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
	      #1->1+i^k*2
	      Concatenation(nl,nj,[j[2][1]*j[2][2]^(i^k)],
	                          j[2]{[2..Length(j[2])]})));
        #od;
      fi;
  
      # multiplications

      for k in List( Flat( GeneratorsPrimeResidues(i^j[1])!.generators ),
              Int )  do

	Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
	    #1->1^k
	    Concatenation(nl,nj,[j[2][1]^k],j[2]{[2..Length(j[2])]})));
      od;

    od;
    
    # the mixing ones
    for j in [1..Length(e)] do
      for k in [1..Length(e)] do
	if k<>j then
	  nj:=Concatenation(List(e{Difference([1..Length(e)],[j,k])},i->i[2]));
	  offs:=Maximum(0,e[k][1]-e[j][1]);
	  if Length(e[j][2])=1 and Length(e[k][2])=1 then
	    max:=Minimum(e[j][1],e[k][1])-1;
	  else
	    max:=0;
	  fi;
	  for m in [0..max] do
	    Add(au,GroupHomomorphismByImagesNC(G,G,
	       Concatenation(nl,nj,e[j][2],e[k][2]),
	       Concatenation(nl,nj,[e[j][2][1]*e[k][2][1]^(i^(offs+m))],
				    e[j][2]{[2..Length(e[j][2])]},e[k][2])));
	  od;
	fi;
      od;
    od;
  od;

  for i in au do
    SetIsBijective(i,true);
    SetIsConjugatorAutomorphism(i,false);
    SetFilterObj(i,IsMultiplicativeElementWithInverse);
  od;

  au:= GroupByGenerators( au, IdentityMapping( G ) );
  SetIsAutomorphismGroup( au, true );

  if Size(G)<MORPHEUSELMS then
    # note permutation action
    StoreNiceMonomorphismAutomGroup(au,
      Filtered(AsList(G),i->Order(i)>1),
      GeneratorsOfGroup(G));
  fi;
  SetInnerAutomorphismsAutomorphismGroup(au,TrivialSubgroup(au));

  if IsFinite(G) then
    SetIsFinite(au,true);
  fi;

  return au;
end);

#############################################################################
##
#F  IsomorphismAbelianGroups(<G>)
##
InstallGlobalFunction(IsomorphismAbelianGroups,function(G,H)
local o,p,gens,hens;

  # get standard generating system
  if not IsPermGroup(G) then
    p:=IsomorphismPermGroup(G);
    gens:=IndependentGeneratorsOfAbelianGroup(Image(p));
    gens:=List(gens,i->PreImagesRepresentative(p,i));
  else
    gens:=IndependentGeneratorsOfAbelianGroup(G);
  fi;
  gens:=ShallowCopy(gens);

  # get standard generating system
  if not IsPermGroup(H) then
    p:=IsomorphismPermGroup(H);
    hens:=IndependentGeneratorsOfAbelianGroup(Image(p));
    hens:=List(hens,i->PreImagesRepresentative(p,i));
  else
    hens:=IndependentGeneratorsOfAbelianGroup(H);
  fi;
  hens:=ShallowCopy(hens);

  o:=List(gens,i->Order(i));
  p:=List(hens,i->Order(i));

  SortParallel(o,gens);
  SortParallel(p,hens);

  if o<>p then
    return fail;
  fi;

  o:=GroupHomomorphismByImagesNC(G,H,gens,hens);
  SetIsBijective(o,true);

  return o;
end);

#############################################################################
##
#M  AutomorphismGroup(<G>) . . group of automorphisms, given as Homomorphisms
##
InstallMethod(AutomorphismGroup,"Group",true,[IsGroup and IsFinite],0,
function(G)
local a;
  if IsAbelian(G) then
    a:=AutomorphismGroupAbelianGroup(G);
    if HasIsFinite(G) and IsFinite(G) then
      SetIsFinite(a,true);
    fi;
    return a;
  fi;
  a:=Morphium(G,G,true);
  if IsList(a.aut) then
    a.aut:= GroupByGenerators( Concatenation( a.aut, a.inner ),
                               IdentityMapping( G ) );
    a.inner:=SubgroupNC(a.aut,a.inner);
  fi;
  SetInnerAutomorphismsAutomorphismGroup(a.aut,a.inner);
  SetIsFinite(a.aut,true);
  SetIsAutomorphismGroup( a.aut, true );
  if HasIsFinite(G) and IsFinite(G) then
    SetIsFinite(a.aut,true);
  fi;
  return a.aut;
end);

RedispatchOnCondition(AutomorphismGroup,true,[IsGroup],
    [IsGroup and IsFinite],0);

#############################################################################
##
#M AutomorphismGroup( G )
##
InstallMethod( AutomorphismGroup, 
               "finite abelian groups",
               true,
               [IsGroup and IsFinite and IsAbelian],
               0,
AutomorphismGroupAbelianGroup);


#############################################################################
##
#M NiceMonomorphism 
##
InstallMethod(NiceMonomorphism,"for automorphism groups",true,
              [IsAutomorphismGroup and IsFinite],0,
function( A )
local G, elms,stack,i,j,img;

    G  := Source( Identity(A) );

    StoreNiceMonomorphismAutomGroup(A,false,SmallGeneratingSet(G));

    # as `StoreNice' will have stored an attribute value this cannot cause
    # an infinite recursion:
    return NiceMonomorphism(A);
end);

#############################################################################
##
#M  IsomorphismPermGroup 
##
InstallMethod(IsomorphismPermGroup,"for automorphism groups",true,
               [IsAutomorphismGroup and IsFinite],0,
function(A)
local nice;
  nice:=NiceMonomorphism(A);
  if IsPermGroup(Range(nice)) then
    return nice;
  else
    return CompositionMapping(IsomorphismPermGroup(Image(nice)),nice);
  fi;
end);

#############################################################################
##
#M InnerAutomorphismsAutomorphismGroup(<A>) 
##
InstallMethod( InnerAutomorphismsAutomorphismGroup,
               "for automorphism groups",
               true,
               [IsAutomorphismGroup and IsFinite],
               0,
function( A )
local G,gens;
  G:=Source(Identity(A));
  gens:=GeneratorsOfGroup(G);
  # get the non-central generators
  gens:=Filtered(gens,i->not ForAll(gens,j->i*j=j*i));
  return List(gens,i->InnerAutomorphism(G,i));
end);


#############################################################################
##
#F  IsomorphismGroups(<G>,<H>) . . . . . . . . . .  isomorphism from G onto H
##
InstallGlobalFunction(IsomorphismGroups,function(G,H)
local m,n;

  #AH: Spezielle Methoden ?
  if Size(G)=1 then
    if Size(H)<>1 then
      return fail;
    else
      return GroupHomomorphismByImagesNC(G,H,[],[]);
    fi;
  fi;
  if IsAbelian(G) then
    if not IsAbelian(H) then
      return fail;
    else
      return IsomorphismAbelianGroups(G,H);
    fi;
  fi;

  #Print("GroupId not yet implemented\n");
  if Size(G)<>Size(H) or
     Length(ConjugacyClasses(G))<>Length(ConjugacyClasses(H))
     or (ID_AVAILABLE( Size( G ) ) =true and IdGroup(G)<>IdGroup(H))
     then
   return fail;
  fi;

  m:=Morphium(G,H,false);
  if IsList(m) and Length(m)=0 then
    return fail;
  else
    return m;
  fi;

end);


#############################################################################
##
#F  GQuotients(<F>,<G>)  . . . . . epimorphisms from F onto G up to conjugacy
##
InstallMethod(GQuotients,"for groups which can compute element orders",true,
  [IsGroup,IsGroup and IsFinite],1,
function (F,G)
local Fgens,	# generators of F
      cl,	# classes of G
      u,	# trial generating set's group
      pimgs,	# possible images
      val,	# its value
      best,	# best generating set
      bestval,	# its value
      sz,	# |class|
      i,	# loop
      h,	# epis
      len,	# nr. gens tried
      fak,	# multiplication factor
      cnt;	# countdown for finish

  # if we have a pontentially infinite fp group we cannot be clever
  if IsSubgroupFpGroup(F) and
    (not HasSize(F) or Size(F)=infinity) then
    TryNextMethod();
  fi;

  Fgens:=GeneratorsOfGroup(F);
  if IsAbelian(G) and not IsAbelian(F) then
    Info(InfoMorph,1,"abelian quotients vi F/F'");
    # for abelian factors go via the commutator factor group
    fak:=CommutatorFactorGroup(F);
    h:=NaturalHomomorphismByNormalSubgroup(F,DerivedSubgroup(F));
    fak:=Image(h,F);
    u:=GQuotients(fak,G);
    cl:=[];
    for i in u do
      i:=GroupHomomorphismByImagesNC(F,G,Fgens,
	     List(Fgens,j->Image(i,Image(h,j))));
      Add(cl,i);
    od;
    return cl;
  fi;

  if Size(G)=1 then
    return [GroupHomomorphismByImagesNC(F,G,Fgens,
			  List(Fgens,i->One(G)))];
  elif IsCyclic(F) then
    Info(InfoMorph,1,"Cyclic group: only one quotient possible");
    # a cyclic group has at most one quotient
    if not IsCyclic(G) or not IsInt(Size(F)/Size(G)) then
      return [];
    else
      # get the cyclic gens
      u:=First(AsList(F),i->Order(i)=Size(F));
      h:=First(AsList(G),i->Order(i)=Size(G));
      # just map them
      return [GroupHomomorphismByImagesNC(F,G,[u],[h])];
    fi;
  fi;

  if IsAbelian(G) then
    fak:=5;
  else
    fak:=50;
  fi;

  cl:=ConjugacyClasses(G);

  # first try to find a short generating system
  best:=false;
  bestval:=infinity;
  if Size(F)<10000000 and Length(Fgens)>2 then
    len:=Maximum(2,Length(SmallGeneratingSet(
                 Image(NaturalHomomorphismByNormalSubgroup(F,
		   DerivedSubgroup(F))))));
  else
    len:=2;
  fi;
  cnt:=0;
  repeat
    u:=List([1..len],i->Random(F));
    if Index(F,Subgroup(F,u))=1 then

      # find potential images
      pimgs:=[];
      for i in u do
        sz:=Index(F,Centralizer(F,i));
	Add(pimgs,Filtered(cl,j->IsInt(Order(i)/Order(Representative(j)))
			     and IsInt(sz/Size(j))));
      od;

      # sort u in descending order -> large reductions when centralizing
      SortParallel(pimgs,u,function(a,b)
			     return Sum(a,Size)>Sum(b,Size);
                           end);

      val:=Product(pimgs,i->Sum(i,Size));
      if val<bestval then
	Info(InfoMorph,2,"better value: ",List(u,i->Order(i)),
	      "->",val);
	best:=[u,pimgs];
	bestval:=val;
      fi;

    fi;
    cnt:=cnt+1;
    if cnt=len*fak and best=false then
      cnt:=0;
      Info(InfoMorph,1,"trying one generator more");
      len:=len+1;
    fi;
  until best<>false and (cnt>len*fak or bestval<3*cnt);

  h:=MorClassLoop(G,best[2],rec(gens:=best[1],to:=G,from:=F),13);
  cl:=[];
  u:=[];
  for i in h do
    if not KernelOfMultiplicativeGeneralMapping(i) in u then
      Add(u,KernelOfMultiplicativeGeneralMapping(i));
      Add(cl,i);
    fi;
  od;

  Info(InfoMorph,1,Length(h)," found -> ",Length(cl)," homs");
  return cl;
end);

InstallMethod(GQuotients,"without computing element orders",true,
  [IsSubgroupFpGroup,IsGroup and IsFinite],1,
function (F,G)
local Fgens,	# generators of F
      rels,	# power relations
      cl,	# classes of G
      u,	# trial generating set's group
      pimgs,	# possible images
      val,	# its value
      best,	# best generating set
      bestval,	# its value
      sz,	# |class|
      i,	# loop
      h,	# epis
      len,	# nr. gens tried
      cnt;	# countdown for finish

  Fgens:=GeneratorsOfGroup(F);

  if Length(Fgens)=0 then
    if Size(G)>1 then
      return [];
    else
      return [GroupHomomorphismByImagesNC(F,G,[],[])];
    fi;
  fi;

  if Size(G)=1 then
    return [GroupHomomorphismByImagesNC(F,G,Fgens,
			  List(Fgens,i->One(G)))];
  elif Length(Fgens)=1 then
    Info(InfoMorph,1,"Cyclic group: only one quotient possible");
    # a cyclic group has at most one quotient
    if not IsCyclic(G) then
      return [];
    else
      # get the cyclic gens
      h:=First(AsList(G),i->Order(i)=Size(G));
      # just map them
      return [GroupHomomorphismByImagesNC(F,G,Fgens,[h])];
    fi;
  fi;

  cl:=ConjugacyClasses(G);

  # search relators in only one generator
  rels:=ListWithIdenticalEntries(Length(Fgens),false);
  if IsSubgroupFpGroup(F) and IsWholeFamily(F) then
    for i in RelatorsOfFpGroup(F) do
      u:=List([1..Length(i)],j->Subword(i,j,j));
      if Length(Set(u))=1 then
        # found relator in only one generator
	val:=Position(FreeGeneratorsOfFpGroup(F),u[1]);
	if val=fail then
	  val:=Position(FreeGeneratorsOfFpGroup(F),u[1]^-1);
	  if val=fail then Error();fi;
	fi;
	u:=Length(u);
	if rels[val]=false then
	  rels[val]:=u;
	else
	  rels[val]:=Gcd(rels[val],u);
	fi;
      fi;
    od;
  fi;

  # find potential images
  pimgs:=[];

  for i in [1..Length(Fgens)] do
    if rels[i]<>false then
      Info(InfoMorph,2,"generator order must divide ",rels[i]);
      u:=Filtered(cl,j->IsInt(rels[i]/Order(Representative(j))));
    else
      Info(InfoMorph,2,"no restriction on generator order");
      u:=ShallowCopy(cl);
    fi;
    Add(pimgs,u);
  od;

  val:=Product(pimgs,i->Sum(i,Size));
  Info(InfoMorph,2,"Value: ",val);

  h:=MorClassLoop(G,pimgs,rec(gens:=Fgens,to:=G,from:=F),13);
  Info(InfoMorph,2,"Test kernels");
  cl:=[];
  u:=[];
  for i in h do
    if not KernelOfMultiplicativeGeneralMapping(i) in u then
      Add(u,KernelOfMultiplicativeGeneralMapping(i));
      Add(cl,i);
    fi;
  od;

  Info(InfoMorph,1,Length(h)," found -> ",Length(cl)," homs");
  return cl;
end);

#############################################################################
##
#E  morpheus.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
