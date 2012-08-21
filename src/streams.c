/****************************************************************************
**
*W  streams.c                   GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/
#include        <stdio.h>
#include        <string.h>              /* memcpy */
#include        "system.h"              /* system dependent part           */

const char * Revision_streams_c =
   "@(#)$Id$";

#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */
#include        "read.h"                /* reader                          */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */

#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#define INCLUDE_DECLARATION_PART
#include        "streams.h"             /* streams package                 */
#undef  INCLUDE_DECLARATION_PART


/****************************************************************************
**

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/

Int READ_COMMAND ( void ) {

    ExecStatus    status;

    ClearError();
    status = ReadEvalCommand();
    if( status == STATUS_EOF )
        return 0;

    if ( UserHasQuit || UserHasQUIT )
        return 0;
    
    /* handle return-value or return-void command                          */
    if ( status & (STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
        Pr( "'return' must not be used in file read-eval loop", 0L, 0L );
    }

    /* handle quit command or <end-of-file>                                */
    else if (status == STATUS_QUIT) {
        UserHasQuit = 1;
    }
    else if (status == STATUS_QQUIT) {
        UserHasQUIT = 1;
    }
    ClearError();

    return 1;
}

Obj FuncREAD_COMMAND ( Obj self, Obj stream, Obj echo ) {

    Int status;

    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return Fail;
    }

    if (echo == True)
      Input->echo = 1;
    else
      Input->echo = 0;

    status = READ_COMMAND();
    
    CloseInput();

    if( status == 0 ) return Fail;

    return ReadEvalResult ? ReadEvalResult : Fail;
}

/****************************************************************************
**

*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream.
*/

static UInt LastReadValueGVar;

