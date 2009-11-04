/****************************************************************************
**
*W  gmpints.c                   GAP source                     John McDermott
**                                                           
**                                                           
**
*H  @(#)$Id: gmpints.c,v 4.7 2008/09/30 13:33:07 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file implements the  functions  handling  GMP integers.
**
*/
#ifdef USE_GMP

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "bool.h"                /* booleans                        */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "string.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#include        "extern/include/jhash.h" /* Jenkins Hash function, from extern */

#include <stdio.h>

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#include <stdlib.h>

#include <gmp.h>

#include <assert.h>
#include <string.h>
#include <ctype.h>

#define INCLUDE_DECLARATION_PART
#include        "gmpints.h"             /* GMP integers                    */
#undef  INCLUDE_DECLARATION_PART

const char * Revision_gmpints_c =
   "@(#)$Id: gmpints.c,v 4.7 2008/09/30 13:33:07 sal Exp $";

/* macros to save typing later :)                                          */
#define VAL_LIMB0(obj)         ( *(TypLimb *)ADDR_OBJ(obj)                  )
#define SET_VAL_LIMB0(obj,val) ( *(TypLimb *)ADDR_OBJ(obj) = val            )
#define IS_INTPOS(obj)         (  TNUM_OBJ(obj) == T_INTPOS                 )
#define IS_INTNEG(obj)         (  TNUM_OBJ(obj) == T_INTNEG                 )
#define IS_LARGEINT(obj)       (  ( TNUM_OBJ(obj) == T_INTPOS ) || \
                                  ( TNUM_OBJ(obj) == T_INTNEG )             )


/****************************************************************************
**
*F  TypeInt(<gmp>)  . . . . . . . . . . . . . . . . . . .  type of integer
**
**  'TypeInt' returns the type of the integer <gmp>.
**
**  'TypeInt' is the function in 'TypeObjFuncs' for integers.
*/
Obj             TYPE_INT_SMALL_ZERO;
Obj             TYPE_INT_SMALL_POS;
Obj             TYPE_INT_SMALL_NEG;
Obj             TYPE_INT_LARGE_POS;
Obj             TYPE_INT_LARGE_NEG;

Obj             TypeIntSmall (
    Obj                 val )
{
    if ( 0 == INT_INTOBJ(val) ) {
        return TYPE_INT_SMALL_ZERO;
    }
    else if ( 0 < INT_INTOBJ(val) ) {
        return TYPE_INT_SMALL_POS;
    }
    else {
        return TYPE_INT_SMALL_NEG;
    }
}

Obj TypeIntLargePos ( Obj val )
{
    return TYPE_INT_LARGE_POS;
}

Obj TypeIntLargeNeg ( Obj val )
{
    return TYPE_INT_LARGE_NEG;
}


/****************************************************************************
**
*F  FuncIS_INT( <self>, <val> ) . . . . . . . . . . internal function 'IsInt'
**
**  'FuncIS_INT' implements the internal filter 'IsInt'.
**
**  'IsInt( <val> )'
**
**  'IsInt'  returns 'true'  if the  value  <val>  is an small integer or a
**  large int, and 'false' otherwise.
*/
Obj IsIntFilt;

Obj FuncIS_INT ( Obj self, Obj val )
{
  if (    TNUM_OBJ(val) == T_INT 
       || TNUM_OBJ(val) == T_INTPOS
       || TNUM_OBJ(val) == T_INTNEG ) {
    return True;
  }
  else if ( TNUM_OBJ(val) <= FIRST_EXTERNAL_TNUM ) {
    return False;
  }
  else {
    return DoFilter( self, val );
  }
}


/****************************************************************************
**
*F  SaveInt( <gmp> )
**
**  
*/
void SaveInt( Obj gmp )
{
  TypLimb *ptr;
  UInt i;
  ptr = (TypLimb *)ADDR_INT(gmp);
  for (i = 0; i < SIZE_INT(gmp); i++)
    SaveLimb(*ptr++);
  return;
}


/****************************************************************************
**
*F  LoadInt( <gmp> )
**
**
*/
void LoadInt( Obj gmp )
{
  TypLimb *ptr;
  UInt i;
  ptr = (TypLimb *)ADDR_INT(gmp);
  for (i = 0; i < SIZE_INT(gmp); i++)
    *ptr++ = LoadLimb();
  return;
}


/****************************************************************************
**
*F  NEW_INT( <gmp> )
**
**
*/
static inline Obj NEW_INT( Obj gmp )
{
  Obj new;

  new = NewBag( TNUM_OBJ(gmp), SIZE_OBJ(gmp) );
  memcpy( ADDR_INT(new), ADDR_INT(gmp), SIZE_OBJ(gmp) );

  return new;
}


/****************************************************************************
**
*F  NEW_INTPOS( <gmp> )
**
**
*/
static inline Obj NEW_INTPOS( Obj gmp )
{
  Obj new;

  new = NewBag( T_INTPOS, SIZE_OBJ(gmp) );
  memcpy( ADDR_INT(new), ADDR_INT(gmp), SIZE_OBJ(gmp) );

  return new;
}


/****************************************************************************
**
*F  NEW_INTNEG( <gmp> )
**
**
*/
static inline Obj NEW_INTNEG( Obj gmp )
{
  Obj new;

  new = NewBag( T_INTNEG, SIZE_OBJ(gmp) );
  memcpy( ADDR_INT(new), ADDR_INT(gmp), SIZE_OBJ(gmp) );

  return new;
}


/****************************************************************************
**
*F  GMP_NORMALIZE( <gmp> ) . . . . . . .  remove leading zeros from a GMP bag
**
**  'GMP_NORMALIZE' removes any leading zeros from a <GMP> and returns a
**  small int or resizes the bag if possible.
**  
*/
/* findme - Should we rename these? */

Obj FuncGMP_NORMALIZE( Obj self, Obj gmp )
{
  if ( !IS_LARGEINT(gmp) ) return Fail;
  return GMP_NORMALIZE( gmp );
}

Obj GMP_NORMALIZE ( Obj gmp )
{
  TypGMPSize size;
  if IS_INTOBJ( gmp ) {
    return gmp;
  }
  for ( size = SIZE_INT(gmp); size != (TypGMPSize)1; size-- ) {
    if ( ADDR_INT(gmp)[(size - 1)] != (TypLimb)0 ) {
      break;
    }
  }
  if ( size < SIZE_INT(gmp) ) {
    ResizeBag( gmp, size*sizeof(TypLimb) );
  }
  return gmp;
}

Obj FuncGMP_REDUCE( Obj self, Obj gmp )
{
  if ( !IS_LARGEINT(gmp) ) return Fail;
  return GMP_REDUCE( gmp );
}

Obj GMP_REDUCE( Obj gmp )
{
  if IS_INTOBJ( gmp ) {
    return gmp;
  }
  if ( SIZE_INT(gmp) == 1){
    if ( ( VAL_LIMB0(gmp) < (TypLimb)((1L<<NR_SMALL_INT_BITS)) ) ||
	 ( IS_INTNEG(gmp) && 
	   ( VAL_LIMB0(gmp) == (TypLimb)(1L<<NR_SMALL_INT_BITS) ) ) ) {
      if ( IS_INTNEG(gmp) ) {
	return INTOBJ_INT( -(Int)VAL_LIMB0(gmp) );
      }
      else {
	return INTOBJ_INT(  (Int)VAL_LIMB0(gmp) );
      }
    }
  }
  return gmp;
}


/****************************************************************************
**
*F  FuncGMP_INTOBJ(<gmp>) . . . . . . . . . . . . . . . . . . . .  conversion
**
*/
Obj FuncGMP_INTOBJ( Obj self, Obj i )
{
  Obj gmp;
  Int   j;

  if ( !IS_INTOBJ(i) ) {
    return Fail;
  }
  else {
    j = INT_INTOBJ( i );
    if ( j < 0 ) {
      gmp = NewBag( T_INTNEG, sizeof(TypLimb) );
      j = -j;
    }
    else {
      gmp = NewBag( T_INTPOS, sizeof(TypLimb) );
    }
  }
  memcpy( ADDR_INT(gmp), &j, sizeof(Int) );
  return gmp;
}

  
/****************************************************************************
**
*F  GMPorINTOBJ_INT( <cint> ) . . . . . . . .  convert c int to gmp or intobj
**
**  'GMPorINTOBJ_INT' takes the C integer <cint> and returns the equivalent
**  GMP obj or int obj, according to the value of <cint>.
**
*/
Obj GMPorINTOBJ_INT( Int i )
{
  Obj gmp;

  if ( (-(1L<<NR_SMALL_INT_BITS) <= i) && (i < 1L<<NR_SMALL_INT_BITS )) {
    return INTOBJ_INT(i);
  }
    else if (i < 0 ) {
    gmp = NewBag( T_INTNEG, sizeof(TypLimb) );
    }
  else {
    gmp = NewBag( T_INTPOS, sizeof(TypLimb) );
  }
  SET_VAL_LIMB0( gmp, i );
  return gmp;
}

/* findme - missing ObjInt_UInt */
Obj ObjInt_Int( Int i )
{
  return GMPorINTOBJ_INT( i );
}

/****************************************************************************
**
*F  PrintInt( <gmp> ) . . . . . . . . . . . . . . . . print a GMP constant
**
**  'PrintInt' prints the GMP integer <gmp> in the usual decimal
**  notation.
**
**  cf PrintInt in integer.c
*/
void PrintInt ( Obj op )
{
  Char buf[20000];

  /* print a small integer                                                 */
  if ( IS_INTOBJ(op) ) {
    Pr( "%>%d%<", INT_INTOBJ(op), 0L );
  }
  
  /* print a large integer                                                 */
  else if ( SIZE_INT(op) < 1000 ) {
    /* use gmp func to print int to buffer                                 */
    if IS_INTPOS(op) {
      gmp_snprintf( buf, 19999, "%Ni", (TypLimb *)ADDR_INT(op),
		   (TypGMPSize)SIZE_INT(op) );
    }
    else {
      gmp_snprintf( buf, 19999, "-%Ni", (TypLimb *)ADDR_INT(op),
		   (TypGMPSize)SIZE_INT(op) );
    }
    /* print the buffer, %> means insert '\' before a linebreak            */
    Pr("%>%s%<",(Int)buf, 0);
  }
  else {
    Pr("<<an integer too large to be printed>>",0L,0L);
  }
}


/****************************************************************************
**
*F  FuncHexStringInt( <self>, <gmp> ) . . . . . . . .  hex string for gmp int
*F  FuncIntHexString( <self>, <string> ) . . . . . .  gmp int from hex string
**  
**  The  function  `FuncHexStringInt'  constructs from  a gmp integer  the
**  corresponding string in  hexadecimal notation. It has  a leading '-'
**  for negative numbers and the digits 10..15 are written as A..F.
**  
**  The  function `FuncIntHexString'  does  the converse,  but here  the
**  letters a..f are also allowed in <string> instead of A..F.
**  
*/
Obj FuncHexStringInt( Obj self, Obj integer )
{
  size_t alloc_size, str_size;
  Int i, j, n; /* len */
  UInt nf;
  /* TypLimb d, f; */
  UInt1 *p, a, *s;
  Obj res;
  
  /* immediate integers */
  if (IS_INTOBJ(integer)) {
    n = INT_INTOBJ(integer);
    /* 0 is special */
    if (n == 0) {
      res = NEW_STRING(1);
      CHARS_STRING(res)[0] = '0';
      return res;
    }
    
    /* else we create a string big enough for any immediate integer        */
    res = NEW_STRING(2 * NR_HEX_DIGITS + 1);
    p = CHARS_STRING(res);
    /* handle sign */
    if (n<0) {
      p[0] = '-';
      n = -n;
      p++;
    }
    else 
      SET_LEN_STRING(res, GET_LEN_STRING(res)-1);
    /* collect digits, skipping leading zeros                              */
    j = 0;
    nf = ((UInt)15) << (4*(2*NR_HEX_DIGITS-1));
    for (i = 2*NR_HEX_DIGITS; i; i-- ) {
      a = ((UInt)n & nf) >> (4*(i-1));
      if (j==0 && a==0) SET_LEN_STRING(res, GET_LEN_STRING(res)-1);
      else if (a<10) p[j++] = a + '0';
      else p[j++] = a - 10 + 'A';
      nf = nf >> 4;
    }
    /* final null character                                                */
    p[j] = 0;
    return res;
  }

  else if ( IS_LARGEINT(integer) ) {
    alloc_size = SIZE_INT(integer)*sizeof(TypLimb)*2+1;
    alloc_size += IS_INTNEG(integer);

    res = NEW_STRING( alloc_size );
    s = CHARS_STRING( res );

    if ( IS_INTNEG(integer) )
      *s++ = '-';

    str_size = mpn_get_str( s, 16, ADDR_INT(integer), SIZE_INT(integer) );
    assert ( str_size <= alloc_size - ( IS_INTNEG(integer) ) );

    for (j = 0; j < str_size-1; j++)
      if (s[j] != 0)
	break;
    

    for ( i = 0; i < str_size-j; i++ )
      s[i] = "0123456789ABCDEF"[s[i+j]];

    assert ( str_size - j == 1 || *s != '0' );

    /* findme  - this fails: */
    /*    assert ( strlen( CSTR_STRING(res) ) == alloc_size ); */
    /* adjust length in case of trailing \0 characters */
    /* [Is there a way to get it right from the beginning? FL] */
    /*     while (s[alloc_size-1] == '\0') 
	   alloc_size--; */
    SET_LEN_STRING(res, str_size-j + (IS_INTNEG(integer)));
    /*  assert ( strlen( CSTR_STRING(res) ) == GET_LEN_STRING(res) ); */
    return res;
  }

  else 
    ErrorReturnObj("HexStringInt: argument must be a int, (not a %s)",
		   (Int)TNAM_OBJ(integer), 0L,
		   "");
  /* please picky cc                                                       */
  return (Obj) 0L; 

}


