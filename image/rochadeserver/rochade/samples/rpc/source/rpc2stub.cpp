/* Copyright (c) 1982-2011 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG    "@(#) rpcstub 7.00.06"

/*************************************************************
**
**                R P C - S E R V I C E  ( S T A R T U P )
**
**  Description:
**       This is the portable startup code for a
**       ROCHADE service. The service is called by
**       the monitor.
**
**  Parameter:
**       serviceid section inifile
**
**       The "serviceid" is a unique stamp created by the
**       monitor. It is used for identification and MUST be
**       delivered as an argument to the RoSInitAPI function.
**       The "section" and the "inifile" are used for the
**       API startup and for the communication layer. These
**       parameters have to be passed to the RoSInitAPI
**       function, too.
**
**  Usage:
**       The code for a special service module can be
**       concentrated within the function DoIt().
**       Please link this startup module with your special
**       module containing this fuction.
**       If the function DoIt() returns with ROAPI_FALSE, then
**       the service will be stopped. Otherwise the service
**       will wait for a new task.
**
**  Remark:
**       Windows 95/NT: The library "roapiaxn.lib"
**       must be used for linking the executable. 
**       The executable itself should be 
**       a character based executable.
**
**************************************************************
**
**  History:
**
** 05.08.02 GG 6.02.01 created
** 05.02.03 GG 6.02.02 Copyright 2003
** 03.02.03 LG 6.02.03 TRUE -> ROAPI_TRUE
** 03.03.03 LG 6.02.04 main return type int, SetServiceName static
** 01.04.03 GG 6.02.05 no quiet() for ibm_c
** 30.10.03 AI 6.02.06 ROUNICODE for RPC Service sample 7
** 25.11.04 AI 6.02.07 additional check of SERVICEDEBUG in INI file
**                     section after connect added (because environment
**                     seems no longer accessible under MVS with IBM C
**
** 31.01.05 AI 7.00.00 last extension does not work for sample 7 (ROUNICODE)
**                     -> disabled for ROUNICODE
** 30.07.10 GG 7.00.01 bug fixed unicode handling, rounicode enabled
** 10.09.10 LG 7.00.02 more bug fixes unicode handling
** 03.08.11 AI 7.00.03 warnings/64bit version
** 07.02.14 GG 7.00.04 try disconnect in exception case if session was established
** 27.10.15 LG 7.00.05 redirect $INFORM messages to message file,
**                     MVS: enable SERVICEDEBUG on HFS
** 28.10.15 LG 7.00.06 set retcodebuf in RPCInformObj::invoke()
*************************************************************/



#include    "rosmpstr.h"
#include    "rpc2stub.h"
#include    "rpc2tool.h"

#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>

#ifndef MVS
#include <malloc.h>
#endif

#ifndef MVS
static void  SetDebugFile(const char *arg);
#else
static void  SetDebugFile(const char *arg, bool isHFS);
#endif

static ROAPI_PCNSTC modname = "unknown";   /* service name         */
static ROAPI_CHAR msg[257]  = "";          /* name of message file */

static ROAPI_PCNSTC mes1 = "Service started" ;
static ROAPI_PCNSTC mes2 = "Illegal startup parameters";
static ROAPI_PCNSTC mes3 = "Startuparameters:";
static ROAPI_PCNSTC mes4 = "    ServiceId=%s";
static ROAPI_PCNSTC mes5 = "    Section=%.200s";
static ROAPI_PCNSTC mes6 = "    IniFile=%.200s";
static ROAPI_PCNSTC mes7 = "Error %d returned by newRoSession(), API version is %d\n";

static ROAPI_PCNSTC mes8 = "Exec $PROFILE GET $CMDLINE $STARTSECTION failed";
static ROAPI_PCNSTC mes9 = "Exec $PROFILE GET startsection ARGDEBUG failed";
static ROAPI_PCNSTC mes10 = "Service registered, waiting for tasks" ;
static ROAPI_PCNSTC mes11 = "SUnbind and RoReInit called";
static ROAPI_PCNSTC mes12 = "EXEC, current ServiceId=%s";
static ROAPI_PCNSTC mes13 = "EXEC_W, current ServiceId=%s";
static ROAPI_PCNSTC mes14 = "terminate signal received";
static ROAPI_PCNSTC mes15 = "unknown function (%hd)";
static ROAPI_PCNSTC mes16 = "Service stopped";

