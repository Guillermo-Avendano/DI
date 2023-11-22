
/* Copyright (c) 1982-2003 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG    "@(#) rpc2s2 6.02.03"

/********************************************************************
**
**   RPC sample 2
**                    
**   Description: 
**
**       RPC service: execute SYSTEM calls
**
**       The service waits for a stream of STRING tokens.
** 
**       The first string has to be a file name. In this file
**       all data will be stored.
**       The second string contains the system call. This line will
**       be executed by the oprating system using the fuction "system()".
**       The third string contains the name of response file. This content
**       of this file will be send back to the caller.
**       4-n'th String. All these strings are stored to the file, 
**       which name is defined in string 1.
**
**       Example:
**
**           RPC_STRING: c:\tmp\meine.bat
**           RPC_STRING: c:\tmp\meine.bat arg1 arg2 arg3 >c:\tmp\meine.erg
**           RPC_STRING: c:\tmp\meine.erg
**           RPC_STRING: progr1 %1 %2 >c:\tmp\xx.bat
**           RPC_STRING: progr2 c:\tmp\xx.bat c:\tmp\meine.erg %3
**
**       The results in the file defined by the third string will be
**       send back to the caller, if the task has to be executed
**       synchronously (EXEC-W).
**       The first line contains a status information.
**       This is either an error message (could not write file ...)
**       or the return code of the system call.
**       The next strings contain the response file.
**       If the file does not exist or is empty, the second line will
**       contain the string "<empty>".
**
**       No status information is available if the procedure is running.
**
*************************************************************************
**  History:
**
** 08.08.02.GG 6.02.01 created 
** 05.02.03 GG 6.02.02 Copyright 2003
** 26.02.03 LG 6.02.03 error handling corrected
*/

#include   "roapi2.h"
#include   "rpc2stub.h"
#include   "rpc2tool.h"
#include   "rosmpstr.h"

#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>
#ifndef MVS
#include <malloc.h>
#endif


#define DATASIZE       256              /* max. size of data       */
#define FILENAMESIZE   256              /* max. size of file name  */
#define DOWA           "SVC-DO"         /* wa name for $do         */
#define ERGWA          "SVC-ERG"        /* wa name for the result  */

/*************************************************************/
/* an implementation of SUnbind() as required by rpcstub.h   */
/*************************************************************/


void SUnbind(ROAPI_SESSION&) {
}


/*************************************************************/
/* an implementation of DoIt() as required by rpcstub.h      */
/*************************************************************/