Obj FuncIntHexString( Obj self,  Obj str )
{
  Obj res;
  Int  i, j, len, sign, nd;
  UInt n;
  UInt1 *p, a;
  UChar c;
  
  if (! IsStringConv(str))
    ErrorReturnObj("IntHexString: argument must be string (not a %s)",
		   (Int)TNAM_OBJ(str), 0L,
		   "");

  len = GET_LEN_STRING(str);
  if (len == 0) {
    res = INT_INTOBJ(0);
    return res;
  }
  if (*(CHARS_STRING(str)) == '-') {
    sign = -1;
    i = 1;
  }
  else {
    sign = 1;
    i = 0;
  }

  if ((len-i)*4 <= NR_SMALL_INT_BITS) {
    n = 0;
    p = CHARS_STRING(str);
    for (; i<len; i++) {
      a = p[i];
      if (a>96) 
	a -= 87;
      else if (a>64) 
	a -= 55;
      else 
	a -= 48;
      if (a > 15)
	ErrorReturnObj("IntHexString: non-valid character in hex-string",
		       0L, 0L, "");
      n = (n << 4) + a;
    }
    res = INTOBJ_INT(sign * n);
    return res;
  }

  else {
    nd = (len-i)/NR_HEX_DIGITS;
    if (nd * NR_HEX_DIGITS < (len-i)) nd++;
    /*   nd += ((3*nd) % 4); */
    if (sign == 1)
      res = NewBag( T_INTPOS, nd*sizeof(TypLimb) );
    else
      res = NewBag( T_INTNEG, nd*sizeof(TypLimb) );

    p = CHARS_STRING(str)+i;

    /* findme */
    /* the following destroys the supplied string - document this          */
    for (j=0;j<len-i;j++){
      c=p[j];
      if (isdigit (c))
	p[j] = c - '0';
      else if (islower (c))
	p[j] = c - 'a' + 10;
      else if (isupper (c))
	p[j] = c - 'A' + 10;
      else
	ErrorReturnObj("IntHexString: non-valid character in hex-string",
		       0L, 0L, "");
      if (p[j] >= 16)
	ErrorReturnObj("IntHexString: non-valid character in hex-string",
		       0L, 0L, "");
    }

    mpn_set_str(ADDR_INT(res),p,len-i,16);
    res = GMP_NORMALIZE(res);
    return res;
  }
}


/****************************************************************************
**
*F  FuncLog2Int( <self>, <gmp> ) . . . . . . . . . .  nr of bits of a GMP - 1
**  
**  Given to GAP-Level as "Log2Int".
*/
Obj FuncLog2Int( Obj self, Obj integer)
{
  Int res;
  Int a, len;
  Int mask;
  TypLimb dmask;
  
  /* case of small ints                                                    */
  if (IS_INTOBJ(integer)) {
    a = INT_INTOBJ(integer);
    if (a < 0) a = -a;
    res = NR_SMALL_INT_BITS;
    for(res = NR_SMALL_INT_BITS - 1, mask = (Int)1 << (NR_SMALL_INT_BITS-1);
        (mask & a) == 0 && mask != (Int)0;
        mask = mask >> 1, res--);
    return INTOBJ_INT(res);
  }

  /* case of long ints                                                     */
  if ( IS_LARGEINT(integer) ) {
    for (len = SIZE_INT(integer); ADDR_INT(integer)[len-1] == 0; len--);
    res = len * GMP_LIMB_BITS - 1;
    a = (TypLimb)(ADDR_INT(integer)[len-1]); 
    for(dmask = (TypLimb)1 << (GMP_LIMB_BITS - 1);
        (dmask & a) == 0 && dmask != (TypLimb)0;
        dmask = dmask >> 1, res--);
    return INTOBJ_INT(res);
  }
  else {
    ErrorReturnObj("Log2Int: argument must be a int, (not a %s)",
           (Int)TNAM_OBJ(integer), 0L,
           "");
    /* please picky cc                                                     */
    return (Obj) 0L;
  }
}

/****************************************************************************
**
*F  FuncSTRING_INT( <self>, <gmp> ) . . . . . . . . convert a GMP to a string
**
**  `FuncSTRING_INT' returns an immutable string representing the integer
**  <gmp>
**
*/
Obj String;

Obj FuncSTRING_INT( Obj self, Obj integer )
{
  Int   x;
  Obj str;
  Int len;
  Int   i;
  Char  c;
  Int neg;

  /* findme - enough space for a 1000 limb gmp int on a 64 bit machine     */
  /* change when 128 bit comes along!                                      */
  Char buf[20000];

  
  /* handle a small integer                                                */
  if ( IS_INTOBJ(integer) ) {
    x = INT_INTOBJ(integer);
    str = NEW_STRING( (NR_SMALL_INT_BITS+5)/3 );
    RetypeBag(str, T_STRING+IMMUTABLE);
    len = 0;
    /* Case of zero                                                        */
    if (x == 0)
      {
	CHARS_STRING(str)[0] = '0';
	CHARS_STRING(str)[1] = '\0';
	ResizeBag(str, SIZEBAG_STRINGLEN(1));
	SET_LEN_STRING(str, 1);
	
	return str;
      }
    /* Negative numbers                                                    */
    if (x < 0)
      {
	CHARS_STRING(str)[len++] = '-';
	x = -x;
	neg = 1;
      }
    else
      neg = 0;

    /* Now the main case                                                   */
    while (x != 0)
      {
	CHARS_STRING(str)[len++] = '0'+ x % 10;
	x /= 10;
      }
    CHARS_STRING(str)[len] = '\0';
    
    /* finally, reverse the digits in place                                */
    for (i = neg; i < (neg+len)/2; i++)
      {
	c = CHARS_STRING(str)[neg+len-1-i];
	CHARS_STRING(str)[neg+len-1-i] = CHARS_STRING(str)[i];
	CHARS_STRING(str)[i] = c;
      }
    
    ResizeBag(str, SIZEBAG_STRINGLEN(len));
    SET_LEN_STRING(str, len);
    return str;
  }

  /* handle a large integer                                                */
  else if ( SIZE_INT(integer) < 1000 ) {

    if IS_INTNEG(integer) {
    len = gmp_snprintf( buf, 19999, "-%Ni", (TypLimb *)ADDR_INT(integer),
	  (TypGMPSize)SIZE_INT(integer) );
    }
    else {
    len = gmp_snprintf( buf, 19999,  "%Ni", (TypLimb *)ADDR_INT(integer),
	  (TypGMPSize)SIZE_INT(integer) );
    }

    assert (len <= 19999);
    C_NEW_STRING( str, (TypGMPSize)len, buf );

    return str;

  }

  else {

      /* Very large integer, fall back on the GAP function                 */
      return CALL_1ARGS( String, integer);
  }
}
  

/****************************************************************************
**
*F  EqInt( <gmpL>, <gmpR> ) . . . . . . . . .  test if two integers are equal
**
**  
*/

  /* findme - For comparisons, do we first normalize and, if possible,
     reduce? Or (for one small, one gmp int) make the small int into a
     1-limb gmp to compare to the gmp. Or should we assume that gmp ints
     cannot be 'small'? */

Int EqInt ( Obj gmpL, Obj gmpR )
{
  Obj opL;
  Obj opR;

  /* compare two small integers                                          */
  if ( ARE_INTOBJS( gmpL, gmpR ) ) {
    if ( INT_INTOBJ(gmpL) == INT_INTOBJ(gmpR) )  return 1L;
    else                                       return 0L;
  }

  /* small ints fit into one limb of a GMP                                 */
  if IS_INTOBJ(gmpL) {
    if ( ( INT_INTOBJ(gmpL) <  0 && IS_INTPOS(gmpR) ) ||
	 ( 0 <= INT_INTOBJ(gmpL) && IS_INTNEG(gmpR) ) ||
	 ( SIZE_INT(gmpR) > (TypGMPSize)1 ) ) return 0L;
    opL = FuncGMP_INTOBJ( (Obj)0, gmpL );
  }
  else {
    opL = gmpL;
  }

  if IS_INTOBJ(gmpR) {
    if ( ( INT_INTOBJ(gmpR) <  0 && IS_INTPOS(gmpL) ) ||
	 ( 0 <= INT_INTOBJ(gmpR) && IS_INTNEG(gmpL) ) ||
	 ( SIZE_INT(gmpL) > (TypGMPSize)1 ) ) return 0L;
    opR = FuncGMP_INTOBJ( (Obj)0, gmpR );
  }
  else {
    opR = gmpR;
  }

  /* compare the sign and size                                             */
  if ( TNUM_OBJ(opL) != TNUM_OBJ(opR)
       || SIZE_INT(opL) != SIZE_INT(opR) )
    return 0L;

  if ( mpn_cmp( ADDR_INT(opL), ADDR_INT(opR), SIZE_INT(opL) ) == 0 ) 
    return 1L;
  else
    return 0L;
}

/****************************************************************************
**
*F  LtInt( <gmpL>, <gmpR> )  . . . . . . . . . . test whether <gmpL> < <gmpR>
**
*/
Int LtInt ( Obj gmpL, Obj gmpR )
{
  Obj opL;
  Obj opR;

  /* compare two small integers                                          */
  if ( ARE_INTOBJS( gmpL, gmpR ) ) {
    if ( INT_INTOBJ(gmpL) <  INT_INTOBJ(gmpR) ) return 1L;
    else return 0L;
  }

  /* compare a small and a large integer                                   */
  if ( IS_INTOBJ(gmpL) ) {
    if ( SIZE_INT(gmpR) > (TypGMPSize)1 ) {
      if ( IS_INTPOS(gmpR) ) return 1L;
      else return 0L;
    }
    else opL = FuncGMP_INTOBJ( (Obj)0, gmpL );
  }
  else {
    opL = gmpL;
  }

  if ( IS_INTOBJ(gmpR) ) {
    if ( SIZE_INT(gmpL) > (TypGMPSize)1 ) {
      if ( IS_INTNEG(gmpL) )  return 1L;
      else return 0L;
    }
    else opR = FuncGMP_INTOBJ( (Obj)0, gmpR );
  }
  else {
    opR = gmpR;
  }

  /* compare two large integers                                            */
  if ( IS_INTNEG(opL) && IS_INTPOS(opR) )
    return 1L;
  else if (   IS_INTPOS(opL) && IS_INTNEG(opR) )
    return 0L;
  else if ( ( IS_INTPOS(opR) && SIZE_INT(opL) < SIZE_INT(opR) ) ||
	    ( IS_INTNEG(opR) && SIZE_INT(opL) > SIZE_INT(opR) ) )
    return 1L;
  else if ( ( IS_INTPOS(opL) && SIZE_INT(opL) > SIZE_INT(opR) ) ||
	    ( IS_INTNEG(opL) && SIZE_INT(opL) < SIZE_INT(opR) ) )
    return 0L;
  else if ( IS_INTPOS(opL) ) {
    if ( mpn_cmp( ADDR_INT(opL), ADDR_INT(opR), SIZE_INT(opL) ) < 0 ) 
      return 1L;
    else
      return 0L;
  }
  else {
    if ( mpn_cmp( ADDR_INT(opL), ADDR_INT(opR), SIZE_INT(opL) ) > 0 ) 
      return 1L;
    else
      return 0L;
  }
}


