#define MODULKENNUNG    "@(#) rpc2s1.cpp 7.00.01"
/***********************************************************************
**
**   RPC sample 1 and its UNICODE version sample 7
**
**   RPC sample 1
**
**   Description:
**
**         RPC service: execute a set ROCHADE commands/procedures
**
**         The service waits for a stream of STRING tokens.
**         All strings will be stored within a global work area.
**         This working area is interpreted by "$DO <wa>". The results
**         in the current work area are devivered to the client,
**         if the request was executed in sychronous mode (EXEC-W).
**         The first line contains the ROCHADE return code.
**
**         Note that the executed procedure is responsible for preparing 
**         databases, configuration paths, and system tables.
**
**         No status information is available while the procedure is running.
**
**   Example:
**         The client send using $RPC EXEC-W :
**             #$db test u p
**             #$movelog sysadm
**             #$sdc user all
**         The client receives :
**             T
**             <list of all user documents>
**
***************************************************************************
** history of changes
**
** 10.09.10 LG 7.00.00 merged rpc2s1.cpp and rpc2s7.cpp, unicode handling
**                     simplified and z/OS enabled
** 21.12.15 LG 7.00.01 use default work area as output
**                              
***********************************************************************/

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


#ifdef MVS
#pragma convlit(suspend)
#endif
static ROAPI_PCNSTC bind_err = "Unbind called";
static ROAPI_PCNSTC mes1 = "Bind called";
static ROAPI_PCNSTC mes2 = "$PROFILE GET STARTSECTION";
static ROAPI_PCNSTC mes3 = "Exec $PROFILE GET $CMDLINE $STARTSECTION failed";
static ROAPI_PCNSTC mes4 = "$PROFILE GET PROC-DB";
static ROAPI_PCNSTC mes5 = "Exec $PROFILE GET startsection PROC-DB failed";
static ROAPI_PCNSTC mes6 = "$PROFILE GET USER-DB";
static ROAPI_PCNSTC mes7 = "Exec $PROFILE GET startsection USER-DB failed";
static ROAPI_PCNSTC mes8 = "$DB PROC-DB";
static ROAPI_PCNSTC mes9 = "Exec $DB PDB failed";
static ROAPI_PCNSTC mes10 = "Exec $MAKE failed";
static ROAPI_PCNSTC mes11 = "$DB PROC-DB";
static ROAPI_PCNSTC mes12 = "Exec $DB PDB failed";
static ROAPI_PCNSTC mes13 = "$DB USER-DB";
static ROAPI_PCNSTC mes14 = "Exec $DB UDB failed";
static ROAPI_PCNSTC mes15 = "$SELDB USERDB";
static ROAPI_PCNSTC mes16 = "Exec $SELDB UDB failed";
static ROAPI_PCNSTC mes17 = "$MOVELOG *";
static ROAPI_PCNSTC mes18 = "Exec $MOVELOG * failed";
static ROAPI_PCNSTC mes19 = "Bind OK";
static ROAPI_PCNSTC mes20 = "API Error: %d, (%s)";
static ROAPI_PCNSTC mes21 = "Current Service-ID: %s";
static ROAPI_PCNSTC mes22 = "RPC_EOD received";
static ROAPI_PCNSTC mes23 = "task canceled by RPC_CANCEL";
static ROAPI_PCNSTC mes24 = "RPC_BIN not allowed, skipping all data";
static ROAPI_PCNSTC mes25 = "String, len=%ld, txt=%.200s";
static ROAPI_PCNSTC mes26 = "internal error, unknown token received (%hd)";
static ROAPI_PCNSTC mes27 = "F illegal token sequence received";
static ROAPI_PCNSTC mes28 = "current task aborted";
static ROAPI_PCNSTC mes29 = "$DEL 2 $ failed";
static ROAPI_PCNSTC mes30 = "$LPUTLN #$EXIT :RETCODE failed";
static ROAPI_PCNSTC mes31 = "$FIRST ARGTMP failed";