Int READ ( void )
{
    ExecStatus                status;


    MakeReadWriteGVar(LastReadValueGVar);
    AssGVar( LastReadValueGVar, 0);
    MakeReadOnlyGVar(LastReadValueGVar);
    /* now do the reading                                                  */
    while ( 1 ) {
        ClearError();
        status = ReadEvalCommand();
	if (UserHasQuit || UserHasQUIT)
	  break;
        /* handle return-value or return-void command                      */
        if ( status &(STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
            Pr(
                "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( status  == STATUS_EOF) 
	  break;
	else if (status == STATUS_QUIT) {
	  UserHasQuit = 1;
	  break;
	}
	else if (status == STATUS_QQUIT) {
	  UserHasQUIT = 1;
	  break;
	}
	if (ReadEvalResult)
	  {
	    MakeReadWriteGVar(LastReadValueGVar);
	    AssGVar( LastReadValueGVar, ReadEvalResult);
	    MakeReadOnlyGVar(LastReadValueGVar);
	  }
	
    }


    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: READ cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();

    return 1;
}


/****************************************************************************
**
*F  READ_AS_FUNC()  . . . . . . . . . . . . .  read current input as function
**
**  Read the current input as function and close the input stream.
*/
Obj READ_AS_FUNC ( void )
{
    Obj                 func;
    UInt                type;

    /* now do the reading                                                  */
    ClearError();
    type = ReadEvalFile();

    /* get the function                                                    */
    if ( type == 0 ) {
        func = ReadEvalResult;
    }
    else {
        func = Fail;
    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: READ_AS_FUNC cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();

    /* return the function                                                 */
    return func;
}


/****************************************************************************
**
*F  READ_TEST() . . . . . . . . . . . . . . . . .  read current input as test
**
**  Read the current input as test and close the input stream.
*/
Int READ_TEST ( void )
{
    UInt                type;
    UInt                time;

    /* get the starting time                                               */
    time = SyTime();

    /* now do the reading                                                  */
    while ( 1 ) {

        /* read and evaluate the command                                   */
        ClearError();
        type = ReadEvalCommand();

        /* stop the stopwatch                                              */
        AssGVar( Time, INTOBJ_INT( SyTime() - time ) );

        /* handle ordinary command                                         */
        if ( type == 0 && ReadEvalResult != 0 ) {

            /* remember the value in 'last' and the time in 'time'         */
            AssGVar( Last3, VAL_GVAR( Last2 ) );
            AssGVar( Last2, VAL_GVAR( Last  ) );
            AssGVar( Last,  ReadEvalResult   );

            /* print the result                                            */
            if ( ! DualSemicolon ) {
                ViewObjHandler( ReadEvalResult );
            }
        }

        /* handle return-value or return-void command                      */
        else if ( type == 1 || type == 2 ) {
            Pr( "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseTest() ) {
        ErrorQuit(
            "Panic: ReadTest cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();

    return 1;
}


/****************************************************************************
**
*F  READ_GAP_ROOT( <filename> ) . . .  read from gap root, dyn-load or static
**
**  'READ_GAP_ROOT' tries to find  a file under  the root directory,  it will
**  search all   directories given   in 'SyGapRootPaths',  check  dynamically
**  loadable modules and statically linked modules.
*/


Int READ_GAP_ROOT ( Char * filename )
{
    Char                result[256];
    Int                 res;
    UInt                type;
    StructInitInfo *    info;
    Obj                 fname;

    /* try to find the file                                                */
    res = SyFindOrLinkGapRootFile( filename, 0L, result, 256 );

    /* not found                                                           */
    if ( res == 0 ) {
        return 0;
    }

    /* dynamically linked                                                  */
    else if ( res == 1 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' dynamically\n",
                (Int)filename, 0L );
        }
        info = *(StructInitInfo**)result;
	res  = info->initKernel(info);
	if (!SyRestoring) {
	  UpdateCopyFopyInfo();
	  res  = res || info->initLibrary(info);
	}
	if ( res ) {
	    Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
	}
	
	info->isGapRootRelative = 1;
        RecordLoadedModule(info, filename);
        return 1;
    }

    /* statically linked                                                   */
    else if ( res == 2 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' statically\n",
                (Int)filename, 0L );
        }
        info = *(StructInitInfo**)result;
	res  = info->initKernel(info);
	if (!SyRestoring) {
	  UpdateCopyFopyInfo();
	  res  = res || info->initLibrary(info);
	}
	if ( res ) {
	    Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
	}
	info->isGapRootRelative = 1;
        RecordLoadedModule(info, filename);
        return 1;
    }

    /* special handling for the other cases, if we are trying to load compiled
       modules needed for a saved workspace ErrorQuit is not available */
    else if (SyRestoring)
      {
	if (res == 3 || res == 4)
	  Pr("Can't find compiled module '%s' needed by saved workspace\n",
	     (Int) filename, 0L);
	else
	  Pr("unknown result code %d from 'SyFindGapRoot'", res, 0L );
	SyExit(1);
      }
    
    /* ordinary gap file                                                   */
    else if ( res == 3 || res == 4  ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' as GAP file\n",
                (Int)filename, 0L );
        }
        if ( OpenInput(result) ) {
            while ( 1 ) {
                ClearError();
                type = ReadEvalCommand();
		if (UserHasQuit || UserHasQUIT)
		  break;
                if ( type == 1 || type == 2 ) {
                    Pr( "'return' must not be used in file", 0L, 0L );
                }
                else if ( type == 8 || type == 16 ) {
                    break;
                }
            }
            CloseInput();
            ClearError();
            return 1;
        }
        else {
            return 0;
        }
    }

    /* don't know                                                          */
    else {
        ErrorQuit( "unknown result code %d from 'SyFindGapRoot'", res, 0L );
        return 0;
    }
    return 0;
}


/****************************************************************************
**

*F  FuncCLOSE_LOG_TO()  . . . . . . . . . . . . . . . . . . . .  stop logging
**
**  'FuncCLOSE_LOG_TO' implements a method for 'LogTo'.
**
**  'LogTo()'
**
**  'LogTo' called with no argument closes the current logfile again, so that
**  input   from  '*stdin*'  and  '*errin*'  and  output  to  '*stdout*'  and
**  '*errout*' will no longer be echoed to a file.
*/
Obj FuncCLOSE_LOG_TO (
    Obj                 self )
{
    if ( ! CloseLog() ) {
        ErrorQuit("LogTo: can not close the logfile",0L,0L);
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncLOG_TO( <filename> ) . . . . . . . . . . . .  start logging to a file
**
**  'FuncLOG_TO' implements a method for 'LogTo'
**
**  'LogTo( <filename> )'
**
**  'LogTo' instructs GAP to echo all input from the  standard  input  files,
**  '*stdin*' and '*errin*' and all output  to  the  standard  output  files,
**  '*stdout*'  and  '*errout*',  to  the  file  with  the  name  <filename>.
**  The file is created if it does not  exist,  otherwise  it  is  truncated.
*/
Obj FuncLOG_TO (
    Obj                 self,
    Obj                 filename )
{
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "LogTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    if ( ! OpenLog( CSTR_STRING(filename) ) ) {
        ErrorReturnVoid( "LogTo: cannot log to %s",
                         (Int)CSTR_STRING(filename), 0L,
                         "you can return" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncLOG_TO_STREAM( <stream> ) . . . . . . . . . start logging to a stream
*/
Obj FuncLOG_TO_STREAM (
    Obj                 self,
    Obj                 stream )
{
    if ( ! OpenLogStream(stream) ) {
        ErrorReturnVoid( "LogTo: cannot log to stream", 0L, 0L,
                         "you can return" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncCLOSE_INPUT_LOG_TO()  . . . . . . . . . . . . . . . . .  stop logging
**
**  'FuncCLOSE_INPUT_LOG_TO' implements a method for 'InputLogTo'.
**
**  'InputLogTo()'
**
**  'InputLogTo' called with no argument closes the current logfile again, so
**  that input from  '*stdin*' and '*errin*' will   no longer be  echoed to a
**  file.
*/
Obj FuncCLOSE_INPUT_LOG_TO (
    Obj                 self )
{
    if ( ! CloseInputLog() ) {
        ErrorQuit("InputLogTo: can not close the logfile",0L,0L);
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncINPUT_LOG_TO( <filename> )  . . . . . . . . . start logging to a file
**
**  'FuncINPUT_LOG_TO' implements a method for 'InputLogTo'
**
**  'InputLogTo( <filename> )'
**
**  'InputLogTo'  instructs  GAP to echo   all input from  the standard input
**  files, '*stdin*' and '*errin*' to the file with the name <filename>.  The
**  file is created if it does not exist, otherwise it is truncated.
*/
Obj FuncINPUT_LOG_TO (
    Obj                 self,
    Obj                 filename )
{
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "InputLogTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    if ( ! OpenInputLog( CSTR_STRING(filename) ) ) {
        ErrorReturnVoid( "InputLogTo: cannot log to %s",
                         (Int)CSTR_STRING(filename), 0L,
                         "you can return" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncINPUT_LOG_TO_STREAM( <stream> ) . . . . . . start logging to a stream
*/
Obj FuncINPUT_LOG_TO_STREAM (
    Obj                 self,
    Obj                 stream )
{
    if ( ! OpenInputLogStream(stream) ) {
        ErrorReturnVoid( "InputLogTo: cannot log to stream", 0L, 0L,
                         "you can return" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncCLOSE_OUTPUT_LOG_TO()  . . . . . . . . . . . . . . . . . stop logging
**
**  'FuncCLOSE_OUTPUT_LOG_TO' implements a method for 'OutputLogTo'.
**
**  'OutputLogTo()'
**
**  'OutputLogTo'  called with no argument  closes the current logfile again,
**  so that output from '*stdin*' and '*errin*' will no longer be echoed to a
**  file.
*/
Obj FuncCLOSE_OUTPUT_LOG_TO (
    Obj                 self )
{
    if ( ! CloseOutputLog() ) {
        ErrorQuit("OutputLogTo: can not close the logfile",0L,0L);
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncOUTPUT_LOG_TO( <filename> )  . . . . . . . .  start logging to a file
**
**  'FuncOUTPUT_LOG_TO' implements a method for 'OutputLogTo'
**
**  'OutputLogTo( <filename> )'
**
**  'OutputLogTo' instructs GAP  to echo all  output from the standard output
**  files, '*stdin*' and '*errin*' to the file with the name <filename>.  The
**  file is created if it does not exist, otherwise it is truncated.
*/
Obj FuncOUTPUT_LOG_TO (
    Obj                 self,
    Obj                 filename )
{
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "OutputLogTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    if ( ! OpenOutputLog( CSTR_STRING(filename) ) ) {
        ErrorReturnVoid( "OutputLogTo: cannot log to %s",
                         (Int)CSTR_STRING(filename), 0L,
                         "you can return" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncOUTPUT_LOG_TO_STREAM( <stream> ) . . . . .  start logging to a stream
*/
Obj FuncOUTPUT_LOG_TO_STREAM (
    Obj                 self,
    Obj                 stream )
{
    if ( ! OpenOutputLogStream(stream) ) {
        ErrorReturnVoid( "OutputLogTo: cannot log to stream", 0L, 0L,
                         "you can return" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncPrint( <self>, <args> ) . . . . . . . . . . . . . . . .  print <args>
*/
Obj FuncPrint (
    Obj                 self,
    Obj                 args )
{
    volatile Obj        arg;
    volatile UInt       i;
    jmp_buf             readJmpError;

    /* print all the arguments, take care of strings and functions         */
    for ( i = 1;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);
        if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
            PrintString1(arg);
        }
        else if ( IS_STRING_REP(arg) ) {
            PrintString1(arg);
        }
        else if ( TNUM_OBJ( arg ) == T_FUNCTION ) {
	  PrintFunction( arg );
        }
        else {
            memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );

            /* if an error occurs stop printing                            */
            if ( ! READ_ERROR() ) {
                PrintObj( arg );
            }
            else {
                memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
                ReadEvalError();
            }
            memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
        }
    }

    return 0;
}


/****************************************************************************
**
*F  FuncPRINT_TO( <self>, <args> )  . . . . . . . . . . . . . .  print <args>
*/
Obj FuncPRINT_TO (
    Obj                 self,
    Obj                 args )
{
    volatile Obj        arg;
    volatile Obj        filename;
    volatile UInt       i;
    jmp_buf             readJmpError;

    /* first entry is the filename                                         */
    filename = ELM_LIST(args,1);
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "PrintTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file for output                                     */
    if ( ! OpenOutput( CSTR_STRING(filename) ) ) {
        ErrorQuit( "PrintTo: cannot open '%s' for output",
                   (Int)CSTR_STRING(filename), 0L );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);
        if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
            PrintString1(arg);
        }
        else if ( IS_STRING_REP(arg) ) {
            PrintString1(arg);
        }
        else if ( TNUM_OBJ( arg ) == T_FUNCTION ) {
            PrintObjFull = 1;
            PrintFunction( arg );
            PrintObjFull = 0;
        }
        else {
            memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );

            /* if an error occurs stop printing                            */
            if ( ! READ_ERROR() ) {
                PrintObj( arg );
            }
            else {
                CloseOutput();
                memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
                ReadEvalError();
            }
            memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
        }
    }

    /* close the output file again, and return nothing                     */
    if ( ! CloseOutput() ) {
        ErrorQuit( "PrintTo: cannot close output", 0L, 0L );
        return 0;
    }

    return 0;
}


/****************************************************************************
**
*F  FuncPRINT_TO_STREAM( <self>, <args> ) . . . . . . . . . . .  print <args>
*/
Obj FuncPRINT_TO_STREAM (
    Obj                 self,
    Obj                 args )
{
    volatile Obj        arg;
    volatile Obj        stream;
    volatile UInt       i;
    jmp_buf             readJmpError;

    /* first entry is the stream                                           */
    stream = ELM_LIST(args,1);

    /* try to open the file for output                                     */
    if ( ! OpenOutputStream(stream) ) {
        ErrorQuit( "PrintTo: cannot open stream for output", 0L, 0L );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);

        /* if an error occurs stop printing                                */
        memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );
        if ( ! READ_ERROR() ) {
            if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
                PrintString1(arg);
            }
            else if ( IS_STRING_REP(arg) ) {
                PrintString1(arg);
            }
            else if ( TNUM_OBJ( arg ) == T_FUNCTION ) {
                PrintObjFull = 1;
                PrintFunction( arg );
                PrintObjFull = 0;
            }
            else {
                PrintObj( arg );
            }
        }
        else {
            CloseOutput();
            memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
            ReadEvalError();
        }
        memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
    }

    /* close the output file again, and return nothing                     */
    if ( ! CloseOutput() ) {
        ErrorQuit( "PrintTo: cannot close output", 0L, 0L );
        return 0;
    }

    return 0;
}


/****************************************************************************
**
*F  FuncAPPEND_TO( <self>, <args> ) . . . . . . . . . . . . . . append <args>
*/
Obj FuncAPPEND_TO (
    Obj                 self,
    Obj                 args )
{
    volatile Obj        arg;
    volatile Obj        filename;
    volatile UInt       i;
    jmp_buf             readJmpError;

    /* first entry is the filename                                         */
    filename = ELM_LIST(args,1);
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "AppendTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file for output                                     */
    if ( ! OpenAppend( CSTR_STRING(filename) ) ) {
        ErrorQuit( "AppendTo: cannot open '%s' for output",
                   (Int)CSTR_STRING(filename), 0L );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);
        if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
            PrintString1(arg);
        }
        else if ( IS_STRING_REP(arg) ) {
            PrintString1(arg);
        }
        else if ( TNUM_OBJ(arg) == T_FUNCTION ) {
            PrintObjFull = 1;
            PrintFunction( arg );
            PrintObjFull = 0;
        }
        else {
            memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );

            /* if an error occurs stop printing                            */
            if ( ! READ_ERROR() ) {
                PrintObj( arg );
            }
            else {
                CloseOutput();
                memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
                ReadEvalError();
            }
            memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
        }
    }

    /* close the output file again, and return nothing                     */
    if ( ! CloseOutput() ) {
        ErrorQuit( "AppendTo: cannot close output", 0L, 0L );
        return 0;
    }

    return 0;
}


/****************************************************************************
**
*F  FuncAPPEND_TO_STREAM( <self>, <args> )  . . . . . . . . . . append <args>
*/
Obj FuncAPPEND_TO_STREAM (
    Obj                 self,
    Obj                 args )
{
    volatile Obj        arg;
    volatile Obj        stream;
    volatile UInt       i;
    jmp_buf             readJmpError;

    /* first entry is the stream                                           */
    stream = ELM_LIST(args,1);

    /* try to open the file for output                                     */
    if ( ! OpenAppendStream(stream) ) {
        ErrorQuit( "AppendTo: cannot open stream for output", 0L, 0L );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);

        /* if an error occurs stop printing                                */
        memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );
        if ( ! READ_ERROR() ) {
            if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
                PrintString1(arg);
            }
            else if ( IS_STRING_REP(arg) ) {
                PrintString1(arg);
            }
            else if ( TNUM_OBJ( arg ) == T_FUNCTION ) {
                PrintObjFull = 1;
                PrintFunction( arg );
                PrintObjFull = 0;
            }
            else {
                PrintObj( arg );
            }
        }
        else {
            CloseOutput();
            memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
            ReadEvalError();
        }
        memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
    }

    /* close the output file again, and return nothing                     */
    if ( ! CloseOutput() ) {
        ErrorQuit( "AppendTo: cannot close output", 0L, 0L );
        return 0;
    }

    return 0;
}


/****************************************************************************
**
*F  FuncREAD( <self>, <filename> )  . . . . . . . . . . . . . . . read a file
*/
Obj FuncREAD (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return False;
    }

    /* read the test file                                                  */
    return READ() ? True : False;
}


/****************************************************************************
**
*F  FuncREAD_STREAM( <self>, <stream> )   . . . . . . . . . . . read a stream
*/
Obj FuncREAD_STREAM (
    Obj                 self,
    Obj                 stream )
{
    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return False;
    }

    /* read the test file                                                  */
    return READ() ? True : False;
}


/****************************************************************************
**
*F  FuncREAD_TEST( <self>, <filename> ) . . . . . . . . . .  read a test file
*/
Obj FuncREAD_TEST (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "ReadTest: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    if ( ! OpenTest( CSTR_STRING(filename) ) ) {
        return False;
    }

    /* read the test file                                                  */
    return READ_TEST() ? True : False;
}


/****************************************************************************
**
*F  FuncREAD_TEST_STREAM( <self>, <stream> )  . . . . . .  read a test stream
*/
Obj FuncREAD_TEST_STREAM (
    Obj                 self,
    Obj                 stream )
{
    /* try to open the file                                                */
    if ( ! OpenTestStream(stream) ) {
        return False;
    }

    /* read the test file                                                  */
    return READ_TEST() ? True : False;
}


/****************************************************************************
**
*F  FuncREAD_AS_FUNC( <self>, <filename> )  . . . . . . . . . . . read a file
*/
Obj FuncREAD_AS_FUNC (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ_AS_FUNC: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return Fail;
    }

    /* read the function                                                   */
    return READ_AS_FUNC();
}


/****************************************************************************
**
*F  FuncREAD_AS_FUNC_STREAM( <self>, <filename> ) . . . . . . . . read a file
*/
Obj FuncREAD_AS_FUNC_STREAM (
    Obj                 self,
    Obj                 stream )
{
    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return Fail;
    }

    /* read the function                                                   */
    return READ_AS_FUNC();
}


/****************************************************************************
**
*F  FuncREAD_GAP_ROOT( <self>, <filename> ) . . . . . . . . . . . read a file
*/
Obj FuncREAD_GAP_ROOT (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    return READ_GAP_ROOT(CSTR_STRING(filename)) ? True : False;
}


/****************************************************************************
**

*F  FuncTmpName( <self> ) . . . . . . . . . . . . . . return a temporary name
*/
Obj FuncTmpName (
    Obj                 self )
{
    Char *              tmp;
    Obj                 name;

    tmp = SyTmpname();
    if ( tmp == 0 )
        return Fail;
    C_NEW_STRING( name, SyStrlen(tmp), tmp );
    return name;
}


/****************************************************************************
**
*F  FuncTmpDirectory( <self> )  . . . . . . . .  return a temporary directory
*/
Obj FuncTmpDirectory (
    Obj                 self )
{
    Char *              tmp;
    Obj                 name;

    tmp = SyTmpdir("tmp");
    if ( tmp == 0 )
        return Fail;
    C_NEW_STRING( name, SyStrlen(tmp), tmp );
    return name;
}


/****************************************************************************
**
*F  FuncRemoveFile( <self>, <name> )  . . . . . . . . . .  remove file <name>
*/
Obj FuncRemoveFile (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    return SyRemoveFile( CSTR_STRING(filename) ) == -1 ? Fail : True;
}


/****************************************************************************
**

*F * * * * * * * * * * * file access test functions * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncLastSystemError( <self> ) .  . . . . . .  return the last system error
*/
UInt ErrorMessageRNam;
UInt ErrorNumberRNam;

Obj FuncLastSystemError (
    Obj             self )
{
    Obj             err;
    Obj             msg;

    /* constructed an error record                                         */
    err = NEW_PREC(0);

    /* check if an errors has occured                                      */
    if ( SyLastErrorNo != 0 ) {
        ASS_REC( err, ErrorNumberRNam, INTOBJ_INT(SyLastErrorNo) );
        C_NEW_STRING(msg, SyStrlen(SyLastErrorMessage), SyLastErrorMessage);
        ASS_REC( err, ErrorMessageRNam, msg );
    }

    /* no error has occured                                                */
    else {
        ASS_REC( err, ErrorNumberRNam, INTOBJ_INT(0) );
        C_NEW_STRING( msg, 8, "no error" );
        ASS_REC( err, ErrorMessageRNam, msg );
    }

    /* return the error record                                             */
    return err;
}


/****************************************************************************
**
*F  FuncIsExistingFile( <self>, <name> )  . . . . . . does file <name> exists
*/
Obj FuncIsExistingFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsExistingFile( CSTR_STRING(filename) );
    return res == -1 ? Fail : ( res == 0 ? True : False );
}


/****************************************************************************
**
*F  FuncIsReadableFile( <self>, <name> )  . . . . . . is file <name> readable
*/
Obj FuncIsReadableFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsReadableFile( CSTR_STRING(filename) );
    return res == -1 ? Fail : ( res == 0 ? True : False );
}


/****************************************************************************
**
*F  FuncIsWritableFile( <self>, <name> )  . . . . . . is file <name> writable
*/
Obj FuncIsWritableFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsWritableFile( CSTR_STRING(filename) );
    return res == -1 ? Fail : ( res == 0 ? True : False );
}