/****************************************************************************
**
*F  SumInt( <gmpL>, <gmpR> ) . . . . . . . . . . . .  sum of two GMP integers
**
*/
Obj SumInt ( Obj gmpL, Obj gmpR )
{
  Obj sum;

  sum = SumOrDiffInt( gmpL, gmpR, +1 );

  return sum;

}


/****************************************************************************
**
*F  DiffInt( <gmpL>, <gmpR> ) . . . . . . . .  difference of two GMP integers
**
**  'DiffInt' returns the difference of the two GMP int arguments <gmpL>  and
**  <gmpR>.  'DiffInt' handles  operands  of  type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  'DiffInt' is a little bit tricky since there are many different cases to
**  handle, each operand can be positive or negative, small or large integer.
**  If the operands have opposite sign 'DiffInt' calls 'SumInt',  this  helps
**  reduce the total amount of code by a factor of two.
*/
Obj DiffInt ( Obj gmpL, Obj gmpR )
{
  Obj dif;
  
  dif = SumOrDiffInt( gmpL, gmpR, -1 );
  
  return dif;
}


/****************************************************************************
**
*F  SumOrDiffInt( <gmpL>, <gmpR> ) . . . . .  sum or diff of two Int integers
**
*/
Obj SumOrDiffInt ( Obj gmpL, Obj gmpR, Int sign )
{
  Obj       res; /* handle of result bag                                   */
  Int  twosmall; /* sum of two smalls                                      */
  Int  onesmall; /* set to 1 if one of args is a small int, 0 otherwise    */
  Int   swapped; /* set to 1 if args were swapped, 0 otherwise             */
  Int    resneg; /* set to 1 if result will be negative                    */
  Int   compare; /* value of mpn_cmp for two large ints                    */
  TypLimb carry; /* hold any carry or borrow                               */

  twosmall = 0;
  onesmall = 0;
  swapped  = 0;
  resneg   = 0;
  compare  = 0;

  /* findme - later change to put the non-overflow versions of these small
int adds/subs into the caller funcs SumInt, DiffInt. Then remove check of
SUM or DIFF _INTOBJS and document (at least in code) that this should not
be called directly */

  if ( sign != 1 && sign != -1 ) {
    ErrorReturnObj(
		   "SumOrDiffInt: <sign> must be +1 or -1. \nDo not call this function directly.",
		   0L, 0L,
		   "" );
  }

    /* adding two small integers                                           */
  if ( ARE_INTOBJS( gmpL, gmpR ) ) {

    /* add or subtract two small integers with a small sum                 */
    if (sign == 1) {
      if ( SUM_INTOBJS( res, gmpL, gmpR ) ) {
	return res;
      }
      else {
	twosmall = INT_INTOBJ(gmpL) + INT_INTOBJ(gmpR);
      }
    }
    else if (sign == -1) {
      if ( DIFF_INTOBJS( res, gmpL, gmpR ) ) {
	return res;
      }
      else {
	twosmall = INT_INTOBJ(gmpL) - INT_INTOBJ(gmpR);
      }
    }

    /* if two small integers have a large sum or difference form the gmp int*/
    if ( 0 < twosmall ) {
      res = NewBag( T_INTPOS, sizeof(TypLimb) );
      SET_VAL_LIMB0( res, (TypLimb)twosmall );
    }
    else {
      res = NewBag( T_INTNEG, sizeof(TypLimb) );
      SET_VAL_LIMB0( res, (TypLimb)(-twosmall) );
    }


    return res;
  }

  /* findme - we repeat some of this work in the 'add' part later on.
     Can we recycle some code? */

  /* the case of one small integer and one large                           */
  else if ( IS_INTOBJ( gmpL ) || IS_INTOBJ( gmpR ) ) {
    onesmall = 1;
    if ( IS_INTOBJ( gmpL ) ) {
      /* findme - do we need to normalize here? */
      gmpR = GMP_NORMALIZE( gmpR );
      gmpR = GMP_REDUCE( gmpR );
      if ( IS_INTOBJ(gmpR) ) {
	return INTOBJ_INT( INT_INTOBJ(gmpL) + sign*INT_INTOBJ(gmpR) );
      }
      res = gmpL; gmpL = gmpR; gmpR = res;
      swapped = 1;
    }
    else {
      gmpL = GMP_NORMALIZE( gmpL );
      gmpL = GMP_REDUCE( gmpL );
      if ( IS_INTOBJ(gmpL) ) {
	return INTOBJ_INT( INT_INTOBJ(gmpL) + sign*INT_INTOBJ(gmpR) );
      }
    }
  }

  /* two large ints                                                        */
  else if ( SIZE_INT( gmpL ) < SIZE_INT( gmpR ) ) {
    /* swap gmpL and gmpR                                                  */
    res = gmpL; gmpL = gmpR; gmpR = res;
    swapped = 1;
  }

  if      ( ( ( sign == +1 ) &&
	      ( (  ( onesmall ) &&
		  ( (IS_INTNEG(gmpL) && 0 <= INT_INTOBJ(gmpR)) ||
		    (IS_INTPOS(gmpL) && 0 >  INT_INTOBJ(gmpR)) )  ) ||
		( !( onesmall ) &&
		  ( (IS_INTPOS(gmpL) &&       IS_INTNEG(gmpR)) ||
		    (IS_INTNEG(gmpL) &&       IS_INTPOS(gmpR)) )  ) ) ) ||
	    ( ( sign == -1 ) &&
	      ( (  ( onesmall ) &&
		  ( (IS_INTNEG(gmpL) && 0 >  INT_INTOBJ(gmpR)) ||
		    (IS_INTPOS(gmpL) && 0 <= INT_INTOBJ(gmpR)) ) ) ||
		( !( onesmall ) &&
		  ( (IS_INTPOS(gmpL) &&       IS_INTPOS(gmpR)) ||
		    (IS_INTNEG(gmpL) &&       IS_INTNEG(gmpR)) )  ) ) ) ) {

    /* the args have different sign (or same sign and this is a subtraction)
       - compare to see which to subtract                                  */
    if ( onesmall ) {
      if ( ( ( ( swapped == 1 && sign == +1 ) || swapped == 0 )
	     && IS_INTNEG(gmpL) ) || 
	   ( swapped == 1 && sign == -1 && IS_INTPOS(gmpL) ) ) {
	res = NewBag( T_INTNEG, SIZE_OBJ(gmpL) );
      }
      else {
	res = NewBag( T_INTPOS, SIZE_OBJ(gmpL) );
      }
      gmpR = FuncGMP_INTOBJ( (Obj)0, gmpR );
      carry = mpn_sub_1( ADDR_INT(res), 
			 ADDR_INT(gmpL), SIZE_INT(gmpL),
			*ADDR_INT(gmpR) );
    }
    /* this test correct since size(gmpL) >= size(gmpR)                    */
    else if ( SIZE_INT(gmpL) != SIZE_INT(gmpR) ) {
      if ( ( ( ( swapped == 1 && sign == +1 ) || swapped == 0 )
	     && IS_INTNEG(gmpL) ) || 
	   ( swapped == 1 && sign == -1 && IS_INTPOS(gmpL) ) ) {
	res = NewBag( T_INTNEG, SIZE_OBJ(gmpL) );
      }
      else {
	res = NewBag( T_INTPOS, SIZE_OBJ(gmpL) );
      }
      carry = mpn_sub( ADDR_INT(res),
		       ADDR_INT(gmpL), SIZE_INT(gmpL),
		       ADDR_INT(gmpR), SIZE_INT(gmpR) );
    }
    /* ok, so they're the same size in limbs - which is the bigger number? */
    else if ( mpn_cmp( ADDR_INT(gmpL),
		       ADDR_INT(gmpR), SIZE_INT(gmpL) ) < 0 ) {
      if ( IS_INTPOS(gmpL) ) {
	res = NewBag( T_INTNEG, SIZE_OBJ(gmpL) );
      }
      else {
	res = NewBag( T_INTPOS, SIZE_OBJ(gmpL) );
      }
      carry = mpn_sub_n( ADDR_INT(res),
			 ADDR_INT(gmpR),
			 ADDR_INT(gmpL), SIZE_INT(gmpR) );
    }

    else {
      if ( IS_INTNEG(gmpL) ) {
	res = NewBag( T_INTNEG, SIZE_OBJ(gmpL) );
      }
      else {
	res = NewBag( T_INTPOS, SIZE_OBJ(gmpL) );
      }
      carry = mpn_sub_n( ADDR_INT(res),
			 ADDR_INT(gmpL),
			 ADDR_INT(gmpR), SIZE_INT(gmpL) );
    }

    res = GMP_NORMALIZE( res );
    res = GMP_REDUCE( res );
    return res;
  }

  else {
    /* The args have the same sign (or opp sign and this is a subtraction) 
       - so add them. At this stage, we are dealing with a large and a 
       small, or two large integers                                        */

    /* Will the result be negative?                                        */
    if ( ( sign ==  1 && IS_INTNEG(gmpL) ) ||
	 ( sign == -1 &&
	   ( ( swapped == 0 && IS_INTNEG(gmpL) ) ||
	     ( swapped == 1 && IS_INTPOS(gmpL) ) ) ) ) {
      resneg = 1;
    }
	 /*	   ( ( onesmall        && IS_INTNEG(gmpL) ) ||
	     ( IS_INTNEG(gmpL) && IS_INTNEG(gmpR) ) ||
	     ( SIZE_INT(gmpL) > SIZE_INT(gmpR) && IS_INTNEG(gmpL) ) ) ) ||
    if ( resneg == 0 && sign == 1 && SIZE_INT(gmpL) == SIZE_INT(gmpR) ) {
      compare = mpn_cmp( ADDR_INT(gmpL), ADDR_INT(gmpR), SIZE_INT(gmpL) );
      if ( ( compare >= 0 && IS_INTNEG(gmpL) ) ||
	   ( compare  < 0 && IS_INTNEG(gmpR) ) ) {
	resneg = 1;
      }
    }
	 */
    if ( onesmall ) {
      if ( resneg == 0 ) {
	res = NewBag( T_INTPOS, SIZE_OBJ(gmpL) + sizeof(TypLimb) );
      }
      else {
	res = NewBag( T_INTNEG, SIZE_OBJ(gmpL) + sizeof(TypLimb) );
      }
      gmpR = FuncGMP_INTOBJ( (Obj)0, gmpR );
      carry = mpn_add_1( ADDR_INT(res),
			 ADDR_INT(gmpL),SIZE_INT(gmpL),
			*ADDR_INT(gmpR) );
      if ( carry == (TypLimb)0 ) {
	ResizeBag( res, SIZE_OBJ(gmpL) );
      }
      else {
	( ADDR_INT(res) )[ SIZE_INT(gmpL) ] = (TypLimb)1; /* = carry ? */
      }
      /* findme - debugging 231107
      res = GMP_NORMALIZE( res );
      res = GMP_REDUCE( res ); */
    }

    else {
      /* put the smaller one (in limbs) to the right                       */
      if ( SIZE_INT(gmpL) < SIZE_INT(gmpR) ) { 
	res = gmpR; gmpR = gmpL; gmpL = res;
      }

      /* allocate result bag                                               */
      if ( resneg == 0 ) {
	res = NewBag( T_INTPOS, ( SIZE_OBJ(gmpL) + sizeof(TypLimb) ) );
      }
      else {
	res = NewBag( T_INTNEG, ( SIZE_OBJ(gmpL) + sizeof(TypLimb) ) );
      }
      
      /* mpn_lshift is faster still than mpn_add_n for adding a TypLimb
	 number to itself                                                  */
      if ( EqInt( gmpL, gmpR ) ) {
	carry = mpn_lshift( ADDR_INT(res),
			    ADDR_INT(gmpL), SIZE_INT(gmpL),
			    1 );
      }
      else {
	carry =    mpn_add( ADDR_INT(res),
			    ADDR_INT(gmpL), SIZE_INT(gmpL),
			    ADDR_INT(gmpR), SIZE_INT(gmpR) );
      }
      if ( carry == (TypLimb)0 ){
	ResizeBag( res, SIZE_OBJ(gmpL) );
      }
      else{
	( ADDR_INT(res) )[ SIZE_INT(gmpL) ] = (TypLimb)1;
      }
      /* findme - don't need this after carry ? */
      /* res = GMP_NORMALIZE( res );
	 res = GMP_REDUCE( res ); */
    }

    return res;
  }

}