#ifdef MVS
#pragma convlit(resume)
#endif


#define     DOWA     ROTEXT("SVC-DO")           /* wa name for executing  */

/*************************************************************/
/* an implementation of SBind() as required by rpcstub.h     */
/*************************************************************/

static ROAPI_BOOL bind_ok = ROAPI_FALSE;
static ROAPI_BOOL secure_mode;


static void SBind(ROAPI_SESSION& session)
{
    RoAPIString varname;
    RoAPIString varval;
    
    PutMess(mes1);
    try { 
        varname.setValue(ROTEXT("ARGPDB"));
        session.putVariable(varname, varval);
        varname.setValue(ROTEXT("ARGUDB"));
        session.putVariable(varname, varval);
    
        PutMess(mes2);
    
        execCmd(session,
                 ROTEXT("$PROFILE GET $CMDLINE $STARTSECTION ARGTMP"),
                 mes3,
                 ROTEXT("T"));
        PutMess(mes4);
        execCmd(session,
                 ROTEXT("$PROFILE GET :ARGTMP PROC-DB ARGPDB"),
                 mes5,
                 ROTEXT("T"));
        varname.setValue(ROTEXT("ARGPDB"));
        session.getVariable(varname, varval);
#ifdef ROUNICODE
        if (varval.getWLen() == 0) {
#else
        if (varval.getLen() == 0) {
#endif
           bind_ok = ROAPI_TRUE;
           secure_mode = ROAPI_FALSE;
           return;
        }
        else {
            secure_mode = ROAPI_TRUE;
        }
        PutMess(mes6);
        execCmd(session,
              ROTEXT("$PROFILE GET :ARGTMP USER-DB ARGUDB"),
              mes7,
              ROTEXT("T"));
        
        varname.setValue(ROTEXT("ARGUDB"));
        session.getVariable(varname, varval);
#ifdef ROUNICODE
        if (varval.getWLen() == 0) {
#else
        if (varval.getLen() == 0) {
#endif
            PutMess(mes8);
            /* use value of P-DB for U-DB as well */
            execCmd(session,
             ROTEXT("$DB :ARGPDB R P"),
              mes9,
              ROTEXT("T"));
                
            execCmd(session,
             ROTEXT("$MAKE ARGUDB :ARGPDB"),
             mes10,
             ROTEXT("T"));
        }
        else {
            PutMess(mes11);
            execCmd(session,
              ROTEXT("$DB :ARGPDB R P"),
              mes12,
              ROTEXT("T"));
           
            PutMess(mes13);
            execCmd(session,
              ROTEXT("$DB :ARGUDB R P"),
               mes14, 
               ROTEXT("T"));
        }
        
        PutMess(mes15);
        execCmd(session,
         ROTEXT("$SELDB :ARGUDB"), 
         mes16, 
         ROTEXT("T"));
        
        PutMess(mes17);
        execCmd(session,
          ROTEXT("$MOVELOG *"),
          mes18,
          ROTEXT("T"));
        
        PutMess(mes19);
        bind_ok = ROAPI_TRUE;
    }
    catch (RPC_EXCEPTION& e) {
        PutMess(e.getMessage());
    }
    catch (ROAPI_EXCEPTION& e) {
        RoAPIStringA msg;
        
        e.getMessage(msg);
        char tmp[256];
        
        sprintf(tmp, mes20, e.getState(), msg.getRef());
        PutMess(tmp);
    }
}



/*************************************************************/
/* an implementation of SUnbind() as required by rpcstub.h   */
/*************************************************************/

void SUnbind(ROAPI_SESSION&) {
    bind_ok = ROAPI_FALSE;
}


/*************************************************************/
/* an implementation of DoIt() as required by rpcstub.h      */
/*************************************************************/

void DoIt(
         ROAPI_SESSION& session, 
         ROAPI_SHORT    fun,          /* RPC_EXEC |RPC_EXEC_W   */
         ROAPI_LONG     seq,          /* sequence number        */
         ROAPI_PCNSTC curserviceid) /* service-Id assigned*/
                                      /* to the client-BIND    */
{

   ROAPI_BOOL   cont, skip;
   ROAPI_LINENO lno;
   ROAPI_SHORT  token;
   ROAPI_LONG   container;
   RoAPIString  datstring;
   RoAPIString  retstring;
   RoAPIString  waName;

   ROAPI_CHAR   mbuf[MESSAGESIZE+1];
   
   static ROAPI_BOOL    first = ROAPI_TRUE;

   sprintf(mbuf, mes21,curserviceid);
   PutMess(mbuf);

   (void)seq; // not used here
   
   /*********************************************************/
   /* initial processing at first startup: allocate memory  */
   /*********************************************************/

   if (first == ROAPI_TRUE) {

        /*****************************/
        /* create the two work areas */
        /*****************************/

        waName.setValue(DOWA);
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
   lno             = 0;


   while (cont == ROAPI_TRUE) {
      session.sGetToken(token, container);

      if (skip == ROAPI_TRUE)   /* ignore all data until  */
         continue;              /* exception is thrown    */

      switch(token) {
         case RPC_EOD:
                                /* all data received      */
                                /* switch to processing   */
            PutMess(mes22);
            break;

         case RPC_CANCEL:
                                /* cancel current task    */
            PutMess(mes23);
            cont = ROAPI_FALSE;
            break;

         case RPC_BIN:
                                /* illegal in this example*/
            PutMess(mes24);
            skip = ROAPI_TRUE;
            break;

         case RPC_STRING:        /* ok, string received    */
                                /* read string and put it */ 
                                /* to the work area       */
                 
            session.sGetValue(datstring);
            {
#ifdef ROUNICODE
              RoAPIStringA datstringA;
              uni2local(session, datstring, datstringA);
              RoAPIStringA &dat = datstringA;
#else
              RoAPIString &dat = datstring;
#endif
              ROAPI_SHORT len =  dat.getLen();
              sprintf(mbuf, mes25, len, dat.getRef());
            
              PutMess(mbuf);
            }  
            session.insertLine(lno++, datstring);
            break;

         default:                      
            sprintf(mbuf,mes26,token);
            //PutMess(mbuf);
            throw RPC_EXCEPTION(mbuf);
            break;
      }

      /***************************************/
      /* last token received was RPC_EOD,    */
      /* leave loop and switch to processing */
      /***************************************/
  
      if (token == RPC_EOD) break;   
   }


   /* 1. Exec after bind, determine whether secure mode: */
   if (bind_ok != ROAPI_TRUE) {
      SBind(session);
      /* Sbind() sets the var. 'bind_ok' and 'secure_mode' */
   }
      
   /*************************************************/
   /* check, if the datastream has been read        */
   /* correctly, and whether bind-status is ok.     */   
   /* Otherwise send a error message as an answer.  */ 
   /*************************************************/

   if (cont!=ROAPI_TRUE || skip==ROAPI_TRUE || bind_ok!=ROAPI_TRUE) {

      if (cont==ROAPI_FALSE || skip==ROAPI_TRUE || bind_ok!=ROAPI_TRUE) {

         /******************************************/
         /* close working areas, and send message  */
         /* and EOD to the monitor                 */
         /******************************************/

         clearWA(session);
         session.closeWA();

         if ((skip==ROAPI_TRUE || bind_ok!=ROAPI_TRUE) &&  fun==RPC_EXEC_W) {
            token = RPC_STRING;
            if (bind_ok != ROAPI_TRUE)
               sprintf(mbuf, bind_err);
            else
               sprintf(mbuf, mes27);
            PutMess(mbuf);
            datstring.setValue(mbuf);
            
            ROAPI_SHORT len;
#ifdef ROUNICODE
            len = datstring.getWLen();
#else
            len = datstring.getLen();
#endif     
            session.sPutToken (token, len);
            session.sPutValue(datstring);
            session.sPutToken (RPC_EOD, 0);
         }
      }
      PutMess(mes28);
      return;
   }


   /******************************************************/
   /************ Test values for secure mode *************/
   /******************************************************/

   if (secure_mode == ROAPI_TRUE) {
      execCmd(session,
       ROTEXT("$DEL 2 $"), 
       mes29);
      
      /* Return RETCODE: */
      execCmd(session, 
        ROTEXT("$LPUTLN #$EXIT@ :RETCODE"),
         mes30,
         ROTEXT("T"));
      
      /* Check whether RPL command in line 1: */
      execCmd(session,
       ROTEXT("$FIRST ARGTMP"),
        mes31,
        ROTEXT("T"));
  
      RoAPIString varname(ROTEXT("ARGTMP"));
      RoAPIString varval;
      session.getVariable(varname, varval);
 
#ifdef ROUNICODE
      if (varval.getWRef()[0] != ROTEXTCHAR('#') || 
          !(
             (varval.getWRef()[1] >= ROTEXTCHAR('A') && varval.getWRef()[1] <= ROTEXTCHAR('Z'))
             ||
             (varval.getWRef()[1] >= ROTEXTCHAR('a') && varval.getWRef()[1] <= ROTEXTCHAR('z'))
           )
         )
#else
      if (varval.getRef()[0] != '#' || 
          !(
             (varval.getRef()[1] >= 'A' && varval.getRef()[1] <= 'Z')
             ||
             (varval.getRef()[1] >= 'a' && varval.getRef()[1] <= 'z')
           )
         )
#endif     
      {
         ROAPI_SHORT len;    
        
         clearWA(session);
         session.closeWA();
         token = RPC_STRING;
         datstring.setValue(ROTEXT("P"));
#ifdef ROUNICODE
         len = datstring.getWLen();
#else
         len = datstring.getLen();
#endif     
         session.sPutToken (token, len);
         session.sPutValue(datstring);
         
         token = RPC_STRING;
         datstring.setValue(ROTEXT("Invalid Request denied"));
         {
#ifdef ROUNICODE
             RoAPIStringA datstringA;
             uni2local(session, datstring, datstringA);
             RoAPIStringA &dat = datstringA;
#else
             RoAPIString &dat = datstring;
#endif
             PutMess(dat.getRef());
         }
         
#ifdef ROUNICODE
         len = datstring.getWLen();
#else
         len = datstring.getLen();
#endif
         session.sPutToken (token, len);
         session.sPutValue(datstring);
         session.sPutToken(RPC_EOD, 0);
         return;
      }
   } /* End of special Test in secure Mode */
      
   /******************************************************/
   /************** Step 2: processing ********************/
   /******************************************************/

   session.closeWA();
   execWA(session, DOWA, retstring);

   /**********************************************************/
   /***** Step 3: put answer, in case of RPC_EXEC_W **********/
   /**********************************************************/

    if (fun == RPC_EXEC_W) {
        token = RPC_STRING;
        ROAPI_SHORT len;    
#ifdef ROUNICODE
         len = retstring.getWLen();
#else
         len = retstring.getLen();
#endif     
        session.sPutToken(token, len);
        session.sPutValue(retstring);
        /*********************************/ 
        /* read all lines of the wa and  */
        /* send it to the monitor        */
        /*********************************/
        ROAPI_LINENO last;
        last = session.getSizeWA();
        for (lno = 1; lno <= last; lno++) {
            session.getLine(lno, datstring);
#ifdef ROUNICODE
            len = datstring.getWLen();
#else
            len = datstring.getLen();
#endif     
            session.sPutToken (token, len);
            session.sPutValue(datstring);
        }

        /*********************************/
        /* all lines processed, send EOD */
        /*********************************/

        session.sPutToken (RPC_EOD, 0);
    }

   /************************************/
   /* clear wa's and return to rpcstub */
   /************************************/

   clearWA(session);
}