/****************************************************************************
**
*F  FuncIsExecutableFile( <self>, <name> )  . . . . is file <name> executable
*/
Obj FuncIsExecutableFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsExecutableFile( CSTR_STRING(filename) );
    return res == -1 ? Fail : ( res == 0 ? True : False );
}


/****************************************************************************
**
*F  FuncIsDirectoryPath( <self>, <name> ) . . . .  is file <name> a directory
*/
Obj FuncIsDirectoryPath (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsDirectoryPath( CSTR_STRING(filename) );
    return res == -1 ? Fail : ( res == 0 ? True : False );
}


/****************************************************************************
**

*F * * * * * * * * * * * * text stream functions  * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  FuncCLOSE_FILE( <self>, <fid> ) . . . . . . . . . . . . .  close a stream
*/
Obj FuncCLOSE_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    
    /* call the system dependent function                                  */
    ret = SyFclose( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : True;
}


/****************************************************************************
**
*F  FuncINPUT_TEXT_FILE( <self>, <name> ) . . . . . . . . . . . open a stream
*/
Obj FuncINPUT_TEXT_FILE (
    Obj             self,
    Obj             filename )
{
    Int             fid;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    SyClearErrorNo();
    fid = SyFopen( CSTR_STRING(filename), "r" );
    if ( fid == - 1)
        SySetErrorNo();
    return fid == -1 ? Fail : INTOBJ_INT(fid);
}


