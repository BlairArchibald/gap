/****************************************************************************
**
*W  vec8bit.h                    GAP source                     Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  St Andrews
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_vec8bit_h =
   "@(#)$Id$";
#endif

	
/****************************************************************************
**
*F  RewriteGF2Vec( <vec>, <q> ) . . .
**                convert a GF(2) vector into a GF(2^k) vector in place
**
*/

extern void RewriteGF2Vec( Obj vec, UInt q);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoVec8bit()  . . . . . . . . . . . . . . . . table of init functions
*/
extern StructInitInfo * InitInfoVec8bit ( void );


/****************************************************************************
**

*E  vecgf2.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