/****************************************************************************
**
*F  ZeroInt(<gmp>)  . . . . . . . . . . . . . . . . . . . .  zero of integers
*/
Obj ZeroInt ( Obj  op )
{
  return INTOBJ_INT( (Int)0 );
}


/****************************************************************************
**
*F  AInvInt(<gmp>) . . . . . . . . . . . . . . additive inverse of an integer
*/
Obj AInvInt ( Obj gmp )
{
  Obj inv;

  /* handle small integer                                                */
  if ( IS_INTOBJ( gmp ) ) {
    
    /* special case (ugh)                                              */
    if ( gmp == INTOBJ_INT( -(1L<<NR_SMALL_INT_BITS) ) ) {
      inv = NewBag( T_INTPOS, sizeof(TypLimb) );
      SET_VAL_LIMB0( inv, 1L<<NR_SMALL_INT_BITS );
    }
    
    /* general case                                                    */
    else {
      inv = INTOBJ_INT( - INT_INTOBJ( gmp ) );
    }
    
  }

  else {
    if ( IS_INTPOS(gmp) ) {
      /* special case                                                        */
      if ( ( SIZE_INT(gmp) == 1 ) 
	   && ( VAL_LIMB0(gmp) == (TypLimb) (1L<<NR_SMALL_INT_BITS) ) ) {
	return INTOBJ_INT( -(Int) (1L<<NR_SMALL_INT_BITS) );
      }
      else {
	inv = NewBag( T_INTNEG, SIZE_OBJ(gmp) );
      }
    }
    
    else {
      inv = NewBag( T_INTPOS, SIZE_OBJ(gmp) );
    }

    memcpy( ADDR_INT(inv), ADDR_INT(gmp), SIZE_OBJ(gmp) );
  }
  
  /* return the inverse                                                    */
  return inv;

}

Obj AbsInt( Obj gmp )
{
  Obj a;
  if (IS_INTOBJ(gmp)) {
    if (((Int)gmp) > 0) 
      return gmp;
    else if (gmp == INTOBJ_INT(-(1L << NR_SMALL_INT_BITS)))
      return AInvInt(gmp);
    else
      return (Obj)(2-(Int)gmp);
  }
  if (TNUM_OBJ(gmp) == T_INTPOS)
    return gmp;
  a = NewBag(T_INTPOS, SIZE_OBJ(gmp));
  memcpy( ADDR_INT(a), ADDR_INT(gmp), SIZE_OBJ(gmp) );
  return a;
}

Obj FuncABS_INT(Obj self, Obj gmp)
{
  return AbsInt(gmp);
}


/* findme - documentation: remove or fix all references to EvProd, EvMod,
   etc., left from original integer.c (see the following preamble)         */

/****************************************************************************
**
**
**  'ProdInt' returns the product of the two  integer  arguments  <intL>
**  and <intR>.  'ProdInt' handles  operands  of  type 'T_INT', 'T_INTPOS'
**  and 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvProd' for a better efficiency.
**
**  Is called from the 'EvProd' binop so both operands are already evaluated.
**
**  The only difficulty about this function is the fact that is has to handle
**  3 different situations, depending on how many arguments  are  small ints.
*/
Obj ProdInt ( Obj gmpL, Obj gmpR )
{
  Obj                 prd;            /* handle of the result bag          */
  Int                   i;            /* hold small int value              */
  Int                   k;            /* hold small int value              */
  TypLimb           carry;            /* most significant limb: mpn_mul_1  */
  
  /* multiplying two small integers                                        */
  if ( ARE_INTOBJS( gmpL, gmpR ) ) {
    
    /* multiply two small integers with a small product                    */
    /* multiply and divide back to check that no overflow occured          */
    if ( PROD_INTOBJS( prd, gmpL, gmpR ) ) {
      return prd;
    }
    
    /* get the integer values                                              */
    i = INT_INTOBJ(gmpL);
    k = INT_INTOBJ(gmpR);
    
    /* allocate the product bag                                            */
    if ( (0 < i && 0 < k) || (i < 0 && k < 0) )
      prd = NewBag( T_INTPOS, 2*sizeof(TypLimb) );
    else
      prd = NewBag( T_INTNEG, 2*sizeof(TypLimb) );
    
    /* make both operands positive                                         */
    if ( i < 0 )  i = -i;
    if ( k < 0 )  k = -k;
    
    /* multiply                                                            */
    mpn_mul_n( ADDR_INT( prd ), (TypLimb*)( &i ),
	       (TypLimb*)( &k ), (TypGMPSize)1 );
  }
  
  /* multiply a small and a large integer                                  */
  else if ( IS_INTOBJ(gmpL) || IS_INTOBJ(gmpR) ) {

    /* make the right operand the small one                                */
    if ( IS_INTOBJ(gmpL) ) {
      k = INT_INTOBJ(gmpL);  gmpL = gmpR;
    }
    else {
      k = INT_INTOBJ(gmpR);
    }
    
    /* handle trivial cases first                                          */
    if ( k == 0 )
      return INTOBJ_INT(0);
    if ( k == 1 )
      return gmpL;
    
    /* eg: for 32 bit systems, the large integer 1<<28 times -1 is the small
       integer -(1<<28)                                                    */
    if ( ( k == -1 ) && (SIZE_INT(gmpL)==1) 
	 && ( VAL_LIMB0(gmpL) == (TypLimb)(1L<<NR_SMALL_INT_BITS) ) )
      return INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS));
    
    /* multiplication by -1 is easy, just switch the sign and copy         */
    if ( k == -1 ) {
      if ( TNUM_OBJ(gmpL) == T_INTPOS ) {
	prd = NewBag( T_INTNEG, SIZE_OBJ(gmpL) );
      }
      else {
	prd = NewBag( T_INTPOS, SIZE_OBJ(gmpL) );
      }
      memcpy( ADDR_OBJ(prd), ADDR_OBJ(gmpL), SIZE_OBJ(gmpL) );
      return prd;
    }
    
    /* allocate a bag for the result                                       */
    if ( (0 < k && TNUM_OBJ(gmpL) == T_INTPOS)
	 || (k < 0 && TNUM_OBJ(gmpL) == T_INTNEG) ) {
      prd = NewBag( T_INTPOS, (SIZE_INT(gmpL)+1)*sizeof(TypLimb) );
    }
    else {
      prd = NewBag( T_INTNEG, (SIZE_INT(gmpL)+1)*sizeof(TypLimb) );
    }
    
    if ( k < 0 )  k = -k;
    
    /* multiply                                                            */
    carry = mpn_mul_1( ADDR_INT(prd), ADDR_INT(gmpL),
	       SIZE_INT(gmpL), (TypLimb)k );
    if ( carry == (TypLimb)0 ) {
      ResizeBag( prd, SIZE_OBJ(gmpL) );
    }
    else {
      ( ADDR_INT(prd) )[ SIZE_INT(gmpL) ] = carry;
    }
  }
  
  /* multiply two large integers                                           */
  else {
    
    /* make the right operand the smaller one, for the mpn function        */
    if ( SIZE_INT(gmpL) < SIZE_INT(gmpR) ) {
      prd = gmpR;  gmpR = gmpL;  gmpL = prd;
    }
    
    /* allocate a bag for the result                                       */
    if ( TNUM_OBJ(gmpL) == TNUM_OBJ(gmpR) )
      prd = NewBag( T_INTPOS, SIZE_OBJ(gmpL)+SIZE_OBJ(gmpR) );
    else
      prd = NewBag( T_INTNEG, SIZE_OBJ(gmpL)+SIZE_OBJ(gmpR) );
    
    /* multiply                                                            */
    mpn_mul( ADDR_INT(prd),
	     ADDR_INT(gmpL), SIZE_INT(gmpL),
	     ADDR_INT(gmpR), SIZE_INT(gmpR) );
  }
  
  /* normalize and return the product                                      */
  prd = GMP_NORMALIZE( prd );
  prd = GMP_REDUCE( prd );
  return prd;
}


/****************************************************************************
**
*F  ProdIntObj(<n>,<op>)  . . . . . . . . product of an integer and an object
*/
Obj ProdIntObj ( Obj n, Obj op )
{
  Obj                 res = 0;        /* result                            */
  UInt                i, k;           /* loop variables                    */
  TypLimb             l;              /* loop variable                     */

  /* if the integer is zero, return the neutral element of the operand     */
  if      ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) ==  0 ) {
    res = ZERO( op );
  }
  
  /* if the integer is one, return the object if immutable -
     if mutable, add the object to its ZeroSameMutability to
     ensure correct mutability propagation                                 */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) ==  1 ) {
    if (IS_MUTABLE_OBJ(op))
      res = SUM(ZERO(op),op);
    else
      res = op;
  }
  
  /* if the integer is minus one, return the inverse of the operand        */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) == -1 ) {
    res = AINV( op );
  }
  
  /* if the integer is negative, invert the operand and the integer        */
  else if ( ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) <  -1 )
	    || IS_INTNEG(n) ) {
    res = AINV( op );
    if ( res == Fail ) {
      return ErrorReturnObj(
			    "Operations: <obj> must have an additive inverse",
			    0L, 0L,
			    "you can supply an inverse <inv> for <obj> via 'return <inv>;'" );
    }
    res = PROD( AINV( n ), res );
  }

  /* if the integer is small, compute the product by repeated doubling     */
  /* the loop invariant is <result> = <k>*<res> + <l>*<op>, <l> < <k>      */
  /* <res> = 0 means that <res> is the neutral element                     */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) >   1 ) {
    res = 0;
    k = 1L << (NR_SMALL_INT_BITS+1);
    l = INT_INTOBJ(n);
    while ( 1 < k ) {
      res = (res == 0 ? res : SUM( res, res ));
      k = k / 2;
      if ( k <= l ) {
	res = (res == 0 ? op : SUM( res, op ));
	l = l - k;
      }
    }
  }
  
  /* if the integer is large, compute the product by repeated doubling     */
  else if ( TNUM_OBJ(n) == T_INTPOS ) {
    res = 0;
    for ( i = SIZE_INT(n); 0 < i; i-- ) {
      k = 8*sizeof(TypLimb);
      l = ((TypLimb*) ADDR_INT(n))[i-1];
      while ( 0 < k ) {
	res = (res == 0 ? res : SUM( res, res ));
	k--;
	if ( (l >> k) & 1 ) {
	  res = (res == 0 ? op : SUM( res, op ));
	}
      }
    }
  }
  
  /* return the result                                                     */
  return res;
}

Obj ProdIntObjFunc;

Obj FuncPROD_INT_OBJ ( Obj self, Obj opL, Obj opR )
{
  return ProdIntObj( opL, opR );
}


/****************************************************************************
**
*F  OneInt(<gmp>) . . . . . . . . . . . . . . . . . . . . . one of an integer
*/
static Obj OneAttr;

Obj OneInt ( Obj op )
{
  return INTOBJ_INT( 1 );
}


/****************************************************************************
**
*F  PowInt( <intL>, <intR> )  . . . . . . . . . . . .  power of an integer
**
**  'PowInt' returns the <intR>-th (an integer) power of the integer
**  <intL>.
**  'PowInt' handles operands of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvPow' for a better  efficiency.
**
**  Is called from the 'EvPow'  binop so both operands are already evaluated.
*/
Obj PowInt ( Obj gmpL, Obj gmpR )
{
  Int                 i;
  Obj                 pow;
  
  /* power with a large exponent                                         */
  if ( ! IS_INTOBJ(gmpR) ) {
    if ( gmpL == INTOBJ_INT(0) )
      pow = INTOBJ_INT(0);
    else if ( gmpL == INTOBJ_INT(1) )
      pow = INTOBJ_INT(1);
    else if ( gmpL == INTOBJ_INT(-1) && ADDR_INT(gmpR)[0] % 2 == 0 )
      pow = INTOBJ_INT(1);
    else if ( gmpL == INTOBJ_INT(-1) && ADDR_INT(gmpR)[0] % 2 != 0 )
      pow = INTOBJ_INT(-1);
    else {
      gmpR = ErrorReturnObj(
			    "Integer operands: <exponent> is too large",
			    0L, 0L,
			    "you can replace the integer <exponent> via 'return <exponent>;'" );
      return POW( gmpL, gmpR );
    }
  }
  
  /* power with a negative exponent                                      */
  else if ( INT_INTOBJ(gmpR) < 0 ) {
    if ( gmpL == INTOBJ_INT(0) ) {
      gmpL = ErrorReturnObj(
			    "Integer operands: <base> must not be zero",
			    0L, 0L,
			    "you can replace the integer <base> via 'return <base>;'" );
      return POW( gmpL, gmpR );
    }
    else if ( gmpL == INTOBJ_INT(1) )
      pow = INTOBJ_INT(1);
    else if ( gmpL == INTOBJ_INT(-1) && INT_INTOBJ(gmpR) % 2 == 0 )
      pow = INTOBJ_INT(1);
    else if ( gmpL == INTOBJ_INT(-1) && INT_INTOBJ(gmpR) % 2 != 0 )
      pow = INTOBJ_INT(-1);
    else
      pow = QUO( INTOBJ_INT(1),
		 PowInt( gmpL, INTOBJ_INT( -INT_INTOBJ(gmpR)) ) );
  }
  
  /* findme - can we use the gmp function mpz_n_pow_ui? */

  /* power with a small positive exponent, do it by a repeated squaring  */
  else {
    pow = INTOBJ_INT(1);
    i = INT_INTOBJ(gmpR);
    while ( i != 0 ) {
      if ( i % 2 == 1 )  pow = ProdInt( pow, gmpL );
      if ( i     >  1 )  gmpL = ProdInt( gmpL, gmpL );
      i = i / 2;
    }
  }
  
  /* return the power                                                    */
  return pow;
}