/****************************************************************************
**
*F  FuncIS_END_OF_FILE( <self>, <fid> ) . . . . . . . . . . .  is end of file
*/
Obj FuncIS_END_OF_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    
    ret = SyIsEndOfFile( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : ( ret == 0 ? False : True );
}


/****************************************************************************
**
*F  FuncOUTPUT_TEXT_FILE( <self>, <name>, <append> )  . . . . . open a stream
*/
Obj FuncOUTPUT_TEXT_FILE (
    Obj             self,
    Obj             filename,
    Obj             append )
{
    Int             fid;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    while ( append != True && append != False ) {
        filename = ErrorReturnObj(
            "<append> must be a boolean (not a %s)",
            (Int)TNAM_OBJ(append), 0L,
            "you can return a string for <append>" );
    }
    
    /* call the system dependent function                                  */
    SyClearErrorNo();
    if ( append == True ) {
        fid = SyFopen( CSTR_STRING(filename), "a" );
    }
    else {
        fid = SyFopen( CSTR_STRING(filename), "w" );
    }
    if ( fid == - 1)
        SySetErrorNo();
    return fid == -1 ? Fail : INTOBJ_INT(fid);
}


/****************************************************************************
**
*F  FuncPOSITION_FILE( <self>, <fid> )  . . . . . . . . .  position of stream
*/
Obj FuncPOSITION_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    
    ret = SyFtell( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : INTOBJ_INT(ret);
}


