
/*	$Id: tixError.c,v 1.1.1.1 2000/05/17 11:08:41 idiscovery Exp $	*/

/*
 * tixError.c --
 *
 *	Implements error handlers for Tix.
 *
 * Copyright (c) 1996, Expert Interface Technologies
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "tixPort.h"
#include "tixInt.h"

int Tix_ArgcError(interp, argc, objv, prefixCount, message)
    Tcl_Interp 	      * interp;
    int			argc;
    Tcl_Obj *CONST *objv;
    int			prefixCount;
    char	      * message;
{
    int i;

    Tcl_AppendResult(interp, "wrong # of arguments, should be \"",         NULL);

    for (i=0; i<prefixCount && i<argc; i++) {
	Tcl_AppendResult(interp, Tcl_GetString(objv[i]), " ",          NULL);
    }

    Tcl_AppendResult(interp, message, "\".",          NULL);

    return TCL_ERROR;
}

#if 0

int Tix_ValueMissingError(interp, spec)
    Tcl_Interp 	      * interp;
    char	      * spec;
{
    Tcl_AppendResult(interp, "value for \"", spec,
	"\" missing",          NULL);
    return TCL_ERROR;
}


/*----------------------------------------------------------------------
 * Tix_UnknownPublicMethodError --
 *
 *
 * ToDo: sort the list of commands.
 *----------------------------------------------------------------------
 */
int Tix_UnknownPublicMethodError(interp, cPtr, widRec, method)
    Tcl_Interp 	      * interp;
    TixClassRecord    * cPtr;
    char 	      * widRec;
    char	      * method;
{
    int     i;
    char  * lead = "";

    Tcl_AppendResult(interp, "unknown option \"", method,
	"\": must be ",
	         NULL);

    for (i=0; i<cPtr->nMethods-1; i++) {
	Tcl_AppendResult(interp, lead, cPtr->methods[i],          NULL);
	lead = ", ";
    }
    if (cPtr->nMethods>1) {
	Tcl_AppendResult(interp, " or ",          NULL);
    }
    if (cPtr->nMethods>0) {
	Tcl_AppendResult(interp, cPtr->methods[i],          NULL);
    }
    return TCL_ERROR;
}

#endif