/****************************************************************************
**
*F  PowObjInt(<op>,<n>) . . . . . . . . . . power of an object and an integer
*/
Obj             PowObjInt ( Obj op, Obj n )
{
  Obj                 res = 0;        /* result                          */
  UInt                i, k;           /* loop variables                  */
  TypLimb             l;              /* loop variable                   */
  
  /* if the integer is zero, return the neutral element of the operand   */
  if      ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) ==  0 ) {
    return ONE_MUT( op );
  }
  
  /* if the integer is one, return a copy of the operand                 */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) ==  1 ) {
    res = CopyObj( op, 0 );
  }
  
  /* if the integer is minus one, return the inverse of the operand      */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) == -1 ) {
    res = INV_MUT( op );
  }
  
  /* if the integer is negative, invert the operand and the integer      */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) <   0 ) {
    res = INV_MUT( op );
    if ( res == Fail ) {
      return ErrorReturnObj(
			    "Operations: <obj> must have an inverse",
			    0L, 0L,
			    "you can supply an inverse <inv> for <obj> via 'return <inv>;'" );
    }
    res = POW( res, AINV( n ) );
  }
  
  /* if the integer is negative, invert the operand and the integer      */
  else if ( TNUM_OBJ(n) == T_INTNEG ) {
    res = INV_MUT( op );
    if ( res == Fail ) {
      return ErrorReturnObj(
			    "Operations: <obj> must have an inverse",
			    0L, 0L,
			    "you can supply an inverse <inv> for <obj> via 'return <inv>;'" );
    }
    res = POW( res, AINV( n ) );
  }
  
  /* if the integer is small, compute the power by repeated squaring     */
  /* the loop invariant is <result> = <res>^<k> * <op>^<l>, <l> < <k>    */
  /* <res> = 0 means that <res> is the neutral element                   */
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) >   0 ) {
    res = 0;
    k = 1L << (NR_SMALL_INT_BITS+1);
    l = INT_INTOBJ(n);
    while ( 1 < k ) {
      res = (res == 0 ? res : PROD( res, res ));
      k = k / 2;
      if ( k <= l ) {
	res = (res == 0 ? op : PROD( res, op ));
	l = l - k;
      }
    }
  }
  
  /* if the integer is large, compute the power by repeated squaring     */
  else if ( TNUM_OBJ(n) == T_INTPOS ) {
    res = 0;
    for ( i = SIZE_INT(n); 0 < i; i-- ) {
      k = 8*sizeof(TypLimb);
      l = ((TypLimb*) ADDR_INT(n))[i-1];
      while ( 0 < k ) {
	res = (res == 0 ? res : PROD( res, res ));
	k--;
	if ( (l>>k) & 1 ) {
	  res = (res == 0 ? op : PROD( res, op ));
	}
      }
    }
  }

  /* return the result                                                   */
  return res;
}

Obj PowObjIntFunc;

Obj FuncPOW_OBJ_INT ( Obj self, Obj opL, Obj opR )
{
  return PowObjInt( opL, opR );
}


/****************************************************************************
**
*F  ModInt( <intL>, <intR> )  . representative of residue class of an integer
**
**  'ModInt' returns the smallest positive representant of the residue  class
**  of the  integer  <intL>  modulo  the  integer  <intR>.  'ModInt'  handles
**  operands of type 'T_INT', 'T_INTPOS', 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvMod' for a better efficiency.
p**
**  Is called from the 'EvMod'  binop so both operands are already evaluated.
*/
Obj ModInt ( Obj opL, Obj opR )
{
  Int                    i;             /* loop count, value for small int */
  Int                    k;             /* loop count, value for small int */
  UInt                   c;             /* product of two digits           */
  Obj                  mod;             /* handle of the remainder bag     */
  Obj                  quo;             /* handle of the quotient bag      */
  
  /* compute the remainder of two small integers                           */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* pathological case first                                             */
    if ( opR == INTOBJ_INT(0) ) {
      opR = ErrorReturnObj(
			   "Integer operations: <divisor> must be nonzero",
			   0L, 0L,
			   "you can replace the integer <divisor> via 'return <divisor>;'" );
      return MOD( opL, opR );
    }
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* compute the remainder, make sure we divide only positive numbers    */
    if (      0 <= i && 0 <= k )  i =       (  i %  k );
    else if ( 0 <= i && k <  0 )  i =       (  i % -k );
    else if ( i < 0  && 0 <= k )  i = ( k - ( -i %  k )) % k;
    else if ( i < 0  && k <  0 )  i = (-k - ( -i % -k )) % k;
    mod = INTOBJ_INT( i );
    
  }
  
  /* compute the remainder of a small integer by a large integer           */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) mod the large int (1<<28) is 0               */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS) )
	 && ( TNUM_OBJ(opR) == T_INTPOS )
         && ( SIZE_INT(opR) == 1 )
	 && ( VAL_LIMB0(opR) == (TypLimb)(1L<<NR_SMALL_INT_BITS) ) )
      mod = INTOBJ_INT(0);
    
    /* in all other cases the remainder is equal the left operand          */
    else if ( 0 <= INT_INTOBJ(opL) )
      mod = opL;
    else if ( TNUM_OBJ(opR) == T_INTPOS )
      mod = SumOrDiffInt( opL, opR,  1 );
    else
      mod = SumOrDiffInt( opL, opR, -1 );
  }
  
  /* compute the remainder of a large integer by a small integer           */
  else if ( IS_INTOBJ(opR) ) {

    /* pathological case first                                             */
    if ( opR == INTOBJ_INT(0) ) {
      opR = ErrorReturnObj(
			   "Integer operations: <divisor> must be nonzero",
			   0L, 0L,
			   "you can replace the integer <divisor> via 'return <divisor>;'" );
      return MOD( opL, opR );
    }
    
    /* get the integer value, make positive                                */
    i = INT_INTOBJ(opR);  if ( i < 0 )  i = -i;
    
    /* maybe it's trivial                                                  */
    if ( INTBASE % i == 0 ) {
      c = ADDR_INT(opL)[0] % i;
    }
    
    /* otherwise use the gmp function to divide                            */
    else {
      c = mpn_mod_1( ADDR_INT(opL), SIZE_INT(opL), (TypLimb)i );
    }
    
    /* now c is the result, it has the same sign as the left operand       */
    if ( TNUM_OBJ(opL) == T_INTPOS )
      mod = INTOBJ_INT( c );
    else if ( c == 0 )
      mod = INTOBJ_INT( c );
    else if ( 0 <= INT_INTOBJ(opR) )
      mod = SumOrDiffInt( INTOBJ_INT( -(Int)c ), opR,  1 );
    else
      mod = SumOrDiffInt( INTOBJ_INT( -(Int)c ), opR, -1 );
    
  }
  
  /* compute the remainder of a large integer modulo a large integer       */
  else {

    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) ) {
      if ( TNUM_OBJ(opL) == T_INTPOS )
	return opL;
      else if ( TNUM_OBJ(opR) == T_INTPOS )
	mod = SumOrDiffInt( opL, opR,  1 );
      else
	mod = SumOrDiffInt( opL, opR, -1 );
      if IS_INTNEG(mod) return NEW_INTPOS(mod);
      else return mod;
    }
    
    mod = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(TypLimb) );

    quo = NewBag( T_INTPOS,
		   (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );

    /* and let gmp do the work                                             */
    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(mod), 0,
		 ADDR_INT(opL), SIZE_INT(opL),
		 ADDR_INT(opR), SIZE_INT(opR)    );
      
    /* reduce to small integer if possible, otherwise shrink bag           */
    mod = GMP_NORMALIZE( mod );
    mod = GMP_REDUCE( mod );
    
    /* make the representative positive                                    */
    if ( (TNUM_OBJ(mod) == T_INT && INT_INTOBJ(mod) < 0)
	 || TNUM_OBJ(mod) == T_INTNEG ) {
      if ( TNUM_OBJ(opR) == T_INTPOS )
	mod = SumOrDiffInt( mod, opR,  1 );
      else
	mod = SumOrDiffInt( mod, opR, -1 );
    }
    
  }
  
  /* return the result                                                     */
  if IS_INTNEG(mod)
    return NEW_INTPOS(mod);
  else if ( IS_INTOBJ(mod) && 0 > INT_INTOBJ(mod) )
    return INTOBJ_INT(-INT_INTOBJ(mod));
  else
    return mod;
}


/****************************************************************************
**
*F  QuoInt( <intL>, <intR> )  . . . . . . . . . . . quotient of two integers
**
**  'QuoInt' returns the integer part of the two ints <gmpL> and  <gmpR>.
**  'QuoInt' handles operands of type  'T_INT',  'T_INTPOS'  and  'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**
*/
Obj QuoInt ( Obj opL, Obj opR )
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  Obj                 quo;            /* handle of the result bag          */
  Obj                 rem;            /* handle of the remainder bag       */
  
  /* divide two small integers                                             */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* pathological case first                                             */
    if ( opR == INTOBJ_INT(0) ) {
      opR = ErrorReturnObj(
			   "Integer operations: <divisor> must be nonzero",
			   0L, 0L,
			   "you can replace the integer <divisor> via 'return <divisor>;'" );
      return QUO( opL, opR );
    }
    
    /* the small int -(1<<28) divided by -1 is the large int (1<<28)       */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS)) 
	 && opR == INTOBJ_INT(-1) ) {
      quo = NewBag( T_INTPOS, sizeof(TypLimb) );
      SET_VAL_LIMB0( quo, 1L<<NR_SMALL_INT_BITS );
      return quo;
    }
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* divide, make sure we divide only positive numbers                   */
    if (      0 <= i && 0 <= k )  i =    (  i /  k );
    else if ( 0 <= i && k <  0 )  i =  - (  i / -k );
    else if ( i < 0  && 0 <= k )  i =  - ( -i /  k );
    else if ( i < 0  && k <  0 )  i =    ( -i / -k );
    quo = INTOBJ_INT( i );
    
  }
  
  /* divide a small integer by a large one                                 */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) divided by the large int (1<<28) is -1       */
    
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS))
	 && TNUM_OBJ(opR) == T_INTPOS && SIZE_INT(opR) == 1
	 && VAL_LIMB0(opR) == 1L<<NR_SMALL_INT_BITS )
      quo = INTOBJ_INT(-1);
    
    /* in all other cases the quotient is of course zero                   */
    else
      quo = INTOBJ_INT(0);
    
  }
  
  /* divide a large integer by a small integer                             */
  else if ( IS_INTOBJ(opR) ) {
    
    /* pathological case first                                             */
    if ( opR == INTOBJ_INT(0) ) {
      opR = ErrorReturnObj(
			   "Integer operations: <divisor> must be nonzero",
			   0L, 0L,
			   "you can replace the integer <divisor> via 'return <divisor>;'" );
      return QUO( opL, opR );
    }
    
    /* allocate a bag for the result and set up the pointers               */
    if ( (TNUM_OBJ(opL)==T_INTPOS && 0 < INT_INTOBJ(opR))
	 || (TNUM_OBJ(opL)==T_INTNEG && INT_INTOBJ(opR) < 0) )
      quo = NewBag( T_INTPOS, SIZE_OBJ(opL) );
    else
      quo = NewBag( T_INTNEG, SIZE_OBJ(opL) );
    
    opR = FuncGMP_INTOBJ( (Obj)0, opR );

    /* use gmp function for dividing by a 1-limb number                    */
    mpn_divrem_1( ADDR_INT(quo), 0,
		  ADDR_INT(opL), SIZE_INT(opL),
		  *ADDR_INT(opR) );
  }
  
  /* divide a large integer by a large integer                             */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return INTOBJ_INT(0);
    
    /* create a new bag for the remainder                                  */
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(TypLimb) );

    /* allocate a bag for the quotient                                     */

    /* findme - is this not enough space? does it account for the 
       'floating exception' crashes we get for QuoInt(a,b) when
       b is not as big as a? */
    if ( TNUM_OBJ(opL) == TNUM_OBJ(opR) )
      quo = NewBag( T_INTPOS, 
		    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );
    else
      quo = NewBag( T_INTNEG,
		    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );

    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(rem), 0,
		 ADDR_INT(opL), SIZE_INT(opL),
		 ADDR_INT(opR), SIZE_INT(opR) );
  }
  
  /* normalize and return the result                                       */
  quo = GMP_NORMALIZE(quo);
  quo = GMP_REDUCE( quo );
  return quo;
}