/****************************************************************************
**
*F  FuncREAD_BYTE_FILE( <self>, <fid> ) . . . . . . . . . . . . . read a byte
*/
Obj FuncREAD_BYTE_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    
    /* Check if we are at the end of the file.                             */
    ret = SyIsEndOfFile( INT_INTOBJ(fid) );
    if( ret == -1 || ret == 1 ) return Fail;

    /* call the system dependent function                                  */
    ret = SyGetch( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : INTOBJ_INT(ret);
}


/****************************************************************************
**
*F  FuncREAD_LINE_FILE( <self>, <fid> ) . . . . . . . . . . . . . read a line
*/
Obj FuncREAD_LINE_FILE (
    Obj             self,
    Obj             fid )
{
    Char            buf[256];
    Char *          cstr;
    Int             len;
    Obj             str;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    
    /* read <fid> until we see a newline or eof                            */
    str = NEW_STRING(0);
    len = 0;
    while (1) {
        len += 255;
        ResizeBag( str, 1+len );
        if ( SyFgets( buf, 256, INT_INTOBJ(fid) ) == 0 )
            break;
        cstr = CSTR_STRING(str);
        SyStrncat( cstr, buf, 255 );
        if ( buf[SyStrlen(buf)-1] == '\n' )
            break;
    }

    /* fix the length of <str>                                             */
    len = SyStrlen( CSTR_STRING(str) );
    ResizeBag( str, len+1 );

    /* and return                                                          */
    return len == 0 ? Fail : str;
}