/**********************************************************************/
/* static variables                                                   */
/**********************************************************************/

static ROAPI_BOOL outon     = ROAPI_FALSE;    /* enable / disable     */
static void SetServiceName(ROAPI_PCNSTC txt);
static void SetMessFile2(ROAPI_PCNSTC);

/*
 * Class that redirects $INFORM messages to the message file.
 */
class RPCInformObj : public ROAPI_EXTOBJ {
private:
   ROAPI_PCHAR mbuf;
   int mlen; 

public:
   RPCInformObj(ROAPI_PCHAR mbuf, int mlen) {
      this->mbuf = mbuf;
      this->mlen = mlen;
   }

   virtual unsigned ROLONG ROCALLCONV invoke(
      ROAPI_OUT_STRING&   retcodebuf,
      int                 argc,
      ROAPI_IN_STRING    *argv[]) {

      if (outon != ROAPI_TRUE) {
         retcodebuf.setValue(1, "T");
         return -1;
      }

      const ROAPI_CHAR start[] = "$INFORM ";
      strcpy(mbuf, start);
      int len = strlen(mbuf);
      int avail = mlen - len;
      for (int i = 0; i < argc; i++) {
          int argLen = argv[i]->getLen();
          int nCopy = avail >= argLen ? argLen : avail;
          strncpy(mbuf + len, argv[i]->getRef(), nCopy);
          len += nCopy;
          avail -= nCopy;
          if (avail > 0 && i < argc - 1) {
              strcpy(mbuf + len, " ");
              len++;
              avail--;
          }
          if (avail <= 0) {
              break;
          }
      }
      mbuf[len] = '\0';
      PutMess(mbuf);
      retcodebuf.setValue(1, "T");
      return -1;
   }
};

