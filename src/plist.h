/****************************************************************************
**
*A  plist.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions that deal with plain lists.
**
**  A  plain list is a list  that may have holes  and may contain elements of
**  arbitrary types.  A plain list may also have room for elements beyond its
**  current  logical length.  The  last position to  which  an element can be
**  assigned without resizing the plain list is called the physical length.
**
**  This representation  is encoded by  the macros 'NEW_PLIST', 'GROW_PLIST',
**  'SHRINK_PLIST', 'SET_LEN_PLIST',    'LEN_PLIST',     'SET_ELM_PLIST', and
**  'ELM_PLIST', which are used by the functions in this package and the rest
**  of the {\GAP} kernel to access plain lists.
**
**  This package also contains the list functions for  plain lists, which are
**  installed in the appropriate tables by 'InitPlist'.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_plist_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F  NEW_PLIST(<type>,<plen>)  . . . . . . . . . . . allocate a new plain list
**
**  'NEW_PLIST'  allocates    a new plain   list  of  type <type> ('T_PLIST',
**  'T_SET', 'T_VECTOR') that has room for at least <plen> elements.
**
**  Note that 'NEW_PLIST' is a  macro, so do not call  it with arguments that
**  have sideeffects.
*/
#define NEW_PLIST(type,plen)            NewBag(type,((plen)+1)*sizeof(Obj))


/****************************************************************************
**
*F  GROW_PLIST(<list>,<plen>) . . . .  make sure a plain list is large enough
**
**  'GROW_PLIST' grows  the plain list <list>  if necessary to ensure that it
**  has room for at least <plen> elements.
**
**  Note that 'GROW_PLIST' is a macro, so do not call it with arguments that
**  have sideeffects.
*/
#define GROW_PLIST(list,plen)   ((plen) < SIZE_OBJ(list)/sizeof(Obj) ? \
                                 0L : GrowPlist(list,plen) )

extern  Int             GrowPlist (
            Obj                 list,
            UInt                need );


/****************************************************************************
**
*F  SHRINK_PLIST(<list>,<plen>) . . . . . . . . . . . . . shrink a plain list
**
**  'SHINK_PLIST' shrinks  the plain list <list>  if possible  so that it has
**  still room for at least <plen> elements.
**
**  Note that 'SHINK_PLIST' is a macro, so do not call it with arguments that
**  have sideeffects.
*/
#define SHRINK_PLIST(list,plen)         ResizeBag(list,((plen)+1)*sizeof(Obj))


/****************************************************************************
**
*F  SET_LEN_PLIST(<list>,<len>) . . . . . . .  set the length of a plain list
**
**  'SET_LEN_PLIST' sets the length of  the plain list  <list> to <len>.
**
**  Note  that 'SET_LEN_PLIST'  is a macro, so do not call it with  arguments
**  that have sideeffects.
*/
#define SET_LEN_PLIST(list,len)         (ADDR_OBJ(list)[0] = (Obj)(len))


/****************************************************************************
**
*F  LEN_PLIST(<list>) . . . . . . . . . . . . . . . .  length of a plain list
**
**  'LEN_PLIST' returns the logical length of the list <list> as a C integer.
**
**  Note that 'LEN_PLIST' is a  macro, so do  not call it with arguments that
**  have sideeffects.
*/
#define LEN_PLIST(list)                 ((Int)(ADDR_OBJ(list)[0]))


/****************************************************************************
**
*F  SET_ELM_PLIST(<list>,<pos>,<val>) . . . assign an element to a plain list
**
**  'SET_ELM_PLIST' assigns the value  <val> to the  plain list <list> at the
**  position <pos>.  <pos> must be a  positive integer less  than or equal to
**  the length of <list>.
**
**  Note that 'SET_ELM_PLIST' is a  macro, so do not  call it  with arguments
**  that have sideeffects.
*/
#define SET_ELM_PLIST(list,pos,val)     (ADDR_OBJ(list)[pos] = (val))


/****************************************************************************
**
*F  ELM_PLIST(<list>,<pos>) . . . . . . . . . . . . . element of a plain list
**
**  'ELM_PLIST' return the  <pos>-th element of  the list <list>.  <pos> must
**  be a positive  integer  less than  or  equal  to the  physical  length of
**  <list>.  If <list> has no assigned element at position <pos>, 'ELM_PLIST'
**  returns 0.
**
**  Note that  'ELM_PLIST' is a macro, so do  not call it with arguments that
**  have sideeffects.
*/
#define ELM_PLIST(list,pos)             (ADDR_OBJ(list)[pos])


/****************************************************************************
**
*F  IS_PLIST( <list> )  . . . . . . . . . . . check if <list> is a plain list
*/
#define IS_PLIST( list ) \
  (FIRST_PLIST_TYPE <= TYPE_OBJ(list) && TYPE_OBJ(list) <= LAST_PLIST_TYPE)


/****************************************************************************
**

*F  InitPlist() . . . . . . . . . . . . . . . . . initialize the list package
**
**  'InitPlist' initializes the plain list package.
*/
extern  void            InitPlist ( void );