/****************************************************************************
**
*F  FuncSEEK_POSITION_FILE( <self>, <fid>, <pos> )  . seek position of stream
*/
Obj FuncSEEK_POSITION_FILE (
    Obj             self,
    Obj             fid,
    Obj             pos )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    while ( ! IS_INTOBJ(pos) ) {
        pos = ErrorReturnObj(
            "<pos> must be an integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L,
            "you can return an integer for <pos>" );
    }
    
    ret = SyFseek( INT_INTOBJ(fid), INT_INTOBJ(pos) );
    return ret == -1 ? Fail : True;
}


/****************************************************************************
**
*F  FuncWRITE_BYTE_FILE( <self>, <fid>, <byte> )  . . . . . . .  write a byte
*/
Obj FuncWRITE_BYTE_FILE (
    Obj             self,
    Obj             fid,
    Obj             ch )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can return an integer for <fid>" );
    }
    while ( ! IS_INTOBJ(ch) ) {
        ch = ErrorReturnObj(
            "<ch> must be an integer (not a %s)",
            (Int)TNAM_OBJ(ch), 0L,
            "you can return an integer for <ch>" );
    }
    
    /* call the system dependent function                                  */
    ret = SyEchoch( INT_INTOBJ(ch), INT_INTOBJ(fid) );
    return ret == -1 ? Fail : True;
}