/****************************************************************************
**
*F  FuncQUO_INT(<self>,<opL>,<opR>) . . . . . . .  internal function 'QuoInt
**
**  'FuncQUO_INT' implements the internal function 'QuoInt'.
**
**  'QuoInt( <i>, <k> )'
**
**  'Quo' returns the  integer part of the quotient  of its integer operands.
**  If <i>  and <k> are  positive 'Quo( <i>,  <k> )' is  the largest positive
**  integer <q>  such that '<q> * <k>  \<= <i>'.  If  <i> or  <k> or both are
**  negative we define 'Abs( Quo(<i>,<k>) ) = Quo( Abs(<i>), Abs(<k>) )'  and
**  'Sign( Quo(<i>,<k>) ) = Sign(<i>) * Sign(<k>)'.  Dividing by 0  causes an
**  error.  'Rem' (see "Rem") can be used to compute the remainder.
*/
Obj FuncQUO_INT ( Obj self, Obj opL, Obj opR )
{
  /* check the arguments                                                   */
  while ( TNUM_OBJ(opL) != T_INT
	  && TNUM_OBJ(opL) != T_INTPOS
	  && TNUM_OBJ(opL) != T_INTNEG ) {
    opL = ErrorReturnObj(
			 "QuoInt: <left> must be a int (not a %s)",
			 (Int)TNAM_OBJ(opL), 0L,
			 "you can replace <left> via 'return <left>;'" );
  }
  while ( TNUM_OBJ(opR) != T_INT
	  && TNUM_OBJ(opR) != T_INTPOS
	  && TNUM_OBJ(opR) != T_INTNEG ) {
    opR = ErrorReturnObj(
			 "QuoInt: <right> must be a int (not a %s)",
			 (Int)TNAM_OBJ(opR), 0L,
			 "you can replace <right> via 'return <right>;'" );
  }
  
  /* return the quotient                                                   */
  return QuoInt( opL, opR );
}


/****************************************************************************
**
*F  RemInt( <intL>, <intR> )  . . . . . . . . . . . remainder of two integers
**
**  'RemInt' returns the remainder of the quotient  of  the  integers  <intL>
**  and <intR>.  'RemInt' handles operands of type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  Note that the remainder is different from the value returned by the 'mod'
**  operator which is always positive.
*/
Obj RemInt ( Obj opL, Obj opR )
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  UInt                c;              /* product of two digits             */
  Obj                 rem;            /* handle of the remainder bag       */
  Obj                 quo;            /* handle of the quotient bag        */

  /* compute the remainder of two small integers                           */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* pathological case first                                             */
    if ( opR == INTOBJ_INT(0) ) {
      opR = ErrorReturnObj(
			   "Integer operations: <divisor> must be nonzero",
			   0L, 0L,
			   "you can replace the integer <divisor> via 'return <divisor>;'" );
      return QUO( opL, opR );
    }
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* compute the remainder, make sure we divide only positive numbers    */
    if (      0 <= i && 0 <= k )  i =    (  i %  k );
    else if ( 0 <= i && k <  0 )  i =    (  i % -k );
    else if ( i < 0  && 0 <= k )  i =  - ( -i %  k );
    else if ( i < 0  && k <  0 )  i =  - ( -i % -k );
    rem = INTOBJ_INT( i );
    
  }
  
  /* compute the remainder of a small integer by a large integer           */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) rem the large int (1<<28) is 0               */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS))
	 && TNUM_OBJ(opR) == T_INTPOS && SIZE_INT(opR) == 1
	 && VAL_LIMB0(opR) == 1L<<NR_SMALL_INT_BITS )
      rem = INTOBJ_INT(0);
    
    /* in all other cases the remainder is equal the left operand          */
    else
      rem = opL;
  }
  
  /* compute the remainder of a large integer by a small integer           */
  else if ( IS_INTOBJ(opR) ) {
    
    /* pathological case first                                             */
    if ( opR == INTOBJ_INT(0) ) {
      opR = ErrorReturnObj(
			   "Integer operations: <divisor> must be nonzero",
			   0L, 0L,
			   "you can replace the integer <divisor> via 'return <divisor>;'" );
      return QUO( opL, opR );
    }
    
    /* maybe it's trivial                                                   */
    if ( INTBASE % abs(INT_INTOBJ(opR)) == 0 ) {
      c = ADDR_INT(opL)[0] % abs(INT_INTOBJ(opR));
    }
    
    /* otherwise run through the left operand and divide digitwise         */
    else {
      opR = FuncGMP_INTOBJ( (Obj)0, opR );
      c = mpn_mod_1( ADDR_INT(opL), SIZE_INT(opL), *ADDR_INT(opR) );
    }
    
    /* now c is the result, it has the same sign as the left operand       */
    if ( TNUM_OBJ(opL) == T_INTPOS )
      rem = INTOBJ_INT(  c );
    else
      rem = INTOBJ_INT( -(Int)c );
    
  }
  
  /* compute the remainder of a large integer modulo a large integer       */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return opL;
    
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(TypLimb) );
    
    quo = NewBag( T_INTPOS,
		  (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );
    
    /* and let gmp do the work                                             */
    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(rem), 0,
		 ADDR_INT(opL), SIZE_INT(opL),
		 ADDR_INT(opR), SIZE_INT(opR)    );
    
    /* reduce to small integer if possible, otherwise shrink bag           */
    rem = GMP_NORMALIZE( rem );
    rem = GMP_REDUCE( rem );
    
  }
  
  /* return the result                                                     */
  return rem;
  
}


/****************************************************************************
**
*F  FuncREM_INT(<self>,<opL>,<opR>)  . . . . . . .  internal function 'RemInt'
**
**  'FuncREM_INT' implements the internal function 'RemInt'.
**
**  'RemInt( <i>, <k> )'
**
**  'Rem' returns the remainder of its two integer operands,  i.e., if <k> is
**  not equal to zero 'Rem( <i>, <k> ) = <i> - <k> *  Quo( <i>, <k> )'.  Note
**  that the rules given  for 'Quo' (see "Quo") imply  that 'Rem( <i>, <k> )'
**  has the same sign as <i> and its absolute value is strictly less than the
**  absolute value of <k>.  Dividing by 0 causes an error.
*/
Obj FuncREM_INT ( Obj self, Obj opL, Obj opR )
{
  /* check the arguments                                                   */
  while ( TNUM_OBJ(opL) != T_INT
	  && TNUM_OBJ(opL) != T_INTPOS
	  && TNUM_OBJ(opL) != T_INTNEG ) {
    opL = ErrorReturnObj(
			 "RemInt: <left> must be an integer (not a %s)",
			 (Int)TNAM_OBJ(opL), 0L,
			 "you can replace <left> via 'return <left>;'" );
  }
  while ( TNUM_OBJ(opR) != T_INT
	  && TNUM_OBJ(opR) != T_INTPOS
	  && TNUM_OBJ(opR) != T_INTNEG ) {
    opR = ErrorReturnObj(
			 "RemInt: <right> must be an integer (not a %s)",
			 (Int)TNAM_OBJ(opR), 0L,
			 "you can replace <right> via 'return <right>;'" );
  }

  /* return the remainder                                                  */
  return RemInt( opL, opR );
}


/****************************************************************************
**
*F  GcdInt( <opL>, <opR> )  . . . . . . . . . . .  gcd of two GMP integers
**
**  'GcdInt' returns the gcd of the two integers <opL> and <opR>.
**
**  It is called from 'FuncGCD_INT' and from the rational package.
*/
Obj GcdInt ( Obj opL, Obj opR )
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  UInt                c;              /* product of two digits             */
  Obj                 gmpL;           /* copy of the first arg             */
  Obj                 gmpR;           /* copy of the second arg            */
  Obj                 gcd;            /* handle of the result              */
  Int                 p,q;            /* number of zero limbs per arg      */
  Int                 r,s;            /* number of zero bits per arg       */
  TypLimb             bmask;          /* bit mask                          */

  /* compute the gcd of two small integers                                 */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* get the integer values, make them positive                          */
    i = INT_INTOBJ(opL);  if ( i < 0 )  i = -i;
    k = INT_INTOBJ(opR);  if ( k < 0 )  k = -k;
    
    /* compute the gcd using Euclids algorithm                             */
    while ( k != 0 ) {
      c = k;
      k = i % k;
      i = c;
    }
    
    /* now i is the result                                                 */
    gcd = GMPorINTOBJ_INT( (Int)i );
    return gcd;    
  }
  
  /* compute the gcd of a small and a large integer                        */
  else if ( IS_INTOBJ(opL) || IS_INTOBJ(opR) ) {
    
    /* make the right operand the small one                                */
    if ( IS_INTOBJ(opL) ) {
      gcd = opL;  opL = opR;  opR = gcd;
    }
    
    /* maybe it's trivial                                                  */
    if ( opR == INTOBJ_INT(0) ) {
      if( TNUM_OBJ( opL ) == T_INTNEG ) {
	/* If opL is negative, change the sign.  We do this by
	   copying opL into a bag of type T_INTPOS.  Note that
	   opL is a large negative number, so it cannot be the
	   the negative of 1 << NR_SMALL_INT_BITS.                     */
	gcd = NEW_INTPOS( opL );
	return gcd;
      }
      else return opL;
    }
    
    /* compute the gcd                                                     */
    opR = FuncGMP_INTOBJ( (Obj)0, opR );
    i = mpn_gcd_1( ADDR_INT(opL), SIZE_INT(opL), *ADDR_INT(opR) );
    gcd = GMPorINTOBJ_INT( (Int)i );
    return gcd;
  }
  
  /* compute the gcd of two large integers                                 */
  else {
    if ( EqInt(opL,opR) ) {
      if IS_INTNEG(opL) {
	return NEW_INTPOS(opL);
      }
      else {
	return opL;
      }
    }
    gmpL = NEW_INT(opL); gmpR = NEW_INT(opR);

    /* find highest power of 2 dividing gmpL and divide out by this */
    for ( p = 0 ; ADDR_INT(gmpL)[p] == (TypLimb)0; p++ ) {
      for ( i = 0 ; i < mp_bits_per_limb ; i++ ) {
      }
    }
    for ( bmask = (TypLimb)1, r = 0 ;
	  ( (bmask & ADDR_INT(gmpL)[p]) == 0 ) && bmask != (TypLimb)0 ;
	  bmask = bmask << 1, r++ ) {
    }
    p = p*mp_bits_per_limb+r;
    for ( i = 0 ; i < p ; i++ ){
      mpn_rshift( ADDR_INT(gmpL), ADDR_INT(gmpL),
		  SIZE_INT(gmpL), (UInt)1 );
    }
    gmpL = GMP_NORMALIZE(gmpL);

    /* find highest power of 2 dividing gmpR and divide out by this */
    for ( q = 0 ; ADDR_INT(gmpR)[q] == (TypLimb)0; q++ ) {
      for ( i = 0 ; i < mp_bits_per_limb ; i++ ) {
      }
    }
    for ( bmask = (TypLimb)1, s = 0 ;
	  ( (bmask & ADDR_INT(gmpR)[q]) == 0 ) && bmask != (TypLimb)0 ;
	  bmask=bmask << 1,  s++ ) {
    }
    q = q*mp_bits_per_limb+s;
    for (i=0;i<q;i++){
      mpn_rshift( ADDR_INT(gmpR), ADDR_INT(gmpR),
		  SIZE_INT(gmpR), (UInt)1 );
    }
    gmpR = GMP_NORMALIZE(gmpR);

    /* put smaller object to right */
    if ( SIZE_INT(gmpL) < SIZE_INT(gmpR) ||
	 ( SIZE_INT(gmpL) == SIZE_INT(gmpR) &&
	   mpn_cmp( ADDR_INT(gmpL), ADDR_INT(gmpR), SIZE_INT(gmpL) ) < 0 ) ) {
      gcd = gmpR; gmpR = gmpL; gmpL = gcd;
    }
    
    /* get gcd of odd numbers gmpL, gmpR - put it in a bag as big as one
       of the original args, which will be big enough for the gcd */
    gcd = NewBag( T_INTPOS, SIZE_OBJ(opR) );
    mpn_gcd( ADDR_INT(gcd), 
	     ADDR_INT(gmpL), SIZE_INT(gmpL),
	     ADDR_INT(gmpR), SIZE_INT(gmpR) );
    
    /* choose smaller of p,q and multiply back in by 2 to that power */
    if ( p > q ) p = q;
    for ( i = 0 ; i < p ; i++ ){
      /*findme - do we need to check the return value for overflow here? */
      mpn_lshift( ADDR_INT(gcd), ADDR_INT(gcd),
		  SIZE_INT(gcd), (UInt)1 );
    }
  }
  gcd = GMP_NORMALIZE(gcd);
  gcd = GMP_REDUCE(gcd);
  
  /* return the result                                                     */
  return gcd;
}