int main(int  argc, char *argv[])
{
    ROAPI_SESSION *pSession;
    ROAPI_PCNSTC   servid;              /* the service id              */ 
    ROAPI_PCNSTC   section;             /* startup section             */
    ROAPI_PCNSTC   inifile;             /* name of inifile             */
  
    RoAPIStringA cur_service;
  
    ROAPI_SHORT    liz;                 /* liz (not supported)         */    
    ROAPI_SHORT    cur_func;            /* current function code       */
    ROAPI_SHORT    vers = ROAPI_VERSION;
    ROAPI_SHORT    errorCode;           /* error code for newRoSession */
    ROAPI_LONG     seq;                 /* sequence number             */
    ROAPI_CHAR     mbuf[MESSAGESIZE+1]; /* name of message file        */

    /***********************************************************/
    /* get service name (i.e. basename of argv[0])             */
    /***********************************************************/

#ifdef MVS
    bool isHFS = false;
#endif

    if (argv[0] != NULL && strlen(argv[0]) > 0)  {
        size_t i;
        for (i = strlen(argv[0]) - 1; i > 0; i--)
            if (argv[0][i] == '\\' || argv[0][i] == '/') {
                i++;
                break;
            }
        SetServiceName(argv[0] + i);
#ifdef MVS
        isHFS = ((argv[0][0] == '/' && argv[0][1] != '/') ||
                 (argv[0][0] == '.' && argv[0][1] == '/'));
#endif
    }
#ifdef MVS
    SetDebugFile(argc > 1 ? argv[1] : "", isHFS);
#else
    SetDebugFile(argc > 1 ? argv[1] : "");
#endif

    PutMess(mes1);
    if (argc < 4 ) {
        PutMess(mes2);
        exit(1);
    }
    else {
        PutMess(mes3);
        sprintf(mbuf, mes4, argv[1]); PutMess(mbuf); 
        sprintf(mbuf, mes5, argv[2]); PutMess(mbuf);
        sprintf(mbuf, mes6, argv[3]); PutMess(mbuf);
    }
    servid      = argv[1];
    section     = argv[2];
    inifile     = argv[3];

    cur_service = "";
    liz         = 0; 
  
    pSession = newRoSession(vers, errorCode);
    if (errorCode != API_ERR_NOERROR) {
        sprintf(mbuf, mes7, (int)errorCode, (int)vers);
        PutMess(mbuf);
        exit(1);
    }

    /***********************************************************/
    /* initiate service API                                    */
    /* This will set up the communication if the connect fails,*/
    /* then the reason can be found in the error message       */
    /***********************************************************/

    bool haveSession = false;
    try {
        RPCInformObj rpcInformObj(mbuf, sizeof(mbuf) - 1);
        pSession->setInformObj(&rpcInformObj);
        pSession->connect(section, inifile, liz, ROAPI_TRUE, servid);
        haveSession = true;
        if (outon == ROAPI_FALSE) {
            // allow enabling of debug output via ini file too
            execCmd(*pSession,
                    ROTEXT("$PROFILE GET $CMDLINE $STARTSECTION ARGTMP"),
                    mes8,
                    ROTEXT("T"))
                     ;
            execCmd(*pSession,
                    ROTEXT("$PROFILE GET :ARGTMP SERVICEDEBUG ARGDEBUG"),
                    mes9,
                    ROTEXT("T"));

            RoAPIString varname;
            RoAPIStringA varval;
            varname.setValue(ROTEXT("ARGDEBUG"));
            pSession->getVariable(varname, varval);
            
            ROAPI_SHORT vlen = varval.getLen();
            const char *p = varval.getRef();

            if (vlen >= 2) {
                if (strncmp(p, "ON", 2) == 0 || strncmp(p, "on", 2) == 0) {
                    size_t i = strlen(argv[1]);
                    if (i > 5)
                         i = i - 5;
                    else i = 0;
#ifdef MVS
                    bool parenthesis = false;
                    bool apostroph = false;
#endif
                    if (vlen >= 4 && p[2] == ';') {
                        strcpy(mbuf, p + 3);
#ifdef MVS
                        if (!isHFS) {
                            size_t len = strlen(mbuf);
                            if (len > 0 && mbuf[len - 1] == '\'') {
                                apostroph = true;
                                len--;
                                mbuf[len] = '\0';
                            }
                            if (len > 0 && mbuf[len - 1] == ')') {
                                parenthesis = true;
                                len--;
                                mbuf[len] = '\0';
                            }
                        }
#endif
                    } else {
#ifdef MVS
                        if (!isHFS) {
                           strcpy(mbuf,"DD:SM#");
                        } else {
                           strcpy(mbuf,"sm_");
                        }
#else
                        strcpy(mbuf,"sm_");
#endif
                    }
                    strcat(mbuf, argv[1] + i);
#ifdef MVS
                    if (!isHFS) {
                        // append ) and/or '
                        if (parenthesis)
                            strcat(mbuf, ")");
                        if (apostroph)
                            strcat(mbuf, "'");
                    } else {
                        strcat(mbuf, ".txt");
                    }
#else
                    strcat(mbuf, ".txt");
#endif
                    SetMessFile2(mbuf);
                }
                             // text stehen lassen - innerhalb suspend-resume!
                PutMess("Service started (DEBUG enabled via INI file)");
            }
        }
        
        PutMess(mes10);
        /***********************************************************/
        /* enter main loop                                         */
        /* it will be executed until a termination order is        */
        /* received by service monitor or until an error occours   */
        /***********************************************************/
     
        cur_func = RPC_EXEC;
        while (cur_func != RPC_TERM) {
     
            /******************************/
            /* get a request from monitor */
            /******************************/
            pSession->sGetFunction(cur_func, cur_service, seq);
            
            ROAPI_PCNSTC p;
            
            switch (cur_func) {
            case   RPC_UNBIND:
                PutMess(mes11);
                SUnbind(*pSession);
                pSession->reset(ROAPI_TRUE); /* keep proc and class cache */
                break;
     
            case   RPC_EXEC:
                p = cur_service.getRef();
                sprintf(mbuf, mes12, p);
                PutMess(mbuf);
                DoIt(*pSession, cur_func, seq, p);
                break;
     
            case   RPC_EXEC_W:
                p = cur_service.getRef();

                sprintf(mbuf, mes13, p);
                PutMess(mbuf);
                DoIt(*pSession, cur_func, seq, p);
                break;
     
            case   RPC_TERM:
     
                /******************************/
                /* terminate request received */
                /******************************/
     
                PutMess(mes14);
                break;
     
            default:
                sprintf(mbuf, mes15, cur_func);
                throw RPC_EXCEPTION(mbuf);
                break;
            }
        }
     
        /*********************************************************/ 
        /* terminate the service API und exit the service itself */
        /*********************************************************/
     
        PutMess(mes16);
        pSession->disconnect();
        pSession->dispose();
        pSession = NULL;
    }
    
    catch (RPC_EXCEPTION& e) {
        PutMess(e.getMessage());
        pSession->dispose();        
        exit(1);
    }
    
    catch (ROAPI_EXCEPTION& e) {
        short stat;
        RoAPIStringA Msg;
        RoAPIStringA lft;
  
        if (outon == ROAPI_TRUE) {
            stat = e.getState();
            e.getMessage(Msg);
            e.getLastFunction(lft);
            FILE *msgfile = fopen(msg,"a");
            if (msgfile != (FILE *)NULL) {
                fprintf(msgfile, "%s: error=%d, lastfu=%s, message=%s\n", 
                        modname, stat, lft.getRef(), Msg.getRef());
                fclose(msgfile);
            }
        }
        if (haveSession) {
           // try regulaer close
           pSession->disconnect();
        }
        pSession->dispose();        
        exit(1);
    }
    exit(0);
}

