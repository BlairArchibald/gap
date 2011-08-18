/****************************************************************************
**
*W  intfuncs.h                   GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**                                                           & Werner  Nickel
**
*H  @(#)$Id: intfuncs.h,v 4.1 2011/05/10 16:04:51 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares some representation nonspecific integer functions
*/

#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_intfuncs_h =
   "@(#)$Id: intfuncs.h,v 4.1 2011/05/10 16:04:51 sal Exp $";
#endif

/* link between Mersenne Twister randim numbers and
   representation specific large integer codes */

extern UInt4 nextrandMT_int32(UInt4* mt);

/* High quality and speed hash functions -- not currently used 
   elsewhere in the kernel but might be a good idea */

extern void MurmurHash3_x86_32 ( const void * key, int len,
                          UInt4 seed, void * out );

extern void MurmurHash3_x64_128 ( const void * key, const int len,
                           const UInt4 seed, void * out );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**                                              \
                                                \

*F  InitInfoInt() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoIntFuncs ( void );


/****************************************************************************
**
*E  integer.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/