void DoIt(
         ROAPI_SESSION& session, 
         ROAPI_SHORT    fun,          /* RPC_EXEC |RPC_EXEC_W   */
         ROAPI_LONG,                  /* sequence number        */
         ROAPI_PCNSTC curserviceid)   /* service-Id assigned*/
                                      /* to the client-BIND    */
{
    ROAPI_SHORT  token;
    ROAPI_LONG   container;
    ROAPI_LINENO lno,last;
    ROAPI_BOOL   cont, skip;
    ROAPI_CHAR   retc[RETCSIZE+1];
    ROAPI_CHAR   mbuf[MESSAGESIZE+1];
    int          i;

    RoAPIString  datstring;
    RoAPIString  filinstring;
    RoAPIString  filoutstring;
    RoAPIString  callstring;
    RoAPIString  retstring;
    RoAPIString  waName;

    static ROAPI_BOOL    first = ROAPI_TRUE;
    static ROAPI_CHAR    myserviceid[SERVICEIDLEN+1];

    
    /****************************************************************/
    /* initial processing at first startup: init, allocate memory   */
    /****************************************************************/


    if (first == ROAPI_TRUE) {

         /*****************************/
         /* create the two work areas */
         /*****************************/

         myserviceid[0] = '\0';
         waName.setValue(DOWA);
         session.createWA(waName);
         waName.setValue(ERGWA);
         session.createWA(waName);
         first = ROAPI_FALSE;
    }

    /*****************************************/
    /* open work area for getting input data */
    /*****************************************/
    waName.setValue(DOWA);
    session.openWA(waName, ROAPI_TRUE);


    /********************************************************/
    /*********** Step 1: read all input data ****************/
    /********************************************************/

    cont            = ROAPI_TRUE;
    skip            = ROAPI_FALSE;

    /***********************************/
    /* compare ID: detect a new client */
    /***********************************/

    if (memcmp(myserviceid,curserviceid, SERVICEIDLEN)!= 0) {
        /************************/ 
        /* it is a new client ! */
        /************************/

        memcpy(myserviceid,curserviceid, SERVICEIDLEN);
        myserviceid[SERVICEIDLEN] = '\0';
        sprintf(mbuf,"new client %s assigned", myserviceid);
        PutMess(mbuf);
    }

    sprintf(mbuf,"task for client %s started", myserviceid);
    PutMess(mbuf);


    /********************************/
    /* main loop for receiving data */
    /********************************/

    i   = 0;
    lno = 0;
    while (cont == ROAPI_TRUE) {
        session.sGetToken(token, container);
        
        if (skip == ROAPI_TRUE)   /* ignore all data until  */
            continue;             /* exception is thrown    */

        switch(token) {
        case RPC_EOD:         /* all data received      */
                                /* switch to processing   */
            break;

        case RPC_CANCEL:
                                /* cancel current task    */
            PutMess("task canceled by RPC_CANCEL");
            cont = ROAPI_FALSE;
            break;

        case RPC_BIN:
                                /* illegal in this example*/
            PutMess("RPC_BIN not allowed, skipping all data");
            skip = ROAPI_TRUE;
            break;

        case RPC_STRING:      /* ok, string received    */
                               /* read string and put it */ 
                               /* to the work area       */

            switch (i) {
            case 0:  
                session.sGetValue(filinstring);
                i++;
                break;
              
            case 1:  
                session.sGetValue(callstring);
                i++;
                break;
              
            case 2:  
                session.sGetValue(filoutstring);
                i++;
                break;
              
            default:
         
                /******************************************************/
                /* all other lines will be buffered in a working area */
                /******************************************************/

                session.sGetValue(datstring);
                session.insertLine(lno++, datstring);
                break;
            }
            break;

        default:
            sprintf(mbuf, "internal error, unknown token received (%hd)", token);
            PutMess(mbuf);
            break;
        }
        
        /***************************************/
        /* last token received was RPC_EOD,    */
        /* leave loop and switch to processing */
        /***************************************/

        if (token == RPC_EOD) break;   
    }

    /*************************************************/
    /* check, if the datastream were read correctly. */   
    /* Otherwise send a error message as an answer.  */ 
    /*************************************************/


    if (cont != ROAPI_TRUE || skip == ROAPI_TRUE) {
        if (cont == ROAPI_FALSE || skip == ROAPI_TRUE) {

            /******************************************/
            /* close working areas, and send message  */
            /* and EOD to the monitor                 */
            /******************************************/

            clearWA(session);
            session.closeWA();
            if (skip == ROAPI_TRUE && fun == RPC_EXEC_W) {

                token = RPC_STRING;
                sprintf(mbuf,"F illegal token sequence received");
                PutMess(mbuf);
                datstring.setValue(mbuf);
             
                session.sPutToken (token, datstring.getLen());
                session.sPutValue(datstring);
                session.sPutToken (RPC_EOD, 0);
            }
        }
        PutMess("current task aborted");
        return;
    }


    /******************************************************/
    /************** Step 2: processing ********************/
    /******************************************************/

    writeOutWA(session,filinstring.getRef(), retc);

    clearWA(session);
    session.closeWA();

    if (retc[0] != 'T' && fun == RPC_EXEC_W){

        /*****************************************/ 
        /* in an error case send message and EOD */
        /*****************************************/ 

        sprintf(mbuf,"couldn't write file %s, rc=%c",filinstring.getRef(), retc[0]);
        PutMess(mbuf);
       
        token = RPC_STRING;
        datstring.setValue(mbuf);
            
        session.sPutToken (token, datstring.getLen());
        session.sPutValue(datstring);
        session.sPutToken (RPC_EOD, 0);

        return;
    }

    /********************/
    /* execute system() */
    /********************/

    i = system(callstring.getRef());
    sprintf(mbuf,"call \"%s\", rc=%d",callstring.getRef(),i);
    PutMess(mbuf);
 
    /***********************************************************/
    /***** Step 3: put answer, in case of RPC_EXEC_W ***********/
    /***********************************************************/

    if (fun == RPC_EXEC_W) {

        token = RPC_STRING;

        /************************************/
        /* send the return code of system() */
        /************************************/

        datstring.setValue(mbuf);
        session.sPutToken (token, datstring.getLen());
        session.sPutValue(datstring);
        waName.setValue(ERGWA);
        session.openWA(waName, ROAPI_TRUE);

        readInWA(session, filoutstring.getRef(), retc);

        /************************************/ 
        /* send all lines of the wa         */
        /************************************/
        last = session.getSizeWA();
        for (lno = 1; lno <= last; lno++) {
             session.getLine(lno, datstring);
             session.sPutToken (token, datstring.getLen());
             session.sPutValue(datstring);
        }


        /*********************************/
        /* all lines processed, send EOD */
        /*********************************/

        session.sPutToken (RPC_EOD, 0);
    }

    /************************************/
    /* close wa's and return to rpcstub */
    /************************************/

    clearWA(session);
    session.closeWA();
}