/**********************************************************************/
/* store service name in the static variable modname                  */
/**********************************************************************/

static void SetServiceName(ROAPI_PCNSTC txt)
{

    if (txt == NULL)
        return;

    size_t i = strlen(txt);
    if (i > 32) {
        txt = txt + (i - 32);
        i = 32;
    }
    modname = txt;
}


#ifndef MVS
static void  SetDebugFile(const char *arg)
#else
static void  SetDebugFile(const char *arg, bool isHFS)
#endif
{
    ROAPI_CHAR mbuf[MESSAGESIZE+1];  /* name of message file   */

    if (arg != NULL)  {
        size_t i = strlen(arg);
        if (i > 5)
            i = i - 5;
        else
            i = 0;
#ifdef MVS
        if (!isHFS) {
            strcpy(mbuf,"DD:SM#");
            strcat(mbuf, arg + i);
        } else {
            strcpy(mbuf,"sm_");
            strcat(mbuf, arg + i);
            strcat(mbuf, ".txt");
        }
#else
        strcpy(mbuf,"sm_");
        strcat(mbuf, arg + i);
        strcat(mbuf, ".txt");
#endif
        SetMessFile(mbuf);
    }
    else {
#ifdef MVS
        if (!isHFS) {
            SetMessFile("DD:SM#ILL");
        } else {
            SetMessFile("sm_ill.txt");
        }
#else
        SetMessFile("sm_ill.txt");
#endif
    }
}

/**********************************************************************/
/* evaluate environment variable SERVICEDEBUG and store the name of   */
/* the message file                                                   */
/**********************************************************************/
void SetMessFile(ROAPI_PCNSTC txt)
{
    char *p = getenv("SERVICEDEBUG");
    if (p && (strncmp(p, "ON", 2) == 0 || strncmp(p, "on", 2) == 0))
        outon = ROAPI_TRUE;
    if (txt == NULL)
        return;
    strcpy(msg, txt);
}

static void SetMessFile2(ROAPI_PCNSTC txt)
{
    outon = ROAPI_TRUE; // enabled via INI file setting
    strcpy(msg, txt);
}

/**********************************************************************/
/* appending message txt to the message file                          */
/**********************************************************************/
void PutMess(ROAPI_PCNSTC txt)
{
    if (outon != ROAPI_TRUE)
        return;

    FILE *msgfile = fopen(msg,"a");
    if (msgfile != (FILE *)NULL) {
        fprintf(msgfile, "%s: %s\n", modname, txt);
        fclose(msgfile);
    }
}
/*********************************************************************/