Obj FuncIntDiv2( Obj self, Obj gmp )
{
  Obj res;
  Int p,r;
  TypLimb bmask;

    p=r=0;
    /*    gmp = NEW_INT(arg);*/

    /* find highest power of 2 dividing gmp and divide out by this */
    for ( p = 0 ; ADDR_INT(gmp)[p] == (TypLimb)0; p++ ) {
      ;
    }
    for ( bmask = (TypLimb)1, r = 0 ;
	  ( (bmask & ADDR_INT(gmp)[p]) == 0 ) && bmask != (TypLimb)0 ;
	  bmask = bmask << 1, r++ ) {
      ;
    }
    res = INTOBJ_INT( p*1000 + r );
    return res;
}

/****************************************************************************
**
*F  FuncGCD_INT(<self>,<opL>,<opR>)  . . . . . . .  internal function 'GcdInt'
**
**  'FuncGCD_INT' implements the internal function 'GcdInt'.
**
**  'GcdInt( <i>, <k> )'
**
**  'Gcd'  returns the greatest common divisor   of the two  integers <m> and
**  <n>, i.e.,  the  greatest integer that  divides  both <m>  and  <n>.  The
**  greatest common divisor is never negative, even if the arguments are.  We
**  define $gcd( m, 0 ) = gcd( 0, m ) = abs( m )$ and $gcd( 0, 0 ) = 0$.
*/
Obj FuncGCD_INT ( Obj self, Obj opL, Obj opR )
{
  /* check the arguments                                                   */
  while ( TNUM_OBJ(opL) != T_INT
	  && TNUM_OBJ(opL) != T_INTPOS
	  && TNUM_OBJ(opL) != T_INTNEG ) {
    opL = ErrorReturnObj(
			 "GcdInt: <left> must be an integer (not a %s)",
			 (Int)TNAM_OBJ(opL), 0L,
			 "you can replace <left> via 'return <left>;'" );
  }
  while ( TNUM_OBJ(opR) != T_INT
	  && TNUM_OBJ(opR) != T_INTPOS
	  && TNUM_OBJ(opR) != T_INTNEG ) {
    opR = ErrorReturnObj(
			 "GcdInt: <right> must be an integer (not a %s)",
			 (Int)TNAM_OBJ(opR), 0L,
			 "you can replace <right> via 'return <right>;'" );
  }
  
  /* return the gcd                                                        */
  return GcdInt( opL, opR );
}


/****************************************************************************
**
*F  FuncHASHKEY_BAG(<self>,<obj>,<factor>,<offset>,<maxlen>)
**
**  'FuncHASHKEY_BAG' implements the internal function 'HASHKEY_BAG'.
**
**  'HASHKEY_BAG( <obj>, <factor>,<offset>,<maxlen> )'
**
**  takes an non-immediate object and a small integer <int> and computes a
**  hash value for the contents of the bag from these. (For this to be
**  usable in algorithms, we need that objects of this kind are stored uniquely
**  internally.
**  The offset and the maximum number of bytes to process both count in
**  bytes. The values passed to these parameters might depend on the word 
**  length of the computer.
**  A <maxlen> value of -1 indicates infinity.
*/
Obj             FuncHASHKEY_BAG (
    Obj                 self,
    Obj                 opL,
    Obj                 opR,
    Obj                 opO,
    Obj			opM)
{
  UInt sum;
  UChar* ptr;
  Int n;
  Int m;
  Int i;
  Int modulus;
  Int offs;

  modulus=1<<28; /* might want to change for 64 bit machines? */
  /* check the arguments                                                 */
  while ( TNUM_OBJ(opR) != T_INT ) {
      opR = ErrorReturnObj(
	  "HASHKEY_BAG: <factor> must be a small integer (not a %s)",
	  (Int)TNAM_OBJ(opR), 0L,
	  "you can replace <factor> via 'return <factor>;'" );
  }

  while ( TNUM_OBJ(opO) != T_INT ) {
      opO = ErrorReturnObj(
	  "HASHKEY_BAG: <offset> must be a small integer (not a %s)",
	  (Int)TNAM_OBJ(opO), 0L,
	  "you can replace <offset> via 'return <offset>;'" );
  }

  while ( TNUM_OBJ(opM) != T_INT ) {
      opM = ErrorReturnObj(
	  "HASHKEY_BAG: <maxlen> must be a small integer (not a %s)",
	  (Int)TNAM_OBJ(opM), 0L,
	  "you can replace <maxlen> via 'return <maxlen>;'" );
  }

  sum=0;
  /* start byte plus offset */
  offs=INT_INTOBJ(opO);
  ptr=(UChar*)ADDR_OBJ(opL)+offs;
  n=SIZE_OBJ(opL)-offs;

  /* maximal number of bytes to read */
  offs=INT_INTOBJ(opM);
  if ((n>offs)&&(offs!=-1)) {n=offs;}; 

  m=INT_INTOBJ(opR);

  for (i=0;i<n;i++) {
    sum=((sum*m)+(UInt)(*ptr++));
    /*    if (i < 100)
	  Pr("%d %d\n",(UInt)*(ptr-1),sum); */
  }
  sum=sum % modulus;

  return INTOBJ_INT(sum);
}

Obj FuncJenkinsHash(Obj self, Obj op, Obj size)
{
   void *input;
   uint32_t len;
   uint32_t key;
   uint32_t init = 0;
   
   len = (uint32_t)INT_INTOBJ(size);
   input = (void *)ADDR_OBJ(op);
   if (len == -1)
     len = (uint32_t)SIZE_OBJ(op);
	
// Take advantage of endianness if possible
#ifdef WORDS_BIGENDIAN
   key = hashbig(input, len, init);
#else
   key = hashlittle(input, len, init);
#endif
   
   return INTOBJ_INT((Int)(key % (1 << 28)));
}



/****************************************************************************
**
*F  FuncSIZE_OBJ(<self>,<obj>)
**
**  'SIZE_OBJ( <obj> )' returns the size of a nonimmediate object. It can be
**  used to debug memory use.
*/
Obj             FuncSIZE_OBJ (
    Obj                 self,
    Obj                 a)
{
  return INTOBJ_INT(SIZE_OBJ(a));
}


/****************************************************************************
**
** * * * * * * * "Mersenne twister" random numbers  * * * * * * * * * * * * *
**
**  Part of this code for fast generation of 32 bit pseudo random numbers with 
**  a period of length 2^19937-1 and a 623-dimensional equidistribution is 
**  taken from:
**          http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
**  (Also look in Wikipedia for "Mersenne twister".)
*/

/****************************************************************************
**
*F  InitRandomMT( <initstr> ) 
**
**  Returns a string that can be used as data structure of a new MT random 
**  number generator. <initstr> can be an arbitrary string as seed.
*/
#define MATRIX_A 0x9908b0dfUL   /* constant vector a */
#define UPPER_MASK 0x80000000UL /* most significant w-r bits */
#define LOWER_MASK 0x7fffffffUL /* least significant r bits */

void initGRMT(UInt4 *mt, UInt4 s)
{
    UInt4 mti;
    mt[0]= s & 0xffffffffUL;
    for (mti=1; mti<624; mti++) {
        mt[mti] = 
	    (1812433253UL * (mt[mti-1] ^ (mt[mti-1] >> 30)) + mti); 
        mt[mti] &= 0xffffffffUL;
    }
    /* store mti as last entry of mt[] */
    mt[624] = mti;
}

Obj FuncInitRandomMT( Obj self, Obj initstr)
{
  Obj str;
  UInt4 *mt, *init_key, key_length, i, j, k, N=624;

  /* check the seed, given as string */
  while (! IsStringConv(initstr)) {
     initstr = ErrorReturnObj(
         "<initstr> must be a string, not a %s)",
         (Int)TNAM_OBJ(initstr), 0L,
         "you can replace <initstr> via 'return <initstr>;'" );
  }
  init_key = (UInt4*) CHARS_STRING(initstr);
  key_length = GET_LEN_STRING(initstr) / 4;
   
   /* store array of 624 UInt4 and one UInt4 as counter "mti" */
   str = NEW_STRING(4*625);
   SET_LEN_STRING(str, 4*625);
   mt = (UInt4*) CHARS_STRING(str);
   /* here the counter mti is set to 624 */
   initGRMT(mt, 19650218UL);
   i=1; j=0;
   k = (N>key_length ? N : key_length);
   for (; k; k--) {
       mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525UL))
         + init_key[j] + j; 
       mt[i] &= 0xffffffffUL; 
       i++; j++;
       if (i>=N) { mt[0] = mt[N-1]; i=1; }
       if (j>=key_length) j=0;
   }
   for (k=N-1; k; k--) {
       mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941UL)) - i; 
       mt[i] &= 0xffffffffUL; 
       i++;
       if (i>=N) { mt[0] = mt[N-1]; i=1; }
   }
   mt[0] = 0x80000000UL; 
   return str; 
}