/****************************************************************************
**
*F  FuncWRITE_STRING_FILE_NC( <self>, <fid>, <string> ) .write a whole string
*/
Obj FuncWRITE_STRING_FILE_NC (
    Obj             self,
    Obj             fid,
    Obj             str )
{
    Int             ret;

    /* don't check the argument                                            */
    
    /* call the system dependent function                                  */
    SyFputs( CSTR_STRING(str), INT_INTOBJ(fid) );
    return True;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * execution functions  * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncExecuteProcess( <self>, <dir>, <prg>, <in>, <out>, <args> )   process
*/
static Obj    ExecArgs  [ 1024 ];
static Char * ExecCArgs [ 1024 ];

Obj FuncExecuteProcess (
    Obj                 self,
    Obj                 dir,
    Obj                 prg,
    Obj                 in,
    Obj                 out,
    Obj                 args )
{
    Obj                 tmp;
    Int                 res;
    Int                 i;

    /* check the argument                                                  */
    while ( ! IsStringConv(dir) ) {
        dir = ErrorReturnObj(
            "<dir> must be a string (not a %s)",
            (Int)TNAM_OBJ(dir), 0L,
            "you can return a string for <dir>" );
    }
    while ( ! IsStringConv(prg) ) {
        prg = ErrorReturnObj(
            "<prg> must be a string (not a %s)",
            (Int)TNAM_OBJ(prg), 0L,
            "you can return a string for <prg>" );
    }
    while ( ! IS_INTOBJ(in) ) {
        in = ErrorReturnObj(
            "<in> must be an integer (not a %s)",
            (Int)TNAM_OBJ(in), 0L,
            "you can return an integer for <in>" );
    }
    while ( ! IS_INTOBJ(out) ) {
        out = ErrorReturnObj(
            "<out> must be an integer (not a %s)",
            (Int)TNAM_OBJ(out), 0L,
            "you can return an integer for <out>" );
    }
    while ( ! IS_SMALL_LIST(args) ) {
        args = ErrorReturnObj(
            "<args> must be a small list (not a %s)",
            (Int)TNAM_OBJ(args), 0L,
            "you can return a small list for <args>" );
    }

    /* create an argument array                                            */
    for ( i = 1;  i <= LEN_LIST(args);  i++ ) {
        if ( i == 1023 )
            break;
        tmp = ELM_LIST( args, i );
        while ( ! IsStringConv(tmp) ) {
            tmp = ErrorReturnObj(
                "<tmp> must be a string (not a %s)",
                (Int)TNAM_OBJ(tmp), 0L,
                "you can return a string for <tmp>" );
        }
        ExecArgs[i] = tmp;
    }
    ExecCArgs[0]   = CSTR_STRING(prg);
    ExecCArgs[i] = 0;
    for ( i--;  0 < i;  i-- ) {
        ExecCArgs[i] = CSTR_STRING(ExecArgs[i]);
    }

    /* execute the process                                                 */
    res = SyExecuteProcess( CSTR_STRING(dir),
                            CSTR_STRING(prg),
                            INT_INTOBJ(in),
                            INT_INTOBJ(out),
                            ExecCArgs );

    return res == 255 ? Fail : INTOBJ_INT(res);
}


/****************************************************************************
**


*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "READ", 1L, "filename",
      FuncREAD, "src/streams.c:READ" },

    { "READ_COMMAND", 2L, "stream, echo", 
      FuncREAD_COMMAND, "src/streams.c:READ_COMMAND" },

    { "READ_STREAM", 1L, "stream",
      FuncREAD_STREAM, "src/sreams.c:READ_STREAM" },

    { "READ_TEST", 1L, "filename", 
      FuncREAD_TEST, "src/sreams.c:READ_TEST" },

    { "READ_TEST_STREAM", 1L, "stream",
      FuncREAD_TEST_STREAM, "src/sreams.c:READ_TEST_STREAM" },

    { "READ_AS_FUNC", 1L, "filename",
      FuncREAD_AS_FUNC, "src/sreams.c:READ_AS_FUNC" },

    { "READ_AS_FUNC_STREAM", 1L, "stream", 
      FuncREAD_AS_FUNC_STREAM, "src/sreams.c:READ_AS_FUNC_STREAM" },

    { "READ_GAP_ROOT", 1L, "filename",
      FuncREAD_GAP_ROOT, "src/sreams.c:READ_GAP_ROOT" },

    { "LOG_TO", 1L, "filename", 
      FuncLOG_TO, "src/sreams.c:LOG_TO" },

    { "LOG_TO_STREAM", 1L, "filename", 
      FuncLOG_TO_STREAM, "src/sreams.c:LOG_TO_STREAM" },

    { "CLOSE_LOG_TO", 0L, "", 
      FuncCLOSE_LOG_TO, "src/sreams.c:CLOSE_LOG_TO" },

    { "INPUT_LOG_TO", 1L, "filename", 
      FuncINPUT_LOG_TO, "src/sreams.c:INPUT_LOG_TO" },

    { "INPUT_LOG_TO_STREAM", 1L, "filename", 
      FuncINPUT_LOG_TO_STREAM, "src/sreams.c:INPUT_LOG_TO_STREAM" },

    { "CLOSE_INPUT_LOG_TO", 0L, "", 
      FuncCLOSE_INPUT_LOG_TO, "src/sreams.c:CLOSE_INPUT_LOG_TO" },

    { "OUTPUT_LOG_TO", 1L, "filename", 
      FuncOUTPUT_LOG_TO, "src/sreams.c:OUTPUT_LOG_TO" },

    { "OUTPUT_LOG_TO_STREAM", 1L, "filename", 
      FuncOUTPUT_LOG_TO_STREAM, "src/sreams.c:OUTPUT_LOG_TO_STREAM" },

    { "CLOSE_OUTPUT_LOG_TO", 0L, "", 
      FuncCLOSE_OUTPUT_LOG_TO, "src/sreams.c:CLOSE_OUTPUT_LOG_TO" },

    { "Print", -1L, "args",
      FuncPrint, "src/streams.c:Print" },

    { "PRINT_TO", -1L, "args",
      FuncPRINT_TO, "src/streams.c:PRINT_TO" },

    { "PRINT_TO_STREAM", -1L, "args",
      FuncPRINT_TO_STREAM, "src/streams.c:PRINT_TO_STREAM" },

    { "APPEND_TO", -1L, "args",
      FuncAPPEND_TO, "src/streams.c:APPEND_TO" },

    { "APPEND_TO_STREAM", -1L, "args",
      FuncAPPEND_TO_STREAM, "src/streams.c:APPEND_TO_STREAM" },

    { "TmpName", 0L, "",
      FuncTmpName, "src/streams.c:TmpName" },

    { "TmpDirectory", 0L, "",
      FuncTmpDirectory, "src/streams.c:TmpDirectory" },

    { "RemoveFile", 1L, "file",
      FuncRemoveFile, "src/streams.c:RemoveFile" },

    { "LastSystemError", 0L, "", 
      FuncLastSystemError, "src/sreams.c:LastSystemError" },

    { "IsExistingFile", 1L, "filename", 
      FuncIsExistingFile, "src/sreams.c:IsExistingFile" },

    { "IsReadableFile", 1L, "filename",
      FuncIsReadableFile, "src/sreams.c:IsReadableFile" },

    { "IsWritableFile", 1L, "filename",
      FuncIsWritableFile, "src/sreams.c:IsWritableFile" },

    { "IsExecutableFile", 1L, "filename",
      FuncIsExecutableFile, "src/sreams.c:IsExecutableFile" },

    { "IsDirectoryPath", 1L, "filename",
      FuncIsDirectoryPath, "src/sreams.c:IsDirectoryPath" },

    { "CLOSE_FILE", 1L, "fid",
      FuncCLOSE_FILE, "src/sreams.c:CLOSE_FILE" },

    { "INPUT_TEXT_FILE", 1L, "filename",
      FuncINPUT_TEXT_FILE, "src/sreams.c:INPUT_TEXT_FILE" },

    { "OUTPUT_TEXT_FILE", 2L, "filename, append",
      FuncOUTPUT_TEXT_FILE, "src/sreams.c:OUTPUT_TEXT_FILE" },

    { "IS_END_OF_FILE", 1L, "fid",
      FuncIS_END_OF_FILE, "src/sreams.c:IS_END_OF_FILE" },

    { "POSITION_FILE", 1L, "fid",
      FuncPOSITION_FILE, "src/sreams.c:POSITION_FILE" },

    { "READ_BYTE_FILE", 1L, "fid",
      FuncREAD_BYTE_FILE, "src/sreams.c:READ_BYTE_FILE" },

    { "READ_LINE_FILE", 1L, "fid",
      FuncREAD_LINE_FILE, "src/sreams.c:READ_LINE_FILE" },

    { "SEEK_POSITION_FILE", 2L, "fid, pos",
      FuncSEEK_POSITION_FILE, "src/sreams.c:SEEK_POSITION_FILE" },

    { "WRITE_BYTE_FILE", 2L, "fid, byte",
      FuncWRITE_BYTE_FILE, "src/sreams.c:WRITE_BYTE_FILE" },

    { "WRITE_STRING_FILE_NC", 2L, "fid, string",
      FuncWRITE_STRING_FILE_NC, "src/sreams.c:WRITE_STRING_FILE_NC" },

    { "ExecuteProcess", 5L, "dir, prg, in, out, args",
      FuncExecuteProcess, "src/sreams.c:ExecuteProcess" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    /* file access test functions                                          */
    ErrorNumberRNam  = RNamName("number");
    ErrorMessageRNam = RNamName("message");

    /* pick up the number of this global */
    LastReadValueGVar = GVarName("LastReadValue");

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );


    /* return success                                                      */
    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoStreams() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "streams" ,                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoStreams ( void )
{
    module.revision_c = Revision_streams_c;
    module.revision_h = Revision_streams_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  streams.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
