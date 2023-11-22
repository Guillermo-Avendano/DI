
/* Copyright (c) 1982-2003 ASG GmbH & Co. KG. All Rights Reserved.        */
/* This program is protected by U.S. and international copyright laws     */

#define MODULKENNUNG    "@(#) roapi2s1 6.02.06"
 
#define roapi2s1_c
 
/*************************************************************
**
**                    R O A P I 2 S 1 . C P P
**                     Sample 1 for API V6.x
**
**************************************************************
**
**  simple API-2 sample application which does the following:
**   - login
**   - simple repository access (lists all items of type USER)
**   - usage of a callback function for $INFORM
**
**  assumptions:
**   - server works with a datebase AP-DATA
**
**  command line:
**     rapi2s1n [section] [inifile]
**
**************************************************************
**
** CHANGE HISTORY
**
** 10.02.02 GG 6.02.01 created
** 31.07.02 LG 6.02.02 adaption to modified ROAPI_IN_STRING
** 02.08.02 LG 6.02.03 BS2 compileable
** 26.08.02 LG 6.02.04 main return type int
** 05.02.03 GG 6.02.05 Copyright 2003
** 17.10.03 AI 6.02.06 do not save pointer, but copy string in exception
***********************************************************************/

#include "roapi2.h"
#include "rosmpstr.h"
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
#define  SECTION      "roapi"
#define  INIFILE      "rochade.ini"

#define  DB_CMD       "$DB AP-DATA U P"
#define  MOVELOG_CMD  "$MOVELOG ADM"

/*
#define  DB_CMD       "$DB TESTP U P"
#define  MOVELOG_CMD  "$MOVELOG TESTUSER"
*/
/*************************************************************
** local functions & classes
**************************************************************/

class RAPIS1_EXCEPTION {
private:
    ROAPI_CHAR mMsg[256];
    
public:
    RAPIS1_EXCEPTION(ROAPI_PCNSTC pMsg);
    RAPIS1_EXCEPTION(const RAPIS1_EXCEPTION& e);
    ~RAPIS1_EXCEPTION();

    ROAPI_PCNSTC ROCALLCONV getMessage();
};
 
RAPIS1_EXCEPTION::RAPIS1_EXCEPTION(ROAPI_PCNSTC pMsg) {
    strncpy(mMsg, pMsg, sizeof(mMsg));
    mMsg[sizeof(mMsg)-1] = '\0';
}

RAPIS1_EXCEPTION::RAPIS1_EXCEPTION(const RAPIS1_EXCEPTION& e) {
    strcpy(mMsg, e.mMsg);
}

RAPIS1_EXCEPTION::~RAPIS1_EXCEPTION() {}
    
ROAPI_PCNSTC RAPIS1_EXCEPTION::getMessage() {
    return mMsg;    
}

/*************************************************************
** convenience function for RPL execution with default RETCODE
**************************************************************/
 
static void myExec(ROAPI_SESSION *session, ROAPI_PCNSTC cmd, ROAPI_PCNSTC defaultRC) {
    RoAPIString  rtCode;
    RoAPIString  cmdBuff(cmd);

    session->exec(rtCode, cmdBuff);
    if (defaultRC != NULL && strcmp(rtCode.getRef(), defaultRC) != 0) {
        ROAPI_CHAR tmp[256];
        sprintf(tmp, "Could not execute '%s', RETCODE='%s'\n", cmd, rtCode.getRef());
        throw RAPIS1_EXCEPTION(tmp);
    }
}

/*************************************************************
** list all items of type USER
**************************************************************/
 
static void ListUser(ROAPI_SESSION *session) {
    RoAPIString  lnVal;
    ROAPI_LINENO lnNo, i;
 
    /*********************************************************
    ** execute the basic command     SDC and write its result in
    ** the current WA
    **********************************************************/
 
    myExec(session, "$SDC USER ACT 1", "T");
 
    /*********************************************************
    ** read the number of lines
    **********************************************************/
 
    lnNo = session->getSizeWA();
 
    /*********************************************************
    ** list the contens of current WA
    **********************************************************/
 
    for (i = 1 ; i <= lnNo ; i++) {
         session->getLine(i, lnVal);
         printf("\t%s\n", lnVal.getRef());
    }
 
    /*********************************************************
    ** erase the current WA
    **********************************************************/
 
    myExec(session, "$DEL 1 $", NULL);
}
 

/*************************************************************
** callback object for $INFORM
**************************************************************/
 
class TST_INFOBJ : public ROAPI_EXTOBJ {
private:
    ROAPI_SESSION *session;
    
public:
    TST_INFOBJ(ROAPI_SESSION *psess) {
        session = psess;
    }
    
    ~TST_INFOBJ() {}