/*  internal, generates a random number on [0,0xffffffff]-interval 
**  argument <mt> is pointer to a string generated by InitRandomMT
**  (the first 4*624 bytes are the random numbers, the last 4 bytes contain
**  a counter)
*/
UInt4 nextrandMT_int32(UInt4* mt)
{
    UInt4 mti, y, N=624, M=397;
    static UInt4 mag01[2]={0x0UL, MATRIX_A};
    
    mti = mt[624];
    if (mti >= N) { 
        int kk;

        for (kk=0;kk<N-M;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        for (;kk<N-1;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1UL];

        mti = 0;
    }
  
    y = mt[mti++];
    mt[624] = mti;

    /* Tempering */
    y ^= (y >> 11);
    y ^= (y << 7) & 0x9d2c5680UL;
    y ^= (y << 15) & 0xefc60000UL;
    y ^= (y >> 18);

    return y;
}


/****************************************************************************
**
*F  RandomIntegerMT( <mtstr>, <nrbits> )
**  
**  Returns an integer with at most <nrbits> bits in uniform distribution. 
**  <nrbits> must be a small integer. <mtstr> is a string as returned by 
**  InitRandomMT.
**  
**  Implementation details are a bit tricky to obtain the same random 
**  integers on 32 bit and 64 bit machines (which have different long
**  integer digit lengths and different ranges of small integers).
**  
*/
/* for comparison in case result is small int */
Obj SMALLEST_INTPOS = NULL;

Obj FuncRandomIntegerMT(Obj self, Obj mtstr, Obj nrbits)
{
  Obj res;
  Int i, n, q, r, qoff, len;
  UInt4 *mt, rand;
  /* The following is a change to allow compilation. This function is badly
     broken. */
  TypLimb *pt;
  while (! IsStringConv(mtstr)) {
     mtstr = ErrorReturnObj(
         "<mtstr> must be a string, not a %s)",
         (Int)TNAM_OBJ(mtstr), 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  while ((! IsStringConv(mtstr)) || GET_LEN_STRING(mtstr) < 2500) {
     mtstr = ErrorReturnObj(
         "<mtstr> must be a string with at least 2500 characters, ",
         0L, 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  while ((! IS_INTOBJ(nrbits)) || INT_INTOBJ(nrbits) < 0) {
     nrbits = ErrorReturnObj(
         "<nrbits> must be a small non-negative integer, not a %s)",
         (Int)TNAM_OBJ(nrbits), 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  n = INT_INTOBJ(nrbits);

  /* small int case */
  if (n <= NR_SMALL_INT_BITS) {
     mt = (UInt4*) CHARS_STRING(mtstr);
#ifdef SYS_IS_64_BIT
     if (n <= 32) {
       res = INTOBJ_INT((Int)(nextrandMT_int32(mt) & ((UInt4) -1L >> (32-n))));
     }
     else {
       unsigned long  rd;
       rd = nextrandMT_int32(mt);
       rd += (unsigned long) ((UInt4) nextrandMT_int32(mt) & 
                              ((UInt4) -1L >> (64-n))) << 32;
       res = INTOBJ_INT((Int)rd);
     }  
#else
     res = INTOBJ_INT((Int)(nextrandMT_int32(mt) & ((UInt4) -1L >> (32-n))));
#endif
  }
  else {
     /* number of Digits */
     q = n / GMP_LIMB_BITS;
     r = n - q*GMP_LIMB_BITS;
     qoff = q + (r==0 ? 0:1);
     len = qoff;
     len = 4*((len+3) / 4);
     /* Another change to help compilation. Do not use these MT functions */
     res = NewBag( T_INTPOS, len*sizeof(TypLimb) );
     pt = ADDR_INT(res);
     mt = (UInt4*) CHARS_STRING(mtstr);
#ifdef SYS_IS_64_BIT
     for (i = 0; i < qoff; i++, pt++) {
       rand = (TypLimb) nextrandMT_int32(mt);
       *pt = rand & 0xFFFFFFFFL;
       rand = (TypLimb) nextrandMT_int32(mt);
       *pt &= (UInt)rand << 32;
     }
#else
     for (i = 0; i < qoff; i++, pt++) {
       rand = nextrandMT_int32(mt);
       *pt = (TypLimb) rand;
     }
#endif
     if (r != 0) {
       ADDR_INT(res)[qoff-1] = ADDR_INT(res)[qoff-1] & ((TypLimb)(-1)
                                                      >> (GMP_LIMB_BITS-r));
     }
     /* shrink bag if necessary */
     res = GMP_NORMALIZE(res);
     /* convert result if small int */
     res = GMP_REDUCE(res);
  }

  return res;
}

Obj FuncRandomListMT(Obj self, Obj mtstr, Obj list)
{
  Int len, a, lg;
  UInt4 *mt;
  while ((! IsStringConv(mtstr)) || GET_LEN_STRING(mtstr) < 2500) {
     mtstr = ErrorReturnObj(
         "<mtstr> must be a string with at least 2500 characters, ",
         0L, 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  while (! IS_LIST(list)) {
     list = ErrorReturnObj(
         "<list> must be a list, not a %s",
         (Int)TNAM_OBJ(list), 0L,
         "you can replace <list> via 'return <list>;'" );
  }
  len = LEN_LIST(list);
  if (len == 0) return Fail;
  mt = (UInt4*) CHARS_STRING(mtstr);
  lg = 31 - INT_INTOBJ(FuncLog2Int((Obj)0, INTOBJ_INT(len)));
  for (a = nextrandMT_int32(mt) >> lg; 
       a >= len; 
       a = nextrandMT_int32(mt) >> lg
    );
  return ELM_LIST(list, a+1);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

  { "IS_INT", "obj", &IsIntFilt,
    FuncIS_INT, "src/gmpints.c:IS_INT" },

  { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  { "QUO_INT", 2, "gmp1, gmp2",
    FuncQUO_INT, "src/gmpints.c:QUO_INT" },

  { "ABS_INT", 1, "x",
    FuncABS_INT, "src/gmpints.c:ABS_INT" },

  { "REM_INT", 2, "gmp1, gmp2",
    FuncREM_INT, "src/gmpints.c:REM_INT" },

  { "GCD_INT", 2, "gmp1, gmp2",
    FuncGCD_INT, "src/gmpints.c:GCD_INT" },
  
  { "PROD_INT_OBJ", 2, "gmp, obj",
    FuncPROD_INT_OBJ, "src/gmpints.c:PROD_INT_OBJ" },
  
  { "POW_OBJ_INT", 2, "obj, gmp",
    FuncPOW_OBJ_INT, "src/gmpints.c:POW_OBJ_INT" },
  
  { "GMP_REDUCE", 1, "obj",
    FuncGMP_REDUCE, "src/gmpints.c:GMP_REDUCE" },

  { "GMP_NORMALIZE", 1, "obj",
    FuncGMP_NORMALIZE, "src/gmpints.c:GMP_NORMALIZE" },

  { "HexStringInt", 1, "gmp",
    FuncHexStringInt, "src/gmpints.c:HexStringInt" },
  
  { "IntHexString", 1, "string",
    FuncIntHexString, "src/gmpints.c:IntHexString" },
  
  { "Log2Int", 1, "gmp",
    FuncLog2Int, "src/gmpints.c:Log2Int" },

  { "IntDiv2", 1, "gmp",
    FuncIntDiv2, "src/gmpints.c:IntDiv2" },

  { "STRING_INT", 1, "gmp",
    FuncSTRING_INT, "src/gmpints.c:STRING_INT" },

  { "HASHKEY_BAG", 4, "obj, gmp,gmp,gmp",
    FuncHASHKEY_BAG, "src/gmpints.c:HASHKEY_BAG" },

  { "JENKINS_HASH", 2, "obj, len",
    FuncJenkinsHash, "src/gmpints.c:JENKINS_HASH" },
  
  { "SIZE_OBJ", 1, "obj",
    FuncSIZE_OBJ, "src/gmpints.c:SIZE_OBJ" },
  
  { "InitRandomMT", 1, "initstr",
    FuncInitRandomMT, "src/gmpints.c:InitRandomMT" },
  
  { "RandomIntegerMT", 2, "mtstr, nrbits",
    FuncRandomIntegerMT, "src/gmpints.c:RandomIntegerMT" },
  
  { "RandomListMT", 2, "mtstr, list",
    FuncRandomListMT, "src/gmpints.c:RandomListMT" },
  
  { 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo * module )
{
  UInt                t1,  t2;

  /* init filters and functions                                            */
  InitHdlrFiltsFromTable( GVarFilts );
  InitHdlrFuncsFromTable( GVarFuncs );
  
  /* install the marking functions                                         */
  InfoBags[         T_INT    ].name = "integer";
#ifdef SYS_IS_64_BIT
  InfoBags[         T_INTPOS ].name = "integer (>= 2^60)";
  InfoBags[         T_INTNEG ].name = "integer (< -2^60)";
#else
  InfoBags[         T_INTPOS ].name = "integer (>= 2^28)";
  InfoBags[         T_INTNEG ].name = "integer (< -2^28)";
#endif
  InitMarkFuncBags( T_INTPOS, MarkNoSubBags );
  InitMarkFuncBags( T_INTNEG, MarkNoSubBags );
  
  /* Install the saving methods */
  SaveObjFuncs [ T_INTPOS ] = SaveInt;
  SaveObjFuncs [ T_INTNEG ] = SaveInt;
  LoadObjFuncs [ T_INTPOS ] = LoadInt;
  LoadObjFuncs [ T_INTNEG ] = LoadInt;
  
  /* install the printing functions                                        */
  PrintObjFuncs[ T_INT    ] = PrintInt;
  PrintObjFuncs[ T_INTPOS ] = PrintInt;
  PrintObjFuncs[ T_INTNEG ] = PrintInt;
  
  /* install the comparison methods                                        */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = T_INT; t2 <= T_INTNEG; t2++ ) {
      EqFuncs  [ t1 ][ t2 ] = EqInt;
      LtFuncs  [ t1 ][ t2 ] = LtInt;
    }
  }
  
  /* install the unary arithmetic methods                                  */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    ZeroFuncs[ t1 ] = ZeroInt;
    ZeroMutFuncs[ t1 ] = ZeroInt;
    AInvFuncs[ t1 ] = AInvInt;
    AInvMutFuncs[ t1 ] = AInvInt;
    OneFuncs [ t1 ] = OneInt;
    OneMutFuncs [ t1 ] = OneInt;
  }    

    /* install the default product and power methods                       */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = FIRST_CONSTANT_TNUM;  t2 <= LAST_CONSTANT_TNUM;  t2++ ) {
      ProdFuncs[ t1 ][ t2 ] = ProdIntObj;
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
    for ( t2 = FIRST_RECORD_TNUM;  t2 <= LAST_RECORD_TNUM;  t2++ ) {
      ProdFuncs[ t1 ][ t2 ] = ProdIntObj;
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
    for ( t2 = FIRST_LIST_TNUM;    t2 <= LAST_LIST_TNUM;    t2++ ) {
      ProdFuncs[ t1 ][ t2 ] = ProdIntObj;
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
  }

  /* install the binary arithmetic methods                                 */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = T_INT; t2 <= T_INTNEG; t2++ ) {
      EqFuncs  [ t1 ][ t2 ] = EqInt;
      LtFuncs  [ t1 ][ t2 ] = LtInt;
      SumFuncs [ t1 ][ t2 ] = SumInt;
      DiffFuncs[ t1 ][ t2 ] = DiffInt;
      ProdFuncs[ t1 ][ t2 ] = ProdInt;
      PowFuncs [ t1 ][ t2 ] = PowInt;
      ModFuncs [ t1 ][ t2 ] = ModInt;
    }
  }

  /* gvars to import from the library                                      */
  ImportGVarFromLibrary( "TYPE_INT_SMALL_ZERO", &TYPE_INT_SMALL_ZERO );
  ImportGVarFromLibrary( "TYPE_INT_SMALL_POS",  &TYPE_INT_SMALL_POS );
  ImportGVarFromLibrary( "TYPE_INT_SMALL_NEG",  &TYPE_INT_SMALL_NEG );
  ImportGVarFromLibrary( "TYPE_INT_LARGE_POS", &TYPE_INT_LARGE_POS );
  ImportGVarFromLibrary( "TYPE_INT_LARGE_NEG", &TYPE_INT_LARGE_NEG );
  ImportGVarFromLibrary( "SMALLEST_INTPOS", &SMALLEST_INTPOS );

  ImportFuncFromLibrary( "String", &String );
  ImportFuncFromLibrary( "One", &OneAttr);

  /* install the kind functions                                          */
  TypeObjFuncs[ T_INT    ] = TypeIntSmall;
  TypeObjFuncs[ T_INTPOS ] = TypeIntLargePos;
  TypeObjFuncs[ T_INTNEG ] = TypeIntLargeNeg;

  /* return success                                                        */
  return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *    module )
{
  UInt gvar; 

  /* init filters and functions                                            */
  InitGVarFiltsFromTable( GVarFilts );
  InitGVarFuncsFromTable( GVarFuncs );
  
  /* findme - reinstate this:
     hold smallest large integer */
  SMALLEST_INTPOS = NewBag( T_INTPOS, sizeof(TypLimb) );
  SET_VAL_LIMB0(SMALLEST_INTPOS, (1L<<NR_SMALL_INT_BITS));
  gvar = GVarName("SMALLEST_INTPOS");
  MakeReadWriteGVar( gvar );
  AssGVar( gvar, SMALLEST_INTPOS );
  MakeReadOnlyGVar(gvar);
  
  /* return success                                                        */
  return 0;
}


/****************************************************************************
**
*F  InitInfoInt() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
  MODULE_BUILTIN,                        /* type                           */
  "gmpints",                            /* name                           */
  0,                                     /* revision entry of c file       */
  0,                                     /* revision entry of h file       */
  0,                                     /* version                        */
  0,                                     /* crc                            */
  InitKernel,                            /* initKernel                     */
  InitLibrary,                           /* initLibrary                    */
  0,                                     /* checkInit                      */
  0,                                     /* preSave                        */
  0,                                     /* postSave                       */
  0                                      /* postRestore                    */
};

StructInitInfo * InitInfoInt ( void )
{
  module.revision_c = Revision_gmpints_c;
  module.revision_h = Revision_gmpints_h;
  FillInVersion( &module );
  return &module;
}

/* corresponds to USE_GMP test at start */
#endif

/****************************************************************************
**
*E  gmpints.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/