    unsigned long ROCALLCONV invoke(
        ROAPI_OUT_STRING&   retcodeBuf,
        int                 argc,
        ROAPI_IN_STRING    *argv[]) {
        
        printf("Inform CallBack invoked:\n");
        for (int i = 0; i < argc; i++) {
            printf("Parameter %d: '%s'\n", i + 1, argv[i]->getRef());
        }
        (void)retcodeBuf.setValue(1, "T");

        printf("Test of Reentry:\n");
        RoAPIString varName("$VER");
        RoAPIString varVal;
        
        session->getVariable(varName, varVal);
        
        printf("\tReentry successful,     VER = \"%s\"\n", varVal.getRef());
        return 1; //     CALLRC = "T" (ignored for $INFORM)
    }
};



/*************************************************************
** test $INFORM callback
**************************************************************/
 
static void UseCB(ROAPI_SESSION *session) {
    RoAPIString rtCode;

    // Test of $INFORM callback:
    TST_INFOBJ     infCB(session);
     
    session->setInformObj(&infCB);
 
    myExec(session, "$INFORM OK Version= :$VER Datum= :$DATE", NULL);
 
    session->setInformObj(NULL);
}

 
/*************************************************************
** external object for test of $SEND re. an external object
**************************************************************/
 
class TST_SENDOBJ : public ROAPI_EXTOBJ {
private:
    ROAPI_SESSION *session;
    RoAPIString proxy;
    
public:
    TST_SENDOBJ(ROAPI_SESSION *psess) {
        session = psess;
    }
    
    ~TST_SENDOBJ() {}

    void createProxy(ROAPI_OUT_STRING& prx) {
        session->createProxy(proxy, this);
        (void)prx.setValue(proxy.getLen(), proxy.getRef());
    }
    
    unsigned long ROCALLCONV invoke(
        ROAPI_OUT_STRING&   retcodeBuf,
        int                 argc,
        ROAPI_IN_STRING    *argv[]) {
        
        printf("Proxy CallBack invoked:\n");
        for (int i = 0; i < argc; i++) {
            printf("Parameter %d: '%s'\n", i + 1, argv[i]->getRef());
        }
        
        if (argc > 1 && strcmp(argv[1]->getRef(), "    $TERM") == 0) {
            session->destroyProxy(proxy);
        }
        else if (argc > 1 && strcmp(argv[1]->getRef(), "$$INIT") != 0) {
            printf("Test of Reentry:\n");
            RoAPIString varName("$VER");
            RoAPIString varVal;
        
            session->getVariable(varName, varVal);
            printf("\tReentry successful,     $VER = \"%s\"\n", varVal.getRef());
        }
        
        (void)retcodeBuf.setValue(1, "T");
        return 1; // $CALLRC -> "T"
    }
};


/*************************************************************
** Test of invocation of an external object by $SEND
**************************************************************/
 
static void UseProxy(ROAPI_SESSION *session) {
    RoAPIString rtCode;

    // Test of External Object:
    TST_SENDOBJ extCB(session);
    RoAPIString objID; 
     
    extCB.createProxy(objID);
    
    RoAPIString objVar("OBJ-ID");
    session->putVariable(objVar, objID);
    
    myExec(session, "$SEND :OBJ-ID TEST-METHOD PAR1 PAR2 PAR3", "T");
    myExec(session, "$SEND :OBJ-ID $DESTROY", "T");
}


 
/*************************************************************
** main function
**************************************************************/

int main(int argc, char *argv[]) {
    ROAPI_SESSION  *session = NULL; 
    ROAPI_PCNSTC sec = SECTION;
    ROAPI_PCNSTC ini = INIFILE;
    ROAPI_SHORT  rc;


    printf("\n***   start API2 sample 1   ***\n");
    
    try {
        ROAPI_SHORT vers = ROAPI_VERSION;
        session = newRoSession(vers, rc);
        if (rc != API_ERR_NOERROR) {
            ROAPI_CHAR tmp[256];
            sprintf(tmp, "Error %d returned by newRoSession(), API version is %d\n",
                         (int)rc, (int)vers);
            throw RAPIS1_EXCEPTION(tmp);
        }
        
        if  (argc >= 2)  sec = argv[1];
        if  (argc >= 3)  ini = argv[2];
 
        session->connect(sec, ini, 0, ROAPI_FALSE, NULL);
        myExec(session, DB_CMD, "T");
    
        /*********************************************************
        ** login
        **********************************************************/
        myExec(session, MOVELOG_CMD, "T");
       
        /*********************************************************/
        printf("\n***   list all items of type USER\n\n");
        ListUser(session);
     
        /*********************************************************/
        printf("\n***   use the callback object for $INFORM\n\n");
        UseCB(session);
     
        /*********************************************************/
        printf("\n***   use the external object for $SEND\n\n");
        UseProxy(session);
       
        session->disconnect();
    }
    catch (RAPIS1_EXCEPTION& e) {
        printf("RAPIException, Error: %s\n", e.getMessage());
    }
    catch (ROAPI_EXCEPTION& e) {
        RoAPIString msgbu;
        RoAPIString fubu;
        short  s;

        s = e.getState();
        e.getMessage(msgbu);
        
        e.getLastFunction(fubu);
        printf("ROAPI_EXCEPTION, Function=%s, ErrorMessage=%s \n",fubu.getRef(), msgbu.getRef());
    }
    
    if (session) {
        session->dispose();
        session = 0;
    }

    return 0;
}
